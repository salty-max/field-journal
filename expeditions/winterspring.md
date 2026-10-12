---
zone: 1452   # Winterspring
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: winterspring-gogo
    tier: near
    gestures: [WAVE, HELLO, GREET]
    creature: 11753   # Gogo, dump 61.2, 38.6, in Everlook
    found: target   # in the town: only by finding her
    hint_area: { x: 61.0, y: 38.0, r: 3 }
    danger: "Quiet"
    sources: "the WoWWiki archive's Gogo and Jack Sterling pages (no quests, no services); the dump's spawns"
quarry:
  id: 10200   # Rak'shiri
  sources: "the WoWWiki archive's Rak'shiri page (the frostsaber near Frostsaber Rock, its striking coat); the dump's path and respawn (24 to 48 hours)"
---
## winterspring-gogo
In the goblins' town in the snow, everyone sells something, hires someone or wants something fetched.
One goblin among them sells nothing, asks nothing, and has nothing to say.
Find her, and be friendly anyway.
? Everlook.
= Gogo, a goblin of Everlook, who offers nothing at all.
+ She is not the only one: Jack Sterling, a human in the same town, has nothing to offer either.

## quarry
On the slopes below Frostsaber Rock, where the elves' saber riders come for their mounts,
a white saber walks that looks like one of the mounts itself.
Kill it, and a day at the least passes before it is back; two at the most.
= Rak'shiri, a frostsaber of Winterspring, near Frostsaber Rock.
+ Hunters seek it for its coat, which no other wild saber of these lands shares.
