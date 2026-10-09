#!/usr/bin/env python3
"""The Atlas's zones, per game: data/zones-classic.json and data/zones-forever.json.

  python3 scripts/zones.py

From the client's own tables (wago.tools, cached in .cache/<game>/): UiMap (the
zones, type 3, and their continent), UiMapXMapArt and WorldMapOverlay (the
map's explorable places: each overlay is lifted from the fog by the areas it
names, as the game's exploration achievements count them), AreaTable (the
places' names). Forever's build is pinned, as the Codex's.

Each zone: { id (uiMap), name, continent (uiMap), places: [{ name, areas, rect }] }
(rect: left, top, right, bottom on the map art: the addon asks the game which
of the place's areas are explored at points inside it).
Battlegrounds are left out.
"""
import csv, json, os, urllib.request

ROOT = os.path.join(os.path.dirname(__file__), "..")
GAMES = {
    "classic": "product=wow_classic_era",
    "forever": "product=wow_classic_beta&build=1.60.1.70291",
}
TABLES = ("UiMap", "UiMapXMapArt", "WorldMapOverlay", "AreaTable")
UA = {"User-Agent": "ExplorersFieldJournal/0.1 (addon data; github.com/salty-max/field-journal)"}
SUBDIR = {"classic": "era", "forever": "forever"}
BATTLEGROUNDS = {1459, 1460, 1461}  # Alterac Valley, Warsong Gulch, Arathi Basin


def table(game, name):
    path = os.path.join(ROOT, ".cache", SUBDIR[game], f"{name}.csv")
    if not os.path.exists(path):
        os.makedirs(os.path.dirname(path), exist_ok=True)
        url = f"https://wago.tools/db2/{name}/csv?{GAMES[game]}"
        with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=180) as r, open(path, "wb") as f:
            f.write(r.read())
    return list(csv.DictReader(open(path, encoding="utf-8")))


def zones(game):
    uimaps = {int(r["ID"]): r for r in table(game, "UiMap")}
    areas = {int(r["ID"]): r for r in table(game, "AreaTable")}
    art = {}
    for r in table(game, "UiMapXMapArt"):
        if r["PhaseID"] == "0":
            art[int(r["UiMapID"])] = int(r["UiMapArtID"])
    # Only areas a character can discover (AreaTable flag 0x40): the game
    # reports the others as explored for everyone (the capitals drawn on their
    # zone's map, Forever's Dalaran behind its dome), and its exploration
    # achievements leave them out. A place with none of them is no place.
    explorable = {i for i, a in areas.items() if int(a["Flags_0"]) & 0x40}
    # Forever marks the overlays that exploration lifts (flag 4); the others
    # it draws for everyone, and reports as explored: their places count only
    # once visited (the game names the zone or subzone you stand in after
    # them). Classic marks none, and lifts them all.
    rows = table(game, "WorldMapOverlay")
    flagged = any(int(r["Flags"]) & 4 for r in rows)
    overlays = {}
    for r in rows:
        ids = [int(r[f"AreaID_{i}"]) for i in range(4) if int(r[f"AreaID_{i}"]) in explorable]
        if ids:
            # the overlay's hover rectangle on the map art (its texture's
            # rectangle where it has none): where to ask the game about it
            ox, oy = int(r["OffsetX"]), int(r["OffsetY"])
            rect = [int(r["HitRectLeft"]), int(r["HitRectTop"]), int(r["HitRectRight"]), int(r["HitRectBottom"])]
            if rect[2] <= rect[0] or rect[3] <= rect[1]:
                rect = [ox, oy, ox + int(r["TextureWidth"]), oy + int(r["TextureHeight"])]
            visit = flagged and not int(r["Flags"]) & 4
            overlays.setdefault(int(r["UiMapArtID"]), []).append((ids, rect, visit))
    out = []
    for uid, m in sorted(uimaps.items()):
        if m["Type"] != "3" or uid in BATTLEGROUNDS:
            continue
        parent = uimaps.get(int(m["ParentUiMapID"]))
        places, seen = [], set()
        for ids, rect, visit in overlays.get(art.get(uid), []):
            key = tuple(sorted(ids))
            if key in seen:
                continue
            seen.add(key)
            name = next((areas[a]["AreaName_lang"] for a in ids if a in areas), "?")
            places.append({"name": name, "areas": ids, "rect": rect, **({"visit": True} if visit else {})})
        places.sort(key=lambda p: p["name"])
        out.append({
            "id": uid,
            "name": m["Name_lang"],
            "continent": int(m["ParentUiMapID"]) if parent and parent["Type"] == "2" else 0,
            "places": places,
        })
    return out, {int(k): v["Name_lang"] for k, v in uimaps.items() if v["Type"] == "2"}


def main():
    for game in GAMES:
        z, continents = zones(game)
        path = os.path.join(ROOT, "data", f"zones-{game}.json")
        with open(path, "w") as f:
            json.dump({"continents": continents, "zones": z}, f, indent=1)
            f.write("\n")
        print(f"{game}: {len(z)} zones, {sum(len(x['places']) for x in z)} places -> data/zones-{game}.json")


if __name__ == "__main__":
    main()
