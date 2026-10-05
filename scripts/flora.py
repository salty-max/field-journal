#!/usr/bin/env python3
"""
data/flora.json: the herbs and fish of the original world, for the Plants and
Fish tabs. From the CMaNGOS Classic database (the same pinned commit as
scripts/creatures.py: a community reconstruction of the 1.12 server, not an
official Blizzard source), with the client's own tables from wago.tools
(Classic Era): Lock (the Herbalism skill a node needs), AreaTable, UiMap and
UiMapAssignment (which zone a place or a spot of the world is in).

Herbs: the items the database files as herbs (Trade Goods, Herb), each with
the nodes that give it (game objects of the same name, plus the herbs found
in another's node: Swiftthistle, Wildvine), the Herbalism skill the node needs,
and the zones where its nodes grow (from the nodes' spawns, placed by the
Atlas's places of each zone; a zone counts with at least 6 of them and 3% of
the herb's, so the strays at a border don't).

Fish: what fishing gives (the fishing loot by zone or subzone, through its
reference tables), less the junk (crates, chests, potions, skulls, the bloated
fish one opens): the fish one cooks, the reagents, the Deviate Fish, the quest
fish. Each with the zones where it bites (and the subzones, where the table is
a subzone's: the Barrens' oases), the schools that hold it, and its weighed
weighed catches ("32 Pound Catfish") as entries of their own (one per kind:
Catfish, Grouper...), and the season of the seasonal ones (Winter Squid,
Summer Bass: the database's fishing season events). The database doesn't
model the hour (Nightfin Snapper by night, Sunscale Salmon by day): the
character's catches record it.

  python3 scripts/flora.py            (the database and tables are cached in .cache/)
"""
import collections, json, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import creatures as db  # the pinned dump and its SQL readers
import zones as zones_script  # the client's tables from wago.tools

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
OUT = os.path.join(ROOT, "data", "flora.json")

HERBALISM = 2  # LockType: Herbalism
SKILL_KEY = 2  # Lock type of an entry: a skill (LOCK_KEY_SKILL)
FISHING_HOLE = 25  # game object type: a school


def wago(name):
    """A Classic Era client table, through scripts/zones.py's cache (.cache/era)."""
    return zones_script.table("classic", name)


def table(sql, name):
    cols = db.columns(sql, name)
    return [dict(zip(cols, r)) for r in db.rows(sql, name)]


# ── zones ─────────────────────────────────────────────────────────────────────
def zone_tools():
    areas = {int(r["ID"]): r for r in wago("AreaTable")}
    uimaps = {int(r["ID"]): r for r in wago("UiMap")}
    zone_maps = {i for i, m in uimaps.items() if m["Type"] == "3"}  # zones
    assign = [r for r in wago("UiMapAssignment") if int(r["UiMapID"]) in zone_maps]
    by_area = {}
    for r in assign:
        if int(r["AreaID"]):
            by_area.setdefault(int(r["AreaID"]), int(r["UiMapID"]))

    def top(area):
        """The zone an area belongs to (its top parent), and the area itself."""
        a, seen = area, set()
        while a in areas and int(areas[a]["ParentAreaID"]) and a not in seen:
            seen.add(a)
            a = int(areas[a]["ParentAreaID"])
        return a

    def area_zone(area):
        z = top(area)
        m = by_area.get(z) or by_area.get(area)
        return uimaps[m]["Name_lang"] if m else None

    # The Atlas's places of each zone (data/zones-classic.json): rectangles on
    # the zone's map art (1002 x 668), where the zone really is.
    with open(os.path.join(ROOT, "data", "zones-classic.json")) as f:
        places = {z["id"]: [p["rect"] for p in z["places"]] for z in json.load(f)["zones"]}

    def on_map(r, x, y):
        """A world spot on a zone's map art, in pixels (the world's x runs north,
        its y west)."""
        x0, y0, x1, y1 = float(r["Region_0"]), float(r["Region_1"]), float(r["Region_3"]), float(r["Region_4"])
        u0, v0, u1, v1 = float(r["UiMin_0"]), float(r["UiMin_1"]), float(r["UiMax_0"]), float(r["UiMax_1"])
        u = u0 + (y1 - y) / (y1 - y0) * (u1 - u0)
        v = v0 + (x1 - x) / (x1 - x0) * (v1 - v0)
        return u * 1002, v * 668

    def spot_zone(mapid, x, y):
        """The zone a spot of the world is in. The zones' rectangles overlap near
        their borders: the zone with one of its places at that spot (with a
        margin) wins; else the one whose centre is nearest (as
        scripts/rare_zones.py)."""
        best = None
        for r in assign:
            if int(r["MapID"]) != mapid:
                continue
            x0, y0, x1, y1 = float(r["Region_0"]), float(r["Region_1"]), float(r["Region_3"]), float(r["Region_4"])
            if x0 <= x <= x1 and y0 <= y <= y1:
                px, py = on_map(r, x, y)
                inside = any(a - 25 <= px <= c + 25 and b - 25 <= py <= d + 25 for a, b, c, d in places.get(int(r["UiMapID"]), []))
                d = (x - (x0 + x1) / 2) ** 2 + (y - (y0 + y1) / 2) ** 2
                key = (0 if inside else 1, d)
                if best is None or key < best[0]:
                    best = (key, int(r["UiMapID"]))
        return uimaps[best[1]]["Name_lang"] if best else None

    def area_name(area):
        return areas[area]["AreaName_lang"] if area in areas else None

    maps = {int(r["ID"]): r["MapName_lang"] for r in wago("Map")}
    return area_zone, spot_zone, area_name, top, maps


