#!/usr/bin/env python3
"""The weighed catches' kinds in a client language, English one of them:
"Catfish" from the game's "17 Pound Catfish" ("Poisson-chat de 17 livres",
"17-pfündiger Wels", "17磅重的鲶鱼"), each language's own pattern, every
weight of a kind giving the same kind (else an error), from wow-data's
databases (../wow-data: the items' names in every language). Writes
i18n/<locale>/catches.json, { "<the kind's id, its lightest catch>": name },
for scripts/locales.ts to put in the language's Text file (the Fish tab names
a kind in the client's language). Run from Yonder's folder, after
scripts/flora.py:

  python3 scripts/catch_names.py frFR
"""
import json, os, re, sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "wow-data", "py"))
from wowdata import db

locale = sys.argv[1]
# (a catch's name: its number of pounds or kilos, the kind)
PATTERNS = {
    "enUS": r"^\d+ Pound (.+)$",
    "itIT": r"^\d+ Pound (.+)$",
    "deDE": r"^\d+-pfündige[rsn]? (.+)$",
    "esES": r"^(.+) de \d+ kilos$",
    "esMX": r"^(.+) de \d+ kilos$",
    "frFR": r"^(.+) de \d+ livres?$",
    "koKR": r"^\d+(?:Kg|kg) (.+)$",
    "ptBR": r"^(.+) de \d+ [Qq]uilos$",
    "ruRU": r"^\d+-фунтов\S* (.+)$",
    "zhCN": r"^\d+磅重的(.+)$",
    "zhTW": r"^\d+磅重的(.+)$",
}
if locale not in PATTERNS:
    sys.exit(f"catch_names.py: no pattern for {locale}")
pattern = re.compile(PATTERNS[locale])
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
flora = json.load(open(os.path.join(ROOT, "data", "flora.json"), encoding="utf-8"))


def named(id):
    for game in ("forever", "classic"):
        row = db(game).execute("SELECT name FROM name WHERE kind = 'item' AND id = ? AND locale = ?", (id, locale)).fetchone()
        if row and row[0] and not row[0].startswith("["):
            return re.sub(r"\s+", " ", row[0]).strip()  # (French's no-break spaces)


out, errors = {}, []
for fish in flora["fish"]:
    if fish.get("kind") != "record":
        continue
    kinds = set()
    for w in fish["weights"]:
        n = named(w["id"])
        m = n and pattern.match(n)
        if not m:
            errors.append(f"{fish['name']}: {w['id']} {n!r} doesn't read as a weighed catch in {locale}")
            continue
        kind = m.group(1).strip()
        kinds.add(kind[:1].upper() + kind[1:])
    if len(kinds) > 1:
        errors.append(f"{fish['name']}: its weights name {sorted(kinds)} in {locale}")
    elif kinds:
        out[str(fish["id"])] = kinds.pop()
if errors:
    sys.exit("catch_names.py:\n  " + "\n  ".join(errors))
os.makedirs(os.path.join(ROOT, "i18n", locale), exist_ok=True)
with open(os.path.join(ROOT, "i18n", locale, "catches.json"), "w", encoding="utf-8") as f:
    json.dump(dict(sorted(out.items(), key=lambda kv: int(kv[0]))), f, ensure_ascii=False, indent=1)
    f.write("\n")
print(f"i18n/{locale}/catches.json: {len(out)} kinds of weighed catch")
