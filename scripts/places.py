#!/usr/bin/env python3
"""The Plants' and Fish' places in a client language (the fish's waters, the
herbs' and fish's dungeons, data/flora.json's): i18n/<locale>/places.json,
{ English: the game's name }, Forever's, else Classic Era's (wow-data's
databases, through ../addon-kit/glossary.py); i18n/<locale>/places-by-hand.json's
win (a client's own slip: Forever's French "lle de l'effroi"). Run from the
addon's folder:

  python3 scripts/places.py frFR
"""
import json, os, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "addon-kit"))
from glossary import KINDS, names  # noqa: E402

locale = sys.argv[1]
flora = json.load(open("data/flora.json"))
wanted = sorted(
    {n for h in flora["herbs"] for n in h.get("dungeons", [])}
    | {n for x in flora["fish"] for n in x.get("subzones", []) + x.get("dungeons", [])}
)
forever, classic = names("forever", KINDS["places"], locale), names("classic", KINDS["places"], locale)
hand_file = f"i18n/{locale}/places-by-hand.json"
hand = json.load(open(hand_file, encoding="utf-8")) if os.path.exists(hand_file) else {}
out, missing = {}, []
for en in wanted:
    name = hand.get(en) or forever.get(en) or classic.get(en)
    if name:
        out[en] = name
    else:
        missing.append(en)
with open(f"i18n/{locale}/places.json", "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
    f.write("\n")
print(f"i18n/{locale}/places.json: {len(out)} places{', no name for ' + ', '.join(missing) if missing else ''}")
