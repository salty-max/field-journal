"""Guard the data-join rules used by finds-audit.py, without a database download."""
import collections
import importlib.util
import pathlib
import unittest

spec = importlib.util.spec_from_file_location("finds_audit", pathlib.Path(__file__).with_name("finds-audit.py"))
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


def loot(item=None, ref=None):
    return {"item_id": item, "ref_id": ref}


class FindsAuditTest(unittest.TestCase):
    def setUp(self):
        self.inv = audit.Inventory.__new__(audit.Inventory)
        self.inv.loot = collections.defaultdict(list)
        self.inv.reference_issues = set()

    def test_entity_ids_do_not_collide_with_template_ids(self):
        # Copper Vein's entity is 1731, its Classic loot template is 1502.
        # Fadeleaf's template happens to be 1731. Pyrite must stay with copper.
        self.inv.loot[("object", 1502, "classicdb")] = [loot(2770)]
        self.inv.loot[("object", 1731, "classicdb")] = [loot(3818)]
        self.inv.loot[("object", 1731, "questie")] = [loot(249391)]
        self.assertEqual(self.inv.yields("object", 1731, 1502), {2770, 249391})
        self.assertEqual(self.inv.yields("object", 2042, 1731), {3818})
        # Two node entities may legitimately share one Classic template.
        self.assertEqual(self.inv.yields("object", 999, 1502), {2770})

    def test_reference_expansion_retains_items_and_reports_bad_links(self):
        self.inv.loot[("reference", 1, "classicdb")] = [loot(774), loot(ref=2)]
        self.inv.loot[("reference", 2, "classicdb")] = [loot(818), loot(ref=1), loot(ref=3)]
        self.assertEqual(self.inv.expand([loot(ref=1)]), {774, 818})
        self.assertEqual(len(self.inv.reference_issues), 2)
        self.assertIn("missing reference: 3", self.inv.reference_issues)

    def test_zero_skill_and_last_lock_slot_are_valid(self):
        self.inv.locks = {1: {"Type_7": 2, "_Index_7": 3, "Skill_7": 0}}
        self.assertEqual(self.inv.gather_skill({"lock_id": 1}, 3), 0)
        self.assertIsNone(self.inv.gather_skill({"lock_id": 1}, 2))
        self.assertIsNone(self.inv.gather_skill({"lock_id": 99}, 3))

    def test_frozen_requirements_and_explicit_skinning_do_not_need_classic_templates(self):
        self.inv.gathering = {(562111, 186): {"min_skill": 1}}
        self.assertEqual(self.inv.gather_skill({"id": 562111, "lock_id": None}, 3), 1)
        self.inv.loot[("skinning", 270693, "wowhead")] = [loot(249427)]
        self.assertEqual(self.inv.yields("skinning", 270693, None), {249427})
        self.inv.loot[("object", 1502, "players")] = [loot(2770)]
        self.assertEqual(self.inv.yields("object", 1731, 1502), {2770})

    def test_professions_follow_parent_ids_without_name_matching(self):
        self.inv.skills = {
            186: {"ParentSkillLineID": 0},
            2946: {"ParentSkillLineID": 186},
            9999: {"ParentSkillLineID": 2946},
            8888: {"ParentSkillLineID": 8888},
        }
        self.inv.names = {}
        result = self.inv.professions()
        self.assertEqual([r["id"] for r in result["mining"]], [186, 2946, 9999])
        self.assertEqual(result["leather"], [])


if __name__ == "__main__":
    unittest.main()
