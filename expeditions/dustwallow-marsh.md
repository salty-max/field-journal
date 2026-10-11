---
zone: 1445   # Dustwallow Marsh
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: dustwallow-marsh-shady-rest
    tier: near
    object: 20992   # dump 29.6, 48.6; Wowhead 29.6, 48.5
    hint_area: { x: 28.8, y: 44.7, r: 8 }
    danger: "Quiet"
    sources: "quests 1251, 1253, 1320, 1301, 1302; the Codex's shady-rest-inn page"
  - id: dustwallow-marsh-nat-pagle
    tier: hidden
    gestures: [SIT]
    creature: 12919   # Nat Pagle, dump 58.6, 60.1; Wowhead 58.6, 60.0
    hint_area: { x: 57.1, y: 58.1, r: 5 }
    danger: "Quiet"
    sources: "quest 6607"
  - id: dustwallow-marsh-theramore
    tier: town
    faction: alliance   # its town's: for that faction alone
    gestures: [BOW, CURTSEY]
    creature: 4968   # Lady Jaina Proudmoore, dump 66.3, 49.0; Wowhead 66.2, 49.0
    hint_area: { x: 64.0, y: 48.0, r: 5 }
    danger: "Quiet"
    sources: "the Codex's jaina-proudmoore and theramore-isle pages"
  - id: dustwallow-marsh-brackenwall
    tier: town
    faction: horde   # its town's: for that faction alone
    creature: 4500   # Overlord Mok'Morokk, dump 36.3, 31.4; Wowhead 36.2, 31.4
    hint_area: { x: 37.8, y: 33.4, r: 5 }
    danger: "Quiet"
    sources: "the Codex's brackenwall-village page"
quarry:
  id: 4841
  sources: "quest 1205 (Melor Stonehoof)"
---
## dustwallow-marsh-shady-rest
On the road from the plains to the island city, an inn where both sides drank
burned down, and only its chimney still stands.
Someone fixed an iron shield to it. Find the shield.
? The Shady Rest Inn, on the road from the Barrens to Theramore.
= The black shield on the Shady Rest's chimney. Its strap was made for someone very large.
+ The inn was James Hyal's, a fine cook who crossed the sea with Lady Proudmoore after working in Menethil Harbor; the investigators of both sides keep finding things that do not fit together.

## dustwallow-marsh-nat-pagle
On an island in the marsh, the greatest fisherman of the age
says he does not much enjoy fishing, after twenty or thirty years of it.
The secret, he says, is the patience to do nothing for hours.
Find him, and show him you have it.
? An island in the middle of Dustwallow Marsh.
= Nat Pagle, Angler Extreme.
+ 'I reckon you just need to be determined - determined enough to sit on your duff for hours at a time, doin' nothin'.'

## dustwallow-marsh-theramore
In the white city on the island, the sorceress who would not follow a prince into a burning city
led what was left of her people across the sea,
and made a peace with the Horde no one thought possible.
Pay her the courtesy a lady of her rank is owed.
? Theramore Isle, in Foothold Citadel.
= Lady Jaina Proudmoore, ruler of Theramore.
+ Not all of the soldiers who crossed the sea with her, Kul Tiran marines among them, have made their peace with her peace.

## dustwallow-marsh-brackenwall
In the Horde's camp in the north of the marsh, an ogre
was made overlord of his clan by the beastmaster,
and his ogres will tell you so, often. Find the overlord.
? Brackenwall Village.
= Overlord Mok'Morokk, of the Stonemaul.
+ The Stonemaul are allies of the Horde thanks to Rexxar, who made Mok'Morokk their leader.

## quarry
An ancient crocolisk drags his huge body through the marsh;
his old bones grind, though he still moves with the speed of youth,
and his great spirit lives on in a body that tortures it.
The tauren would see him led to peace. He keeps to the quagmire.
= Deadmire. Melor Stonehoof, in Thunder Bluff, asks for his tooth: it is time the noble creature's pain ended.
+ Melor knows the hunt is not easy, and is glad of it only because the beast's pain is over.
