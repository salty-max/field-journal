#!/usr/bin/env python3
"""
data/creatures.json: the creatures of the original world, for sorting into the
Bestiary's families. From wow-data's Classic Era database (the creatures
Questie and the CMaNGOS Classic database know, pinned there: a community
reconstruction of the 1.12 server, not an official Blizzard source; their
levels Questie's, their factions and flags the Classic database's).

Dungeon and raid bosses come from the encounters (the templates rank most of
them merely elite).

Kept: creatures that spawn in the world (or bosses, which may be summoned),
with no vendor/quest/gossip flags, selectable, not critters or totems, not on
either side (Alliance or Horde: guards, soldiers), and not the database's
helpers (triggers, dummies, markers, unused entries).

  python3 scripts/creatures.py
"""
import json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import client, db  # noqa: E402

OUT = os.path.join(ROOT, "data", "creatures.json")
# The client's faction templates (Classic Era's, wow-data's database): which
# side a creature is on. Creatures friendly to the Alliance or the Horde
# (guards, soldiers, town folk of either side) are people, not the
# Bestiary's game.
PLAYER, ALLIANCE, HORDE = 1, 2, 4

TYPES = {1: "Beast", 2: "Dragonkin", 3: "Demon", 4: "Elemental", 5: "Giant", 6: "Undead", 7: "Humanoid", 9: "Mechanical", 10: "NotSpecified"}
RANKS = {0: "normal", 1: "elite", 2: "rareelite", 3: "boss", 4: "rare"}
NOT_SELECTABLE = 0x02000000
# Event and friendly NPCs the faction rules let through (elite town guards of
# events, festival NPCs, leaders who appear in scripted scenes, captives).
EVENT = re.compile(r"Infantry|Infantryman|Booty Bay Elite|Lookout|Lunar Festival|Christmas|^Tyrande$|^Fandral Staghelm$|^Rhonin$|^Argent |Argent Dawn|Captive|Spectator|Enslaved|Quarry Slave|Cenarion Hold|^Warrior \d+$|^Qiraji (Officer|Lieutenant|Captain|Major|Brigadier General)|^Narnie$|^Cornish Rex$|^Bombay$|^Senegal$|^Cockatiel$|^Cockroach$|^Black Kingsnake$|^\"Plucky\" Johnson$")
HELPER = re.compile(r"\b(Trigger|Doodad|Dummy|Marker|Target|Bunny|DND|UNUSED|unused|Visual|Spell|Generator|TEST|Test)\b|^\[|\(1\)$")


def aligned_factions():
    """Faction templates on a side (Alliance or Horde), and those friendly to every player."""
    sides, friendly = set(), set()
    for r in client("classic", "FactionTemplate"):
        groups = int(r["FactionGroup"]) | int(r["FriendGroup"])
        if groups & (ALLIANCE | HORDE):
            sides.add(int(r["ID"]))
        elif groups & PLAYER:
            friendly.add(int(r["ID"]))  # mounts, pets, neutral town folk
    return sides, friendly


def main():
    c = db("classic")
    sides, friendly = aligned_factions()
    one = lambda sql: {r[0] for r in c.execute(sql)}
    spawned = one("SELECT DISTINCT entity_id FROM spawn WHERE kind = 'creature' AND source = 'classicdb'")
    # Creatures that share a spawn point with others (a rare that sometimes
    # takes an ordinary mob's place) are listed in their own tables.
    spawned |= one("SELECT entity_id FROM spawn_entry WHERE kind = 'creature'")
    spawned |= one("SELECT e.entity_id FROM spawn_group_entry e JOIN spawn_group g ON g.id = e.group_id WHERE g.kind = 'creature'")
    # Dungeon and raid bosses: the encounters' kill credits. The templates call
    # most of them merely elite.
    bosses = one("SELECT credit_id FROM encounter WHERE credit_type = 0")
    out = []
    for cid, name, ctype, family, rank, lo, hi, faction, npc_flags, unit_flags, models in c.execute(
        """SELECT c.id, n.name, c.type_id, c.family_id, c.rank, c.min_level, c.max_level, c.faction_id, c.npc_flags,
                  c.unit_flags, c.display_ids
           FROM creature c LEFT JOIN name n ON n.kind = 'creature' AND n.id = c.id AND n.locale = 'enUS'
           WHERE c.unit_flags IS NOT NULL ORDER BY c.id"""
    ):
        if ctype not in TYPES:
            continue  # critters, totems, untyped
        rank = 3 if cid in bosses else rank or 0
        if cid not in spawned and rank != 3:
            continue
        # Gossip or quest flags mark town folk, but some rares carry them too
        # (Old Grizzlegut, Commander Felstrom): rares stay.
        if (npc_flags and rank not in (2, 3, 4)) or unit_flags & NOT_SELECTABLE or HELPER.search(name or "") or EVENT.search(name or ""):
            continue
        # Either side's folk out. Those friendly to every player too, except
        # elites, rares and bosses: many start friendly and turn on you through
        # their scripts (Zum'rah, Nefarius, the khans of Maraudon, the arena of
        # Blackrock Depths).
        if faction in sides or (faction in friendly and rank == 0):
            continue
        out.append({
            "id": cid,
            "name": name,
            "type": TYPES[ctype],
            "family": family or 0,
            "rank": RANKS.get(rank, "normal"),
            "levels": [lo, hi],
            # the first of its display ids: the book's 3D portrait
            "model": int((models or "0").split(",")[0]),
        })
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as f:
        f.write("[\n" + ",\n".join(json.dumps(c, ensure_ascii=True) for c in out) + "\n]\n")
    print(f"{len(out)} creatures -> data/creatures.json")


if __name__ == "__main__":
    main()
