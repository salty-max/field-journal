---
zone: 1429   # Elwynn Forest
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: elwynn-forest-cats
    tier: near
    gestures: [MEOW, PURR]
    name: Donni Anthania's Cats
    creature: 6367   # Donni Anthania, dump 44.2, 53.4, in her house: her four cats at her feet (Bombay 7385, Wowhead places none of them)
    companions: [7381, 7382, 7384, 7385]   # Silver Tabby, Orange Tabby, Cornish Rex, Bombay
    hint_area: { x: 45.0, y: 52.5, r: 4 }
    danger: "Quiet"
    sources: "the dump: Donni Anthania <Crazy Cat Lady> and her four cats in her house, and who sells cats (npc_vendor: her four carriers, forty silver each; Lil Timmy's White Kitten, one at a time); warcraft.wiki.gg's Donni Anthania page"
  - id: elwynn-forest-heroes-vigil
    tier: hidden
    gestures: [SALUTE, BOW, KNEEL, MOURN, PRAY]
    area: Heroes' Vigil   # placed: the Stone of Remembrance, dump 74.5, 51.7 (no Wowhead position: the area solves, the stone places the hint)
    anchor: { object: 20923 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 75.0, y: 55.7, r: 8 }
    danger: "Guarded (the Defias Rogue Wizards)"
    sources: "the WoWWiki archive's Heroes' Vigil, Stone of Remembrance and Stone Cairn Lake pages; object 20923"
quarry:
  id: 471   # Mother Fang
  sources: "the WoWWiki archive's Mother Fang page (the inner mine, the hunter's pet, the meat); https://classic.warcraftdb.com/data/spell/12023 (Web, cast by Mother Fang); the pinned dump's spawn and creature_ai_scripts"
---
## elwynn-forest-cats
In a house on the road between the abbey and the gold town,
a woman lives with four cats, and her title says what the neighbours make of it.
The cats have the run of the place.
Address them in their own tongue.
? Donni Anthania's house, on the road from Northshire down to Goldshire. Answer one of the cats in its own tongue. A meow will do.
= Donni Anthania, the Crazy Cat Lady, and her four cats: a Bombay, a Cornish Rex, an Orange Tabby and a Silver Tabby. Every one of them is for sale, at forty silver a carrier.
+ They are four of the five cats anyone in the world will sell you. The fifth, a white kitten, is carried about Stormwind by a boy called Lil Timmy, and sold one at a time.

## elwynn-forest-heroes-vigil
In a lake shaped like a ring, an island holds a ring of stones
and a stone raised so that heroes would be remembered.
Renegade wizards hold the island now, gone over to the bandits.
Cross the water, and give the stone what it was raised for.
? The ring-shaped lake north of the road to Eastvale has an island in its middle. Heroes are honoured there. Kneel by the memorial stone.
= Heroes' Vigil, and its Stone of Remembrance: a cairn for the dead of the First War, when the orcs sacked Goldshire and the lands around it. The lake takes its name from the cairn.
+ The lake was a place of pilgrimage once. The Defias' renegade wizards have made it a dangerous one.

## quarry
East of the gold town, in the mine the kobolds dig,
a mother of spiders hunts the inner galleries.
Her hunting ground lies beyond the kobolds' workings.
Go past the kobolds, and keep going.
= Mother Fang, a spider of the Jasperlode Mine. A hunter can tame her: a fair first companion, if a demanding one, for she eats only meat.
+ Her web holds whoever she catches for a few seconds, long enough for her bite.
