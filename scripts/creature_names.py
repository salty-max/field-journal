#!/usr/bin/env python3
"""The Bestiary's creatures by their names in a client language, each game's
(wow-data's databases, ../wow-data: Forever's names and Classic Era's, each
at its pinned build): i18n/<locale>/creatures.json, { "forever": { id: name
}, "classic": { id: name where Classic's differs } }. Run from the addon's
folder:

  python3 scripts/creature_names.py frFR
"""
import json, os, re, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "addon-kit"))
from glossary import bare, creature
from wowdata import db  # noqa: E402  (the path glossary set)

locale = sys.argv[1]
ids = [str(c["id"]) for c in json.load(open("data/creatures.json"))]

out = {"forever": {}, "classic": {}}
for id in ids:
    fv, cl = creature("forever", id, locale), creature("classic", id, locale)
    fv, cl = bare(fv) if fv else None, bare(cl) if cl else None
    # (a name the game left in English stays the game's own)
    if fv:
        out["forever"][id] = fv
    if cl and cl != (fv or None):
        out["classic"][id] = cl
# Forever's own creatures, which data/creatures.json (the original world's)
# doesn't hold: the journal records one by the name the game gave the day it
# was met, so a client of another language since reads it by its id here
# ("Snow Leopard Prowler" met in English, Schneeleopardenpirscher in German)
classic_ids = {r[0] for r in db("classic").execute("SELECT id FROM creature")}
for (fid,) in db("forever").execute("SELECT id FROM creature WHERE removed IS NOT 1 ORDER BY id"):
    if fid in classic_ids or str(fid) in out["forever"]:
        continue
    fv = creature("forever", fid, locale)
    if fv and not re.match(r"^\s*[\[(<]", fv):
        out["forever"][str(fid)] = bare(fv)
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/creatures.json", "w", encoding="utf-8") as f:
    json.dump({k: dict(sorted(v.items(), key=lambda kv: int(kv[0]))) for k, v in out.items()}, f, ensure_ascii=False, indent=1)
    f.write("\n")
missing = [id for id in ids if id not in out["forever"] and id not in out["classic"]]
print(f"i18n/{locale}/creatures.json: {len(out['forever'])} Forever names, {len(out['classic'])} Classic ones of their own, {len(missing)} without a name")
