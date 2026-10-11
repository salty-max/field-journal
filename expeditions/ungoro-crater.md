---
zone: 1449   # Un'Goro Crater
client: both
# the spots: an object the pinned dump and Wowhead place alike, a sub-area of the game's (its hint
# placed by the client's map overlay or by something pinned inside it), or a place pinned by the
# data (a creature that stands still, a quest's exploration trigger); danger by hand: the build
# computes its own from the spawns. gestures: the emotes it accepts, the story's own first.
riddles:
  - id: ungoro-crater-ringo
    tier: off
    where: { x: 51.9, y: 49.8, r: 1 }   # Ringo, dump 51.9, 49.8; Wowhead 52.0, 50.0 (he walks only when escorted)
    hint_area: { x: 53.7, y: 48.0, r: 5 }
    danger: "Perilous (fire elementals)"
    sources: "quest 4492; the Codex's fire-plume-ridge page"
  - id: ungoro-crater-linkens-raft
    tier: hidden
    object: 161505   # dump 63.0, 68.6; Wowhead 63.1, 68.4
    hint_area: { x: 62.3, y: 64.7, r: 8 }
    danger: "Guarded"
    sources: "quest 3844"
# quarry: the zone's own, in the hunts' pass
---
## ungoro-crater-ringo
On the burning ridge in the middle of the crater,
an explorer who went to look at the volcano never came back
to his friend at the refuge, who sent a canteen after him. Find him.
? Fire Plume Ridge, in the middle of Un'Goro.
= Ringo, lost on Fire Plume Ridge.
+ 'Oh... I'm so glad someone found me...' Spraggle Frock, at Marshal's Refuge, had been worrying.

## ungoro-crater-linkens-raft
In the eastern marshes, a raft lies wrecked by a pond too small to sail,
and the trees say the water does not always stand where it stands now.
Whoever it belonged to forgot a great deal. Find the raft.
? A pond in the Marshlands, in the east of Un'Goro.
= A wrecked raft; at the bottom of the pond, a water-logged pack.
+ It is Linken's, who lost his memory in the crater; 'It's a secret to everybody.'