def main():
    sql = db.sql_text()
    area_zone, spot_zone, area_name, top, maps = zone_tools()
    items = {r["entry"]: r for r in table(sql, "item_template")}
    gos = {g["entry"]: g for g in table(sql, "gameobject_template")}
    goloot = collections.defaultdict(list)
    for r in table(sql, "gameobject_loot_template"):
        goloot[r["entry"]].append(r)
    spawns = collections.defaultdict(list)
    for r in table(sql, "gameobject"):
        spawns[r["id"]].append(r)
    locks = {int(r["ID"]): r for r in wago("Lock")}

    def herb_skill(lock):
        r = locks.get(lock)
        if not r:
            return None
        for i in range(8):
            if int(r[f"Type_{i}"]) == SKILL_KEY and int(r[f"_Index_{i}"]) == HERBALISM:
                return int(r[f"Skill_{i}"])
        return None

    ref = collections.defaultdict(list)
    for r in table(sql, "reference_loot_template"):
        ref[r["entry"]].append(r)

    def expand(rows):
        """A loot table's items, through its reference tables."""
        for r in rows:
            n = int(r["mincountOrRef"])
            if n < 0:
                yield from expand(ref.get(str(-n), []))
            else:
                yield r["item"]

    # Fish of a season: loot rows only while a fishing season's event is on.
    events = {r["entry"]: r["description"] for r in table(sql, "game_event")}
    conds = {r["condition_entry"]: r for r in table(sql, "conditions")}
    season = {}
    for t in ("reference_loot_template", "fishing_loot_template"):
        for r in table(sql, t):
            c = conds.get(r["condition_id"])
            if c and c["type"] == "12":  # an active game event
                m = re.match(r"(Winter|Summer) Season Fishing", events.get(c["value1"], ""))
                if m:
                    season[r["item"]] = m.group(1).lower()

    # ── herbs ─────────────────────────────────────────────────────────────────
    herb_items = {e: r for e, r in items.items() if r["class"] == "7" and r["subclass"] == "9"}
    names = {r["name"]: e for e, r in herb_items.items()}
    herbs = []
    for e, r in sorted(herb_items.items(), key=lambda x: (int(x[1]["ItemLevel"]), x[1]["name"])):
        nodes = []
        for g in gos.values():
            if g["type"] != "3" or g["name"] not in names:
                continue
            loot = list(expand(goloot.get(g["data1"], [])))
            if e in loot and herb_skill(int(g["data0"])) is not None:
                nodes.append(g)
        zones, dungeons = collections.Counter(), set()
        for g in nodes:
            for s in spawns[g["entry"]]:
                z = spot_zone(int(s["map"]), float(s["position_x"]), float(s["position_y"]))
                if z:
                    zones[z] += 1
                elif int(s["map"]) not in (0, 1) and int(s["map"]) in maps:
                    dungeons.add(maps[int(s["map"])])  # inside: Dire Maul, Zul'Gurub...
        total = sum(zones.values())
        kept = [z for z, n in zones.most_common() if n >= 6 and n >= total * 0.03]  # not the strays at a border
        own = [g for g in nodes if g["name"] == r["name"]]
        herbs.append({
            "id": int(e), "name": r["name"], "level": int(r["ItemLevel"]),
            "skill": min((herb_skill(int(g["data0"])) for g in (own or nodes)), default=None),
            "nodes": sorted({g["name"] for g in nodes}), "nodeIds": sorted(int(g["entry"]) for g in nodes), "spawns": total,
            "zones": kept, "dungeons": sorted(dungeons),
            **({"inside": True} if not own else {}),  # found in another herb's node
        })

    # ── fish ──────────────────────────────────────────────────────────────────
    where = collections.defaultdict(set)  # item: areas
    fishing = collections.defaultdict(list)
    for r in table(sql, "fishing_loot_template"):
        fishing[int(r["entry"])].append(r)
    for area, rows in fishing.items():
        for item in expand(rows):
            where[item].add(area)

    def kind(r):
        c, s, name = r["class"], r["subclass"], r["name"]
        if re.match(r"Bloated |Oil Covered|Sickly Looking", name):
            return None  # junk one opens or throws back
        if c == "0" and s in ("0", "3") and not re.search(r"Potion", name):
            return "food"
        if c == "5":
            return "reagent"
        if c == "7" and name == "Deviate Fish":
            return "special"
        if c == "12":
            return "quest"
        return None

    # The weighed catches ("32 Pound Catfish"): one entry per kind of fish,
    # its weights the items (groupers have no other fish of their own).
    records = collections.defaultdict(list)
    for e in where:
        m = re.match(r"(\d+) Pound (.+)$", items[e]["name"])
        if m:
            records[m.group(2)].append({"id": int(e), "pounds": int(m.group(1))})

    schools, school_ids = collections.defaultdict(set), collections.defaultdict(set)
    for g in gos.values():
        if g["type"] == str(FISHING_HOLE):
            for item in expand(goloot.get(g["data1"], [])):
                schools[item].add(g["name"])
                school_ids[item].add(int(g["entry"]))

    fish = []
    for e in sorted(where, key=lambda e: (int(items[e]["ItemLevel"]), items[e]["name"])):
        r = items[e]
        k = kind(r)
        if not k:
            continue
        zones, subzones, dungeons = collections.OrderedDict(), [], []
        for a in sorted(where[e]):
            z = area_zone(a)
            if z:
                zones[z] = True
            elif area_name(top(a)):
                dungeons.append(area_name(top(a)))  # no zone map: an instance
            if top(a) != a and area_name(a):
                subzones.append(area_name(a))
        fish.append({
            "id": int(e), "name": r["name"], "level": int(r["ItemLevel"]), "kind": k,
            "zones": sorted(zones), "subzones": sorted(set(subzones)), "dungeons": sorted(set(dungeons)),
            "schools": sorted(schools.get(e, [])), "schoolIds": sorted(school_ids.get(e, [])),
            **({"season": season[e]} if e in season else {}),
        })
    for name, weights in sorted(records.items()):
        weights.sort(key=lambda x: x["pounds"])
        areas = set().union(*(where[str(w["id"])] for w in weights))
        fish.append({
            "id": weights[0]["id"], "name": name, "level": int(items[str(weights[0]["id"])]["ItemLevel"]), "kind": "record",
            "zones": sorted({z for z in (area_zone(a) for a in areas) if z}),
            "subzones": sorted({area_name(a) for a in areas if top(a) != a and area_name(a)}),
            "dungeons": sorted({area_name(top(a)) for a in areas if not area_zone(a) and area_name(top(a))}),
            "schools": [], "schoolIds": [], "weights": weights,
        })

    every_school = sorted(int(g["entry"]) for g in gos.values() if g["type"] == str(FISHING_HOLE))
    with open(OUT, "w") as f:
        json.dump({"herbs": herbs, "fish": fish, "schools": every_school}, f, indent=1)
    print(f"{len(herbs)} herbs, {len(fish)} fish -> data/flora.json")
    for h in herbs:
        print(f"  herb {h['name']:<22} skill {h['skill']!s:>4}  {h['spawns']:>5} spawns  {', '.join(h['zones'][:6])}"
              f"{'  | ' + ', '.join(h['dungeons']) if h['dungeons'] else ''}")
    for x in fish:
        print(f"  fish {x['name']:<30} {x['kind']:<8} {len(x['zones']):>2} zones  {'| ' + ', '.join(x['dungeons']) + '  ' if x['dungeons'] else ''}schools: {', '.join(x['schools']) or '-'}"
              f"{'  weights ' + ', '.join(str(w['pounds']) for w in x['weights']) if x.get('weights') else ''}")


if __name__ == "__main__":
    main()
