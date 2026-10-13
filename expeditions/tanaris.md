---
zone: 1446   # Tanaris
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: tanaris-gadgetzan
    tier: near
    reading: Old Hatreds - The Colonization of Kalimdor
    object: 175763   # dump 51.0, 29.4, in Gadgetzan
    hint_area: { x: 51.5, y: 28.5, r: 3 }
    danger: "Quiet"
    sources: "object 175763's text"
  - id: tanaris-zalashji
    tier: off
    gestures: [WAVE, HELLO, GREET, BOW, HAIL]
    creature: 8617   # Zalashji, dump 67.7, 32.2, at his den
    hint_area: { x: 67.0, y: 33.0, r: 3 }
    danger: "Guarded (Wastewander bandits and steeljaw snappers nearby)"
    sources: "the WoWWiki archive's Zalashji page (friendly, no purpose anyone knows); the dump's spawn and faction (friendly to all)"
  - id: tanaris-winkey
    tier: hidden
    gestures: [WINK, SMILE, BLUSH]
    creature: 7770   # Winkey, dump 65.7, 64.2, alone on an islet
    hint_area: { x: 64.0, y: 63.0, r: 4 }
    danger: "Guarded (surf gliders and coast striders, level 48, in the shallows)"
    sources: "the WoWWiki archive's Winkey and Southbreak Shore pages; the dump's spawn and words; quest 3823's text (Oralius and his 'Winky')"
quarry:
  id: 8201   # Omgorn the Lost
  sources: "the WoWWiki archive's Omgorn the Lost page (one of three camps, a great axe); the pinned dump's spawns and creature_ai_scripts (16856 Mortal Strike)"
---
## tanaris-gadgetzan
In the desert's goblin town, find a daughter who chose the peace her father had come to break.
Their quarrel crossed an ocean before it ended.
The town keeps the account among its books.
? Gadgetzan.
= Old Hatreds - The Colonization of Kalimdor, in Gadgetzan: Durotar named for Thrall's father, and Jaina Proudmoore against her father, the Grand Admiral.
+ He died before she could reconcile with him. For her loyalty, the orcs let her forces go home to Theramore in peace.

## tanaris-zalashji
East of the goblins' town, a naga keeps a den in the rocks,
and wants nothing at all from you: no war, no treasure, no blood.
Be friendly, for once.
? Zalashji's Den, east of Gadgetzan.
= Zalashji, a naga at home in his den: friendly to all, and wanting nothing from anyone.
+ Horde and Alliance alike may walk up to him unharmed, as to few naga anywhere.

## tanaris-winkey
Off the quiet beach south of the pirates' cove, a little island holds one gnome, alone,
sunning herself as if the whole sea were her garden.
She has one request for whoever swims out to her. Be nice.
? An islet off Southbreak Shore, south of Lost Rigger Cove.
= Winkey, a gnome alone on her islet off Southbreak Shore: 'Hey there, cutie! Mind rubbing some lotion on my exposed areas?'
+ Far away in the Burning Steppes, a dwarf at Morgan's Vigil grabs at the air and shouts at someone called Winky who isn't there. Whether he means her, nobody can say.

## quarry
The ogres of the southern desert hold three camps among old troll ruins.
An ogre with a great axe may be found at any one of them.
Lost, they call him. He has company enough wherever he turns up.
= Omgorn the Lost, a Dunemaul ogre, in the Dunemaul Compound, the Eastmoon Ruins or the Southmoon Ruins.
+ His axe leaves wounds that resist healing.
