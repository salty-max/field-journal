"""Read-only wow-data inventory shared by the Finds generator and audit."""
import collections
import functools
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))

PROFESSIONS = {"fish": 356, "plants": 182, "mining": 186, "leather": 393}
LOCALES = ("enUS", "frFR", "deDE", "esES", "esMX", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW")
# Baseline cloth identities, not a heuristic based on the translated name.
CLOTH = (2589, 2592, 4306, 4338, 14047, 14256)


class Inventory:
    def __init__(self, game):
        from wowdata import db
        self.game = game
        self.db = db(game)
        self.names = {(k, i, loc): (n, source) for k, i, loc, n, source in self.db.execute(
            "SELECT kind, id, locale, name, source FROM name WHERE kind IN ('item','object','creature','skill_line')"
        )}
        self.items = {r["id"]: r for r in self.rows("SELECT * FROM item")}
        self.icons = {i: icon for i, icon in self.db.execute("SELECT ID, IconFileDataID FROM client_Item")}
        self.objects = {r["id"]: r for r in self.rows("SELECT * FROM object")}
        self.creatures = {r["id"]: r for r in self.rows("SELECT * FROM creature")}
        self.skills = {r["ID"]: r for r in self.rows("SELECT * FROM client_SkillLine")}
        self.locks = {r["ID"]: r for r in self.rows("SELECT * FROM client_Lock")}
        self.gathering = {(r["object_id"], r["skill_line_id"]): r for r in self.rows("SELECT * FROM gathering_node")} if self.db.execute(
            "SELECT 1 FROM sqlite_master WHERE name='gathering_node'"
        ).fetchone() else {}
        self.loot = collections.defaultdict(list)
        self.reverse_loot = collections.defaultdict(list)
        for r in self.rows("SELECT * FROM loot"):
            self.loot[(r["kind"], r["source_id"], r["source"])].append(r)
            if r["item_id"]:
                self.reverse_loot[r["item_id"]].append(r)
        self.spawns = collections.defaultdict(collections.Counter)
        for kind, entity, source, n in self.db.execute(
            "SELECT kind, entity_id, source, count(*) FROM spawn GROUP BY kind, entity_id, source"
        ):
            self.spawns[(kind, entity)][source] = n
        self.reference_issues = set()

    def rows(self, sql, params=()):
        cursor = self.db.execute(sql, params)
        columns = [c[0] for c in cursor.description]
        return [dict(zip(columns, row)) for row in cursor]

    def name(self, kind, id):
        return self.names.get((kind, id, "enUS"), (None, None))[0]

    def localization(self, kind, id):
        return {
            "missing": [loc for loc in LOCALES if not self.names.get((kind, id, loc), (None,))[0]],
            "english_fallback": [loc for loc in LOCALES if self.names.get((kind, id, loc), (None, None))[1] == "english"],
        }

    def expand(self, rows, trail=()):
        out = set()
        for r in rows:
            if r["ref_id"]:
                ref = r["ref_id"]
                if ref in trail:
                    self.reference_issues.add(f"cycle: {trail} -> {ref}")
                    continue
                target = self.loot[("reference", ref, "classicdb")]
                if not target:
                    self.reference_issues.add(f"missing reference: {ref}")
                out.update(self.expand(target, trail + (ref,)))
            elif r["item_id"]:
                out.add(r["item_id"])
        return out

    @functools.lru_cache(maxsize=None)
    def yields(self, kind, id, template):
        # Classic and the existing players importer use loot template IDs.
        # Questie and Wowhead use entity IDs.
        rows = list(self.loot[(kind, template, "classicdb")]) if template else []
        rows.extend(self.loot[(kind, template or id, "players")])
        for source in ("questie", "wowhead"):
            rows.extend(self.loot[(kind, id, source)])
        return frozenset(self.expand(rows))

    def gather_skill(self, obj, lock_type):
        profession = {2: 182, 3: 186}.get(lock_type)
        normalized = getattr(self, "gathering", {}).get((obj.get("id"), profession))
        if normalized:
            return normalized["min_skill"]
        lock = self.locks.get(obj["lock_id"], {})
        values = [lock[f"Skill_{i}"] for i in range(8)
                  if lock.get(f"Type_{i}") == 2 and lock.get(f"_Index_{i}") == lock_type]
        return min(values) if values else None

    def item(self, id):
        item = self.items.get(id, {})
        return {
            "id": id, "name": self.name("item", id), "class": item.get("class_id"),
            "subclass": item.get("subclass_id"), "removed": item.get("removed"),
            "icon": self.icons.get(id), "localization": self.localization("item", id),
            "direct_loot_rows": dict(collections.Counter(r["kind"] for r in self.reverse_loot[id])),
            "direct_loot_providers": dict(collections.Counter(r["source"] for r in self.reverse_loot[id])),
        }

    def nodes(self, lock_type):
        out = []
        for id, obj in self.objects.items():
            skill = self.gather_skill(obj, lock_type)
            if obj["type"] != 3 or skill is None:
                continue
            out.append({
                "id": id, "name": self.name("object", id), "skill": skill,
                "template": obj["loot_id"], "removed": obj["removed"],
                "spawns": dict(self.spawns[("object", id)]),
                "items": sorted(self.yields("object", id, obj["loot_id"])),
                "localization": self.localization("object", id),
                "requirement_evidence": self.gathering.get((id, {2: 182, 3: 186}[lock_type])),
            })
        return sorted(out, key=lambda r: r["id"])

    def professions(self):
        out = {}
        for family, root in PROFESSIONS.items():
            def belongs(id):
                seen = set()
                while id in self.skills and id not in seen:
                    if id == root:
                        return True
                    seen.add(id)
                    id = self.skills[id]["ParentSkillLineID"]
                return False
            ids = sorted(id for id in self.skills if belongs(id))
            out[family] = [{"id": id, "name": self.name("skill_line", id),
                            "parent": self.skills[id]["ParentSkillLineID"],
                            "localization": self.localization("skill_line", id)} for id in ids]
        return out

    def audit(self):
        mining = self.nodes(3)
        herbs = self.nodes(2)
        mining_items = set().union(*(set(r["items"]) for r in mining))
        skin_creatures = [r for r in self.creatures.values() if r["skin_loot_id"] or
                          any(self.loot[("skinning", r["id"], source)] for source in ("questie", "wowhead"))]
        skin_items = set().union(*(set(self.yields("skinning", r["id"], r["skin_loot_id"])) for r in skin_creatures))
        unresolved_nodes = []
        for id, obj in self.objects.items():
            name = self.name("object", id) or ""
            # Name search is only a gap-finding aid, never a classification rule.
            if obj["type"] == 3 and self.gather_skill(obj, 3) is None and not obj["lock_id"] and re.search(r"Vein|Deposit|Chunk of Amber", name):
                unresolved_nodes.append({
                    "id": id, "name": name, "spawns": dict(self.spawns[("object", id)]),
                    "lock": obj["lock_id"], "template": obj["loot_id"], "removed": obj["removed"],
                    "items": sorted(self.yields("object", id, obj["loot_id"])),
                    "localization": self.localization("object", id),
                })
        effects = self.rows("""SELECT SpellID AS spell, Effect AS effect, EffectMiscValue_0 AS kind
                               FROM client_SpellEffect WHERE Effect IN (33,95,118)
                               ORDER BY SpellID,Effect""")
        gathering = {
            "open_lock_mining": sorted({r["spell"] for r in effects if r["effect"] == 33 and r["kind"] == 3}),
            "open_lock_herbalism": sorted({r["spell"] for r in effects if r["effect"] == 33 and r["kind"] == 2}),
            "skin_effect": [dict(r, name=self.names_for_spell(r["spell"])) for r in effects if r["effect"] == 95],
        }
        # The client classes are candidate selectors only: even Forever's
        # cloth category contains thread and crafted bolts, not just finds.
        typed = {key: [self.item(id) for id, r in sorted(self.items.items())
                       if r["class_id"] == 7 and r["subclass_id"] == sub]
                 for key, sub in (("cloth", 5), ("leather", 6))}
        cloth = []
        for id in CLOTH:
            creatures = [r for r in self.creatures.values()
                         if id in self.yields("creature", r["id"], r["loot_id"])]
            cloth.append(dict(self.item(id), creature_source_count=len(creatures),
                              creature_sources_without_spawns=sum(
                                  not self.spawns[("creature", r["id"])] for r in creatures)))
        supported_ids = set(CLOTH) | mining_items | skin_items
        return {
            "metadata": dict(self.db.execute("SELECT key,value FROM meta")),
            "professions": self.professions(), "gathering_spells": gathering,
            "mining_nodes": mining, "herbalism_node_count": len(herbs),
            "mining_nodes_without_yields": [r["id"] for r in mining if not r["items"]],
            "mining_nodes_without_spawns": [r["id"] for r in mining if not r["spawns"]],
            "mining_yields": [self.item(id) for id in sorted(mining_items)],
            "skinning_yields": [self.item(id) for id in sorted(skin_items)],
            "skinnable_creature_count": len(skin_creatures),
            "skin_creatures_without_spawns": sorted(r["id"] for r in skin_creatures
                                                    if not self.spawns[("creature", r["id"])]),
            "skin_creatures_without_yields": [r["id"] for r in skin_creatures if not self.yields("skinning", r["id"], r["skin_loot_id"])],
            "baseline_cloth": cloth,
            "client_subclass_candidates": typed,
            "unresolved_node_candidates": sorted(unresolved_nodes, key=lambda r: r["id"]),
            "reference_issues": sorted(self.reference_issues),
            "missing_item_rows": sorted(supported_ids - self.items.keys()),
            "missing_item_icons": sorted(id for id in supported_ids if not self.icons.get(id)),
            "name_coverage": {loc: {
                "present": sum(bool(self.names.get(("item", id, loc), (None,))[0]) for id in supported_ids),
                "total": len(supported_ids),
                "missing_ids": sorted(id for id in supported_ids if not self.names.get(("item", id, loc), (None,))[0]),
            } for loc in LOCALES},
        }

    def names_for_spell(self, id):
        row = self.db.execute("SELECT name FROM name WHERE kind='spell' AND id=? AND locale='enUS'", (id,)).fetchone()
        return row[0] if row else None
