---
zone: 1439   # Darkshore
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: darkshore-auberdine
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 6887   # Yalda, dump 37.4, 45.2, by a house east of the inn
    found: target   # in the town: only by finding her
    hint_area: { x: 37.5, y: 44.5, r: 3 }
    danger: "Quiet"
    sources: "the WoWWiki archive's Yalda page (translucent, no purpose anyone knows); the dump's spawn"
  - id: darkshore-illidans-gift
    tier: town
    faction: alliance
    reading: Mount Hyjal and Illidan's Gift
    object: 175729
    hint_area: { x: 36.5, y: 44.0, r: 3 }
    danger: "Quiet"
    sources: "object 175729's eight pages; Classic database spawn 36.56, 44.03 and frozen Wowhead 36.6, 44.0"
quarry:
  id: 2191   # Licillin
  sources: "the WoWWiki archive's Licillin page (a grell spellcaster); the pinned dump's spawn and creature_ai_scripts (11980 Curse of Weakness; spell lists differ on the damaging spell, so no element claimed)"
---
## darkshore-auberdine
In the elves' town on the dark shore, by a house just east of the inn,
a woman stands whom you can see straight through.
She has no wares and no errands, and nobody in the town remarks on her.
Find her.
? Auberdine, east of the inn. Speak to the ghostly woman.
= Yalda, at Auberdine: you can see through her, and nobody in the town has a word to say about it.
+ She is not hiding, and she is no spirit healer. She simply stands there, and the town goes on around her.

## darkshore-illidans-gift
In Auberdine, seek an account of water carried through the Sundering.
The first Well was gone, but some of its water survived.
Read what one brother made of it on Hyjal,
and why the other would not thank him for the gift.
? In Auberdine's inn, open the book about Mount Hyjal and Illidan's gift.
= Mount Hyjal and Illidan's Gift: Illidan poured water saved from the first Well of Eternity into a lake on Hyjal, creating a second Well. His brother saw a danger where Illidan thought he had made a gift.
+ The book says the night elves feared destroying the new Well would cause another catastrophe. They left the waters, and imprisoned the brother who had put them there.

## quarry
Among the grells of the ruined towers, seek one with a name of his own.
He has spells for an intruder as well as teeth,
and makes his home where the elves left theirs.
= Licillin, a grell spellcaster of Bashal'Aran.
+ Whoever strikes him is cursed, and strikes weaker for it.
