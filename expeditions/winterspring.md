---
zone: 1452   # Winterspring
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: winterspring-farflinger
    tier: near
    creature: 14742   # Zap Farflinger, Unbalanced Engineer, in Everlook
    found: target   # his invention is described in his gossip
    hint_area: { x: 61.0, y: 38.0, r: 3 }
    danger: "Quiet"
    sources: "https://www.wowhead.com/classic/npc=14742/zap-farflinger; https://warcraft.wiki.gg/wiki/Zap_Farflinger (gossip, added in 1.5.0); the dump's gossip menu 6092 and npc_text 7249/7250 (the imploder, the explosion, goblin engineering), spawn and lack of quest relations"
quarry:
  id: 10200   # Rak'shiri
  sources: "https://www.wow-petopia.com/classic/look.php?id=ridingtigerskinaqua (Rak'shiri and Shy-Rotam share the aqua coat); the dump's path near Frostsaber Rock"
---
## winterspring-farflinger
In the goblins' town in the snow, an engineer has finished a machine
and is waiting for someone else to try it.
Find the inventor whose title gives you reason to hesitate.
? Everlook.
= Zap Farflinger, Unbalanced Engineer. His plan for instant transport begins by blowing the traveller to pieces, then reassembling the particles at Everlook.
+ He teaches skilled goblin engineers to build the ripper that connects to his machine. His answer to doubts about safety is that survival comes second to engineering.

## quarry
Below Frostsaber Rock, a saber's coat puts a little colour into the snow:
aqua beneath the stripes, among the white and lavender of its neighbours.
Search the slopes and the ground beside the frozen lake.
= Rak'shiri, an aqua-coated saber of Winterspring, near Frostsaber Rock.
+ Only one other cat wears the aqua coat: Shy-Rotam.
