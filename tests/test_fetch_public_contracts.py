"""Offline tests for tools/fetch_public_contracts.py (no network)."""

import importlib.util
import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("fpc", ROOT / "tools" / "fetch_public_contracts.py")
fpc = importlib.util.module_from_spec(spec)
sys.modules["fpc"] = fpc
spec.loader.exec_module(fpc)

BASE = "https://example.test/spec/openapi.yaml"


class Deref(unittest.TestCase):
    def setUp(self):
        fpc._cache.clear()
        fpc._cache[BASE] = {"components": {"X": {"type": "string"}, "Loop": {"a": {"$ref": "#/components/Loop"}}}}

    def test_inlines_pointer(self):
        self.assertEqual(fpc.deref({"s": {"$ref": "#/components/X"}}, BASE), {"s": {"type": "string"}})

    def test_siblings_override(self):
        out = fpc.deref({"$ref": "#/components/X", "description": "d"}, BASE)
        self.assertEqual(out, {"type": "string", "description": "d"})

    def test_cycle_becomes_stub(self):
        out = fpc.deref({"$ref": "#/components/Loop"}, BASE)
        self.assertIn("recursive reference", out["a"]["description"])


class Annotate(unittest.TestCase):
    def test_lifts_direction_and_implementation(self):
        item = {"post": {"description": "To `RECEIVE` a thing. Implementation: `MANDATORY`"}}
        fpc.annotate(item, "emp")
        self.assertEqual(item["post"]["x-emp-direction"], "RECEIVE")
        self.assertEqual(item["post"]["x-emp-implementation"], "MANDATORY")

    def test_ignores_non_operations(self):
        item = {"parameters": [], "get": {"description": "nothing"}}
        fpc.annotate(item, "emp")
        self.assertNotIn("x-emp-direction", item["get"])


class Pins(unittest.TestCase):
    def test_pins_file_is_complete_and_sha_shaped(self):
        pins = json.loads(fpc.PINS_FILE.read_text())["pins"]
        self.assertEqual(set(pins), set(fpc.UPSTREAM))
        for repo, sha in pins.items():
            self.assertRegex(sha, r"^[0-9a-f]{40}$", repo)

    def test_manifest_matches_files(self):
        src = fpc.PINS_FILE.parent
        for line in (src / "SHA256SUMS").read_text().splitlines():
            digest, name = line.split("  ", 1)
            self.assertEqual(fpc.sha256(src / name), digest, name)

    def test_generated_files_carry_licence_and_commit(self):
        pins = set(json.loads(fpc.PINS_FILE.read_text())["pins"].values())
        for p in fpc.generated_files(fpc.PINS_FILE.parent):
            text = p.read_text()
            info = json.loads(text)["info"] if p.suffix == ".json" else fpc.yaml.safe_load(text)["info"]
            self.assertEqual(info["x-licence"], "CC BY-SA 4.0", p.name)
            self.assertIn(info["x-commit"], pins, p.name)


if __name__ == "__main__":
    unittest.main()
