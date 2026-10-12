---
zone: 1419   # Blasted Lands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: blasted-lands-dark-portal
    tier: near
    area: The Dark Portal   # placed: the client's overlay: 58.4, 56.5, half-size 6.5 by 7.9
    hint_area: { x: 57.0, y: 54.0, r: 10 }
    danger: "Guarded (demons and ogres)"
    sources: "object 21582's text (Beyond the Dark Portal); the Codex's the-dark-portal page"
  - id: blasted-lands-tainted-scar
    tier: hidden
    area: The Tainted Scar   # placed: the client's overlay: 37.9, 62.5, half-size 11.5 by 18.3
    hint_area: { x: 40.0, y: 60.0, r: 16 }
    danger: "Perilous (Lord Kazzak and his felguard)"
    sources: "the Codex's lord-kazzak page; the Lord Kazzak (tactics) pages of Warcraft Wiki and Wowpedia (Capture Soul, his supreme fury)"
  - id: blasted-lands-nethergarde
    tier: town
    faction: alliance   # its town's: for that faction alone
    reading: Beyond the Dark Portal
    object: 21582   # dump 65.2, 22.9; Wowhead's page alike
    hint_area: { x: 62.7, y: 26.0, r: 8 }
    danger: "Quiet"
    sources: "object 21582's text; the Codex's nethergarde-keep page"
quarry:
  id: 8297
  sources: "the dump: his spawn at Dreadmaul Post, Akubar the Seer's beside it"
---
## blasted-lands-dark-portal
At the bottom of the red waste stands the gate the orcs first came through.
It was shattered, and opened again; the last heroes who went through it
destroyed it from the far side so that this world would live,
and nobody knows whether they came home. Stand before it.
? The Dark Portal, in the south of the Blasted Lands.
= The Dark Portal, still and dark.
+ Khadgar, Turalyon, Alleria, Kurdran and Danath chose to stay on the dying world: 'whether or not they escaped the death throes of Draenor remains to be seen.'

## blasted-lands-tainted-scar
In the south-west of the waste, a great demon who stayed behind
holds a scar in the land with his host,
and every life lost near him gives him back his own.
Find his ground, and do not linger.
? The Tainted Scar, in the Blasted Lands' south-west.
= The Tainted Scar, Lord Kazzak's ground.
+ Each death near him heals him for seventy thousand; and if he still stands three minutes after the first blow, his fury leaves no one standing.

## blasted-lands-nethergarde
In the keep built to watch the gate, a history tells
of the last army that went through it,
and of the heroes who closed it behind them.
? Nethergarde Keep.
= Beyond the Dark Portal, in the keep Khadgar urged the kingdoms to build.
+ Ner'zhul escaped through one of his own portals with his most trusted servants, while Khadgar fought to bring his comrades home.

## quarry
The Dreadmaul ogres keep a post in the middle of these blasted lands,
on the way between their hold in the north and the portal in the south.
One of them is called the Unyielding, and keeps to that post,
when he is there at all.
= Magronos the Unyielding, an ogre of the Dreadmaul. Seldom met: the post is his on some days, and empty of him on most.
+ Akubar the Seer, another of the Dreadmaul as seldom seen, has been met at the same post.
