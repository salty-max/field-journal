#!/usr/bin/env python3
"""Where each riddle of expeditions/*.md is solved: data/expeditions.json.

  python3 scripts/expeditions.py

A riddle names its spot by what the game's data pins down:

  object: <id>     a game object of the pinned CMaNGOS dump (scripts/creatures.py):
                   every spawn of it on the zone's map, each checked against
                   Wowhead's (nether.wowhead.com's tooltip, cached in
                   .cache/wowhead/): within 0.6% of one of its points
  creature: <id>   a creature: its spawns inside the hint circle, Wowhead's
                   alike; found where it stands still (no further than 10
                   yards from its spawn: the dump's wandering radius or its
                   path), and, one of a kind, by targeting it near (anywhere
                   it walks); `found: target` for one found only by talking
                   to it (in a town, where passing by would solve it), or
                   one that walks: its path crossing the hint circle will do
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
spawn groups) that Wowhead places there too, and the places Wowhead's
players met it, gathered into its haunts: the points within HAUNT percent of
each other, each a circle around them wide enough for its wandering (the
dump's radius or path), HAUNT_MIN at least.

A zone of Forever's own (`client: forever`, Zephras Isle) is placed on
Forever's client tables (wago.tools, the beta build zones.py pins, cached in
.cache/forever/), its creatures from the QuestieDB traces (Questie's in-game
recorder of the beta, pinned; percent of the zone's map), each point kept only
where Wowhead's Forever database (its tooltip) places the creature too: a
creature or a sub-area, and a quarry the data doesn't know (its name, level,
rank and model given in the file).

Then the riddles are checked as a reader meets them:

  - never a kill: a creature asked for is no foe of the side that may solve
    it (the client's FactionTemplate; a riddle of one side's says so:
    `faction:`, on any tier);
  - never the same deed twice in a zone, for either side's reader: one
    arrival, one reading, one creature found by speaking to it at most, and
    no gesture two riddles both accept;
  - never on Forever's own new quests' road (its quests no Classic one is:
    AllTheThings' Forever database and QuestieDB's traces, both pinned): no
    new quest gives, ends or asks for the riddle's creature or object, none
    names it in its title or its objectives, and none sends a player (its
    giver, its ender, what it asks for, by either source's points) within
    FOREVER_NEAR of a riddle solved by arriving.

Anything that fails is printed and nothing is written.
"""
import collections, csv, json, math, os, re, sys, time, urllib.error, urllib.request

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
EXPEDITIONS = os.path.join(ROOT, "expeditions")
OUT = os.path.join(ROOT, "data", "expeditions.json")
ERA = os.path.join(ROOT, ".cache", "era")
FOREVER = os.path.join(ROOT, ".cache", "forever")
WOWHEAD = os.path.join(ROOT, ".cache", "wowhead")
WAGO = {"classic": "https://wago.tools/db2/{}/csv?product=wow_classic_era",
        "forever": "https://wago.tools/db2/{}/csv?product=wow_classic_beta&build=1.60.1.70291"}
QUESTIEDB_COMMIT = "7e87203312ef7ba309b96361fed90e492e145cff"
QUESTIEDB = f"https://raw.githubusercontent.com/Questie/QuestieDB/{QUESTIEDB_COMMIT}/src/corrections/Forever/traces/forever{{}}Traces.lua"
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
# Wowhead's sightings of a quarry count within this of a spawn the two agree
# on (further out, they are another place's, or noise).
ROAM = 10
# AllTheThings' Forever database, pinned (as Hearthtale's scripts/forever-data.ts).
ATT_REPO, ATT_COMMIT = "ATTWoWAddon/AllTheThings", "a21caf2a7ec636785505a7f4e7e4311d16ce28af"
# A new quest of Forever's this near an arrival's spot (percent of the map's
# width) sends its players through it.
FOREVER_NEAR = 4


