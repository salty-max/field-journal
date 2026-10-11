---
zone: 1417   # Arathi Highlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: arathi-highlands-goshek-watchers
    tier: near
    gestures: [SILENCE, SNEAK]
    creature: 2712   # Quae, dump 60.2, 53.8; Wowhead 60.2, 53.8
    hint_area: { x: 58.8, y: 51.1, r: 6 }
    danger: "Guarded (the orcs of the farm)"
    sources: "quests 659, 658, 661"
  - id: arathi-highlands-inner-binding
    tier: off
    object: 2702   # dump 36.2, 57.4; Wowhead's page alike
    hint_area: { x: 39.7, y: 55.4, r: 8 }
    danger: "Guarded"
    sources: "quests 651, 652, 656"
  - id: arathi-highlands-lolo
    tier: off
    gestures: [WAVE, GREET, HELLO]
    creature: 2766   # Lolo the Lookout, dump 31.8, 82.7; Wowhead 31.4-31.8, 82.4-82.6
    hint_area: { x: 28.9, y: 83.6, r: 6 }
    danger: "Guarded (naga in the water)"
    sources: "quests 663, 664"
  - id: arathi-highlands-trollbane
    tier: hidden
    gestures: [KNEEL]
    object: 2703   # dump 28.9, 59.6; Wowhead's page alike
    hint_area: { x: 27.9, y: 63.5, r: 8 }
    danger: "Perilous (Stromgarde's Syndicate and ogres)"
    sources: "quests 639, 645, 646"
  - id: arathi-highlands-refuge-pointe
    tier: town
    faction: alliance   # its town's: for that faction alone
    creature: 2700   # Captain Nials, dump 45.8, 47.6; Wowhead 45.8, 47.6
    hint_area: { x: 48.2, y: 46.9, r: 5 }
    danger: "Quiet"
    sources: "quest 681"
  - id: arathi-highlands-hammerfall
    tier: town
    faction: horde   # its town's: for that faction alone
    gestures: [SALUTE, BOW]
    creature: 2792   # Gor'mul, dump 72.6, 33.9; Wowhead 72.6, 34.0
    hint_area: { x: 70.3, y: 32.8, r: 5 }
    danger: "Quiet"
    sources: "quests 655, 672, 675"
quarry:
  id: 2783
  sources: "quests 684 (Refuge Pointe's poster), 673 (Tor'gan)"
---
## arathi-highlands-goshek-watchers
Above a farm the orcs work for the dead, two companions from the southern shore
keep watch for days, for a friend who saw his cousin's dog grow monstrous.
Orcs do not take kindly to being spied on.
Find their hiding place without giving it away.
? Above the Go'Shek Farm, east of Refuge Pointe.
= Quae and Kinelory, Phin Odelic's companions from Southshore.
+ 'I've seen Kinelory look way worse after a night in the tavern than she does now.' Quae, after the raid on the farm.

## arathi-highlands-inner-binding
Four rings of stone pin a princess of the earth beneath the highlands.
Through a shard she pleads to be freed, and calls whoever helps her noble.
Ask why the giants chained her in the first place.
Find the innermost ring.
? The Circle of Inner Binding, south-west of Refuge Pointe.
= The Stone of Inner Binding, Myzrael's prison. Her gratitude, she promised, would 'shake the very foundations of the earth'.
+ 'If she can be controlled then why did the giants chain her in the first place?? Crazy logic, eh?'

## arathi-highlands-lolo
In a cove on the south-west coast, a ship rides at anchor,
and two others lie broken on a reef that was not only a reef.
High above the deck, someone is always on the lookout,
and has seen you long before you are seen.
? Faldir's Cove, on Arathi's south-west coast; the lookout calls out to everyone spotted.
= Lolo the Lookout, of Captain O'Breen's Harbinger.
+ The Spirit of Silverpine and the Maiden's Folly went down when the sea rumbled and the tide fell; the Maiden's captain wishes he had gone down with her.

## arathi-highlands-trollbane
Behind the chapel of a fallen city of men, in a sanctum,
a lord of Strom the trolls named Trollbane lies in his tomb,
and the stone hands of it held the sword the trolls feared most.
Pay him the respect of the kingdom he defended.
? Stromgarde Keep, in the Sanctum behind its chapel.
= Trollbane's tomb. The sword Trol'kalar sat in its stone hands.
+ The Horde's trolls took the sword for their war in Zul'Gurub: 'For generations, the forces of Strom and Arathor ravaged the trolls. Now their greatest weapon is in our hands.'

## arathi-highlands-refuge-pointe
On a rise in the middle of the highlands, the last soldiers of a great city
hold a camp and count their losses:
ogres, the Syndicate and they divide what is left of their home.
Find their captain.
? Refuge Pointe.
= Captain Nials, of the Stromgarde militia.
+ 'We are fighting a war for Stromgarde, and we are losing.' The supplies from Southshore rarely get through the Syndicate's ground.

## arathi-highlands-hammerfall
In the Horde's camp in the highlands, inside the walls of an old prison,
a grey warrior who was a captive here saw his Warchief struck down from behind.
When the camp was freed he was left behind, and he has not forgiven fate for sparing him.
Honour him as his Warchief would have.
? Hammerfall.
= Gor'mul, once a captive of the camp that is Hammerfall now.
+ 'Mercy was denied me when I was not allowed to die with my Warchief in battle.' Tor'gan still believes the shamans' power will return him to his once proud self.

## quarry
Within the walls of Stromgarde, which the Syndicate holds,
a warlock trafficks with demons, and calls them up in numbers
through a bloodstone orb the orcs of Hammerfall would see destroyed.
Refuge Pointe has posted her head, and advises extreme caution.
= Marez Cowl, a high-level advisor and operative of the Syndicate. Captain Nials at Refuge Pointe pays for her head; Tor'gan in Hammerfall wants the orb.
+ Refuge Pointe has heard she carried messages between the Syndicate and some other, darker power.
