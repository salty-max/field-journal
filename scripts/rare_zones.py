#!/usr/bin/env python3
"""The zone of every rare in data/creatures.json, for the trophies-by-zone
milestones: data/rare-zones.json ({creature id: uiMap id}).

  python3 scripts/rare_zones.py

Two sources, from wow-data (../wow-data), the first that knows wins:
  1. Questie's zone for the rare (its spawns are by zone: the zone's own map);
  2. the rare's spawn points (the Classic database's, with the spawns another
     creature may take) placed in the zones' map rectangles (the client's
     UiMapAssignment); where rectangles overlap near a border, the zone whose
     centre is nearest.
Disagreements between the two are printed for review.
"""
import collections, json, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import client, db  # noqa: E402

OUT = os.path.join(ROOT, "data", "rare-zones.json")


def questie_zones():
    """Rare id -> its zone's map, by Questie's spawns (the most of them)."""
    d = db("classic")
    out = {}
    for id, ui, n in d.execute(
        """SELECT s.entity_id, (SELECT a.UiMapID FROM client_UiMapAssignment a JOIN client_UiMap u ON u.ID = a.UiMapID
                                WHERE a.AreaID = s.area_id AND u.Type = 3 ORDER BY a.OrderIndex LIMIT 1) AS ui, count(*)
           FROM spawn s WHERE s.kind = 'creature' AND s.source = 'questie' AND s.area_id IS NOT NULL
           GROUP BY s.entity_id, ui ORDER BY s.entity_id, count(*) DESC"""
    ):
        if ui is not None:
            out.setdefault(id, ui)
    return out


def main():
    data = {c["id"]: c for c in json.load(open(os.path.join(ROOT, "data", "creatures.json")))}
    rares = {i for i, c in data.items() if c["rank"] in ("rare", "rareelite")}

    # Spawn points: a spawn's own entry, or the entries that may take its place.
    d = db("classic")
    pos = {}
    entries = collections.defaultdict(set)
    for guid, id, m, x, y in d.execute("SELECT spawn_id, entity_id, map_id, x, y FROM spawn WHERE kind = 'creature' AND source = 'classicdb'"):
        pos[guid] = (m, x, y)
        entries[guid].add(id)
    for guid, id in d.execute(
        """SELECT spawn_id, entity_id FROM spawn_entry WHERE kind = 'creature'
           UNION SELECT s.spawn_id, e.entity_id FROM spawn_group_spawn s JOIN spawn_group_entry e ON e.group_id = s.group_id
           JOIN spawn_group g ON g.id = s.group_id WHERE g.kind = 'creature'"""
    ):
        entries[guid].add(id)
    spawns = collections.defaultdict(list)
    for guid, ids in entries.items():
        for i in ids & rares:
            if guid in pos:
                spawns[i].append(pos[guid])

    uimap = {r["ID"]: r for r in client("classic", "UiMap")}
    rects = [
        (int(r["MapID"]), float(r["Region_0"]), float(r["Region_1"]), float(r["Region_3"]), float(r["Region_4"]), int(r["UiMapID"]))
        for r in client("classic", "UiMapAssignment")
        if uimap[r["UiMapID"]]["Type"] == "3"
    ]

    def place(m, x, y):
        best = None
        for zm, x0, y0, x1, y1, ui in rects:
            if zm == m and x0 <= x <= x1 and y0 <= y <= y1:
                d = ((x - (x0 + x1) / 2) / (x1 - x0)) ** 2 + ((y - (y0 + y1) / 2) / (y1 - y0)) ** 2
                if best is None or d < best[0]:
                    best = (d, ui)
        return best and best[1]

    questie = questie_zones()
    out, disagree, unplaced = {}, [], []
    for i in sorted(rares):
        name = data[i]["name"]
        counts = collections.Counter(place(*s) for s in spawns[i])
        counts.pop(None, None)
        coords = counts.most_common(1)[0][0] if counts else None
        zone = questie.get(i) or coords
        if questie.get(i) and coords and questie[i] != coords:
            disagree.append(f"{name}: Questie {uimap[str(questie[i])]['Name_lang']}, coordinates {uimap[str(coords)]['Name_lang']}")
        if zone:
            out[str(i)] = zone
        else:
            unplaced.append(name)  # dungeons, raids: no zone of the world map
    with open(OUT, "w") as f:
        json.dump(out, f, indent=0, sort_keys=True)
        f.write("\n")
    print(f"{len(out)} rares placed -> data/rare-zones.json; {len(unplaced)} in no zone (dungeons)")
    for line in disagree:
        print("  Questie wins:", line)


if __name__ == "__main__":
    main()
