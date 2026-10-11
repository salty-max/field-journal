---
zone: 1443   # Desolace
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: desolace-kodo-graveyard
    tier: near
    gestures: [BOW, KNEEL]
    area: Kodo Graveyard   # placed: the client's overlay: 50.6, 58.0, half-size 7.2 by 9.4
    hint_area: { x: 49.0, y: 59.0, r: 11 }
    danger: "Quiet"
    sources: "the Codex's kodo-graveyard page; quest 5561"
  - id: desolace-rackmore
    tier: off
    object: 177787   # dump 36.1, 30.4; Wowhead 36.1, 30.4
    hint_area: { x: 33.6, y: 27.2, r: 8 }
    danger: "Guarded (the coast's creatures)"
    sources: "quest 6161"
  - id: desolace-mannoroc-coven
    tier: off
    area: Mannoroc Coven   # placed: the client's overlay: 53.4, 79.3, half-size 8.0 by 9.0
    hint_area: { x: 52.0, y: 77.0, r: 11 }
    danger: "Perilous (demons)"
    sources: "the Codex's mannoroc-coven page; quest 5581"
  - id: desolace-dalinda
    tier: hidden
    where: { x: 54.9, y: 26.1, r: 1 }   # Dalinda Malem, dump 54.9, 26.1; Wowhead 54.8, 26.2 (she walks only when escorted)
    hint_area: { x: 57.4, y: 26.4, r: 5 }
    danger: "Perilous (the Burning Blade)"
    sources: "quests 1437, 1438"
  - id: desolace-nijels-point
    tier: town
    faction: alliance   # its town's: for that faction alone
    where: { x: 66.4, y: 11.8, r: 1 }   # Vahlarriel Demonslayer, dump 66.4, 11.8; Wowhead 66.4, 11.8
    hint_area: { x: 68.7, y: 12.7, r: 5 }
    danger: "Quiet"
    sources: "quests 1437, 1465"
  - id: desolace-shadowprey
    tier: town
    faction: horde   # its town's: for that faction alone
    where: { x: 25.8, y: 68.2, r: 1 }   # Taiga Wisemane, dump 25.8, 68.2; Wowhead 25.8, 68.2
    hint_area: { x: 28.2, y: 67.6, r: 5 }
    danger: "Quiet"
    sources: "quest 5581; the Codex's shadowprey-village page"
# quarry: the zone's own, in the hunts' pass
---
## desolace-kodo-graveyard
In the middle of the grey country, the great beasts of the plains
come from far away to lie down among the bones of those before them,
and nobody knows why. Walk among them as their people do.
? The Kodo Graveyard, in the middle of Desolace.
= The Kodo Graveyard.
+ Old kodos still lumber in from the plains to lie down there; a goblin of the Gizelton caravan has found a way to jolt the dying ones back to work.

## desolace-rackmore
On the north-western shore, a captain's log lies among the wrecks.
His ship was bound for the moon-elves' island when the sea's creatures took it,
and before they could take his treasure, he hid it on an isle.
Find the log.
? Ethel Rethor, on Desolace's north-west coast.
= Rackmore's log.
+ His chest on Ranazjar Isle wants two keys, a silver and a gold, both lost.

## desolace-mannoroc-coven
In the south of the grey country, demons walk openly in a scorched valley
among broken altars and green fire,
and they did not come there by chance. Find where they were let in.
? The Mannoroc Coven, in the south of Desolace.
= The Mannoroc Coven.
+ The Burning Blade let them in; at Shadowprey Village, Taiga Wisemane sends hunters to banish their portals.

## desolace-dalinda
In a fortress of demon-worshipping orcs in the north,
a daughter of a merchant house waits to be given to their masters.
She came against her people's wishes, after a brother hungry for magic.
Find her.
? Thunder Axe Fortress, in the north of Desolace.
= Dalinda Malem, of House Malem of Darnassus.
+ 'Tyranis has recently begun craving knowledge of all things arcane, even against the wishes of our people.' Vahlarriel's superiors cared more that Dalinda be found than her brother.

## desolace-nijels-point
At the Alliance's camp under the northern mountains, an agent from the tree city
has come to find two missing children of a merchant house,
and hopes not to be here long. Find him.
? Nijel's Point.
= Vahlarriel Demonslayer, searching for Tyranis and Dalinda Malem.
+ Their wagon was found attacked by spells and weapons, with no blood and no bodies, and footprints leading south toward a fort.

## desolace-shadowprey
In the village on stilts by the western sea, a shaman keeps
a gruesome hand that can close the doors the demons come through.
Find him.
? Shadowprey Village.
= Taiga Wisemane, keeper of the Hand of Iruxos.
+ 'Your effort has helped greatly in fighting the demon threat, and all of Azeroth is safer because of it.'
