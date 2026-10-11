---
zone: 1426   # Dun Morogh
home: alliance   # a starting zone: its riddles are its faction's alone, as a capital's
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: dun-morogh-near
    tier: near
    reading: Etched Note
    object: 174746   # dump 52.5, 37.1; Wowhead 52.6, 37.1
    hint_area: { x: 53.2, y: 41.0, r: 8 }
    danger: "Quiet"
    sources: "object 174746's text; quests 1650, 1652, 1653, 1806"
  - id: dun-morogh-off
    tier: off
    area: Brewnall Village   # placed: Rejold Barleybrew, dump 30.2, 45.7; Wowhead 30.2, 45.8
    hint_area: { x: 27.8, y: 43.1, r: 7 }
    danger: "Quiet"
    sources: "quests 318, 319, 415; Rejold Barleybrew (creature 1374) places the hint"
  - id: dun-morogh-hidden
    tier: hidden
    gesture: KNEEL
    object: 2059   # dump 79.7, 36.2; Wowhead 79.7, 36.2
    hint_area: { x: 76.0, y: 37.7, r: 8 }
    danger: "Guarded (Ice Claw Bears; Mangeclaw)"
    sources: "quests 419, 417"
# quarry: the zone's own, in the hunts' pass
---
## dun-morogh-near
Below the great gates, where every traveller climbs,
a smith has claimed an anvil in writing,
politely, and very firmly.
Read what he etched beside it.
? At the foot of the road up to Ironforge, an anvil has an owner.
= 'This anvil is the property of Jordan Stilwell - Please do NOT use!' Ironforge has a great many anvils. This one is spoken for.
+ Jordan Stilwell is no dwarf: a human smith with a house on Westfall's Longshore, who meant to be a paladin before smithing took him, and came to work beside the dwarves while his wife, Daphne, waited by the sea. The paladins who pass his tests carry a hammer he forges and names for a dwarven paladin he called a friend.

## dun-morogh-off
West of the town of the thunder brewers, a hamlet brews
what the cold road needs: one drink to keep a traveller warm,
another to lay all but the stoutest dwarf flat,
and the bears and cats of the snows wander close to the casks.
Find where the brewing is done.
? Rejold Barleybrew brews in a hamlet west of Kharanos.
= Brewnall Village, where Rejold Barleybrew tries what a careful brewer would not. Some of it tastes good.
+ Evershine burns so hot that Pilot Bellowfiz throws it in his engine's furnace for a burst of power, and swears it has got him out of more than one tight spot.

## dun-morogh-hidden
A pilot of the siege engines drove up a hill too steep,
went on alone for the ore he was sure of,
and met a great bear of the ice claws.
The cold kept him where he fell, on the eastern heights. Kneel by him.
? Pilot Hammerfoot still guards the engines in the east, and waits for his friend.
= Mori Hildelve, of the Ironforge Siege Brigade: mauled, frozen, and his journal still in his hand. It asks for one thing, revenge on Mangeclaw.
+ He was searching for a rare ore needed for a high-grade blastpowder. He drove the bear off once; it came back.
