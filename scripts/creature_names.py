#!/usr/bin/env python3
"""The Bestiary's creatures by their names in a client language, from
Wowhead's tooltips (Forever's and Classic Era's: each game shows its own):
i18n/<locale>/creatures.json, { "forever": { id: name }, "classic": { id:
name where Classic's differs } }. The tooltips are cached in the kit's
.cache/i18n/ (addon-kit/glossary.py). Run from the addon's folder:

  python3 scripts/creature_names.py frFR
"""
import json, os, sys
from concurrent.futures import ThreadPoolExecutor
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "addon-kit"))
from glossary import wowhead, bare

locale = sys.argv[1]
ids = [str(c["id"]) for c in json.load(open("data/creatures.json"))]

def names(id):
    return id, wowhead("forever", id, locale), wowhead("classic", id, locale), wowhead("classic", id, "enUS")

out = {"forever": {}, "classic": {}}
with ThreadPoolExecutor(6) as pool:
    for i, (id, fv, cl, en) in enumerate(pool.map(names, ids)):
        fv, cl = bare(fv) if fv else None, bare(cl) if cl else None
        # (a name the tooltip left in English stays the game's own)
        if fv:
            out["forever"][id] = fv
        if cl and cl != (fv or None):
            out["classic"][id] = cl
        if i % 500 == 0:
            print(i, "of", len(ids), flush=True)
os.makedirs(f"i18n/{locale}", exist_ok=True)
with open(f"i18n/{locale}/creatures.json", "w", encoding="utf-8") as f:
    json.dump({k: dict(sorted(v.items(), key=lambda kv: int(kv[0]))) for k, v in out.items()}, f, ensure_ascii=False, indent=1)
    f.write("\n")
missing = [id for id in ids if id not in out["forever"] and id not in out["classic"]]
print(f"i18n/{locale}/creatures.json: {len(out['forever'])} Forever names, {len(out['classic'])} Classic ones of their own, {len(missing)} without a name")
