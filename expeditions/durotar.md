---
zone: 1411   # Durotar
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: durotar-misha
    tier: near
    gestures: [COMFORT, SOOTHE]
    creature: 3193   # Misha Tor'kren, dump 43.1, 30.2; Wowhead 43.0, 30.2
    hint_area: { x: 41.3, y: 27.8, r: 6 }
    danger: "Quiet"
    sources: "quest 816"
  - id: durotar-tiragarde
    tier: off
    reading: Rise of the Horde
    object: 175742   # dump 59.6, 58.1; Wowhead 59.6, 58.2
    hint_area: { x: 61.2, y: 54.4, r: 8 }
    danger: "Guarded (Kul Tiran soldiers)"
    sources: "object 175742's text; quest 784; Warcraft III: Reign of Chaos (Durotar named for Durotan)"
  - id: durotar-dormant-flame
    tier: hidden
    object: 61934   # dump 39.0, 58.2; Wowhead 38.9, 58.2
    hint_area: { x: 35.5, y: 60.2, r: 8 }
    danger: "Quiet (the climb is the danger)"
    sources: "quests 1524, 1525, 1526"
quarry:
  id: 3205
  sources: "quests 826, 808 (Master Gadrin)"
---
## durotar-misha
North-west of the town on the razor's hill, a mother keeps a farm
and waits for a proud son who went to hunt the river's crocolisks
and stormed off when she warned him. He has not come back.
Find her, and be kind.
? Misha Tor'kren's farmstead, north-west of Razor Hill.
= Misha Tor'kren. Her son Kron went west to the Southfury after crocolisks.
+ 'Now that I know what's happened, perhaps I can finally begin to mourn.' She had a gift ready for his return, and cannot bear to look at it.

## durotar-tiragarde
In the keep the admiral's men took back on the red land's coast,
a history of the orcs lies among their enemies:
the arenas the warlocks built, the blood the chieftains drank,
and the one chieftain who would not.
? South of Razor Hill, Kul Tiras still holds a keep on Durotar's shore.
= Rise of the Horde, at Tiragarde Keep. Durotan alone refused Mannoroth's blood; this land bears his name.
+ The keep fell once, when the Horde threw back the Admiral's attack; his reserves, under Lieutenant Benedict, have retaken it since.

## durotar-dormant-flame
Along the river, before it meets the sea,
a hidden trail climbs one of the highest peaks in the land.
At the top a keeper watches a brazier a third your height,
unworn by the weather, its bowl cool to the touch.
? Above the Southfury, on Durotar's western side, a hidden trail climbs to a shrine of fire.
= The Brazier of the Dormant Flame, at the shrine Telf Joolam keeps.
+ Telf says many adventurers climb up looking for treasure or something to slay, and are turned away from a seemingly empty shrine. 'Fire is more than chaos and destruction. It is also about life, and creation.'

## quarry
The isles off the eastern shore were once a tribe's home.
A witchdoctor holds them now, and sends his hexed
across the water to drag more of their kin under his sway.
On the largest isle, skulls sit in his circle of power.
= Zalazane, the witchdoctor of the Echo Isles. Master Gadrin, in Sen'jin Village, wants his head; the trolls he hexed were Darkspear once.
+ Gadrin's own brother, Minshina, was taken by him, and his spirit bound in his skull until someone carried it out of the circle.
