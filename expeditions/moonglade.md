---
zone: 1450   # Moonglade
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: moonglade-flight-masters
    tier: near
    creature: 11800   # Silva Fil'naveth, dump 44.1, 45.2; Bunthen Plainswind (11798) beside her
    found: target   # by speaking to her
    hint_area: { x: 44.0, y: 46.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns and their words; the WoWWiki archive's Silva Fil'naveth and Bunthen Plainswind pages"
  - id: moonglade-bear-spirit
    tier: off
    gestures: [LISTEN]
    creature: 11956
    hint_area: { x: 39.5, y: 27.5, r: 4 }
    danger: "Quiet"
    quest_overlap: [5929, 5930]
    quest_context: "Druid class quests require the spirit's dialogue lessons. This encounter asks any class to give the spirit an attentive ear, with no dialogue choices or quest credit required."
    sources: "Great Bear Spirit's gossip, broadcast text 7438 and lessons 7441, 7443, 7445; class quests 5929 and 5930; Classic database spawn and frozen Wowhead points"
# no quarry: no rare creature lives here
---
## moonglade-flight-masters
In the druids' town by the sacred lake, an elf and a tauren keep flying beasts side by side,
and fly travellers to the capitals of their peoples for nothing.
Ask the elf for a flight, and hear what she tells most of those who ask.
? Nighthaven, by the lake, where the flying beasts wait. Speak to the elven flight master. You can keep your feet on the ground.
= Silva Fil'naveth and Bunthen Plainswind, flight masters of Nighthaven: 'You're not a druid!'
+ They fly druids alone, one way: she to Rut'theran, he to Thunder Bluff, and each sends you to the other for the other road.

## moonglade-bear-spirit
North-west of the town, a bear has no need of flesh.
Its voice reaches you, though its mouth gives no sign.
It has something to teach about strength beyond the size of one's claws.
Give it an attentive ear.
? North-west of Nighthaven, among the trees. Listen to the Great Bear Spirit with a gesture. No druid training is needed for this visit.
= The Great Bear Spirit. A voice reaches you without any sign that the bear is speaking. Druids come here to learn what it means to take its form.
+ Strength of heart, it teaches, is the resolve of a mother defending her cubs or an elder protecting its den. A large body is only half the lesson.
