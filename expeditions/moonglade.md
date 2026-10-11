---
zone: 1450   # Moonglade
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: moonglade-remulos
    tier: off
    gestures: [BOW, KNEEL]
    creature: 11832   # Keeper Remulos, dump 36.2, 41.8; Wowhead 36.2, 41.8
    hint_area: { x: 37.8, y: 43.7, r: 5 }
    danger: "Quiet"
    sources: "the Codex's keeper-remulos page; quest 8446"
# no quarry: no rare creature lives here
---
## moonglade-remulos
In the hidden valley of the druids, by its sacred lake,
a son of the forest god keeps a shrine,
with his father's form below the waist,
and the dreamers come to him when the Dream goes wrong.
Come before him as the druids do.
? The Shrine of Remulos, on the western shore of Lake Elune'ara.
= Keeper Remulos, Cenarius's son.
+ He cleanses the corruption the green dragons leave behind in Lake Elune'ara: 'This may shed some light on my recent failures to delve into the Dream.'
