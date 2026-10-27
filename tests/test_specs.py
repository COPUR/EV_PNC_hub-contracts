"""Guards for the spec bundle under specs/ and the status-code mapping profile."""
import csv
import re
import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
HUB_DIRS = {"HUBJECT": "hubject", "GIREVE": "gireve", "ECLEARING": "e-clearing"}


def _trace_rows():
    with open(ROOT / "specs" / "traceability.csv", encoding="utf-8") as f:
        return list(csv.DictReader(f))


class TraceabilityTest(unittest.TestCase):
    def test_every_referenced_contract_file_exists(self):
        missing = []
        for row in _trace_rows():
            for ref in row["contract"].split(";"):
                ref = ref.strip().split("#")[0].split(" ")[0]
                if not ref or ref.startswith("proposed"):
                    continue
                if not (ROOT / ref).exists():
                    missing.append((row["requirement_id"], ref))
        self.assertEqual([], missing)

    def test_every_referenced_feature_file_exists(self):
        missing = []
        for row in _trace_rows():
            hub = HUB_DIRS[row["hub"]]
            for ref in row["acceptance"].split(";"):
                ref = ref.strip().split("#")[0]
                if not ref or ref == "runbook":
                    continue
                if not (ROOT / "specs" / hub / "acceptance" / ref).exists():
                    missing.append((row["requirement_id"], ref))
        self.assertEqual([], missing)

    def test_every_requirement_in_a_spec_is_traced(self):
        traced = {row["requirement_id"] for row in _trace_rows()}
        declared = set()
        for hub in HUB_DIRS.values():
            text = (ROOT / "specs" / hub / "spec.md").read_text(encoding="utf-8")
            declared |= set(re.findall(r"^### (RH-[A-Z-]+-\d+)", text, re.M))
        self.assertEqual(set(), declared - traced, "requirements without a traceability row")
        self.assertEqual(set(), traced - declared, "traceability rows for requirements no spec declares")


class AuthorizeStatusMappingTest(unittest.TestCase):
    """The Hubject decision -> StatusCode table may only use codes that the pinned OICP contract lists."""

    @staticmethod
    def _official_codes():
        spec = yaml.safe_load((ROOT / "_sources" / "hubject-oicp-2.3-emp.openapi.yaml").read_text(encoding="utf-8"))
        op = spec["paths"]["/charging/v21/operators/{operatorID}/authorize/start"]["post"]
        code = op["responses"]["200"]["content"]["application/json"]["schema"]["properties"]["StatusCode"]["properties"]["Code"]
        return set(re.findall(r"\|\s*(\d{3})\s*\|", code["description"]))

    def test_mapping_uses_only_official_codes(self):
        mapping = yaml.safe_load((ROOT / "profiles" / "hubject-authorize-statuscode.mapping.yaml").read_text(encoding="utf-8"))
        used = {str(mapping["allowed"])}
        for value in mapping["by_reason"].values():
            used |= {str(v) for v in value.values()} if isinstance(value, dict) else {str(value)}
        used |= {str(v) for v in mapping["fallback"].values()}
        self.assertEqual(set(), used - self._official_codes())

    def test_mapping_stays_inference_until_hubject_confirms(self):
        mapping = yaml.safe_load((ROOT / "profiles" / "hubject-authorize-statuscode.mapping.yaml").read_text(encoding="utf-8"))
        self.assertEqual("inference", mapping["confidence"])


if __name__ == "__main__":
    unittest.main()
