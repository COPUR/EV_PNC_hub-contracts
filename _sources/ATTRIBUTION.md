# Attribution

The files in this directory are derived subsets of public API descriptions published by
Hubject GmbH. They are licensed under
[Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
(CC BY-SA 4.0), the licence of the originals.

| Generated file | Original | Changes |
|---|---|---|
| `hubject-oicp-2.3-emp.openapi.yaml` | [hubject/oicp-emp-2.3-api-doc](https://github.com/hubject/oicp-emp-2.3-api-doc) `src/openapi.yaml` | `$ref`s inlined; each operation annotated with `x-emp-direction` and `x-emp-implementation` taken from its description |
| `hubject-oicp-2.3-cpo.openapi.yaml` | [hubject/oicp-cpo-2.3-api-doc](https://github.com/hubject/oicp-cpo-2.3-api-doc) `src/openapi.yaml` | same as above, with `x-cpo-*` |
| `hubject-opcp-*.mo.openapi.json` | [hubject/opcp](https://github.com/hubject/opcp) `OPCP-1.0.0/reference/<name>.v1.json` | operations a mobility operator (eMSP) may not call removed |

Each file records its source URL, upstream commit (`x-commit`) and licence in `info`.
The upstream commits are listed in `pins.json`; `SHA256SUMS` holds the hash of every generated file.

Share-alike: anything adapted from these files must carry the same licence and this notice.
The original copy at the pinned commit is authoritative.

## Do not hand-edit

Regenerate instead:

```bash
uv run tools/fetch_public_contracts.py              # rebuild from pins.json
uv run tools/fetch_public_contracts.py --update-pins   # move pins to upstream HEAD, then review the diff
```

CI fails when these files differ from a fresh build (`--check`) and reports newer upstream commits weekly (`--check-upstream`).
