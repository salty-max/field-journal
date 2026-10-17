#!/usr/bin/env python3
"""Where each riddle of expeditions/*.md is solved: data/expeditions.json.

  python3 scripts/expeditions.py

A riddle names its spot by what the game's data pins down:

  object: <id>     a game object of the CMaNGOS Classic database (wow-data's
                   database, its spawns): every spawn of it on the zone's
                   map, each checked against Wowhead's points (frozen in
                   wow-data: bin/wowhead-points.ts): within 0.6% of one
  creature: <id>   a creature: its spawns inside the hint circle, Wowhead's
                   alike; found where it stands still (no further than 10
                   yards from its spawn: the dump's wandering radius or its
                   path), and, one of a kind, by targeting it near (anywhere
                   it walks); `found: target` for one found only by talking
                   to it (in a town, where passing by would solve it), or
                   one that walks: its path crossing the hint circle will do.
                   `found: place` with `radius: <yards>` anchors a gesture or
                   arrival to fixed surroundings, never a live creature.
                   `found: patrol` requires the nearby creature targeted and
                   a player position along the selected spawn's recorded path
  trigger: <id>    a quest's exploration trigger (the client's AreaTrigger)
  area: <name>     a sub-area of the zone (the client's AreaTable, under the
                   zone's own area): every id of that name

For an object or creature without Wowhead map data, position_check: questie explicitly
checks its Classic world spawn against Questie's independent zone coordinates.
The same agreement tolerance applies. It never uses player observer sightings.

The world positions go on the zone's map by the client's UiMapAssignment
(Classic Era's, wow-data's database: ../wow-data). The hint circle (hint_area,
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

Wowhead's position: its object or NPC page's map data where a browser saved
it (every copy, by zone; its site refuses scripts), else its tooltip (the
zone with the most), frozen in wow-data's data/wowhead/<game>/points.json
(bun ../wow-data/bin/wowhead-points.ts: a new riddle's thing fetched there
first) and read from its databases (spawns of source wowhead).

A zone's quarry (`quarry: { id, sources }`): every spawn of the creature on
the zone's map (its own, or one that may take its place: creature_spawn_entry,
spawn groups) that Wowhead places there too, and the places Wowhead's
players met it, gathered into its haunts: the points within HAUNT percent of
each other, each a circle around them wide enough for its wandering (the
dump's radius or path), HAUNT_MIN at least.

A zone of Forever's own (`client: forever`, Zephras Isle) is placed on
Forever's client tables (wow-data's database), its creatures from Questie's
Forever (its in-game recorder's traces, merged: wow-data's database; percent
of the zone's map), each point kept only
where Wowhead's Forever database (its tooltip) places the creature too: a
creature or a sub-area, and a quarry the data doesn't know (its name, level,
rank and model given in the file).

Then the riddles are checked as a reader meets them:

  - never a kill: a creature asked for is no foe of the side that may solve
    it (the client's FactionTemplate; a riddle of one side's says so:
    `faction:`, on any tier);
  - never the same discovery twice for either side: distinct subjects and
    no overlapping passive arrivals. Different places may share a deed;
  - flag Forever's own new quests' road (its quests no Classic one is:
    Questie's Forever, wow-data's database): no new quest gives, ends or
    asks for the riddle's creature or object (by kind: an item's id is no
    creature's), none names it in its title or its objectives, and none
    sends a player (its giver, its ender, what it asks for, where Questie
    places them) within FOREVER_NEAR of a riddle solved by arriving. An exact
    quest_overlap list and quest_context acknowledge a reviewed separate experience.

Anything that fails is printed and nothing is written.
"""
import collections, json, math, os, re, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import client as client_table, db  # noqa: E402

EXPEDITIONS = os.path.join(ROOT, "expeditions")
OUT = os.path.join(ROOT, "data", "expeditions.json")

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
# A new quest of Forever's this near an arrival's spot (percent of the map's
# width) sends its players through it.
FOREVER_NEAR = 4


def table(name, game="classic"):
    """a client table of the game (wow-data's database, the pinned build)"""
    return client_table(game, name)


