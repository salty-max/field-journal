#!/usr/bin/env python3
"""The zone of every rare in data/creatures.json, for the trophies-by-zone
milestones: data/rare-zones.json ({creature id: uiMap id}).

  python3 scripts/rare_zones.py

Two sources, the first that knows wins:
  1. the "Rare mobs by zone" page of the WoWWiki archive, its section for the
     original game's zones (fetched once into .cache/);
  2. the rare's spawn points (CMaNGOS, as scripts/creatures.py) placed in the
     zones' map rectangles (the client's UiMapAssignment, wago.tools); where
     rectangles overlap near a border, the zone whose centre is nearest.
Disagreements between the two are printed for review.
"""
import collections, csv, json, os, re, urllib.parse, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), "..")
CACHE = os.path.join(ROOT, ".cache")
OUT = os.path.join(ROOT, "data", "rare-zones.json")
WIKI = "https://wowwiki-archive.fandom.com/api.php?action=parse&redirects=1&prop=wikitext&format=json&page=Rare_mobs_by_zone"
WAGO = "https://wago.tools/db2/{}/csv?product=wow_classic_era"
UA = {"User-Agent": "ExplorersFieldJournal/0.1 (addon data; github.com/salty-max/field-journal)"}


def cached(name, url):
    path = os.path.join(CACHE, name)
    if not os.path.exists(path):
        os.makedirs(CACHE, exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120) as r, open(path, "wb") as f:
            f.write(r.read())
    return path


def wiki_zones():
    """Rare name -> zone names, from the original game's section."""
    text = json.load(open(cached("rare-mobs-by-zone.json", WIKI)))["parse"]["wikitext"]["*"]
    section = text[text.index("== In World of Warcraft =="):]
    section = section[: section.index("\n== ", 5)]
    out = collections.defaultdict(set)
    for zone, cell in re.findall(r"^! \[\[([^\]|]+)\]\]\s*\n\| (.+)$", section, re.M):
        for m in re.finditer(r"\[\[([^\]]+)\]\]", cell):
            out[m.group(1).split("|")[-1].strip()].add(zone)
    return out


def main():
    g = {"__file__": os.path.join(ROOT, "scripts", "creatures.py")}
    exec(open(g["__file__"]).read().split("\nif __name__")[0], g)
    sql = g["sql_text"]()
    data = {c["id"]: c for c in json.load(open(os.path.join(ROOT, "data", "creatures.json")))}
    rares = {i for i, c in data.items() if c["rank"] in ("rare", "rareelite")}

    # Spawn points: a spawn's own entry, or the entries that may take its place.
    cols = g["columns"](sql, "creature")
    pos = {}
    entries = collections.defaultdict(set)
    for r in g["rows"](sql, "creature"):
        d = dict(zip(cols, r))
        pos[d["guid"]] = (int(d["map"]), float(d["position_x"]), float(d["position_y"]))
        entries[d["guid"]].add(int(d["id"]))
    c = g["columns"](sql, "creature_spawn_entry")
    for r in g["rows"](sql, "creature_spawn_entry"):
        entries[r[c.index("guid")]].add(int(r[c.index("entry")]))
    c1, c2 = g["columns"](sql, "spawn_group_entry"), g["columns"](sql, "spawn_group_spawn")
    group = collections.defaultdict(set)
    for r in g["rows"](sql, "spawn_group_entry"):
        group[r[c1.index("Id")]].add(int(r[c1.index("Entry")]))
    for r in g["rows"](sql, "spawn_group_spawn"):
        entries[r[c2.index("Guid")]] |= group[r[c2.index("Id")]]
    spawns = collections.defaultdict(list)
    for guid, ids in entries.items():
        for i in ids & rares:
            if guid in pos:
                spawns[i].append(pos[guid])

    uimap = {r["ID"]: r for r in csv.DictReader(open(cached("UiMap.csv", WAGO.format("UiMap"))))}
    rects = [
        (int(r["MapID"]), float(r["Region_0"]), float(r["Region_1"]), float(r["Region_3"]), float(r["Region_4"]), int(r["UiMapID"]))
        for r in csv.DictReader(open(cached("UiMapAssignment.csv", WAGO.format("UiMapAssignment"))))
        if uimap[r["UiMapID"]]["Type"] == "3"
    ]
    by_name = {r["Name_lang"]: int(r["ID"]) for r in uimap.values() if r["Type"] == "3"}

    def place(m, x, y):
        best = None
        for zm, x0, y0, x1, y1, ui in rects:
            if zm == m and x0 <= x <= x1 and y0 <= y <= y1:
                d = ((x - (x0 + x1) / 2) / (x1 - x0)) ** 2 + ((y - (y0 + y1) / 2) / (y1 - y0)) ** 2
                if best is None or d < best[0]:
                    best = (d, ui)
        return best and best[1]

    wiki = wiki_zones()
    out, disagree, unplaced = {}, [], []
    for i in sorted(rares):
        name = data[i]["name"]
        counts = collections.Counter(place(*s) for s in spawns[i])
        counts.pop(None, None)
        coords = counts.most_common(1)[0][0] if counts else None
        named = [by_name[z] for z in wiki.get(name, ()) if z in by_name]
        zone = named[0] if len(named) == 1 else coords
        if named and coords and named[0] != coords:
            disagree.append(f"{name}: wiki {uimap[str(named[0])]['Name_lang']}, coordinates {uimap[str(coords)]['Name_lang']}")
        if zone:
            out[str(i)] = zone
        else:
            unplaced.append(name)  # dungeons, raids: no zone of the world map
    with open(OUT, "w") as f:
        json.dump(out, f, indent=0, sort_keys=True)
        f.write("\n")
    print(f"{len(out)} rares placed -> data/rare-zones.json; {len(unplaced)} in no zone (dungeons)")
    for line in disagree:
        print("  wiki wins:", line)


if __name__ == "__main__":
    main()
