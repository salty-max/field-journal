---
zone: 1452   # Winterspring
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: winterspring-remorseful
    tier: near
    creature: 10684   # the Remorseful Highborne, dump 56.1, 44.4; Wowhead 56.2, 44.4
    hint_area: { x: 57.5, y: 46.5, r: 5 }
    danger: "Guarded (the Highborne ghosts)"
    sources: "quests 5248, 5252; the Codex's ruins-of-keltheril page"
  - id: winterspring-jaron
    tier: off
    object: 175586   # dump 61.4, 60.7; Wowhead 61.4, 60.6
    hint_area: { x: 64.3, y: 63.5, r: 8 }
    danger: "Perilous (the wildkin)"
    sources: "quest 4861; the Codex's mazthoril page"
  - id: winterspring-lorax
    tier: off
    creature: 10918   # Lorax, dump 63.8, 73.8; Wowhead 63.8, 73.8
    hint_area: { x: 65.6, y: 75.5, r: 5 }
    danger: "Perilous"
    sources: "quest 5126"
  - id: winterspring-umbranse
    tier: hidden
    creature: 8588   # Umbranse the Spiritspeaker, dump 67.8, 27.4; Wowhead 67.8, 27.4
    hint_area: { x: 65.6, y: 28.5, r: 5 }
    danger: "Quiet"
    sources: "quest 3512"
# quarry: the zone's own, in the hunts' pass
---
## winterspring-remorseful
By a frozen lake in the middle of the snows, the ghosts of an old town
still grieve for a crystal they stole long ago.
One of them understands what was done, and wants it put right. Find that one.
? Lake Kel'Theril, in the middle of Winterspring.
= The Remorseful Highborne, by Lake Kel'Theril.
+ 'Even though there is no waaaay to change the past, I am now at peacccce knowing that you have recovered the crystal of Zin-Malor.'

## winterspring-jaron
Near the ice caves of the blue dragons, a dwarf's camp was wrecked
by wildkin guarding something he got too close to.
He got away; a friend of his was not so lucky. Find his wagon.
? South of Starfall Village, near Mazthoril.
= Jaron Stoneshaper's wagon.
+ A severely damaged crate stands out among the rest of the destroyed belongings at the camp.

## winterspring-lorax
In a gorge in the south of the snows, a satyr paces about
and talks to himself, and has a tale for whoever stops to question him.
Find him.
? Frostwhisper Gorge, in the south of Winterspring.
= Lorax, a satyr with a tale.
+ 'Lorax makes deals, he does not accept them from insignificant mortals.' He wants the soul of a smith who bartered it, and teaches what that smith was to learn.

## winterspring-umbranse
In the far east of the snows, a man of the human kingdoms
speaks for the dead, and is too old now to go after what was taken from him.
A dragon sends messengers to him. Find him.
? Eastern Winterspring.
= Umbranse the Spiritspeaker, a human medium.
+ Itharius, the green dragon of the Swamp of Sorrows, sends travellers to him so that Eranikus may give advice 'in his own words'.