def traces(kind):
    """Forever's creatures (kind "Npc") or objects as Questie places them
    (wow-data's Forever database): {id: {"name", "spawns": {zone area id:
    [(x, y)]}}}, x and y in percent of the zone's map."""
    out = {}
    k = "creature" if kind == "Npc" else "object"
    for id, name in db("forever").execute(f"SELECT e.id, n.name FROM {k} e LEFT JOIN name n ON n.kind = '{k}' AND n.id = e.id AND n.locale = 'enUS'"):
        out[id] = {"name": name, "spawns": {}}
    for id, area, x, y in db("forever").execute(
        "SELECT entity_id, area_id, ux, uy FROM spawn WHERE kind = ? AND source = 'questie' AND area_id IS NOT NULL AND ux IS NOT NULL ORDER BY rowid", (k,)
    ):
        if id in out:
            out[id]["spawns"].setdefault(area, []).append((x, y))
    return out


def forever_quests(classic):
    """Forever's own new quests (none of Classic's ids): {id: {"text": its
    title and objectives, lower case, "ids": the creatures, objects and items
    that give, end or are asked for by it, by kind ((kind, id): an item's id
    is no creature's), "points": []}} (wow-data's Forever database: where
    they stand is their spawns, by traces())."""
    out = collections.defaultdict(lambda: {"text": "", "ids": set(), "points": []})
    f = db("forever")
    for (q,) in f.execute("SELECT id FROM quest ORDER BY id"):
        if q in classic:
            continue
        d = out[q]
        for (t,) in f.execute(
            """SELECT name FROM name WHERE kind = 'quest' AND id = ?1 AND locale = 'enUS'
               UNION ALL SELECT text FROM quest_text WHERE quest_id = ?1 AND locale = 'enUS' AND field = 'objectives'
               UNION ALL SELECT text FROM quest_objective WHERE quest_id = ?1 AND text IS NOT NULL""",
            (q,),
        ):
            d["text"] += " " + t.lower()
        d["ids"] |= set(f.execute("SELECT kind, entity_id FROM quest_relation WHERE quest_id = ?", (q,)))
        d["ids"] |= {("item" if k == "source" else k, i) for k, i in f.execute("SELECT kind, target_id FROM quest_objective WHERE quest_id = ? AND target_id > 0", (q,))}
    return out


def wowhead(kind, id, area, game="classic"):
    """Wowhead's points of an object or a creature in a zone (its area id), on
    Classic or Forever: its players' sightings, frozen in wow-data
    (bin/wowhead-points.ts, spawns of source wowhead), in Wowhead's order. None
    when Wowhead doesn't place it there."""
    k = "creature" if kind == "npc" else kind
    rows = db(game).execute(
        "SELECT ux, uy FROM spawn WHERE kind = ? AND entity_id = ? AND area_id = ? AND source = 'wowhead' ORDER BY rowid",
        (k, int(id), area),
    ).fetchall()
    return [(x, y) for x, y in rows] or None


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
    if s in ("true", "false"):
        return s == "true"
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


def reviewed_quests(r, known):
    """An explicit editorial review, not permission to copy a quest objective.
    Exact ids keep a future quest from inheriting an unrelated exemption.
    """
    ids, reason = r.get("quest_overlap", []), r.get("quest_context", "")
    if "quest_overlap" not in r and "quest_context" not in r:
        return set()
    if (not isinstance(ids, list) or not ids
        or any(type(q) is not int or q not in known for q in ids)
        or len(ids) != len(set(ids))
        or not isinstance(reason, str) or not reason.strip()):
        raise ValueError("quest_overlap needs distinct known quest ids and quest_context explaining the separate discovery")
    return set(ids)


def repeated_sites(rs, resolved, width, height):
    """Repeated actions are fine at different discoveries. Reusing a subject,
    or overlapping two passive arrival footprints, is not a new discovery.
    The caller passes only the riddles available to one faction.
    """
    errors, occupied = [], {}
    for r in rs:
        subjects = [(kind, r[kind]) for kind in ("object", "creature", "trigger", "area") if kind in r]
        subjects += [("creature", n) for n in r.get("companions", [])]
        for subject in subjects:
            if subject in occupied:
                errors.append(f"{r['id']} reuses {subject[0]} {subject[1]} from {occupied[subject]}")
            else:
                occupied[subject] = r["id"]
    arrivals = [r for r in rs if not r.get("gestures") and "reading" not in r and r.get("found") != "target"]
    for i, a in enumerate(arrivals):
        sa = resolved.get(a["id"], {})
        for b in arrivals[i + 1:]:
            sb = resolved.get(b["id"], {})
            reach = sa.get("r", 0) + sb.get("r", 0) + 5  # the runtime's five-yard cells
            if any(math.hypot((x - u) * width / 100, (y - v) * height / 100) <= reach
                   for x, y in sa.get("spots", []) for u, v in sb.get("spots", [])):
                errors.append(f"{a['id']} and {b['id']} have overlapping arrival footprints")
    return errors


