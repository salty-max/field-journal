---
zone: 1421   # Silverpine Forest
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: silverpine-forest-wallace
    tier: off
    gestures: [HELLO, HAIL, GREET]
    creature: 3534   # Wallace the Blind, dump 46.5, 86.5, among the refugees under the Greymane Wall
    hint_area: { x: 45.0, y: 84.0, r: 5 }
    danger: "Guarded for the Horde (the refugees, levels 18 to 20, are Lordaeron's own), quiet for the Alliance"
    sources: "the dump's spawns and factions (Wallace friendly to all, the refugees to the Alliance alone); the WoWWiki archive's Greymane Wall and Wallace the Blind pages; Warcraft II: Beyond the Dark Portal's manual (the wall)"
quarry:
  id: 1948   # Snarlmane
  sources: "the WoWWiki archive's Snarlmane page; Warcraft III: The Frozen Throne, 'The Dark Lady' (Snarlmane possessed); the dump's spawn"
---
## silverpine-forest-wallace
At the forest's southern end, a wall of grey stone shuts a kingdom in.
Under it, the plague's refugees wait for a gate that does not open,
and among them a smith sells blades to anyone at all:
he cannot see which side you are on. Don't bother waving.
? Under the Greymane Wall, at the south end of Silverpine, among the refugees.
= Wallace the Blind, weaponsmith to Horde and Alliance alike, under the Greymane Wall: Gilneas keeps its gate shut on the refugees at its foot.
+ Gilneas raised the wall after the Second War, when Genn Greymane quit the Alliance over the cost of the orcs' internment camps.

## quarry
On the isle in the lake, the Rot Hide dead hold an old keep.
Down in its cellar, one of them still has a name,
and a gnoll of that name once led a living pack in the Glades,
until the Dark Lady needed it more than he did.
= Snarlmane, a dead gnoll of the Rot Hide, in the cellar of Fenris Keep.
+ In the Third War, Sylvanas set a banshee in the mind of a gnoll chieftain called Snarlmane, and spent his pack against the dreadlord Varimathras. If this is he, someone raised him again.
