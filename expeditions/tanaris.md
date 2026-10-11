---
zone: 1446   # Tanaris
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: tanaris-marvon
    tier: near
    creature: 7771   # Marvon Rivetseeker, dump 52.7, 45.9; Wowhead 52.6, 45.8
    hint_area: { x: 55.2, y: 45.9, r: 5 }
    danger: "Quiet"
    sources: "quest 3444"
  - id: tanaris-caverns-of-time
    tier: off
    area: Caverns of Time   # placed: the client's overlay: 64.1, 49.4, half-size 4.7 by 5.2
    hint_area: { x: 62.0, y: 51.0, r: 8 }
    danger: "Quiet"
    sources: "the Codex's caverns-of-time page; object 175726's text"
  - id: tanaris-lost-rigger-cove
    tier: off
    area: Lost Rigger Cove   # placed: the client's overlay: 71.6, 47.2, half-size 4.2 by 9.0
    hint_area: { x: 70.0, y: 48.0, r: 9 }
    danger: "Perilous (the Southsea pirates)"
    sources: "quests 2875, 8366"
  - id: tanaris-uldum
    tier: hidden
    object: 142343   # dump 37.6, 81.4; Wowhead 37.7, 81.4
    hint_area: { x: 40.5, y: 84.1, r: 8 }
    danger: "Guarded"
    sources: "quests 2946, 2954; the Codex's uldum page"
  - id: tanaris-lands-end
    tier: hidden
    area: Land's End Beach   # placed: the client's overlay: 54.9, 91.7, half-size 7.0 by 7.1; Meridith (creature 15526) on its shore
    hint_area: { x: 56.0, y: 92.0, r: 9 }
    danger: "Quiet"
    sources: "quest 8599"
quarry:
  id: 7847
  sources: "quest 2781 (Gadgetzan's poster)"
---
## tanaris-marvon
By a broken pillar in the middle of the desert, a goblin scholar
who once stumbled out of a sunken temple wading through ooze
remembers a round room of serpent statues, and a stone to match it. Find him.
? The Broken Pillar, in the middle of Tanaris.
= Marvon Rivetseeker.
+ 'The evil in that place penetrates all that enter.' The Stone Circle waits in his workshop in Ratchet.

## tanaris-caverns-of-time
Among the rocks above the eastern sea, a cave leads down
to the lair of the dragons who watch over time itself,
and their master who sees what was and what will be.
Find the way down.
? The Caverns of Time, in the east of Tanaris.
= The Caverns of Time, lair of the bronze dragonflight.
+ Their master is Nozdormu, the Timeless One, whom the Titans charged with guarding time itself.

## tanaris-lost-rigger-cove
On the eastern coast, a pirate is wanted by the cartel for his crimes,
and the notice allows that, should he be indisposed at his hearing,
his head may attend in his place. Find his cove.
? Lost Rigger Cove, on Tanaris's east coast.
= Lost Rigger Cove, the Southsea pirates' den.
+ 'Don't worry about the small print. It's harmless, and... I don't think there's a magnifying glass small enough to read it anyway.' Security Chief Bilgewhizzle.

## tanaris-uldum
Far in the south of the desert, sealed gates of the makers stand in a valley,
and a watcher of stone wakes only for those who carry the right discs
from another of their vaults. Find the pedestal before the gates.
? The Valley of the Watchers, in the far south of Tanaris.
= The gates of Uldum, and the pedestal before them.
+ 'Salutations. I am a guardian of entry.' Without the Plates of Uldum, the gates stay shut.

## tanaris-lands-end
On the beach at the southern end of the world, someone
once pulled a gnome from the wreck of his flying machine,
and has never stopped thinking of him. He thinks it could never work out.
Find the beach.
? Land's End Beach, at the southern tip of Tanaris.
= Land's End Beach, where Meridith the Mermaiden waits.
+ Narain Soothfancy, in Steamwheedle Port, receives her love letter: 'She's a fish! A FISH I tell you! And I'm a gnome. It could never work out.'

## quarry
The Water Company of Gadgetzan has posted a high bounty
on the leader of the desert's outlaws: his people murder its workers,
steal its water, and squat on its wells.
He walks the field of springs south-east of the town.
= Caliph Scorpidsting, leader of the Wastewander. Chief Engineer Bilgewhizzle, in Gadgetzan, pays for his head.
+ Bilgewhizzle hopes his end will push the squatters off Gadgetzan's water wells at last.
