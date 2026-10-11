---
zone: 1419   # Blasted Lands
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: blasted-lands-dark-portal
    tier: near
    area: The Dark Portal   # placed: the client's overlay: 58.4, 56.5, half-size 6.5 by 7.9
    hint_area: { x: 57.0, y: 54.0, r: 10 }
    danger: "Guarded (demons and ogres)"
    sources: "object 21582's text (Beyond the Dark Portal); the Codex's the-dark-portal page"
  - id: blasted-lands-kumisha
    tier: off
    where: { x: 52.0, y: 35.6, r: 1 }   # Kum'isha the Collector, dump 52.0, 35.6; Wowhead 51.8, 35.6
    hint_area: { x: 52.0, y: 38.6, r: 6 }
    danger: "Guarded"
    sources: "quest 2521; the Codex's nethergarde-keep page"
  - id: blasted-lands-tainted-scar
    tier: hidden
    area: The Tainted Scar   # placed: the client's overlay: 37.9, 62.5, half-size 11.5 by 18.3
    hint_area: { x: 40.0, y: 60.0, r: 16 }
    danger: "Perilous (Lord Kazzak and his felguard)"
    sources: "the Codex's lord-kazzak page"
  - id: blasted-lands-nethergarde
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Beyond the Dark Portal
    object: 21582   # dump 65.2, 22.9; Wowhead's page alike
    hint_area: { x: 62.7, y: 26.0, r: 8 }
    danger: "Quiet"
    sources: "object 21582's text; the Codex's nethergarde-keep page"
# quarry: the zone's own, in the hunts' pass
---
## blasted-lands-dark-portal
At the bottom of the red waste stands the gate the orcs first came through.
It was shattered, and opened again; the last heroes who went through it
destroyed it from the far side so that this world would live,
and nobody knows whether they came home. Stand before it.
? The Dark Portal, in the south of the Blasted Lands.
= The Dark Portal, still and dark.
+ Khadgar, Turalyon, Alleria, Kurdran and Danath chose to stay on the dying world: 'whether or not they escaped the death throes of Draenor remains to be seen.'

## blasted-lands-kumisha
In the waste below the keep, one of a people from beyond the gate
waits for a crystal so rare that others of that people have died searching for it,
and calls every stranger small-minded.
Find the collector.
? Between Nethergarde and the Dark Portal, by the road.
= Kum'isha the Collector, a draenei.
+ If a flawless sphere of draenethyst is ever brought: 'Perhaps now a rift can be opened, returning us to our homeland.'

## blasted-lands-tainted-scar
In the south-west of the waste, a great demon who stayed behind
holds a scar in the land with his host,
and every champion he kills makes him stronger.
Find his ground, and do not linger.
? The Tainted Scar, in the Blasted Lands' south-west.
= The Tainted Scar, Lord Kazzak's ground.
+ A failed attack on him leaves the next party facing a stronger enemy.

## blasted-lands-nethergarde
In the keep built to watch the gate, a history tells
of the last army that went through it,
and of the heroes who closed it behind them.
? Nethergarde Keep.
= Beyond the Dark Portal, in the keep Khadgar urged the kingdoms to build.
+ Ner'zhul escaped through one of his own portals with his most trusted servants, while Khadgar fought to bring his comrades home.
