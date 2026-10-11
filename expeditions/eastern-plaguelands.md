---
zone: 1423   # Eastern Plaguelands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: eastern-plaguelands-lights-hope
    tier: near
    gestures: [PRAY, KNEEL]
    area: Light's Hope Chapel   # placed: the client's overlay: 82.1, 58.4, half-size 3.7 by 6.0
    hint_area: { x: 80.5, y: 57.0, r: 7 }
    danger: "Quiet"
    sources: "the Codex's lights-hope-chapel page"
  - id: eastern-plaguelands-egan
    tier: off
    creature: 11140   # Egan, dump 14.4, 33.7; Wowhead 14.4, 33.6
    hint_area: { x: 13.9, y: 36.1, r: 5 }
    danger: "Perilous (Terrordale's dead)"
    sources: "quests 5281, 5282"
  - id: eastern-plaguelands-pamela
    tier: off
    gestures: [INTRODUCE, HELLO, GREET, WAVE]
    creature: 10926   # Pamela Redpath, dump 36.5, 90.8; Wowhead 36.4, 90.8
    hint_area: { x: 38.6, y: 89.4, r: 5 }
    danger: "Guarded (Darrowshire's dead)"
    sources: "quests 5142, 5149; the Codex's darrowshire page"
  - id: eastern-plaguelands-marris-stead
    tier: off
    area: The Marris Stead   # placed: the client's overlay: 26.7, 73.4, half-size 5.2 by 5.2
    hint_area: { x: 28.0, y: 72.0, r: 7 }
    danger: "Perilous for the Alliance (Nathanos, elite)"
    sources: "the Codex's nathanos-blightcaller page"
  - id: eastern-plaguelands-tirion
    tier: hidden
    creature: 1855   # Tirion Fordring, dump 7.6, 43.7; Wowhead 7.4, 43.6
    hint_area: { x: 10.1, y: 43.8, r: 5 }
    danger: "Quiet"
    sources: "the Codex's tirion-fordring and hearthglen pages"
  - id: eastern-plaguelands-hameya
    tier: hidden
    object: 177667   # dump 27.3, 85.2; Wowhead 27.3, 85.3
    hint_area: { x: 28.9, y: 81.5, r: 8 }
    danger: "Perilous (the infected trolls)"
    sources: "quest 6024"
# quarry: the zone's own, in the hunts' pass
---
## eastern-plaguelands-lights-hope
In the east of the dead country, a small stone chapel stands on hallowed ground,
and anyone who fights the dead finds a welcome there, whichever side they come from.
Do there what the ground was hallowed for.
? Light's Hope Chapel, in the east of the Eastern Plaguelands.
= Light's Hope Chapel, where the Argent Dawn holds out.
+ When Naxxramas appeared above the country, even the Scarlet Crusade met the Argent Dawn here to agree on something.

## eastern-plaguelands-egan
In a dreadful dale west of the burned city, a man draws his will to live
from his hatred of the dead, and spends it freeing them:
with a strange device he looses the souls that wander the city's streets,
and hopes his mother is among them. Find him.
? Terrordale, in the west of the Eastern Plaguelands.
= Egan, who has been 'doing miraculous work with ghosts and souls'.
+ Many of Stratholme's people threw themselves into the flames rather than join the Scourge. 'Did you see my mother? Did you free her?'

## eastern-plaguelands-pamela
In a village that stood and fought and fell, a little girl
still waits in her house, as her aunt told her to,
for the bravest father in the whole world to come back for her.
She will ask your name. Find her.
? Darrowshire, in the south of the Eastern Plaguelands.
= Pamela Redpath. Her father, Joseph, led Darrowshire in the battle against the Scourge.
+ 'Sometimes bad people come and whisper to me and I want my dad to make them go away, but he's not here!' She left her doll in town.

## eastern-plaguelands-marris-stead
In the south-west of the dead country, a ranger lord of the old kingdom,
the only man the high elves ever let train beside them,
keeps his own farmhouse again, dead, with his hounds of blight,
as champion of the Banshee Queen. Find his farm.
? The Marris Stead, in the south-west of the Eastern Plaguelands.
= The Marris Stead, Nathanos Blightcaller's old farmhouse.
+ Nathanos Marris, respected by all in life, died in the Plaguelands; he gives the Horde's hunters their errands now.

## eastern-plaguelands-tirion
Beside a river at the western edge of the dead country, a little hut
holds a man who was once a lord and a knight of the Light,
and gave both up rather than break an oath to an orc who saved his life.
Find the hut.
? On the bank of the Thondroril River, at the Eastern Plaguelands' western edge.
= Tirion Fordring, once lord of Mardenholde Keep.
+ There is little in his present lodging to suggest either distinction. His son Taelan serves the Scarlet Crusade at Hearthglen.

## eastern-plaguelands-hameya
Behind a crypt in the south, one who ate bad meat on the road to the trolls' village
felt a lich's words begin in his head,
and wrote a plea for death before his will left him.
Find the scroll.
? The Undercroft, in the south of the Eastern Plaguelands.
= Hameya's torn scroll: 'Kill me. Before it's too late.'
+ He buried a chest in the dirt beside a wagon behind the crypt, and kept the only key.
