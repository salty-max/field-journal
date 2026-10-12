---
zone: 1449   # Un'Goro Crater
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: ungoro-crater-simone
    tier: off
    gestures: [WAVE, HELLO, GREET, SMILE]
    creature: 14527   # Simone the Inconspicuous, with Precious (14528): from Golakka Hot Springs (dump 34.3, 40.8) south and back
    found: target   # she keeps walking
    hint_area: { x: 35.0, y: 45.0, r: 5 }
    danger: "Deadly if provoked (she answers a blow with blows that fell a hero); otherwise quiet"
    sources: "the dump's spawn, path and words; the client's display tables (a troll); the WoWWiki archive's Simone the Inconspicuous page (the succubus beneath, Precious, Fool's Plight)"
quarry:
  id: 6584   # King Mosh
  sources: "the WoWWiki archive's King Mosh page (the infamous devilsaur of the north-west); the dump's path and respawn (48 to 72 hours)"
---
## ungoro-crater-simone
By the hot springs in the crater's west, a troll woman walks with her wolf
and finds everything lovely: the steam, the ferns, the beasts that would eat her.
Be pleasant to her, and only pleasant.
? Golakka Hot Springs, in western Un'Goro; she walks south from there and back.
= Simone the Inconspicuous, with Precious, her wolf: 'What a wonderful day to be alive! Look at the beauty that surrounds you, friend.'
+ She is not what she seems: hunters on the trail of an ancient bow know her as Simone the Seductress, a succubus. Strike her as she is, and she answers with blows that fell a hero in one.

## quarry
Between the river and the great lakes of the crater's north-west, the king of the devilsaurs walks,
and the crater shakes for him.
Bring him down, and two days at the least pass before another king walks there; three at the most.
= King Mosh, the infamous devilsaur of Un'Goro's north-west.
+ Of all the crater's devilsaurs, he is the one they call king.
