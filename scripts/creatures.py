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

  python3 scripts/creatures.py            (downloads ~13 MB once, cached in .cache/)
"""
import csv, gzip, json, os, re, urllib.request

COMMIT = "28ef6259c782928b08a8dc9cacf6bc02e64f2b29"
URL = f"https://github.com/cmangos/classic-db/raw/{COMMIT}/Full_DB/ClassicDB_1_12_1_z2815.sql.gz"
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CACHE = os.path.join(ROOT, ".cache", f"classicdb-{COMMIT[:12]}.sql.gz")
OUT = os.path.join(ROOT, "data", "creatures.json")
# The client's faction templates (wago.tools, Classic Era): which side a
# creature is on. Creatures friendly to the Alliance or the Horde (guards,
# soldiers, town folk of either side) are people, not the Bestiary's game.
FACTIONS_URL = "https://wago.tools/db2/FactionTemplate/csv?product=wow_classic_era"
FACTIONS = os.path.join(ROOT, ".cache", "FactionTemplate.csv")
ALLIANCE, HORDE = 2, 4

TYPES = {1: "Beast", 2: "Dragonkin", 3: "Demon", 4: "Elemental", 5: "Giant", 6: "Undead", 7: "Humanoid", 9: "Mechanical", 10: "NotSpecified"}
RANKS = {0: "normal", 1: "elite", 2: "rareelite", 3: "boss", 4: "rare"}
NOT_SELECTABLE = 0x02000000
HELPER = re.compile(r"\b(Trigger|Doodad|Dummy|Marker|Target|Bunny|DND|UNUSED|unused|Visual|Spell|Generator|TEST|Test)\b|^\[|\(1\)$")


def sql_text():
    if not os.path.exists(CACHE):
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        urllib.request.urlretrieve(URL, CACHE)
    with gzip.open(CACHE, "rt", encoding="utf-8", errors="replace") as f:
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
    """Faction templates that belong to, or are friends with, either side."""
    if not os.path.exists(FACTIONS):
        req = urllib.request.Request(FACTIONS_URL, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req) as r, open(FACTIONS, "wb") as f:
            f.write(r.read())
    out = set()
    with open(FACTIONS) as f:
        for r in csv.DictReader(f):
            if (int(r["FactionGroup"]) | int(r["FriendGroup"])) & (ALLIANCE | HORDE):
                out.add(int(r["ID"]))
    return out


def main():
    sql = sql_text()
    aligned = aligned_factions()
    spawn_cols = columns(sql, "creature")
    spawned = {int(r[spawn_cols.index("id")]) for r in rows(sql, "creature")}
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
        if int(d["NpcFlags"]) or int(d["UnitFlags"]) & NOT_SELECTABLE or HELPER.search(d["Name"]):
            continue
        if int(d["Faction"]) in aligned:
            continue
        out.append({
            "id": cid,
            "name": d["Name"],
            "type": TYPES[ctype],
            "family": int(d["Family"]),
            "rank": RANKS.get(rank, "normal"),
            "levels": [int(d["MinLevel"]), int(d["MaxLevel"])],
        })
    out.sort(key=lambda c: c["id"])
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w") as f:
        f.write("[\n" + ",\n".join(json.dumps(c, ensure_ascii=True) for c in out) + "\n]\n")
    print(f"{len(out)} creatures -> data/creatures.json")


if __name__ == "__main__":
    main()
