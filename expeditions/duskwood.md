---
zone: 1431   # Duskwood
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: duskwood-near
    tier: near
    area: Twilight Grove   # placed: the client's overlay: 47.7, 40.4, half-size 10.7 by 18.7
    hint_area: { x: 46.0, y: 43.0, r: 14 }
    danger: "Quiet; perilous when a dragon of the Nightmare is there"
    sources: "the Codex's dragons-of-nightmare page; quests 8446, 8447"
  - id: duskwood-off
    tier: off
    reading: Eliza's Tombstone
    object: 37   # dump 28.9, 30.5; Wowhead 28.8, 30.4
    hint_area: { x: 32.7, y: 29.2, r: 8 }
    danger: "Guarded (Raven Hill's dead)"
    sources: "object 37's text; quest 253; the Codex's the-embalmer page"
  - id: duskwood-hidden
    tier: hidden
    gesture: KNEEL
    object: 61   # dump 17.7, 29.1; Wowhead 17.7, 29.2
    hint_area: { x: 15.9, y: 32.7, r: 8 }
    danger: "Guarded; Mor'Ladim (elite) wanders near"
    sources: "quests 225, 228, 229, 231; the Codex's morladim page"
quarry: 522   # Mor'Ladim (verified on Wowhead Classic)
---
## duskwood-near
In the heart of the dark wood a great tree stands apart:
a door the sleeping druids walk through to the Dream.
Green dragons were set to keep it; the Nightmare took the keepers.
Stand beneath its boughs, and hope they are elsewhere.
? The road through the forest bends around something older than the town.
= One of four such trees in the world, the green dragonflight's doors into the Emerald Dream. Its guardians came back from the Dream changed.
+ Keeper Remulos, in the Moonglade, gathers the corruption the dragons leave behind, and cleanses it in Lake Elune'ara; it may explain why he can no longer reach into the Dream.

## duskwood-off
A kindly man of potions lost his wife,
and would not let her go; he gave her his own heart.
It woke her hungry, so he keeps her in the earth
above the hill of ravens. Read her stone.
? An old hermit's shack overlooks the graves of Raven Hill; he did not come alone.
= 'Beloved wife, may the earth sate your hunger.' The Embalmer meant it kindly, I think, which is the worst of it.
+ Darkshire tells his story to its children. His heart, taken back from her grave, would be 'a powerful aegis over the town'.

## duskwood-hidden
He came home from the plague to a grave on the hill,
and grief made a killer of a good man's will.
They buried him quickly, past the house on the rise,
outside the hallowed ground. Kneel where the grave lies.
? Not every grave of Raven Hill lies inside its walls.
= The marker says only MORGAN LADIMORE. The earth over it has been disturbed: he did not stay.
+ The forest has worn his name down to Mor'Ladim. His daughter Sarah lived, and serves in the Night Watch; laid on this grave, her ring tells him so, and puts him to rest.

## quarry
The forest calls him by half a name,
the rest worn off like letters from a stone.
He walks among the graves of the hill he came home to,
and kills whoever he meets. Read the stone, and you will know him.
= Not a beast, and no rare in the Bestiary's sense. The Night Watch wants him laid to rest, and his daughter serves in it. Go with company.
+ Some of Darkshire's strongest Watchers have been lost to him; the Night Watch buried him past the house on the hill, and he did not stay there.
