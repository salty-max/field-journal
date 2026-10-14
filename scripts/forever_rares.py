#!/usr/bin/env python3
"""The rares WoW Forever adds (Zephras Isle's, and the new ones in the old
zones), for the Forever package's trophies-by-zone milestones:
data/rare-zones-forever.json ({creature id: {name, zone: uiMap id}}).

  python3 scripts/forever_rares.py

From wow-data's databases (../wow-data): Forever's rares (rare, rare elite)
that Classic's world doesn't have, each placed in the zone most of its
spawns are in (Questie's, by zone), one of the Atlas's Forever zones
(data/zones-forever.json). Their families aren't known before they are met:
the journal files them then, from what the game says of them (Creatures.lua).
"""
import json, os, sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
sys.path.insert(0, os.path.join(ROOT, "..", "wow-data", "py"))
from wowdata import db  # noqa: E402

OUT = os.path.join(ROOT, "data", "rare-zones-forever.json")


def main():
    classic = {r[0] for r in db("classic").execute("SELECT id FROM creature")}
    atlas = {z["id"] for z in json.load(open(os.path.join(ROOT, "data", "zones-forever.json")))["zones"]}
    f = db("forever")
    out = {}
    for cid, name in f.execute(
        """SELECT c.id, n.name FROM creature c JOIN name n ON n.kind = 'creature' AND n.id = c.id AND n.locale = 'enUS'
           WHERE c.rank IN (2, 4) ORDER BY c.id"""
    ):
        if cid in classic:
            continue
        row = f.execute(
            """SELECT (SELECT a.UiMapID FROM client_UiMapAssignment a JOIN client_UiMap u ON u.ID = a.UiMapID
                       WHERE a.AreaID = s.area_id AND u.Type = 3 ORDER BY a.OrderIndex LIMIT 1) AS ui, count(*) AS n
               FROM spawn s WHERE s.kind = 'creature' AND s.entity_id = ? AND s.source = 'questie'
               GROUP BY ui ORDER BY n DESC LIMIT 1""",
            (cid,),
        ).fetchone()
        zone = row and row[0]
        if zone in atlas:
            out[str(cid)] = {"name": name, "zone": zone}
        else:
            print(f"  no zone for {cid} {name} ({zone})")
    with open(OUT, "w") as fh:
        json.dump(out, fh, indent=2)
        fh.write("\n")
    print(f"{len(out)} rares of Forever's own -> {os.path.relpath(OUT, ROOT)}")


if __name__ == "__main__":
    main()
