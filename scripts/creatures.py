#!/usr/bin/env python3
"""
data/creatures.json: the creatures of the original world, for sorting into the
Bestiary's families. From the CMaNGOS Classic database (a community
reconstruction of the 1.12 server, not an official Blizzard source), pinned to
one commit so the output only changes when we choose.

Dungeon and raid bosses come from the database's encounter table (the
templates rank most of them merely elite).

Kept: creatures that spawn in the world (or bosses, which may be summoned),
with no vendor/quest/gossip flags, selectable, not critters or totems, not on
either side (Alliance or Horde: guards, soldiers), and not the database's
helpers (triggers, dummies, markers, unused entries).

  python3 scripts/creatures.py

The dump is wow-data's (../wow-data: pinned in its pins.json, downloaded once
into its cache).
"""
import gzip, json, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import client, path  # noqa: E402

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


def sql_text():
    """the Classic database's dump, as text"""
    with gzip.open(path("classicdb"), "rt", encoding="utf-8", errors="replace") as f:
        return f.read()


def columns(sql, table):
    m = re.search(r"CREATE TABLE `%s` \((.*?)\n\) ENGINE" % table, sql, re.S)
    return re.findall(r"^\s*`(\w+)`", m.group(1), re.M)


def rows(sql, table):
    """The rows of a table's INSERT statements (values as strings)."""
    for m in re.finditer(r"INSERT INTO `%s` (?:\([^)]*\) )?VALUES\s*(.*?);\n" % table, sql, re.S):
        s, i, n = m.group(1), 0, len(m.group(1))
        while i < n:
            if s[i] != "(":
                i += 1
                continue
            i += 1
            vals, cur, quoted = [], "", False
            while True:
                c = s[i]
                if quoted:
                    if c == "\\":
                        cur += s[i + 1]
                        i += 2
                        continue
                    if c == "'":
                        quoted = False
                    else:
                        cur += c
                    i += 1
                    continue
                if c == "'":
                    quoted = True
                elif c == ",":
                    vals.append(cur)
                    cur = ""
                elif c == ")":
                    vals.append(cur)
                    i += 1
                    break
                else:
                    cur += c
                i += 1
            yield vals


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
    sql = sql_text()
    sides, friendly = aligned_factions()
    spawn_cols = columns(sql, "creature")
    spawned = {int(r[spawn_cols.index("id")]) for r in rows(sql, "creature")}
    # Creatures that share a spawn point with others (a rare that sometimes
    # takes an ordinary mob's place) are listed in their own tables.
    for table, col in (("creature_spawn_entry", "entry"), ("spawn_group_entry", "Entry")):
        cols_ = columns(sql, table)
        spawned |= {int(r[cols_.index(col)]) for r in rows(sql, table)}
    # Dungeon and raid bosses: the encounters' kill credits (creditType 0). The
    # templates call most of them merely elite.
    enc_cols = columns(sql, "instance_encounters")
    bosses = {int(r[enc_cols.index("creditEntry")]) for r in rows(sql, "instance_encounters") if r[enc_cols.index("creditType")] == "0"}
    cols = columns(sql, "creature_template")
    out = []
    for r in rows(sql, "creature_template"):
        d = dict(zip(cols, r))
        cid, ctype, rank = int(d["Entry"]), int(d["CreatureType"]), int(d["Rank"])
        if ctype not in TYPES:
            continue  # critters, totems, untyped
        if cid in bosses:
            rank = 3
        if cid not in spawned and rank != 3:
            continue
        # Gossip or quest flags mark town folk, but some rares carry them too
        # (Old Grizzlegut, Commander Felstrom): rares stay.
        if (int(d["NpcFlags"]) and rank not in (2, 3, 4)) or int(d["UnitFlags"]) & NOT_SELECTABLE or HELPER.search(d["Name"]) or EVENT.search(d["Name"]):
            continue
        # Either side's folk out. Those friendly to every player too, except
        # elites, rares and bosses: many start friendly and turn on you through
        # their scripts (Zum'rah, Nefarius, the khans of Maraudon, the arena of
        # Blackrock Depths).
        faction = int(d["Faction"])
        if faction in sides or (faction in friendly and rank == 0):
            continue
        out.append({
            "id": cid,
            "name": d["Name"],
            "type": TYPES[ctype],
            "family": int(d["Family"]),
            "rank": RANKS.get(rank, "normal"),
            "levels": [int(d["MinLevel"]), int(d["MaxLevel"])],
            # the first of its display ids: the book's 3D portrait
            "model": next((int(d[k]) for k in ("ModelId1", "ModelId2", "ModelId3", "ModelId4") if int(d[k])), 0),
        })
    out.sort(key=lambda c: c["id"])
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as f:
        f.write("[\n" + ",\n".join(json.dumps(c, ensure_ascii=True) for c in out) + "\n]\n")
    print(f"{len(out)} creatures -> data/creatures.json")


if __name__ == "__main__":
    main()
