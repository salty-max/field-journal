#!/usr/bin/env python3
"""The flight points' names in a client language, each game's (wow-data's
databases, ../wow-data, the client's TaxiNodes in every language):
i18n/<locale>/taxi.json, { "forever": { id: name }, "classic": { id: name
where Classic's differs } }, only the names that differ from the English (the
others are the game's English, data/zones-<game>.json's). A flight keeps its
points by id: they read in the client's language, and a route flown in two
languages is one. Run from the addon's folder:

  python3 scripts/taxi_names.py frFR
"""
import json, os, re, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "wow-data", "py"))
from wowdata import db  # noqa: E402

locale = sys.argv[1]
# (the client's own paths, never a flight point: "Quest Path 9571: ...")
INTERNAL = re.compile(r"^\s*(Quest Path|\[|zz)|\bTEST\b", re.I)


def names(game, loc):
    return {r[0]: r[1] for r in db(game).execute("SELECT id, name FROM name WHERE kind = 'taxi_node' AND locale = ?", (loc,))}


out = {}
for game in ("forever", "classic"):
    english, here = names(game, "enUS"), names(game, locale)
    own = {str(i): n for i, n in sorted(here.items()) if n and english.get(i) and n != english[i] and not INTERNAL.search(english[i])}
    if game == "classic":
        own = {i: n for i, n in own.items() if out["forever"].get(i) != n}
    out[game] = own
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/taxi.json", "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=1)
    f.write("\n")
print(f"i18n/{locale}/taxi.json: {len(out['forever'])} Forever names, {len(out['classic'])} Classic ones of their own")
