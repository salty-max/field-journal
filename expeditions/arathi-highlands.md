---
zone: 1417   # Arathi Highlands
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: arathi-highlands-thoradins-wall
    tier: off
    gestures: [GAZE, PONDER, THINK, SIGH, LOOK]
    area: Thoradin's Wall   # placed: the client's overlay: 17.7, 37.8, half-size 5.2 by 10.9
    hint_area: { x: 18.5, y: 39.0, r: 9 }
    danger: "Guarded (highland striders, thrashers and creepers)"
    sources: "Lands of Conflict, pp. 88-89 (a symbol of humanity's strength, collapsed and gaping); World of Warcraft: Chronicle, vol. 1, p. 126 (Thoradin's wall against the Amani)"
  - id: arathi-highlands-hammerfall
    tier: town
    faction: horde   # its town's: for that faction alone
    reading: Rise of the Blood Elves
    object: 175760   # dump 74.1, 32.4
    hint_area: { x: 73.0, y: 34.0, r: 4 }
    danger: "Quiet"
    sources: "object 175760's text"
quarry:
  id: 2600   # Singer
  sources: "the WoWWiki archive's Singer page (the Syndicate's mask, Dominate Mind); the dump's spawn and faction (not the Syndicate's)"
---
## arathi-highlands-thoradins-wall
On the highlands' north-western edge, a wall of the first kingdom of men
runs along the border, over the hills, as far as it can see.
It was raised against the trolls, long ago. Now it gapes, broken through.
Go to its foot, and take in what is left.
? Arathi's north-western edge, where the highlands meet the foothills. At the broken wall, ponder what it once kept out.
= Thoradin's Wall, raised by King Thoradin of Arathor, the first kingdom of men, against the Amani trolls, broken now and gaping wide.
+ 'Once a symbol of humanity's strength and defensive might,' an old survey of these lands calls it, 'now fallen to decay and war.'

## arathi-highlands-hammerfall
In the Horde's highland camp, seek the elves who named themselves for their dead.
Their kingdom was lost, but the name travelled with them.
The story is kept on a page.
? Hammerfall. Open the book about the elves' new name.
= Rise of the Blood Elves, in Hammerfall: Kael'thas's high elves, renamed blood elves, cast out by the Alliance and gone to Outland with Illidan.
+ Cut off from the Sunwell, they hungered for magic. Looking for a cure is what led Kael'thas to Illidan and his naga.

## quarry
On the farm at Northfold, among the Syndicate's cutthroats,
stands a woman in one of their masks. She is not of their number.
Come close and she may take your mind for a while.
Her name is all anyone knows of her.
= Singer, at Northfold Manor, masked like the Syndicate around her and none of theirs.
+ Her hold on a mind reaches any humanoid up to level twenty-five: come older than that, and she has nothing over you.
