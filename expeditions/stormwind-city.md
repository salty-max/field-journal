---
zone: 1453   # Stormwind City
home: alliance   # a capital: its riddles are its faction's alone
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: stormwind-city-faol-plaque
    tier: near
    reading: Archbishop Alonsus Faol
    object: 177199   # dump 46.2, 40.4; Wowhead 46.1, 40.4
    hint_area: { x: 48.7, y: 43.6, r: 8 }
    danger: "Quiet"
    sources: "object 177199's text"
  - id: stormwind-city-khadgar-plaque
    tier: off
    reading: Archmage Khadgar of the Kirin Tor
    object: 25333   # dump 64.7, 78.2; Wowhead 64.9, 78.2
    hint_area: { x: 62.7, y: 81.7, r: 8 }
    danger: "Quiet"
    sources: "object 25333's text; objects 25329-25332 (Kurdran, Turalyon, Alleria, Danath); object 21582's text"
  - id: stormwind-city-horatio
    tier: hidden
    reading: Horatio Montgomery, M.D.
    object: 124374   # dump 77.5, 58.7; Wowhead 77.6, 58.9
    hint_area: { x: 75.1, y: 55.5, r: 8 }
    danger: "Quiet"
    sources: "object 124374's text"
# quarry: the zone's own, in the hunts' pass
---
## stormwind-city-faol-plaque
In the great cathedral of the city, a plaque remembers the archbishop
who began his work in a northern city, reformed the brothers of the abbey after the war,
and raised the funds to build this city again. Find his plaque.
? The Cathedral of Light, in Cathedral Square.
= Archbishop Alonsus Faol, 'benevolent patron of the Church of Light'.
+ 'This Cathedral stands not only as a bastion of the Holy Light, but as a lasting testament to one man's noble spirit and generosity.' His resting place is far to the north, beside the Scarlet Monastery.

## stormwind-city-khadgar-plaque
Among the plaques for the heroes who went through the dark gate and stayed,
one remembers the apprentice of a fallen Guardian,
who led them all, and was never seen again.
Find what his old master in the city of mages wrote for him.
? Among the memorials to the Alliance Expedition, in the city.
= Archmage Khadgar of the Kirin Tor: 'Presumed deceased.'
+ 'Never did one so selflessly delve into the dark heart of magic and warfare. We wish you well, bold wanderer. Wherever you are.' - Antonidas, Archmage of Dalaran.

## stormwind-city-horatio
Somewhere in the city, a grateful student set up a memorial
to a healer, teacher and friend who believed it was a healer's duty
to cleanse the sick and weary of every last ailment. Find it.
? Look among the city's healers.
= 'In memory of my dear mentor, Horatio M. Montgomery, M.D. Healer, Teacher, Friend.'
+ 'The world is full of the sick and weary. It is our job, as healers, NAY, as men and women of medicine, to cleanse them ALL of the itis.' - H.M.M., M.D., PhD, JD, Grandmaster Farmer, Dancer Extraordinaire, Friend to the Animals.
