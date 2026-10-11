---
zone: 1440   # Ashenvale
client: both
# the spots: an object of the pinned dump (placed by UiMapAssignment, agreeing with Wowhead's),
# a sub-area of the game's (its hint placed by the client's map overlay or a creature in it),
# or coordinates both sources agree on; danger by hand: the build computes its own from the spawns
riddles:
  - id: ashenvale-near
    tier: near
    reading: Ancient Inscription
    object: 19025   # dump 50.3, 39.6; Wowhead 50.3, 39.6
    hint_area: { x: 46.5, y: 40.8, r: 8 }
    danger: "Guarded (worgen)"
    sources: "object 19025's text; quests 1022, 1037-1044"
  - id: ashenvale-off
    tier: off
    reading: Monument to Grom Hellscream
    object: 21004   # dump 82.8, 79.1; Wowhead 82.9, 79.1
    hint_area: { x: 79.8, y: 76.4, r: 8 }
    danger: "Perilous (the Legion's servants)"
    sources: "object 21004's text; object 175742's text (Rise of the Horde); the Codex's demon-fall-canyon page"
  - id: ashenvale-hidden
    tier: hidden
    object: 19024   # dump 56.4, 49.2; Wowhead 56.4, 49.2
    hint_area: { x: 60.3, y: 48.4, r: 8 }
    danger: "Guarded"
    sources: "quests 1028, 1055; Shael'dryn (creature 3916) at 53.5, 46.2"
# quarry: the zone's own, in the hunts' pass
---
## ashenvale-near
Near the border of the fel-touched woods, wolf-men took a shrine,
and their howling named its vale.
Its stone still prays that the moonlight shine there forever.
Read the inscription.
? The Howling Vale, north of the road, near the Felwood border.
= The Shrine of Mel'Thandris: 'May the light of Elune shine upon this vale eternal and illuminate the ways of the forest as it has for time immemorial.'
+ The priestess Velinde Starsong watched over Felwood from here, then vanished with the Scythe of Elune; her trail runs through Ratchet and Booty Bay to the mines of Duskwood.

## ashenvale-off
In a canyon where demons still walk,
a warchief carved words for his big brother,
whose name meant giant's heart,
who stood alone before the demon and bought his people's freedom with his blood.
Read what the warchief wrote.
? Demon Fall Canyon, in Ashenvale's south-east.
= 'Lok'Tar ogar, big brother. May the Warsong never fade.' Thrall wrote it.
+ Grom was the first chieftain to drink Mannoroth's blood and the one who killed the demon: 'the curse of our people began and ended with Grom.'

## ashenvale-hidden
A shrine with the power to wake an old rod
hides in the mountains that ring a glade.
There are very few paths, and they are narrow:
keep your eyes to the north, and find it.
? South-east of the moonwell where Shael'dryn waits, in the hills that ring the glade.
= The hidden shrine. Dartol's rod was made whole again in its basin.
+ Shael'dryn says rebuilding the rod was simple; finding the shrine with the power to recharge it was the hard part.
