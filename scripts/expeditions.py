#!/usr/bin/env python3
"""Where each riddle of expeditions/*.md is solved: data/expeditions.json.

  python3 scripts/expeditions.py

A riddle names its spot by what the game's data pins down:

  object: <id>     a game object of the pinned CMaNGOS dump (scripts/creatures.py):
                   every spawn of it on the zone's map, each checked against
                   Wowhead's (nether.wowhead.com's tooltip, cached in
                   .cache/wowhead/): within 0.6% of one of its points
  creature: <id>   a creature: one spawn on the zone's map, Wowhead's alike;
                   found by targeting it near (anywhere it walks), and where
                   it stands still (no further than 10 yards from its spawn:
                   the dump's wandering radius or its path) by its place too
  trigger: <id>    a quest's exploration trigger (the client's AreaTrigger)
  area: <name>     a sub-area of the zone (the client's AreaTable, under the
                   zone's own area): every id of that name

The world positions go on the zone's map by the client's UiMapAssignment
(wago.tools, Classic Era, cached in .cache/era/). The hint circle (hint_area,
in percent of the map's width) must hold the spot (an area's: its overlay's
centre, or its anchor's); an object's spawns outside it are other copies (a
history book stands in more than one inn), not the riddle's. Each zone also gets its size in yards
(the addon's cells are yards) and every sub-area id under it (the addon finds
the one it stands in by name; the riddles' own are not singled out). The
client's emote tokens (EmotesText) go with them, for the build to check the
gestures. An area
with no overlay of its own names an anchor inside it for its hint
(`anchor: { creature: <id> }`, `{ object: <id> }`, or `{ grave: <id> }`: a
graveyard the server names, world_safe_locs).

Wowhead's position: its object or NPC page's map data when cached
(.cache/wowhead/page-object-<id>.html: every copy, by zone; its site refuses
scripts after a few pages), else its tooltip (the zone with the most).

A zone's quarry (`quarry: { id, sources }`): every spawn of the creature on
the zone's map (its own, or one that may take its place: creature_spawn_entry,
spawn groups) that Wowhead places there too, gathered into its haunts: the
spawns within HAUNT percent of each other, each a circle around them wide
enough for its wandering (the dump's radius or path), HAUNT_MIN at least.

Anything that fails is printed and nothing is written.
"""
import collections, csv, json, math, os, re, sys, time, urllib.request

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
EXPEDITIONS = os.path.join(ROOT, "expeditions")
OUT = os.path.join(ROOT, "data", "expeditions.json")
ERA = os.path.join(ROOT, ".cache", "era")
WOWHEAD = os.path.join(ROOT, ".cache", "wowhead")
WAGO = "https://wago.tools/db2/{}/csv?product=wow_classic_era"
UA = {"User-Agent": "ExplorersFieldJournal/0.1 (addon data; github.com/salty-max/field-journal)"}
# How near the spot counts, in yards: an object or a creature stood beside
# (a statue's base can be a few yards from its centre), a trigger by its own
# radius (never less).
NEAR = 10
# Dump and Wowhead must agree within this, in percent of the map (a quarry's
# spawn within AGREE_HAUNT: Wowhead's points are sightings of a creature that
# moves, and its haunt is a circle of HAUNT_MIN at least).
AGREE, AGREE_HAUNT = 0.6, 2.0
# The map art's height over its width (1002 by 668): a hint circle's radius is
# in percent of the width.
ASPECT = 668 / 1002
# A quarry's haunts: spawns this near each other (percent of the width) are
# one, a circle never smaller than HAUNT_MIN.
HAUNT, HAUNT_MIN = 6, 3


