#!/usr/bin/env python3
"""The rares WoW Forever adds (Zephras Isle's, and the new ones in the old
zones), for the Forever package's trophies-by-zone milestones:
data/rare-zones-forever.json ({creature id: {name, zone: uiMap id}}).

  python3 scripts/forever_rares.py

From AllTheThings' Forever database (MIT), pinned to one commit: the RARES of
each zone file. Kept: creatures the CMaNGOS Classic database doesn't know
(Forever's own), placed in the zone their coordinates name, matched by name to
the Atlas's Forever zones (data/zones-forever.json). Their families aren't
known before they are met: the journal files them then, from what the game
says of them (Creatures.lua).
"""
import gzip, json, os, re, urllib.parse, urllib.request

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
CACHE = os.path.join(ROOT, ".cache", "att")
OUT = os.path.join(ROOT, "data", "rare-zones-forever.json")
ATT = "ATTWoWAddon/AllTheThings"
ATT_COMMIT = "a21caf2a7ec636785505a7f4e7e4311d16ce28af"
CMANGOS = os.path.join(ROOT, ".cache", "classicdb-28ef6259c782.sql.gz")  # scripts/creatures.py's
UA = {"User-Agent": "ExplorersFieldJournal/0.1 (addon data; github.com/salty-max/field-journal)"}


def fetch(url, path):
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120) as r, open(path, "wb") as f:
            f.write(r.read())
    return path


def att_files():
    tree = json.load(open(fetch(f"https://api.github.com/repos/{ATT}/git/trees/{ATT_COMMIT}?recursive=1",
                                os.path.join(CACHE, f"tree-{ATT_COMMIT[:12]}.json"))))
    for t in tree["tree"]:
        p = t["path"]
        if t["type"] == "blob" and re.match(r"^\.contrib/\.db/forever/zones/.*\.lua$", p):
            local = os.path.join(CACHE, ATT_COMMIT[:12], p.split("forever/", 1)[1])
            url = f"https://raw.githubusercontent.com/{ATT}/{ATT_COMMIT}/" + urllib.parse.quote(p)
            yield open(fetch(url, local), encoding="utf-8").read()


def classic_creatures():
    # the old world's creatures, by id (CREATE TABLE order: Entry first)
    with gzip.open(CMANGOS, "rt", encoding="utf-8", errors="replace") as f:
        sql = f.read()
    ids = set()
    for m in re.finditer(r"INSERT INTO `creature_template` VALUES\s*(.*?);\n", sql, re.S):
        ids.update(int(x) for x in re.findall(r"\((\d+),", m.group(1)))
    return ids


def main():
    if not os.path.exists(CMANGOS):
        raise SystemExit("no CMaNGOS dump: run python3 scripts/creatures.py first")
    classic = classic_creatures()
    norm = lambda s: re.sub(r"[^a-z0-9]+", " ", s.lower().replace("the ", "", 1)).strip()
    # (a name two maps share, Zephras Isle and its flight map: the one with places)
    zones = {}
    for z in sorted(json.load(open(os.path.join(ROOT, "data", "zones-forever.json")))["zones"], key=lambda z: -len(z["places"])):
        zones.setdefault(norm(z["name"]), z["id"])
    out = {}
    for src in att_files():
        root = re.search(r"maproot\(MAP\.(\w+)", src)
        for block in re.finditer(r"n\(RARES, \{(.*?)\n\t\t\}\),", src, re.S):
            body = block.group(1)
            for m in re.finditer(r"n\((\d+), \{\s*-- *([^\n<]+)", body):
                cid = int(m.group(1))
                if cid in classic:
                    continue
                coord = re.search(r"MAP\.(\w+)", body[m.end():m.end() + 400])
                where = coord.group(1) if coord else (root.group(1) if root else "")
                zone = zones.get(norm(where.replace("_", " ")))
                if zone:
                    out[str(cid)] = {"name": m.group(2).strip(), "zone": zone}
                else:
                    print(f"  no zone for {cid} {m.group(2).strip()} ({where})")
    with open(OUT, "w") as f:
        json.dump(dict(sorted(out.items(), key=lambda kv: int(kv[0]))), f, indent=2)
        f.write("\n")
    print(f"{len(out)} rares of Forever's own -> {os.path.relpath(OUT, ROOT)}")


if __name__ == "__main__":
    main()
