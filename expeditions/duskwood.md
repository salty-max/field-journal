---
zone: 1431   # Duskwood
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: duskwood-twilight-grove
    tier: near
    gestures: [SLEEP, LAYDOWN]
    area: Twilight Grove   # placed: the client's overlay: 47.7, 40.4, half-size 10.7 by 18.7
    hint_area: { x: 46.0, y: 43.0, r: 14 }
    danger: "Quiet; perilous when a dragon of the Nightmare is there"
    sources: "the Codex's dragons-of-nightmare page; quests 8446, 8447"
  - id: duskwood-eliza
    tier: off
    reading: Eliza's Tombstone
    object: 37   # dump 28.9, 30.5; Wowhead 28.8, 30.4
    hint_area: { x: 32.7, y: 29.2, r: 8 }
    danger: "Guarded (Raven Hill's dead)"
    sources: "object 37's text; quest 253; the Codex's the-embalmer page"
  - id: duskwood-mistmantle
    tier: off
    area: Manor Mistmantle   # placed: the client's overlay: 74.4, 33.7, half-size 5.0 by 4.5; Stalvan (creature 315), dump 77.3, 36.2
    hint_area: { x: 75.5, y: 35.0, r: 8 }
    danger: "Guarded (Stalvan and the manor's dead)"
    sources: "quests 66-98"
  - id: duskwood-morgan-ladimore
    tier: hidden
    gestures: [KNEEL, MOURN, PRAY]
    object: 61   # dump 17.7, 29.1; Wowhead 17.7, 29.2
    hint_area: { x: 15.1, y: 32.2, r: 8 }
    danger: "Guarded; Mor'Ladim (elite) wanders near"
    sources: "quests 225, 228, 229, 231; the Codex's morladim page"
  - id: duskwood-darkshire
    tier: town
    faction: alliance   # its town's: for that faction alone
    where: { x: 75.8, y: 45.3, r: 1 }   # Madame Eva, dump 75.8, 45.3; Wowhead 75.8, 45.2
    hint_area: { x: 74.9, y: 47.6, r: 5 }
    danger: "Quiet"
    sources: "quests 66, 98"
quarry: 522   # Mor'Ladim (verified on Wowhead Classic)
---
## duskwood-twilight-grove
In the heart of the dark wood a great tree stands apart:
a door the dreaming druids walk through to the Emerald Dream.
Green dragons were set to keep it; the Nightmare took the keepers.
The door opens for those who go the druids' way.
? The road through the forest bends around something older than the town.
= One of four such trees in the world, the green dragonflight's doors into the Emerald Dream. Its guardians came back from the Dream changed.
+ Keeper Remulos, in the Moonglade, cleanses the corruption the dragons leave behind in Lake Elune'ara; it may explain why he can no longer reach into the Dream.

## duskwood-eliza
A kindly man of potions lost his wife,
and would not let her go; he gave her his own heart.
It woke her hungry, so he keeps her in the earth
above the hill of ravens, under a stone with a few kind words.
? An old hermit's shack overlooks the graves of Raven Hill; he did not come alone.
= 'Beloved wife, may the earth sate your hunger.' The Embalmer meant it kindly, I think, which is the worst of it.
+ Darkshire tells his story to its children. His heart, taken back from her grave, would be 'a powerful aegis over the town'.

## duskwood-mistmantle
North of the town of the Night Watch stands the house
of a tutor who once wrote, cheerfully, of the fields of Moonbrook.
The Watch hunted him for years, and the town's seer saw Death in her cards.
Find his house.
? Manor Mistmantle, north of Darkshire.
= Manor Mistmantle, Stalvan's house. The letter in the Moonbrook footlocker was his.
+ Stalvan Mistmantle 'led a life of depravity. Innocent victims died by his hand'; the trail to him runs from a Stormwind registry through Moonbrook, Goldshire and Eastvale.

## duskwood-morgan-ladimore
He came home from the plague to a grave on the hill,
and grief made a killer of a good man's will.
They buried him quickly, past the house on the rise,
outside the hallowed ground, where nobody grieves for him.
? Not every grave of Raven Hill lies inside its walls.
= The marker says only MORGAN LADIMORE. The earth over it has been disturbed: he did not stay.
+ The forest has worn his name down to Mor'Ladim. His daughter Sarah lived, and serves in the Night Watch; laid on this grave, her ring tells him so, and puts him to rest.

## duskwood-darkshire
In the town of the Night Watch, an old woman reads the cards.
She felt her granddaughter in danger one night,
and when she laid them out, Death looked up at her. Find her table.
? Darkshire.
= Madame Eva. Her premonition set the trail to Stalvan going.
+ When Stalvan died, she 'sensed a wave of hope ripple through the tainted forest'.

## quarry
The forest calls him by half a name,
the rest worn off like letters from a stone.
He walks among the graves of the hill he came home to,
and kills whoever he meets. Find the stone, and you will know him.
= Not a beast, and no rare in the Bestiary's sense. The Night Watch wants him laid to rest, and his daughter serves in it. Go with company.
+ Some of Darkshire's strongest Watchers have been lost to him; the Night Watch buried him past the house on the hill, and he did not stay there.
