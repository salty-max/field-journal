---
zone: 1426   # Dun Morogh
home: alliance   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: dun-morogh-etched-note
    tier: near
    reading: Etched Note
    object: 174746   # dump 52.5, 37.1; Wowhead 52.6, 37.1
    hint_area: { x: 49.8, y: 34.1, r: 8 }
    danger: "Quiet"
    sources: "object 174746's text; quests 1650, 1652, 1653, 1806"
  - id: dun-morogh-tundra
    tier: near
    creature: 1266   # Tundra MacGrann, dump 34.6, 51.7; Wowhead 34.6, 51.6
    hint_area: { x: 33.0, y: 49.2, r: 6 }
    danger: "Quiet"
    sources: "quest 312"
  - id: dun-morogh-brewnall
    tier: off
    gestures: [TOAST, DRINK, CHUG]
    area: Brewnall Village   # placed: Rejold Barleybrew, dump 30.2, 45.7; Wowhead 30.2, 45.8
    hint_area: { x: 27.5, y: 43.5, r: 7 }
    danger: "Quiet"
    sources: "quests 310 (the Barleybrews' rivalry with the Thunderbrews), 318, 319"
  - id: dun-morogh-onin
    tier: off
    gestures: [SILENCE, SNEAK]
    creature: 6886   # Onin MacHammar, dump 25.2, 44.5; Wowhead 25.2, 44.4
    hint_area: { x: 24.3, y: 47.4, r: 6 }
    danger: "Guarded (leper gnomes)"
    sources: "quests 2238, 412"
  - id: dun-morogh-mori
    tier: hidden
    gestures: [MOURN, KNEEL, SALUTE]
    object: 2059   # dump 79.7, 36.2; Wowhead 79.7, 36.2
    hint_area: { x: 80.7, y: 40.1, r: 8 }
    danger: "Guarded (Ice Claw Bears; Mangeclaw)"
    sources: "quests 419, 417"
# quarry: the zone's own, in the hunts' pass
---
## dun-morogh-etched-note
Below the great gates, where every traveller climbs,
a smith has claimed an anvil in writing,
politely, and very firmly.
Find what he etched beside it.
? At the foot of the road up to Ironforge, an anvil has an owner, and says so.
= 'This anvil is the property of Jordan Stilwell - Please do NOT use!' Ironforge has a great many anvils. This one is spoken for.
+ Jordan Stilwell is no dwarf: a human smith with a house on Westfall's Longshore, who meant to be a paladin before smithing took him, and came to work beside the dwarves while his wife, Daphne, waited by the sea. The paladins who pass his tests carry a hammer he forges and names for a dwarven paladin he called a friend.

## dun-morogh-tundra
In the valley of the chill wind, an old hunter with a bad leg
lost a month of salted meat to a bear he calls Old Icebeard.
The locker is thorium, and the bear can't open it;
neither can the hunter reach the cave to take it back. Find his camp.
? Chill Breeze Valley, on the road west of Kharanos.
= Tundra MacGrann. He will starve when the cold season comes unless someone fetches his meat from Old Icebeard's cave.
+ He kept the meat locked away so the bears wouldn't get it; Old Icebeard carried off the whole locker while he was out hunting deer.

## dun-morogh-brewnall
West of the town of the thunder brewers, a rival family brews
what the cold road needs: one brew to keep a traveller warm,
another to lay all but the stoutest dwarf flat.
Find their casks, and do what casks are for.
? Rejold Barleybrew brews west of Kharanos; his casks are not there to be looked at.
= Brewnall Village, where Rejold Barleybrew tries what a careful brewer would not. Some of it tastes good.
+ Evershine burns so hot that Pilot Bellowfiz throws it in his engine's furnace for a burst of power, and swears it has got him out of more than one tight spot.

## dun-morogh-onin
Before the gate of the gnomes' poisoned city, among the lepers,
a dwarf hides who reports to a circle of thieves:
they think the king's quarry holds more than one king should keep.
He would rather not be noticed. Find him without giving him away.
? Outside Gnomeregan, among the leper gnomes, someone is not a gnome, and would rather nobody noticed.
= Onin MacHammar, of the Hidden Circle: 'Shhhh! Keep it down you daft fool. They'll hear us.'
+ Gnomeregan's engineers flooded their own city to stop the troggs, and turned most of their people into leper gnomes; two of them, in Kharanos, are building a machine to turn them back.

## dun-morogh-mori
A pilot of the siege engines drove up a hill too steep,
went on alone for the ore he was sure of,
and met a great bear of the ice claws.
The cold kept him where he fell, on the eastern heights;
his friend still waits by the engines.
? Pilot Hammerfoot guards the engines in the east; his friend went on foot into the hills.
= Mori Hildelve, of the Ironforge Siege Brigade: mauled, frozen, his journal still in his hand. It asks for one thing, revenge on Mangeclaw.
+ He was searching for a rare ore needed for a high-grade blastpowder. He drove the bear off once; it came back.