def table(name):
    path = os.path.join(ERA, f"{name}.csv")
    if not os.path.exists(path):
        os.makedirs(ERA, exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(WAGO.format(name), headers=UA), timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    return list(csv.DictReader(open(path, encoding="utf-8")))


def wowhead(kind, id, area):
    """Wowhead Classic's points of an object or a creature in a zone (its area
    id): None when Wowhead doesn't place it there."""
    page = os.path.join(WOWHEAD, f"page-{kind}-{id}.html")
    if os.path.exists(page):
        m = re.search(r"g_mapperData = (\{.*?\});", open(page, encoding="utf-8").read())
        floors = json.loads(m.group(1)).get(str(area)) if m else None
        return [tuple(p) for f in floors for p in f["coords"]] if floors else None
    path = os.path.join(WOWHEAD, f"{kind}-{id}.json")
    if not os.path.exists(path):
        os.makedirs(WOWHEAD, exist_ok=True)
        url = f"https://nether.wowhead.com/classic/tooltip/{kind}/{id}"
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r, open(path, "wb") as f:
            f.write(r.read())
        time.sleep(0.25)
    m = (json.load(open(path)) or {}).get("map") or {}
    coords = m.get("coords") or {}
    if m.get("zone") != area:
        return None
    return [tuple(p) for floor in (coords.values() if isinstance(coords, dict) else []) for p in floor]


# ── the riddle files ───────────────────────────────────────────────────────
def value(s):
    """A front-matter value: { k: v, ... }, [a, b], "quoted", a number or plain text."""
    s = s.strip()
    if s.startswith("{"):
        return {k.strip(): value(v) for k, v in (p.split(":", 1) for p in s[1:-1].split(","))}
    if s.startswith("["):
        return [value(p) for p in s[1:-1].split(",") if p.strip()]
    if s.startswith('"'):
        return s[1:-1]
    if re.fullmatch(r"-?\d+(\.\d+)?", s):
        return float(s) if "." in s else int(s)
    return s


def riddle_files():
    for f in sorted(os.listdir(EXPEDITIONS)):
        if not f.endswith(".md"):
            continue
        src = open(os.path.join(EXPEDITIONS, f)).read()
        head = src.split("\n---\n", 1)[0]
        zone, riddles, quarry, block = None, [], None, None
        for raw in head.split("\n")[1:]:
            line = re.sub(r"\s+#\s.*$", "", raw)
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            m = re.match(r"^(\s*)(- )?(\w+):\s*(.*)$", line)
            if not m:
                sys.exit(f"{f}: can't read {raw!r}")
            indent, item, key, val = m.groups()
            if not indent:
                block = key
                if key == "zone":
                    zone = int(val)
                elif key == "quarry":
                    quarry = {"id": int(val)} if val else {}
            elif block == "quarry" and len(indent) == 2:
                quarry[key] = value(val)
            elif item:
                riddles.append({key: value(val)})
            elif len(indent) == 4 and riddles:
                riddles[-1][key] = value(val)
        yield f, zone, riddles, quarry


# ── placing on a zone's map ────────────────────────────────────────────────
def main():
    g = {"__file__": os.path.join(ROOT, "scripts", "creatures.py")}
    exec(open(g["__file__"]).read().split("\nif __name__")[0], g)
    sql = g["sql_text"]()

    def tab(name):
        cols = g["columns"](sql, name)
        return [dict(zip(cols, r)) for r in g["rows"](sql, name)]

    otypes = {int(d["entry"]): int(d["type"]) for d in tab("gameobject_template")}
    names = {("object", int(d["entry"])): d["name"] for d in tab("gameobject_template")}
    names.update({("creature", int(d["Entry"])): d["Name"] for d in tab("creature_template")})
    objects = collections.defaultdict(list)
    for d in tab("gameobject"):
        objects[int(d["id"])].append((int(d["map"]), float(d["position_x"]), float(d["position_y"])))
    creatures = collections.defaultdict(list)
    for d in tab("creature"):
        creatures[int(d["id"])].append((int(d["map"]), float(d["position_x"]), float(d["position_y"]), d))
    # the spawns a creature may take (a spawn's other entries, its group's), as scripts/rare_zones.py
    spawn = {d["guid"]: d for d in tab("creature")}
    takes = collections.defaultdict(set)
    for d in tab("creature_spawn_entry"):
        takes[int(d["entry"])].add(d["guid"])
    group = collections.defaultdict(set)
    for d in tab("spawn_group_entry"):
        group[d["Id"]].add(int(d["Entry"]))
    for d in tab("spawn_group_spawn"):
        for e in group[d["Id"]]:
            takes[e].add(d["Guid"])
    for c, rows in list(creatures.items()):
        takes[c] |= {d["guid"] for *_, d in rows}
    # the paths creatures walk: a spawn's own (by guid), else its kind's (by entry)
    paths = collections.defaultdict(list)
    for t, key in (("creature_movement", "Id"), ("creature_movement_template", "Entry")):
        for d in tab(t):
            paths[(t, d[key])].append((float(d["PositionX"]), float(d["PositionY"])))
    graves = {int(d["id"]): (int(d["map"]), float(d["x"]), float(d["y"])) for d in tab("world_safe_locs")}

    def path(d):
        """The points a spawn walks through (world x, y), if it walks a path."""
        if d["MovementType"] != "2":
            return []
        return paths[("creature_movement", d["guid"])] or paths[("creature_movement_template", d["id"])]

    def wanders(d):
        """How far a spawn goes from where it stands, in yards."""
        if d["MovementType"] == "1":
            return float(d["spawndist"])
        x, y = float(d["position_x"]), float(d["position_y"])
        return max((((a - x) ** 2 + (b - y) ** 2) ** 0.5 for a, b in path(d)), default=0)

    assignments = collections.defaultdict(list)
    for a in table("UiMapAssignment"):
        assignments[int(a["UiMapID"])].append(a)
    areas = {int(r["ID"]): r for r in table("AreaTable")}
    children = collections.defaultdict(list)
    for i, r in areas.items():
        children[int(r["ParentAreaID"])].append(i)
    triggers = {int(r["ID"]): r for r in table("AreaTrigger")}
    overlays = overlay_centres(areas)

    def on(uimap, m, x, y):
        """A world position on the zone's map, in percent (None if off it)."""
        for a in assignments[uimap]:
            if int(a["MapID"]) != m:
                continue
            x0, y0, x1, y1 = (float(a[k]) for k in ("Region_0", "Region_1", "Region_3", "Region_4"))
            if x0 <= x <= x1 and y0 <= y <= y1:
                u0, v0, u1, v1 = (float(a[k]) for k in ("UiMin_0", "UiMin_1", "UiMax_0", "UiMax_1"))
                return (u0 + (u1 - u0) * (y1 - y) / (y1 - y0)) * 100, (v0 + (v1 - v0) * (x1 - x) / (x1 - x0)) * 100

    def size(uimap):
        """The zone's map in yards: width, height."""
        a = assignments[uimap][0]
        x0, y0, x1, y1 = (float(a[k]) for k in ("Region_0", "Region_1", "Region_3", "Region_4"))
        u0, v0, u1, v1 = (float(a[k]) for k in ("UiMin_0", "UiMin_1", "UiMax_0", "UiMax_1"))
        return (y1 - y0) / (u1 - u0), (x1 - x0) / (v1 - v0)

    def zone_area(uimap):
        ids = collections.Counter(int(a["AreaID"]) for a in assignments[uimap] if int(a["AreaID"]))
        return ids.most_common(1)[0][0]

    def under(area):
        out, todo = [], list(children[area])
        while todo:
            i = todo.pop()
            out.append(i)
            todo += children[i]
        return sorted(out)

    def agreed(kind, id, uimap, points, tolerance=AGREE):
        """The dump's points on the zone's map that Wowhead places in the zone
        too (the maps overlap at their edges, a city lies inside its zone's
        rectangle: a point of the dump alone is another place's)."""
        theirs = wowhead(kind, id, zone_area(uimap)) or []
        return [(x, y) for x, y in points if any(abs(x - a) <= tolerance and abs(y - b) <= tolerance for a, b in theirs)]

    def haunts(uimap, id, w):
        """A quarry's haunts on the zone's map: [[x, y, r]] (percent of the width).
        A spawn that walks a path haunts its path: each of its points is one."""
        found = []
        for g in sorted(takes[id]):
            d = spawn[g]
            p = on(uimap, int(d["map"]), float(d["position_x"]), float(d["position_y"]))
            if p:
                found.append((p, d))
        kept = set(agreed("npc", id, uimap, [p for p, _ in found], AGREE_HAUNT))
        points = []
        for p, d in found:
            if p not in kept:
                continue
            walk = [q for q in (on(uimap, int(d["map"]), a, b) for a, b in path(d)) if q]
            points += [(p, 0)] + [(q, 0) for q in walk] if walk else [(p, wanders(d))]
        out = []
        for p, far in points:
            for c in out:
                cx, cy = sum(q[0] for q, _ in c) / len(c), sum(q[1] for q, _ in c) / len(c)
                if ((p[0] - cx) ** 2 + ((p[1] - cy) * ASPECT) ** 2) ** 0.5 <= HAUNT:
                    c.append((p, far))
                    break
            else:
                out.append([(p, far)])
        circles = []
        for c in out:
            cx, cy = sum(q[0] for q, _ in c) / len(c), sum(q[1] for q, _ in c) / len(c)
            reach = max(((q[0] - cx) ** 2 + ((q[1] - cy) * ASPECT) ** 2) ** 0.5 + far / w * 100 for q, far in c)
            circles.append([round(cx, 1), round(cy, 1), round(max(HAUNT_MIN, reach + 1.5), 1)])
        return circles

    errors, zones, riddles, quarries = [], {}, {}, {}
    for f, uimap, rs, quarry in riddle_files():
        if uimap not in assignments:
            errors.append(f"{f}: no uiMap {uimap}")
            continue
        w, h = size(uimap)
        mine = under(zone_area(uimap))
        zones[str(uimap)] = {"w": round(w, 1), "h": round(h, 1), "areas": mine}
        if quarry:
            id = quarry.get("id")
            spots = id and haunts(uimap, id, w)
            if not spots:
                errors.append(f"{f}: quarry {id}: no spawn on the map that the dump and Wowhead agree on")
            else:
                quarries[str(uimap)] = {"id": id, "name": names.get(("creature", id)), "haunts": spots}
        for r in rs:
            id, out, where = r["id"], {"zone": uimap}, f"{f}: {r['id']}"
            # what it was resolved from: the build refuses a file changed since
            kind = next((k for k in ("object", "creature", "trigger", "area") if k in r), None)
            out["of"] = f"{kind}:{r[kind]}" if kind else None
            if "anchor" in r:
                out["of"] += " " + ",".join(f"{k}:{v}" for k, v in r["anchor"].items())
            if r.get("hint_area"):
                out["hint"] = [r["hint_area"][k] for k in ("x", "y", "r")]
            # its name, once solved: the file's, else the game's (the object's,
            # the creature's, the area's)
            out["name"] = r.get("name") or names.get((kind, r.get(kind))) or (r["area"] if kind == "area" else None)
            if not out["name"]:
                errors.append(f"{where}: no name: give the riddle's own (name:)")
            if "object" in r:
                points = agreed("object", r["object"], uimap, [p for p in (on(uimap, *s) for s in objects[r["object"]]) if p])
                if not points:
                    errors.append(f"{where}: object {r['object']}: no spawn on the map that the dump and Wowhead agree on")
                    continue
                out.update(spots=points, r=NEAR)
                # a reading: a text object, which opens the game's reader (a
                # quest's poster opens the quest window), and its own title
                if "reading" in r and (otypes.get(r["object"]) != 9 or names[("object", r["object"])] != r["reading"]):
                    errors.append(f"{where}: reading: object {r['object']} is no text object titled {r['reading']!r}")
            elif "creature" in r:
                spawns = [(on(uimap, *s[:3]), s[3]) for s in creatures[r["creature"]]]
                spawns = [(p, d) for p, d in spawns if p and agreed("npc", r["creature"], uimap, [p])]
                if len(spawns) != 1:
                    errors.append(f"{where}: creature {r['creature']}: {len(spawns)} spawns on the map that the dump and Wowhead agree on, not one")
                    continue
                (p, d), = spawns
                out["npc"] = r["creature"]
                far = wanders(d)
                if far <= NEAR:
                    out.update(spots=[p], r=NEAR + math.ceil(far))
                points = [p]
            elif "trigger" in r:
                t = triggers.get(r["trigger"])
                p = t and on(uimap, int(t["ContinentID"]), float(t["Pos_0"]), float(t["Pos_1"]))
                if not p:
                    errors.append(f"{where}: trigger {r['trigger']} is not on the map")
                    continue
                out.update(spots=[p], r=max(NEAR, round(float(t["Radius"]))))
            elif "area" in r:
                ids = [i for i in mine if areas[i]["AreaName_lang"].strip() == r["area"]]
                if not ids:
                    errors.append(f"{where}: no sub-area {r['area']!r} in this zone")
                    continue
                out["areas"] = ids
                if "anchor" in r:
                    (kind, n), = r["anchor"].items()
                    found = {"grave": [graves[n]] if n in graves else [], "object": objects[n], "creature": creatures[n]}.get(kind, [])
                    points = [p for p in (on(uimap, *s[:3]) for s in found) if p][:1]
                    if not points:
                        errors.append(f"{where}: the anchor {r['anchor']} is not on the map")
                        continue
                else:
                    points = [overlays[i] for i in ids if i in overlays][:1]
                    if not points:
                        errors.append(f"{where}: the area has no overlay on the map: give an anchor inside it")
                        continue
            else:
                errors.append(f"{where}: no spot (object, creature, trigger or area)")
                continue
            if "reading" in r and "object" not in r:
                errors.append(f"{where}: a reading is an object's")
            if "spots" in out:
                points = out["spots"]
            ha = r.get("hint_area")
            inside = ha and [(x, y) for x, y in points if (x - ha["x"]) ** 2 + ((y - ha["y"]) * ASPECT) ** 2 <= ha["r"] ** 2]
            if not ha:
                errors.append(f"{where}: no hint_area")
            elif not inside:
                errors.append(f"{where}: the hint circle {ha} doesn't hold the spot {points[0]}")
            elif "spots" in out:
                # the copies of a book elsewhere in the zone are other riddles' (or none)
                out["spots"] = [[round(x, 2), round(y, 2)] for x, y in inside]
            riddles[id] = out

    if errors:
        print("\n".join(f"x {e}" for e in errors))
        sys.exit(1)
    with open(OUT, "w") as f:
        f.write("{\n")
        f.write(' "zones": {\n' + ",\n".join(f'  "{k}": {json.dumps(v)}' for k, v in sorted(zones.items(), key=lambda kv: int(kv[0]))) + "\n },\n")
        f.write(' "riddles": {\n' + ",\n".join(f'  "{k}": {json.dumps(v)}' for k, v in sorted(riddles.items())) + "\n },\n")
        f.write(' "quarries": {\n' + ",\n".join(f'  "{k}": {json.dumps(v)}' for k, v in sorted(quarries.items(), key=lambda kv: int(kv[0]))) + "\n },\n")
        f.write(f' "emotes": {json.dumps(sorted(r["Name"] for r in table("EmotesText")))}\n}}\n')
    kinds = collections.Counter("areas" in v and "area" or "spot" for v in riddles.values())
    print(f"{len(riddles)} riddles in {len(zones)} zones ({kinds['spot']} spots, {kinds['area']} areas), {len(quarries)} quarries -> data/expeditions.json")


def overlay_centres(areas):
    """A sub-area's centre on its zone's map, in percent, from the map overlay
    that names it (WorldMapOverlay on the map art, 1002 by 668)."""
    out = {}
    for o in table("WorldMapOverlay"):
        t, b, l, r = (float(o[k]) for k in ("HitRectTop", "HitRectBottom", "HitRectLeft", "HitRectRight"))
        if b <= t or r <= l:
            l, t = float(o["OffsetX"]), float(o["OffsetY"])
            r, b = l + float(o["TextureWidth"]), t + float(o["TextureHeight"])
        for k in ("AreaID_0", "AreaID_1", "AreaID_2", "AreaID_3"):
            a = int(o[k])
            if a and a in areas:
                out.setdefault(a, ((l + r) / 2 / 10.02, (t + b) / 2 / 6.68))
    return out


if __name__ == "__main__":
    main()