# ── placing on a zone's map ────────────────────────────────────────────────
def game_names(kind, id, english):
    """An answer's name in every other language, the game's own (Forever's,
    else Classic's, wow-data's databases), when the answer is the thing's own
    name: never a riddle's own ("Roger and Jamin"), which its translations give.
    An area's by the first of its ids."""
    if kind not in ("object", "creature", "area") or not isinstance(id, int):
        return None
    plain = lambda s: s.replace("\u2019", "'").replace("\u201c", '"').replace("\u201d", '"')
    out = {}
    for game in ("forever", "classic"):
        rows = {loc: plain(n) for loc, n in db(game).execute("SELECT locale, name FROM name WHERE kind = ? AND id = ?", (kind, id))}
        if rows.get("enUS") != english:
            continue
        for loc, n in rows.items():
            if loc not in ("enUS", "enGB"):
                out.setdefault(loc, n)
    return dict(sorted(out.items())) or None


def main():
    cdb = db("classic")
    # the Classic database's world (wow-data's database): its objects and
    # creatures, their spawns and the paths they walk
    otypes = {i: kind for i, kind in cdb.execute("SELECT id, type FROM object WHERE data IS NOT NULL")}
    names = {}
    for kind in ("object", "creature"):
        for i, n in cdb.execute(f"SELECT e.id, n.name FROM {kind} e JOIN name n ON n.kind = '{kind}' AND n.id = e.id AND n.locale = 'enUS'"):
            names[(kind, i)] = n
    # a creature's face (its display id), shown once its riddle is solved
    faces = {i: int(m.split(",")[0]) for i, m in cdb.execute("SELECT id, display_ids FROM creature WHERE display_ids IS NOT NULL")}
    objects = collections.defaultdict(list)
    for i, m, x, y in cdb.execute("SELECT entity_id, map_id, x, y FROM spawn WHERE kind = 'object' AND source = 'classicdb' ORDER BY rowid"):
        objects[i].append((m, x, y))
    creatures, spawn = collections.defaultdict(list), {}
    for guid, i, m, x, y, move, dist in cdb.execute(
        """SELECT spawn_id, entity_id, map_id, x, y, movement_type, wander_distance FROM spawn
           WHERE kind = 'creature' AND source = 'classicdb' ORDER BY rowid"""
    ):
        spawn[guid] = {"guid": guid, "id": i, "map": m, "position_x": x, "position_y": y, "MovementType": str(move), "spawndist": dist}
        creatures[i].append((m, x, y, spawn[guid]))
    # the spawns a creature may take (a spawn's other entries, its group's), as scripts/rare_zones.py
    takes = collections.defaultdict(set)
    for guid, i in cdb.execute(
        """SELECT spawn_id, entity_id FROM spawn_entry WHERE kind = 'creature'
           UNION SELECT s.spawn_id, e.entity_id FROM spawn_group_spawn s JOIN spawn_group_entry e ON e.group_id = s.group_id
           JOIN spawn_group g ON g.id = s.group_id WHERE g.kind = 'creature'"""
    ):
        takes[i].add(guid)
    for c, rows in list(creatures.items()):
        takes[c] |= {s["guid"] for *_, s in rows}
    # the paths creatures walk: a spawn's own (by guid), else its kind's (by entry)
    paths = collections.defaultdict(list)
    for owner, i, x, y in cdb.execute("SELECT owner, owner_id, x, y FROM path WHERE source = 'classicdb' ORDER BY owner, owner_id, path_id, point"):
        paths[(owner, i)].append((x, y))
    graves = {i: (m, x, y) for i, m, x, y in cdb.execute("SELECT id, map_id, x, y FROM graveyard")}

    def path(d):
        """The points a spawn walks through (world x, y), if it walks a path."""
        if d["MovementType"] != "2":
            return []
        return paths[("spawn", d["guid"])] or paths[("creature", d["id"])]

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

    def agreed(kind, id, uimap, points, tolerance=AGREE, source="wowhead"):
        """The dump's points on the zone's map that Wowhead places in the zone
        too (the maps overlap at their edges, a city lies inside its zone's
        rectangle: a point of the dump alone is another place's)."""
        if source == "questie":
            theirs = list(cdb.execute("SELECT ux, uy FROM spawn WHERE kind=? AND entity_id=? AND area_id=? AND source='questie'",
                                     ("creature" if kind == "npc" else kind, id, zone_area(uimap))))
        else:
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
                if game_names("creature", id, names.get(("creature", id))):
                    quarries[str(uimap)]["names"] = game_names("creature", id, names.get(("creature", id)))
        for r in rs:
            id, out, where = r["id"], {"zone": uimap}, f"{f}: {r['id']}"
            if "position_check" in r and (r["position_check"] != "questie" or not any(k in r for k in ("object", "creature"))):
                errors.append(f"{where}: position_check: questie is for a Classic object or creature's independent map position")
                continue
            if r.get("found") == "place" and (r.get("reading") or r.get("companions")
                or type(r.get("radius")) is not int or not 10 <= r["radius"] <= 100):
                errors.append(f"{where}: found: place needs no reading or companions and a radius of 10 to 100 yards")
                continue
            if r.get("found") == "patrol" and (not r.get("gestures") or r.get("companions")):
                errors.append(f"{where}: found: patrol needs a gesture and no companions")
                continue
            if "indoors" in r and (r["indoors"] is not True or "area" in r):
                errors.append(f"{where}: indoors: true requires a precise place")
                continue
            if r.get("indoors"):
                out["indoors"] = True
            # what it was resolved from: the build refuses a file changed since
            kind = next((k for k in ("object", "creature", "trigger", "area") if k in r), None)
            out["of"] = f"{kind}:{r[kind]}" if kind else None
            if "anchor" in r:
                out["of"] += " " + ",".join(f"{k}:{v}" for k, v in r["anchor"].items())
            if r.get("found"):
                out["of"] += f" found:{r['found']}"
            if r.get("position_check"):
                out["of"] += f" position_check:{r['position_check']}"
            if r.get("hint_area"):
                out["hint"] = [r["hint_area"][k] for k in ("x", "y", "r")]
            # its name, once solved: the file's, else the game's (the object's,
            # the creature's, the area's)
            out["name"] = r.get("name") or names.get((kind, r.get(kind))) or (r["area"] if kind == "area" else None)
            if game_names(kind, r.get(kind), out["name"]):
                out["names"] = game_names(kind, r.get(kind), out["name"])
            if not out["name"]:
                errors.append(f"{where}: no name: give the riddle's own (name:)")
            if "object" in r:
                check_source = r.get("position_check", "wowhead")
                points = agreed("object", r["object"], uimap, [p for p in (on(uimap, *s) for s in objects[r["object"]]) if p], source=check_source)
                if not points:
                    errors.append(f"{where}: object {r['object']}: no spawn on the map that the dump and {check_source} agree on")
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
                follows = r.get("found") in ("target", "patrol")
                walks = lambda d: [q for q in (on(uimap, int(d["map"]), x, y) for x, y in path(d)) if q] if follows else []
                found = [(on(uimap, *s[:3]), s[3]) for s in creatures[r["creature"]]]
                # one found by targeting is placed only to the hint's measure: the haunts' tolerance
                tol = AGREE_HAUNT if follows else AGREE
                check_source = r.get("position_check", "wowhead")
                found = [(p, d) for p, d in found if p and agreed("npc", r["creature"], uimap, [p] + walks(d), tol, source=check_source)]
                spawns = [(p, d) for p, d in found if held(p) or any(held(q) for q in walks(d))]
                if not spawns:
                    errors.append(f"{where}: creature {r['creature']}: no spawn inside the hint circle (nor a path through it, found by targeting) that the dump and Wowhead agree on")
                    continue
                # found by targeting it near: one of a kind, or one only so found
                if r.get("found") != "place" and (len(found) == 1 or follows):
                    out["npc"] = r["creature"]
                if faces.get(int(r["creature"])):
                    out["face"] = faces[int(r["creature"])]
                still = [(p, wanders(d)) for p, d in spawns if wanders(d) <= NEAR]
                if not follows and still:
                    out.update(spots=[p for p, _ in still], r=NEAR + math.ceil(max(far for _, far in still)))
                if r.get("found") == "place":
                    if not still:
                        errors.append(f"{where}: found: place needs a stationary anchor")
                        continue
                    out["r"] = r["radius"]
                if r.get("found") == "patrol":
                    if not any(walks(d) for _, d in spawns):
                        errors.append(f"{where}: found: patrol needs a recorded path")
                        continue
                    # Sample whole path segments, not only waypoint circles.
                    # A player and guard can meet between two distant points.
                    samples = []
                    for p, d in spawns:
                        trail = [p] + walks(d)
                        for a, b in zip(trail, trail[1:] + trail[:1]):
                            distance = math.hypot((a[0] - b[0]) / 100 * w, (a[1] - b[1]) / 100 * h)
                            steps = max(1, math.ceil(distance / NEAR))
                            samples.extend([[a[0] + (b[0] - a[0]) * i / steps, a[1] + (b[1] - a[1]) * i / steps] for i in range(steps)])
                    out.update(spots=samples, r=NEAR + 5, bounded=True)
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
                if game_names("area", min(ids), out["name"]):
                    out["names"] = game_names("area", min(ids), out["name"])
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
    ct = {i: {"Faction": faction or 0, "Name": names.get(("creature", i))} for i, faction in cdb.execute("SELECT id, faction_id FROM creature")}
    ft = {int(d["ID"]): d for d in table("FactionTemplate")}
    SIDES = {"alliance": (2, {469, 72, 47, 54, 69, 1}), "horde": (4, {67, 76, 81, 68, 530, 2})}

    def hostile(template, side, templates=None):
        """A creature of this faction template attacks the side's players."""
        t = (ft if templates is None else templates).get(template)
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
            # A place anchor is never a creature the player must meet.
            # Its fixed position survives death, absence or movement.
            place_only = r.get("found") == "place" and r.get("name") and not r.get("gestures")
            if c and not place_only and hostile(int(c["Faction"]), side):
                errors.append(f"{f}: {r['id']}: {c['Name']} attacks the {side}'s players: a riddle never asks for a kill (or give it to the other side: faction:)")
    files = list(riddle_files())
    # A group named in a verse must not silently mean just its first keeper.
    # Companions are real, non-hostile creatures too, and participate in the
    # same quest-road checks as the primary creature below.
    for f, uimap, client, rs, _ in files:
        for r in rs:
            ids = r.get("companions", [])
            if not ids:
                continue
            if (not isinstance(ids, list) or not r.get("gestures") or not r.get("creature")
                or any(type(i) is not int or i <= 0 or i == r["creature"] for i in ids)
                or len(set(ids)) != len(ids)):
                errors.append(f"{f}: {r['id']}: companions: distinct other creature ids for a gesture's group")
                continue
            sides = [r["faction"]] if r.get("faction") else ([homes.get(f)] if homes.get(f) else list(SIDES))
            for game in (["forever"] if client == "forever" else ["classic", "forever"]):
                templates = {int(t["ID"]): t for t in table("FactionTemplate", game)}
                for i in ids:
                    creature = db(game).execute("SELECT faction_id FROM creature WHERE id = ?", (i,)).fetchone()
                    if not creature:
                        errors.append(f"{f}: {r['id']}: no companion creature {i} in {game}")
                    elif any(hostile(int(creature[0] or 0), side, templates) for side in sides):
                        errors.append(f"{f}: {r['id']}: companion {i} attacks a side that may solve the riddle in {game}")
            if r["id"] in riddles:
                riddles[r["id"]]["companions"] = ids
    for f, *_ in files:
        if f not in homes:
            homes[f] = (re.search(r"^home: (\w+)", open(os.path.join(EXPEDITIONS, f)).read(), re.M) or [None, None])[1]
    for f, uimap, client, rs, _ in files:
        for side in SIDES:
            mine = [r for r in rs if (not homes[f] or homes[f] == side) and r.get("faction", side) == side]
            size = zones.get(str(uimap), {})
            for error in repeated_sites(mine, riddles, size.get("w", 0), size.get("h", 0)):
                errors.append(f"{f}: the {side}'s reader: {error}")

    classic = {i for (i,) in cdb.execute("SELECT id FROM quest")}
    new = forever_quests(classic)
    known_quests = classic | {i for (i,) in db("forever").execute("SELECT id FROM quest")}
    norm = lambda x: re.sub(r"[^a-z]", "", x.lower())
    zone_names = {int(z["ID"]): z["Name_lang"] for z in table("UiMap")}
    npcs, objs = traces("Npc"), traces("Object")
    # (Forever's own zones: their riddles' creatures and objects, against its quests too)
    own = [(f, uimap, r, []) for f, uimap, client, rs, _ in files if client == "forever" for r in rs]
    for f, uimap, r, points in placed + own:
        where = f"{f}: {r['id']}"
        try:
            reviewed = reviewed_quests(r, known_quests)
        except ValueError as e:
            errors.append(f"{where}: {e}")
            reviewed = set()
        subject = [(k, int(r[k])) for k in ("creature", "object") if k in r]
        subject += [("creature", i) for i in r.get("companions", [])]
        subject += [(k, int(v)) for k, v in (r.get("anchor") or {}).items() if k in ("creature", "object")]
        named = {n for n in [r.get("name"), r.get("area"), r.get("reading")] + [names.get(s) or ((npcs if s[0] == "creature" else objs).get(s[1]) or {}).get("name") for s in subject] if n and len(n) > 4}
        for q, d in sorted(new.items()):
            if q in reviewed:
                continue
            hit = [i for i in subject if i in d["ids"]]
            if hit:
                errors.append(f"{where}: Forever's new quest {q} gives, ends or asks for {hit[0][0]} {hit[0][1]}")
            said = [n for n in named if re.search(r"\b" + re.escape(n.lower()) + r"\b", d["text"])]
            if said:
                errors.append(f"{where}: Forever's new quest {q} names {said[0]!r}")
            if deed(r) != "arrival" or not points:
                continue
            near = lambda x, y: any(((x - a) ** 2 + ((y - b) * ASPECT) ** 2) ** 0.5 <= FOREVER_NEAR for a, b in points)
            mine = [(x, y) for m, x, y in d["points"] if norm(m) == norm(zone_names.get(uimap, ""))]
            area = zone_area(uimap)
            for k, i in d["ids"]:
                t = npcs.get(i) if k == "creature" else objs.get(i) if k == "object" else None
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
    creatures' points from Questie's Forever (wow-data's database), each kept only where Wowhead's
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
            if game_names("creature", id, quarries[str(uimap)]["name"]):
                quarries[str(uimap)]["names"] = game_names("creature", id, quarries[str(uimap)]["name"])
    for r in rs:
        id, out, where = r["id"], {"zone": uimap}, f"{f}: {r['id']}"
        if r.get("found") == "place" and (r.get("reading") or r.get("companions")
            or type(r.get("radius")) is not int or not 10 <= r["radius"] <= 100):
            errors.append(f"{where}: found: place needs no reading or companions and a radius of 10 to 100 yards")
            continue
        if r.get("found") == "patrol" or "position_check" in r:
            errors.append(f"{where}: patrol and position_check require the Classic world records")
            continue
        if "indoors" in r and (r["indoors"] is not True or "area" in r):
            errors.append(f"{where}: indoors: true requires a precise place")
            continue
        if r.get("indoors"):
            out["indoors"] = True
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
            if game_names("creature", r["creature"], out["name"]):
                out["names"] = game_names("creature", r["creature"], out["name"])
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
                out.update(spots=points, r=r["radius"] if r.get("found") == "place" else NEAR + math.ceil(spread))
        elif kind == "area":
            out["name"] = r.get("name") or r["area"]
            ids = [i for i in mine if areas[i]["AreaName_lang"].strip() == r["area"]]
            if not ids:
                errors.append(f"{where}: no sub-area {r['area']!r} in this zone")
                continue
            out["areas"] = ids
            if game_names("area", min(ids), out["name"]):
                out["names"] = game_names("area", min(ids), out["name"])
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
