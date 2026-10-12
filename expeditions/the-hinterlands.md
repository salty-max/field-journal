---
zone: 1425   # The Hinterlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: the-hinterlands-plaguemist
    tier: off
    gestures: [COUGH, SNIFF, SNEEZE]
    area: Plaguemist Ravine   # placed: the client's overlay: 22.7, 38.2, half-size 3.7 by 11.2
    hint_area: { x: 23.0, y: 36.0, r: 6 }
    danger: "Quiet: nothing lives in it"
    sources: "the WoWWiki archive's Plaguemist Ravine page (the way north to Caer Darrow, the mist, no one in it)"
  - id: the-hinterlands-seradane
    tier: hidden
    gestures: [SLEEP, LAYDOWN]
    area: Seradane   # placed: the client's overlay: 64.1, 25.4, half-size 8.2 by 12.0
    hint_area: { x: 63.0, y: 26.0, r: 9 }
    danger: "Deadly (Dreamtracker, Rothos and the green dragonkin, levels 60 to 62)"
    sources: "the WoWWiki archive's Seradane, Dreamtracker and Rothos pages (the portal, its guardians, the dragon's skull)"
  - id: the-hinterlands-revantusk
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [DANCE]
    creature: 14734   # the Revantusk Drummers, dump 79.4, 79.0, three at their drums
    hint_area: { x: 79.0, y: 80.0, r: 3 }
    danger: "Quiet"
    sources: "the dump's spawns"
quarry:
  id: 8215   # Grimungous
  sources: "https://www.wowhead.com/classic/npc=8215/grimungous (period accounts of War Stomp); the pinned dump's path and creature_ai_scripts (11876 War Stomp, 5568 Trample)"
---
## the-hinterlands-plaguemist
West of the elves' lodge, a ravine climbs out of the green hills,
and a mist hangs in it that does not belong to them:
the air of the dead country comes down it from the north.
Walk up into it, and you will know it by the taste.
? Plaguemist Ravine, north-west of Quel'Danil Lodge.
= Plaguemist Ravine: a way out of the Hinterlands, north toward Caer Darrow and the Western Plaguelands, with the plague's mist in it.
+ Nothing lives in it and nothing waits there. It is only a road, and the mist.

## the-hinterlands-seradane
In the Hinterlands' north-east, green dragons keep a door
that opens on nothing anyone awake has ever seen.
There are four such doors in this world. Linger before this one long enough,
and you might go through it the only way the living can.
? Seradane, in the Hinterlands' north-east.
= Seradane: one of the four doors into the Emerald Dream, kept by the green drakes Dreamtracker and Rothos. Its sisters stand in Duskwood, Ashenvale and Feralas.
+ On the hill north of it lies the skull of a dragon nobody has named, inside a ring of stones like the Arathi Highlands' circles of binding.

## the-hinterlands-revantusk
In the trolls' village on the eastern cliffs, three drummers keep the beat,
and do not stop for anybody.
Show them what their drums are for.
? Revantusk Village, among its huts.
= The Revantusk Drummers, three of them, keeping the village's beat.
+ The village keeps its eye on the Vilebranch of Jintha'Alor, up the hill; the drums are the one sound it makes on purpose.

## quarry
Among the troll ruins in the east of the hills,
a hill giant walks alone, in no hurry.
Seek him on the ground below the trolls' great city.
= Grimungous, an elite hill giant, walking the ruins of Shaol'watha.
+ Crowded, he stamps, and those nearest him are stunned.
