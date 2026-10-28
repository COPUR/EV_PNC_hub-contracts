#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["pyyaml"]
# ///
"""Fetch published hub API contracts at pinned commits and write eMSP-role subsets.

Only reads files the hubs publish in public GitHub repositories (raw file URLs at a
commit SHA). It sends nothing to a hub's QA or production API. Output is deterministic:
the same pins always give byte-identical files, so a diff means the pin or the script
changed, or someone edited a generated file by hand.

    uv run tools/fetch_public_contracts.py                # regenerate _sources/ from the pins
    uv run tools/fetch_public_contracts.py --check        # fail if _sources/ differs from a fresh build
    uv run tools/fetch_public_contracts.py --check-upstream   # report upstream commits newer than the pins
    uv run tools/fetch_public_contracts.py --update-pins  # move the pins to upstream HEAD, then rebuild

Sources (CC BY-SA 4.0; keep attribution and share-alike, see _sources/ATTRIBUTION.md):
  OICP 2.3 EMP/CPO OpenAPI  github.com/hubject/oicp-emp-2.3-api-doc, oicp-cpo-2.3-api-doc
  OPCP 1.0.0 component APIs github.com/hubject/opcp
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

import yaml

RAW = "https://raw.githubusercontent.com/hubject"
ROOT = Path(__file__).resolve().parent.parent
PINS_FILE = ROOT / "_sources" / "pins.json"
# upstream repo -> default branch, used only by --update-pins and --check-upstream
UPSTREAM = {
    "oicp-emp-2.3-api-doc": "master",
    "oicp-cpo-2.3-api-doc": "master",
    "opcp": "main",
}
PINS: dict[str, str] = {}  # upstream repo -> commit SHA, loaded from pins.json
OICP_PATH = "src/openapi.yaml"
OICP_REPO = {"emp": "oicp-emp-2.3-api-doc", "cpo": "oicp-cpo-2.3-api-doc"}
OPCP_PATH = "OPCP-1.0.0/reference"
OPCP = ["rcp", "pcp", "cps", "ccp", "est", "webhooks"]
# OPCP operations an eMSP / mobility operator (MO) is allowed to call, from
# OPCP-1.0.0/docs/04_authentication.md (role table).
MO_OPS = {
    "rcp": {"getRootCert", "getAllRootCerts", "get-v1-root-ctl"},
    "pcp": {"getOEMProvCert", "lookupVehicle"},
    "cps": {
        "createSignedContractData",
        "createAndForwardSignedContractData",
        "generateSignedContractData",
        "put-v1-cps-signContractData",
        "get-cps-signer",
    },
    "ccp": {
        "addSignedContractData",
        "deleteSignedContractData",
        "lookupContract",
        "getContracts",
        "setDefaultContract",
    },
    "est": {"simpleenroll", "cacerts"},
    "webhooks": None,  # all
}
HTTP = {"get", "put", "post", "delete", "patch"}
_cache: dict[str, object] = {}


class _Loader(yaml.SafeLoader):
    """SafeLoader with YAML 1.2 booleans: only true/false, so field names like On stay strings."""


_Loader.yaml_implicit_resolvers = {
    k: [(tag, rx) for tag, rx in v if tag != "tag:yaml.org,2002:bool"]
    for k, v in yaml.SafeLoader.yaml_implicit_resolvers.items()
}
_Loader.add_implicit_resolver(
    "tag:yaml.org,2002:bool", re.compile(r"^(?:true|True|TRUE|false|False|FALSE)$"), list("tTfF")
)


def fetch(url: str) -> object:
    url = url.split("#")[0]
    if url not in _cache:
        req = urllib.request.Request(url, headers={"User-Agent": "ev-roaming-hubs/1.0"})
        with urllib.request.urlopen(req, timeout=30) as r:  # noqa: S310 (public https)
            text = r.read().decode("utf-8")
        _cache[url] = json.loads(text) if url.endswith(".json") else yaml.load(text, Loader=_Loader)  # noqa: S506 (safe subclass)
    return _cache[url]


def deref(node, base: str, stack: tuple[str, ...] = ()):
    """Inline $ref (relative file refs and #/ pointers). Cycles become a stub."""
    if isinstance(node, list):
        return [deref(n, base, stack) for n in node]
    if not isinstance(node, dict):
        return node
    if "$ref" in node and isinstance(node["$ref"], str):
        ref = node["$ref"]
        target = urllib.parse.urljoin(base, ref) if not ref.startswith("#") else base + ref
        if target in stack:
            return {"description": f"recursive reference to {ref.rsplit('/', 1)[-1]}"}
        doc = fetch(target)
        frag = target.split("#", 1)[1] if "#" in target else ""
        for part in [p for p in frag.split("/") if p]:
            doc = doc[part]
        merged = deref(doc, target.split("#")[0], stack + (target,))
        extra = {k: deref(v, base, stack) for k, v in node.items() if k != "$ref"}
        return {**merged, **extra} if isinstance(merged, dict) and extra else merged
    return {k: deref(v, base, stack) for k, v in node.items()}


def raw_url(repo: str, path: str) -> str:
    return f"{RAW}/{repo}/{PINS[repo]}/{path}"


def provenance(url: str, repo: str, licence: str) -> dict:
    return {
        "x-source": url,
        "x-commit": PINS[repo],
        "x-licence": licence,
        "x-note": "Derived subset. Hub copy is authoritative; keep attribution and share-alike.",
    }


NOTE = re.compile(r"To `(?P<dir>[A-Z]+)`.*?Implementation: `(?P<impl>[A-Z]+)`", re.S)


def annotate(item: dict, role: str) -> None:
    """Lift the "To RECEIVE / Implementation: MANDATORY" note into extension fields.

    The note is written from the point of view of the document's role, so for the EMP
    file RECEIVE means the eMSP must expose the endpoint and SEND means it calls Hubject.
    """
    for method, op in item.items():
        if method in HTTP and isinstance(op, dict):
            m = NOTE.search(op.get("description", ""))
            if m:
                op[f"x-{role}-direction"] = m["dir"]
                op[f"x-{role}-implementation"] = m["impl"]


def oicp(role: str, out: Path) -> None:
    repo = OICP_REPO[role]
    url = raw_url(repo, OICP_PATH)
    spec = fetch(url)
    paths = {}
    for path, item in spec["paths"].items():
        paths[path] = deref(item, url)
        annotate(paths[path], role)
    doc = {
        "openapi": "3.0.0",
        "info": {
            "title": f"OICP 2.3 {role.upper()} (pinned subset)",
            "version": "2.3.0",
            **provenance(url, repo, "CC BY-SA 4.0"),
        },
        "servers": spec.get("servers", []),
        "paths": paths,
    }
    dest = out / f"hubject-oicp-2.3-{role}.openapi.yaml"
    dest.write_text(yaml.safe_dump(doc, sort_keys=False, width=100, allow_unicode=True))
    print(f"wrote {dest} ({len(paths)} paths)")


def opcp(name: str, out: Path) -> None:
    url = raw_url("opcp", f"{OPCP_PATH}/{name}.v1.json")
    spec = fetch(url)
    allowed = MO_OPS[name]
    paths = {}
    for path, item in spec["paths"].items():
        kept = {
            m: o
            for m, o in item.items()
            if m not in HTTP or allowed is None or o.get("operationId") in allowed
        }
        if any(m in HTTP for m in kept):
            paths[path] = kept
    spec["paths"] = paths
    info = spec.setdefault("info", {})
    info.update(provenance(url, "opcp", "CC BY-SA 4.0"))
    info["x-role-filter"] = "mobility operator (eMSP) operations only"
    dest = out / f"hubject-opcp-{name}.mo.openapi.json"
    dest.write_text(json.dumps(spec, indent=2, ensure_ascii=False) + "\n")
    print(f"wrote {dest} ({len(paths)} paths)")


def build(out: Path, only: str | None = None) -> int:
    out.mkdir(parents=True, exist_ok=True)
    jobs = []
    if only in (None, "oicp"):
        jobs += [lambda r=r: oicp(r, out) for r in OICP_REPO]
    if only in (None, "opcp"):
        jobs += [lambda n=n: opcp(n, out) for n in OPCP]
    failures = 0
    for job in jobs:
        try:
            job()
        except (urllib.error.URLError, KeyError, ValueError) as exc:
            failures += 1
            print(f"FAILED: {exc}", file=sys.stderr)
    return failures


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generated_files(directory: Path) -> list[Path]:
    return sorted(p for p in directory.glob("hubject-*") if p.suffix in {".yaml", ".json"})


def write_manifest(directory: Path) -> None:
    lines = [f"{sha256(p)}  {p.name}" for p in generated_files(directory)]
    (directory / "SHA256SUMS").write_text("\n".join(lines) + "\n")


def load_pins() -> None:
    PINS.clear()
    PINS.update(json.loads(PINS_FILE.read_text())["pins"])


def upstream_head(repo: str) -> str:
    out = subprocess.run(  # noqa: S603 (fixed argv, public repo)
        ["git", "ls-remote", f"https://github.com/hubject/{repo}", f"refs/heads/{UPSTREAM[repo]}"],
        check=True,
        capture_output=True,
        text=True,
        timeout=60,
    ).stdout.split()
    return out[0]


def write_pins(pins: dict[str, str]) -> None:
    doc = {
        "note": "Upstream commits the generated _sources/ files are built from. Move them with --update-pins and review the diff.",
        "pins": pins,
    }
    PINS_FILE.write_text(json.dumps(doc, indent=2) + "\n")


def check_build() -> int:
    """Rebuild into a temp dir and compare with the committed files."""
    src = PINS_FILE.parent
    with tempfile.TemporaryDirectory() as tmp:
        fresh = Path(tmp)
        failures = build(fresh)
        if failures:
            return 1
        write_manifest(fresh)
        bad = 0
        want = {p.name for p in generated_files(fresh)} | {"SHA256SUMS"}
        have = {p.name for p in generated_files(src)} | ({"SHA256SUMS"} if (src / "SHA256SUMS").exists() else set())
        for name in sorted(want | have):
            a, b = fresh / name, src / name
            if not b.exists():
                print(f"MISSING  {name}")
                bad += 1
            elif not a.exists():
                print(f"UNKNOWN  {name} (not produced by the script)")
                bad += 1
            elif a.read_bytes() != b.read_bytes():
                print(f"CHANGED  {name} (hand edit, or script changed without regenerating)")
                bad += 1
        return 1 if bad else 0


def check_upstream() -> int:
    stale = 0
    for repo, pinned in PINS.items():
        head = upstream_head(repo)
        state = "ok" if head == pinned else "NEWER UPSTREAM"
        print(f"{state:15} {repo} pinned={pinned[:10]} head={head[:10]}")
        stale += head != pinned
    if stale:
        print("Run: uv run tools/fetch_public_contracts.py --update-pins, then review the diff of _sources/.")
    return 1 if stale else 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--out", type=Path, default=PINS_FILE.parent)
    ap.add_argument("--only", choices=["oicp", "opcp"])
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--check", action="store_true", help="fail if committed _sources/ differs from a fresh build")
    mode.add_argument("--check-upstream", action="store_true", help="fail if upstream has commits newer than the pins")
    mode.add_argument("--update-pins", action="store_true", help="move pins to upstream HEAD and rebuild")
    args = ap.parse_args()
    if not PINS_FILE.exists() or args.update_pins:
        if args.update_pins or not PINS_FILE.exists():
            write_pins({repo: upstream_head(repo) for repo in UPSTREAM})
    load_pins()
    if args.check:
        return check_build()
    if args.check_upstream:
        return check_upstream()
    failures = build(args.out, args.only)
    if not failures and args.only is None:
        write_manifest(args.out)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
