---
zone: 1450   # Moonglade
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: moonglade-remulos
    tier: off
    gestures: [BOW, KNEEL]
    where: { x: 36.2, y: 41.8, r: 1 }   # Keeper Remulos, dump 36.2, 41.8; Wowhead 36.2, 41.8
    hint_area: { x: 37.8, y: 43.7, r: 5 }
    danger: "Quiet"
    sources: "the Codex's keeper-remulos page; quest 8446"
# quarry: the zone's own, in the hunts' pass
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
