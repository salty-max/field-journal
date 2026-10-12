---
zone: 1429   # Elwynn Forest
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: elwynn-forest-crystal-lake
    tier: near
    gestures: [CURIOUS, PONDER, PUZZLE, THINK]
    creature: 1651   # Lee Brown, the fisherman, dump 47.6, 62.3 (Jason Mathers beside him)
    hint_area: { x: 49.5, y: 60.5, r: 5 }
    danger: "Quiet"
    sources: "a Stormwind guard's words (broadcast text 6970); Brill's (6758); the WoWWiki archive's Crystal Lake and Lee Brown pages; the dump (Jason Mathers, the children camping)"
  - id: elwynn-forest-ridgepoint
    tier: off
    gestures: [SALUTE, BOW]
    area: Ridgepoint Tower   # placed: the client's overlay: 85.1, 80.5
    hint_area: { x: 82.5, y: 78.0, r: 7 }
    danger: "Quiet (the guards; prowlers on the slopes)"
    sources: "the WoWWiki archive's Ridgepoint Tower page; the dump (four Stormwind guards)"
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
## elwynn-forest-crystal-lake
A city guard tells of a fisherman of the lake east of the gold town
who once hauled a weird mask out of its water,
and supposes he'd had one too many at the Lion's Pride that night.
The fisherman still works that shore, beside a fishmonger called Jason.
Wonder about it where they stand.
? Crystal Lake's western shore, east of Goldshire: a fisherman, a fishmonger, and children camping by the water.
= Lee Brown, who teaches fishing on Crystal Lake's shore. Jason Mathers sells the catch beside him, and a band of children camps by the water.
+ Brill tells a story of its own: a man who fishes Brightwater Lake, psychos in masks, and a children's summer camp shut down the year before.

## elwynn-forest-ridgepoint
After the Second War, the kingdom raised towers to watch its forest.
One stands on a ridge in the far south-east,
where the forest ends and three kinds of trouble begin.
Honour the watch that keeps it.
? Elwynn's south-eastern corner, above the road to Redridge: a guard tower on the ridge.
= Ridgepoint Tower, one of the guard towers Stormwind raised in Elwynn after the Second War.
+ It watches three borders at once: the gnolls and orcs of Redridge, the dead that come up from Duskwood, and the Defias camps in the forest itself.

## elwynn-forest-heroes-vigil
In a lake shaped like a ring, an island holds a ring of stones
and a stone raised so that heroes would be remembered.
Renegade wizards hold the island now, gone over to the bandits.
Cross the water, and give the stone what it was raised for.
? The ring-shaped lake north of the road to Eastvale has an island in its middle; heroes are honoured there.
= Heroes' Vigil, and its Stone of Remembrance: a cairn for the dead of the First War, when the orcs sacked Goldshire and the lands around it. The lake takes its name from the cairn.
+ The lake was a place of pilgrimage once. The Defias' renegade wizards have made it a dangerous one.

## quarry
East of the gold town, in the mine the kobolds dig,
a mother of spiders hunts the inner galleries.
Her hunting ground lies beyond the kobolds' workings.
Go past the kobolds, and keep going.
= Mother Fang, a spider of the Jasperlode Mine. A hunter can tame her: a fair first companion, if a demanding one, for she eats only meat.
+ Her web can stop a retreat without ending the fight. Clear a way back through the mine before disturbing her.
