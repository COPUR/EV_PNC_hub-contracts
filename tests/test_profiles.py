"""Offline checks for the hub profiles in profiles/."""

import unittest
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
PROFILES = ROOT / "profiles"
CONFIDENCE = {"fact", "inference", "unknown"}


def load(name):
    return yaml.safe_load((PROFILES / name).read_text())


class Profiles(unittest.TestCase):
    def test_every_file_parses(self):
        files = sorted(PROFILES.glob("*.yaml"))
        self.assertGreaterEqual(len(files), 6)
        for f in files:
            with self.subTest(file=f.name):
                self.assertIsInstance(yaml.safe_load(f.read_text()), dict)

    def test_hubject_profile_points_at_a_pinned_contract(self):
        profile = load("hubject-oicp-2.3-emp.profile.yaml")
        contract = (PROFILES / profile["base"]["contract"]).resolve()
        self.assertTrue(contract.is_file(), contract)
        self.assertEqual(contract.parent, (ROOT / "_sources").resolve())

    def test_gireve_ocpi_profile_has_what_the_loader_reads(self):
        p = load("gireve-ocpi-2.2.1.profile.yaml")
        self.assertEqual(p["base"]["version"], "2.2.1")
        for key in ("hub", "transport", "registration", "modules", "tokens", "commands", "sessions", "cdrs", "tariffs", "locations", "reliability"):
            self.assertIn(key, p)
        self.assertEqual(set(p["hub"]["party_id"]), {"pre_production", "production"})

    def test_conversion_rules_are_well_formed(self):
        table = load("ocpi-2.3.0-to-2.2.1.conversion.yaml")
        actions = {"drop", "rename", "map", "default", "accept_extension", "block", "widen_canonical"}
        self.assertGreater(len(table["rules"]), 20)
        for i, rule in enumerate(table["rules"]):
            with self.subTest(rule=i):
                self.assertTrue({"object", "module"} & set(rule), rule)
                self.assertIn(rule.get("confidence", "").split(" ")[0], CONFIDENCE | {"fact"}, rule)
                for direction in ("in", "out"):
                    if direction in rule:
                        self.assertIn(rule[direction]["action"], actions, rule)


if __name__ == "__main__":
    unittest.main()