def table(name, client="classic"):
    folder = FOREVER if client == "forever" else ERA
    path = os.path.join(folder, f"{name}.csv")
    if not os.path.exists(path):
        os.makedirs(folder, exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(WAGO[client].format(name), headers=UA), timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    return list(csv.DictReader(open(path, encoding="utf-8")))


def traces(kind):
    """The QuestieDB traces of Forever's creatures (kind "Npc") or objects:
    {id: {"name", "spawns": {zone area id: [(x, y)]}}}, x and y in percent of
    the zone's map."""
    path = os.path.join(FOREVER, f"questiedb-{kind.lower()}-{QUESTIEDB_COMMIT[:12]}.lua")
    if not os.path.exists(path):
        os.makedirs(FOREVER, exist_ok=True)
        with urllib.request.urlopen(urllib.request.Request(QUESTIEDB.format(kind), headers=UA), timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    out = {}
    for m in re.finditer(r"^        \[(\d+)\] = \{\n(.*?)^        \},", open(path, encoding="utf-8").read(), re.S | re.M):
        body = m.group(2)
        name = re.search(r'\.name\] = "((?:[^"\\]|\\.)*)"', body)
        spawns = re.search(r"\.spawns\] = \{(.*)\},\n", body)
        zones = {}
        for z, pts in re.findall(r"\[(\d+)\]=\{((?:\{[\d.]+,[\d.]+\},?)*)\}", spawns.group(1) if spawns else ""):
            zones[int(z)] = [(float(x), float(y)) for x, y in re.findall(r"\{([\d.]+),([\d.]+)\}", pts)]
        out[int(m.group(1))] = {"name": name and name.group(1).replace('\\"', '"'), "spawns": zones}
    return out


def forever_quests(classic):
    """Forever's own new quests (none of Classic's ids): {id: {"text": its
    title and objectives, lower case, "ids": the creatures, objects and items
    that give, end or are asked for by it, "points": [(map name, x, y)] where
    AllTheThings sends its players}}. From QuestieDB's traces and
    AllTheThings' Forever zones (cached in .cache/forever/)."""
    def fetch(url, path):
        if not os.path.exists(path):
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=180) as r, open(path, "wb") as f:
                f.write(r.read())
        return open(path, encoding="utf-8").read()

    out = collections.defaultdict(lambda: {"text": "", "ids": set(), "points": []})
    src = fetch(QUESTIEDB.format("Quest"), os.path.join(FOREVER, f"questiedb-quest-{QUESTIEDB_COMMIT[:12]}.lua"))
    for m in re.finditer(r"^        \[(\d+)\] = \{\n(.*?)^        \},", src, re.S | re.M):
        q = int(m.group(1))
        if q in classic:
            continue
        body = m.group(2)
        for key in ("name", "objectivesText"):
            for t in re.findall(r"\." + key + r'\] = \{?((?:"(?:[^"\\]|\\.)*",?\s*)+)', body):
                out[q]["text"] += " " + " ".join(re.findall(r'"((?:[^"\\]|\\.)*)"', t)).lower()
        for key in ("startedBy_add", "finishedBy_add", "objectives"):
            v = re.search(r"\." + key + r"\] = (.*),\n", body)
            if v:
                out[q]["ids"] |= {int(n) for n in re.findall(r"\b(\d{2,7})\b", v.group(1))}
    for kind in ("Npc", "Object"):
        src = fetch(QUESTIEDB.format(kind), os.path.join(FOREVER, f"questiedb-{kind.lower()}-{QUESTIEDB_COMMIT[:12]}.lua"))
        for m in re.finditer(r"^        \[(\d+)\] = \{\n(.*?)^        \},", src, re.S | re.M):
            for v in re.findall(r"quest(?:Starts|Ends)_add\] = \{([\d,\s]*)\}", m.group(2)):
                for q in re.findall(r"\d+", v):
                    if int(q) not in classic:
                        out[int(q)]["ids"].add(int(m.group(1)))
    tree = json.loads(fetch(f"https://api.github.com/repos/{ATT_REPO}/git/trees/{ATT_COMMIT}?recursive=1",
                            os.path.join(FOREVER, f"att-tree-{ATT_COMMIT[:12]}.json")))
    for f in tree["tree"]:
        if f["type"] != "blob" or not re.match(r"^\.contrib/\.db/forever/zones/.*\.lua$", f["path"]):
            continue
        rel = f["path"][len(".contrib/.db/forever/"):]
        url = f"https://raw.githubusercontent.com/{ATT_REPO}/{ATT_COMMIT}/" + "/".join(urllib.request.quote(x) for x in f["path"].split("/"))
        src = fetch(url, os.path.join(FOREVER, "att", rel))
        parts = re.split(r"\bq\((\d+), \{", src)
        for k in range(1, len(parts), 2):
            q, body = int(parts[k]), parts[k + 1]
            if q in classic:
                continue
            # (a quest's body ends where the next begins: its givers, providers, coordinates)
            out[q]["ids"] |= {int(x) for v in re.findall(r'\["qgs?"\] = \{?\s*([\d, ]+)', body) for x in re.findall(r"\d+", v)}
            out[q]["ids"] |= {int(x) for x in re.findall(r'\{ "[noi]", (\d+) \}', body)}
            out[q]["points"] += [(c, float(a), float(b)) for a, b, c in re.findall(r"\{ ([\d.]+), ([\d.]+), MAP\.(\w+) \}", body)]
    return out


def wowhead(kind, id, area, site="classic"):
    """Wowhead's points of an object or a creature in a zone (its area id), on
    Classic or Forever (site): None when Wowhead doesn't place it there."""
    pre = "" if site == "classic" else f"{site}-"
    page = os.path.join(WOWHEAD, f"{pre}page-{kind}-{id}.html")
    if os.path.exists(page):
        m = re.search(r"g_mapperData = (\{.*?\});", open(page, encoding="utf-8").read())
        floors = json.loads(m.group(1)).get(str(area)) if m else None
        return [tuple(p) for f in floors for p in f["coords"]] if floors else None
    path = os.path.join(WOWHEAD, f"{pre}{kind}-{id}.json")
    if not os.path.exists(path):
        os.makedirs(WOWHEAD, exist_ok=True)
        url = f"https://nether.wowhead.com/{site}/tooltip/{kind}/{id}"
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r:
                data = r.read()
        except urllib.error.HTTPError as e:
            if e.code != 404:
                raise
            data = b"{}"  # Wowhead knows no such thing: no second source
        with open(path, "wb") as f:
            f.write(data)
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
        zone, client, riddles, quarry, block = None, "both", [], None, None
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
                elif key == "client":
                    client = val
                elif key == "quarry":
                    quarry = {"id": int(val)} if val else {}
            elif block == "quarry" and len(indent) == 2:
                quarry[key] = value(val)
            elif item:
                riddles.append({key: value(val)})
            elif len(indent) == 4 and riddles:
                riddles[-1][key] = value(val)
        yield f, zone, client, riddles, quarry


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
        # where players met it, as Wowhead records them (a creature that roams
        # further than its spawn says), near a spawn the two agree on
        near = lambda p: any(((p[0] - q[0]) ** 2 + ((p[1] - q[1]) * ASPECT) ** 2) ** 0.5 <= ROAM for q in kept)
        points = [(tuple(p), 0) for p in (wowhead("npc", id, zone_area(uimap)) or []) if near(p)]
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
    placed = []  # (file, uiMap, riddle, its points on the map), for the checks below
    for f, uimap, client, rs, quarry in riddle_files():
        if client == "forever":
            forever_zone(f, uimap, rs, quarry, errors, zones, riddles, quarries)
            continue
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
            if r.get("found"):
                out["of"] += f" found:{r['found']}"
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
                # its spawns inside the hint circle (a kind standing in more
                # than one place, the Unseen: those the riddle means), the
                # dump's and Wowhead's alike
                ha = r.get("hint_area") or {}
                held = lambda p: ha and (p[0] - ha["x"]) ** 2 + ((p[1] - ha["y"]) * ASPECT) ** 2 <= ha["r"] ** 2
                # one found by targeting may be met anywhere it walks: its path counts
                walks = lambda d: [q for q in (on(uimap, int(d["map"]), x, y) for x, y in path(d)) if q] if r.get("found") == "target" else []
                found = [(on(uimap, *s[:3]), s[3]) for s in creatures[r["creature"]]]
                # one found by targeting is placed only to the hint's measure: the haunts' tolerance
                tol = AGREE_HAUNT if r.get("found") == "target" else AGREE
                found = [(p, d) for p, d in found if p and agreed("npc", r["creature"], uimap, [p] + walks(d), tol)]
                spawns = [(p, d) for p, d in found if held(p) or any(held(q) for q in walks(d))]
                if not spawns:
                    errors.append(f"{where}: creature {r['creature']}: no spawn inside the hint circle (nor a path through it, found by targeting) that the dump and Wowhead agree on")
                    continue
                # found by targeting it near: one of a kind, or one only so found
                if len(found) == 1 or r.get("found") == "target":
                    out["npc"] = r["creature"]
                still = [(p, wanders(d)) for p, d in spawns if wanders(d) <= NEAR]
                if r.get("found") != "target" and still:
                    out.update(spots=[p for p, _ in still], r=NEAR + math.ceil(max(far for _, far in still)))
                points = [q for p, d in spawns for q in ([p] if held(p) else [q for q in walks(d) if held(q)])]
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
            placed.append((f, uimap, r, inside or points))

    # ── as a reader meets them ──────────────────────────────────────────────
    ct = {int(d["Entry"]): d for d in tab("creature_template")}
    ft = {int(d["ID"]): d for d in table("FactionTemplate")}
    SIDES = {"alliance": (2, {469, 72, 47, 54, 69, 1}), "horde": (4, {67, 76, 81, 68, 530, 2})}

    def hostile(template, side):
        """A creature of this faction template attacks the side's players."""
        t = ft.get(template)
        if not t:
            return False
        group, factions = SIDES[side]
        enemies = {int(t[k]) for k in t if k.startswith("Enemies_")}
        friends = {int(t[k]) for k in t if k.startswith("Friend_")}
        if friends & factions:
            return False
        return bool(int(t["EnemyGroup"]) & (1 | group)) or bool(enemies & factions)

    def deed(r):
        if "reading" in r:
            return "reading"
        if r.get("gestures"):
            return "gesture"
        return "speaking" if r.get("found") == "target" else "arrival"

    homes = {f: (re.search(r"^home: (\w+)", open(os.path.join(EXPEDITIONS, f)).read(), re.M) or [None, None])[1] for f, *_ in placed}
    for f, uimap, r, _ in placed:
        sides = [r["faction"]] if r.get("faction") else ([homes[f]] if homes[f] else list(SIDES))
        c = "creature" in r and ct.get(int(r["creature"]))
        for side in sides:
            if c and hostile(int(c["Faction"]), side):
                errors.append(f"{f}: {r['id']}: {c['Name']} attacks the {side}'s players: a riddle never asks for a kill (or give it to the other side: faction:)")
    files = list(riddle_files())
    for f, *_ in files:
        if f not in homes:
            homes[f] = (re.search(r"^home: (\w+)", open(os.path.join(EXPEDITIONS, f)).read(), re.M) or [None, None])[1]
    for f, uimap, client, rs, _ in files:
        for side in SIDES:
            mine = [r for r in rs if (not homes[f] or homes[f] == side) and r.get("faction", side) == side]
            for kind in ("arrival", "reading", "speaking"):
                same = [r["id"] for r in mine if deed(r) == kind]
                if len(same) > 1:
                    errors.append(f"{f}: the {side}'s reader meets more than one {kind} here: {', '.join(same)}")
            asked = collections.defaultdict(list)
            for r in mine:
                for token in r.get("gestures") or []:
                    asked[token].append(r["id"])
            for token, ids in sorted(asked.items()):
                if len(ids) > 1:
                    errors.append(f"{f}: the {side}'s reader is asked {token} twice here: {', '.join(ids)}")

    classic = {int(d["entry"]) for d in tab("quest_template")}
    new = forever_quests(classic)
    norm = lambda x: re.sub(r"[^a-z]", "", x.lower())
    zone_names = {int(z["ID"]): z["Name_lang"] for z in table("UiMap")}
    npcs, objs = traces("Npc"), traces("Object")
    # (Forever's own zones: their riddles' creatures and objects, against its quests too)
    own = [(f, uimap, r, []) for f, uimap, client, rs, _ in files if client == "forever" for r in rs]
    for f, uimap, r, points in placed + own:
        where = f"{f}: {r['id']}"
        subject = [int(r[k]) for k in ("creature", "object") if k in r]
        subject += [int(v) for k, v in (r.get("anchor") or {}).items() if k in ("creature", "object")]
        named = {n for n in [r.get("name"), r.get("area"), r.get("reading")] + [names.get(("creature", i)) or names.get(("object", i)) or (npcs.get(i) or {}).get("name") for i in subject] if n and len(n) > 4}
        for q, d in sorted(new.items()):
            hit = [i for i in subject if i in d["ids"]]
            if hit:
                errors.append(f"{where}: Forever's new quest {q} gives, ends or asks for {hit[0]}")
            said = [n for n in named if re.search(r"\b" + re.escape(n.lower()) + r"\b", d["text"])]
            if said:
                errors.append(f"{where}: Forever's new quest {q} names {said[0]!r}")
            if deed(r) != "arrival" or not points:
                continue
            near = lambda x, y: any(((x - a) ** 2 + ((y - b) * ASPECT) ** 2) ** 0.5 <= FOREVER_NEAR for a, b in points)
            mine = [(x, y) for m, x, y in d["points"] if norm(m) == norm(zone_names.get(uimap, ""))]
            area = zone_area(uimap)
            for i in d["ids"]:
                for t in (npcs.get(i), objs.get(i)):
                    mine += (t or {}).get("spawns", {}).get(area, [])
            close = [(x, y) for x, y in mine if near(x, y)]
            if close:
                errors.append(f"{where}: arriving here is Forever's new quest {q}'s road (a point at {close[0][0]:.1f}, {close[0][1]:.1f})")

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


def overlay_centres(areas, client="classic"):
    """A sub-area's centre on its zone's map, in percent, from the map overlay
    that names it (WorldMapOverlay on the map art, 1002 by 668)."""
    out = {}
    for o in table("WorldMapOverlay", client):
        t, b, l, r = (float(o[k]) for k in ("HitRectTop", "HitRectBottom", "HitRectLeft", "HitRectRight"))
        if b <= t or r <= l:
            l, t = float(o["OffsetX"]), float(o["OffsetY"])
            r, b = l + float(o["TextureWidth"]), t + float(o["TextureHeight"])
        for k in ("AreaID_0", "AreaID_1", "AreaID_2", "AreaID_3"):
            a = int(o[k])
            if a and a in areas:
                out.setdefault(a, ((l + r) / 2 / 10.02, (t + b) / 2 / 6.68))
    return out


def forever_zone(f, uimap, rs, quarry, errors, zones, riddles, quarries):
    """A zone of Forever's own: its map from Forever's client tables, its
    creatures' points from the QuestieDB traces, each kept only where Wowhead's
    Forever database places the creature too (they share the zone's map)."""
    assignments = [a for a in table("UiMapAssignment", "forever") if int(a["UiMapID"]) == uimap]
    if not assignments:
        errors.append(f"{f}: no uiMap {uimap} on Forever")
        return
    areas = {int(r["ID"]): r for r in table("AreaTable", "forever")}
    children = collections.defaultdict(list)
    for i, r in areas.items():
        children[int(r["ParentAreaID"])].append(i)
    a = assignments[0]
    x0, y0, x1, y1 = (float(a[k]) for k in ("Region_0", "Region_1", "Region_3", "Region_4"))
    u0, v0, u1, v1 = (float(a[k]) for k in ("UiMin_0", "UiMin_1", "UiMax_0", "UiMax_1"))
    w, h = (y1 - y0) / (u1 - u0), (x1 - x0) / (v1 - v0)
    zone = collections.Counter(int(a["AreaID"]) for a in assignments if int(a["AreaID"])).most_common(1)[0][0]
    mine, todo = [], list(children[zone])
    while todo:
        i = todo.pop()
        mine.append(i)
        todo += children[i]
    mine.sort()
    zones[str(uimap)] = {"w": round(w, 1), "h": round(h, 1), "areas": mine}
    npcs = traces("Npc")
    overlays = overlay_centres(areas, "forever")

    def agreed(id, tolerance):
        """The traces' points of a creature that Wowhead's Forever places too, and Wowhead's."""
        theirs = wowhead("npc", id, zone, "forever") or []
        ours = (npcs.get(id) or {}).get("spawns", {}).get(zone, [])
        return [p for p in ours if any(abs(p[0] - a) <= tolerance and abs(p[1] - b) <= tolerance for a, b in theirs)], theirs

    yards = lambda p, q: (((p[0] - q[0]) / 100 * w) ** 2 + ((p[1] - q[1]) / 100 * h) ** 2) ** 0.5
    if quarry:
        id = quarry.get("id")
        kept, theirs = agreed(id, AGREE_HAUNT) if id else ([], [])
        near = lambda p: any(((p[0] - q[0]) ** 2 + ((p[1] - q[1]) * ASPECT) ** 2) ** 0.5 <= ROAM for q in kept)
        circles = []
        for p in kept + [p for p in theirs if near(p)]:
            for c in circles:
                cx, cy = sum(q[0] for q in c) / len(c), sum(q[1] for q in c) / len(c)
                if ((p[0] - cx) ** 2 + ((p[1] - cy) * ASPECT) ** 2) ** 0.5 <= HAUNT:
                    c.append(p)
                    break
            else:
                circles.append([p])
        haunts = []
        for c in circles:
            cx, cy = sum(q[0] for q in c) / len(c), sum(q[1] for q in c) / len(c)
            reach = max(((q[0] - cx) ** 2 + ((q[1] - cy) * ASPECT) ** 2) ** 0.5 for q in c)
            haunts.append([round(cx, 1), round(cy, 1), round(max(HAUNT_MIN, reach + 1.5), 1)])
        if not haunts:
            errors.append(f"{f}: quarry {id}: no point the traces and Wowhead's Forever agree on")
        else:
            quarries[str(uimap)] = {"id": id, "name": quarry.get("name") or (npcs.get(id) or {}).get("name"), "haunts": haunts}
    for r in rs:
        id, out, where = r["id"], {"zone": uimap}, f"{f}: {r['id']}"
        kind = next((k for k in ("object", "creature", "trigger", "area") if k in r), None)
        out["of"] = f"{kind}:{r[kind]}" if kind else None
        if "anchor" in r:
            out["of"] += " " + ",".join(f"{k}:{v}" for k, v in r["anchor"].items())
        if r.get("found"):
            out["of"] += f" found:{r['found']}"
        if r.get("hint_area"):
            out["hint"] = [r["hint_area"][k] for k in ("x", "y", "r")]
        ha = r.get("hint_area") or {}
        held = lambda p: ha and (p[0] - ha["x"]) ** 2 + ((p[1] - ha["y"]) * ASPECT) ** 2 <= ha["r"] ** 2
        if kind == "creature":
            out["name"] = r.get("name") or (npcs.get(r["creature"]) or {}).get("name")
            target = r.get("found") == "target"
            kept, _ = agreed(r["creature"], AGREE_HAUNT if target else AGREE)
            points = [p for p in kept if held(p)]
            if not points:
                errors.append(f"{where}: creature {r['creature']}: no point inside the hint circle that the traces and Wowhead's Forever agree on")
                continue
            if target:
                out["npc"] = r["creature"]
            else:
                # one that stands: its points within NEAR yards of each other
                spread = max(yards(p, q) for p in points for q in points)
                if spread > NEAR:
                    errors.append(f"{where}: creature {r['creature']} is met {spread:.0f} yards apart: found: target")
                    continue
                out.update(spots=points, r=NEAR + math.ceil(spread))
        elif kind == "area":
            out["name"] = r.get("name") or r["area"]
            ids = [i for i in mine if areas[i]["AreaName_lang"].strip() == r["area"]]
            if not ids:
                errors.append(f"{where}: no sub-area {r['area']!r} in this zone")
                continue
            out["areas"] = ids
            points = [overlays[i] for i in ids if i in overlays][:1]
            if not points:
                errors.append(f"{where}: the area has no overlay on Forever's map")
                continue
        else:
            errors.append(f"{where}: a zone of Forever's own takes a creature or an area")
            continue
        if not out["name"]:
            errors.append(f"{where}: no name: give the riddle's own (name:)")
        if not ha:
            errors.append(f"{where}: no hint_area")
        elif not [p for p in points if held(p)]:
            errors.append(f"{where}: the hint circle {ha} doesn't hold the spot {points[0]}")
        if "spots" in out:
            out["spots"] = [[round(x, 2), round(y, 2)] for x, y in out["spots"]]
        riddles[id] = out


if __name__ == "__main__":
    main()
