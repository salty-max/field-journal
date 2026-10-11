---
zone: 1435   # Swamp of Sorrows
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: swamp-of-sorrows-harborage
    tier: near
    where: { x: 26.0, y: 31.4, r: 1 }   # Magtoor, dump 26.0, 31.4; Wowhead 26.0, 31.4
    hint_area: { x: 24.2, y: 33.8, r: 6 }
    danger: "Quiet"
    sources: "quest 1389; the Codex's the-lost-ones page"
  - id: swamp-of-sorrows-fallen-hero
    tier: off
    gestures: [LISTEN]
    where: { x: 34.3, y: 66.1, r: 1 }   # the Fallen Hero, dump 34.3, 66.1; Wowhead 34.2, 66.0
    hint_area: { x: 37.2, y: 66.7, r: 6 }
    danger: "Quiet"
    sources: "quests 2621, 2801; the Codex's the-fallen-hero page"
  - id: swamp-of-sorrows-itharius
    tier: hidden
    where: { x: 13.7, y: 71.7, r: 1 }   # Itharius, dump 13.7, 71.7; Wowhead 13.6, 71.6
    hint_area: { x: 12.7, y: 74.5, r: 6 }
    danger: "Quiet"
    sources: "quest 3512; the Codex's eranikus page"
  - id: swamp-of-sorrows-stonard
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: The New Horde
    object: 175752   # dump 47.6, 55.0; Wowhead's page alike
    hint_area: { x: 51.2, y: 53.2, r: 8 }
    danger: "Quiet"
    sources: "object 175752's text"
# quarry: the zone's own, in the hunts' pass
---
## swamp-of-sorrows-harborage
In the swamp's north-west, a few exiles from another world
keep a quiet camp and speak gently to strangers;
their brothers, broken by the journey, raid them from the east.
Find their camp.
? The Harborage, in the north-west of the Swamp of Sorrows.
= Magtoor, of the draenei at the Harborage.
+ Of the Lost Ones: 'Once our brethren, they now live in the Fallow Sanctuary to the east, catching or killing any who wander near.' They stole the crystals the exiles hold sacred.

## swamp-of-sorrows-fallen-hero
Outside the orcs' fortress, a ghost waits for orders that never came.
He led his warriors into the blasted lands without them,
and lost every one to a demon. He blames himself,
and he has a story for anyone with the patience for it.
? West of Stonard, by the road.
= The Fallen Hero of the Horde. The demon Razelikh bound his men's spirits in stones of torment.
+ 'Regret. It is all I have now. One bad decision resulting in several horrible outcomes. If only I had waited for those orders.'

## swamp-of-sorrows-itharius
In a cave at the swamp's western edge, one of the dream's dragons
watches over a sunken temple and a brother caught in nightmares,
between sleep and death. Find the cave.
? Itharius's Cave, at the western edge of the Swamp of Sorrows.
= Itharius, of Ysera's green flight.
+ Eranikus, keeper of the sunken temple, lies 'in a precarious state between sleep and death now, twisted within a weave of nightmares.'

## swamp-of-sorrows-stonard
In the stone fortress above the mire, a history tells
of the orphan a warden raised in his prison-stronghold
and named for what he meant him to be.
? Stonard.
= The New Horde, in Stonard: Aedelas Blackmoore and the orphan he called Thrall.
+ Doomhammer fell freeing one of the camps; Thrall took up his warhammer and his black plate, and became warchief of the Horde.
