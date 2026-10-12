# Expeditions follow-up, 12 October 2026

Follow-up to the review of `312545a`: 117 riddles and 38 quarry posters across
46 zones and capitals. The counts and faction distribution remain the same:
90 riddles available to an Alliance reader, 86 to a Horde reader.

## Clues and discoveries

History-book clues now give the reader one detail to follow: a bargain paid
in sleep, a name chosen for the dead, a prisoner's hunger for power, a king's
confidence in his walls. The fuller account belongs to the note after the
book is found. The books still ask for a reading at their original locations.
The dragon-skull clue in Ironforge and the Medivh book in Westfall stand on
their own, without assuming another riddle has been read first.

Feathermoon, before:

> On the isle off the forest's coast, in the sentinels' stronghold, a history tells
> why the night elf women keep the forests' watch:
> their men went to sleep in a dream, and left them to guard the world alone.

After:

> In the sentinels' island stronghold, seek a promise between lovers
> who might not see each other for centuries.
> The watch these women kept began with that parting.

Revised 29 quarry texts. Removed precise respawn promises and the repeated
minimum/maximum waiting-time margins. The replacements draw on appearance,
location, company, history, tameability and fighting behaviour. Qualitative
rarity remains where useful; there is no need to pretend a rare is always
waiting for the reader. Three vendor margins likewise describe the wares
rather than promise an exact restock time.

King Mosh's new margin:

> His roar sends even armed hunters running. In a crater full of teeth,
> the direction matters.

The weak Gogo discovery becomes Zap Farflinger, Everlook's Unbalanced
Engineer. His original gossip describes a dimensional imploder awaiting a
test; the engineering dialogue explains the explosion and reassembly. The
clue needs neither an engineering profession nor a teleport. Meeting the
inventor nearby is sufficient. His pinned creature has no quest relations,
and the quest texts contain no reference to his name.

## Fair actions

- Ravenholdt and Lucius's lockbox are found by arriving. Their previous
  gesture requirements suggested rogue Stealth, an ability the gesture
  listener does not detect. Finding the groundskeeper or the box is the
  discovery; a mimed sneak adds no value.
- Mirador, Nibbles, Opus and the captive horses accept appropriate alternative
  gestures of kindness. Greetings elsewhere accept plausible equivalents.
- Morlos'Aran asks for reflection rather than counting towns. Its accepted
  gestures include thought and grief. Tethris Aran also makes its intended
  reflection clearer.
- Looking into the Unseen's house accepts LOOK, PEER, GAZE and STARE, as well
  as the existing SHIVER. Apocryphan's Rest and the Rolling Plains accept
  related ways of observing. Gestures still require the original place.

The final mix is 52 gesture riddles, 29 readings, 20 encounters found by
targeting nearby, 15 arrivals and one night discovery. There is no new
solving rule or engine change. The existing gold-only margin rule is retained.

## Corrections and evidence

| Subject | Correction and sources |
| --- | --- |
| Rak'shiri | Aqua, not white; Shy-Rotam shares the coat. [Petopia Classic](https://www.wow-petopia.com/classic/look.php?id=ridingtigerskinaqua). |
| Unseen | The margin names a warlock's [Detect Invisibility](https://www.wowhead.com/classic/spell=2970/detect-invisibility). The mage's [Invisibility](https://www.wowhead.com/tbc/spell=66/invisibility) belongs to TBC, not Vanilla. [Original creature and period reports](https://www.wowhead.com/classic/npc=3094/unseen). |
| Glibb | The monkey is Brann's companion; the clue no longer suggests he answers to Brann's name. Existing Glibb source and creature placement retained. |
| Nadyia | Corrected the subject/verb mismatch; her welcome remains grounded in her own gossip. |
| Durotan | Attribute the refusal to the book; remove the absolute claim that he alone refused the blood. The original book and later accounts need not be made identical. |
| Illidan | Gul'dan was an orc warlock. Describe his skull accordingly, rather than calling it a demon's skull. |
| Khadgar | The plaque presumes him dead. It does not establish his fate, or identify Antonidas as his former master. |
| Zap Farflinger | [Classic creature](https://www.wowhead.com/classic/npc=14742/zap-farflinger), [original gossip](https://warcraft.wiki.gg/wiki/Zap_Farflinger); pinned gossip menu 6092, npc_text 7249 and 7250. No later engineering destinations imported. |
| Broken Tooth | [Petopia's Classic attack speeds](https://www.wow-petopia.com/classic/attackspeed.php) support the quick attacks. No exact attack-speed promise is added for Forever. |
| Brimgore; Shleipnarr; Grimungous; King Mosh | Period reports corroborate their breath, fear or stomp: [Brimgore](https://www.wowhead.com/classic/npc=4339/brimgore), [Shleipnarr](https://www.wowhead.com/classic/npc=8280/shleipnarr), [Grimungous](https://www.wowhead.com/classic/npc=8215/grimungous), [King Mosh](https://www.wowhead.com/classic/npc=6584/king-mosh). Later taming and expansion changes excluded. |
| Mother Fang; Immolatus; Arash-ethis | [Web](https://classic.warcraftdb.com/data/spell/12023), [the archived infernal](https://wowwiki-archive.fandom.com/wiki/Immolatus), and [period wind-serpent reports](https://www.wowhead.com/tbc/npc=5349/arash-ethis) supplement the pinned spell scripts. |
| Vendor rewards | Original item effects: [Goblin Jumper Cables](https://www.wowhead.com/classic/item=7148/goblin-jumper-cables), [Minor Recombobulator](https://www.wowhead.com/classic/item=4381/minor-recombobulator), [Inferno Cloak](https://www.wowhead.com/classic/item=4790/inferno-cloak). |

The pinned CMaNGOS database is a community reconstruction, not Blizzard's
server data or proof of Forever's live behaviour. Its spawn and spell records
support these descriptions alongside period accounts where available. The
new quarry margins also use its Disease Cloud, Fire Shield/Fire Nova,
Mortal Strike and Infected Wound records. Conflicting lists for Licillin's
damaging spell are left unresolved in the prose: the margin uses the agreed
Curse of Weakness, without asserting an exclusive shadow spell or class.
Omgorn can appear at three camps; that does not establish a walk between them.
The Husk's name does not establish a larger former body.

The Unseen's hostility still needs a live check with both factions on each
client. The pinned faction data and player reports do not settle it. The
page therefore no longer calls the house quiet or promises neutral occupants;
it warns of high-level invisible undead and asks the reader to leave them
undisturbed. No claim of confirmed Horde aggression is made.

## Validation

Resolved the new Everlook encounter from the pinned spawn data and Wowhead's
placement, inside its hint circle. Other resolved entries and quarry haunts
are unchanged. Rebuilt both generated addon files and read all revised
quarries and reading clues together to check their flow and variety.

`bun run check` passes: script tests, Lua formatting and lint, generated-data
freshness, and the complete Classic and Forever simulations. A recursive
comparison with the baseline confirms every compiled value outside
`expeditions` is unchanged. Live-client behaviour was not tested.
