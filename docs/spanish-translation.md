# Spanish translation

Completed 17 October 2026. The journal's authored Spanish is in
`i18n/esES`. Both esES and esMX load the full translation. This remains a
first translation, flagged for corrections, rather than a native-reviewed edition.

## Coverage

- 619 interface strings and all nine Bestiary section titles.
- 96 Bestiary family notes.
- 47 Atlas notes, including the Classic and Forever paragraph variants.
- 47 expedition files: all 110 riddles, their hints, danger warnings, solved
  notes and gold margins, plus the 39 quarry posters. Classic includes 106
  riddles and 38 quarries.
- 136 collection notes: 39 fish, 31 herbs, 40 minerals, six cloth and 20 leather.
  Four material items are Forever-only.
- Spanish launcher descriptions in all three TOCs. The README and store
  description now list Spanish among the supported languages.

The new material notes accompany the material catalog prepared for Finds.
The unified Finds runtime and interface are still separate work. This
translation does not implement or advertise that interface.

Four newer Forever Atlas zones have no English surveyor note yet. They have
no Spanish note either. The 47 notes cover every authored English account,
not every zone in the game data.

## Names and regional text

Names were checked against wow-data's Classic and Forever databases. The
shared kit's glossary generator supplies the main glossary and Classic
substitutions. Explicit aliases live in `glossary-by-hand.json`. The small
`names-ok.json` documents grammatical exceptions and false matches, such as
the fish item Frenesí del lago versus the creature Demente del Loch.

Latin American Spanish shares the prose, with explicit regional phrases in
`i18n/esMX/prose-names.json`. These are applied in one pass before the text
is veiled. This preserves differences such as Sala de los Expedicionarios,
Yago Llavenegra and Saltavientos. It also distinguishes the fighting pit
La Marra from the dungeon La Masacre. Each client keeps its own creature,
place, flight, catch and game-supplied answer names.

Daggerfang (270693) is still an English fallback in wow-data's Spanish names.
Wowhead's live Spanish tooltip also returned Daggerfang when checked. This
is evidence for retaining it, not confirmation from a Spanish game client:
https://nether.wowhead.com/forever/tooltip/npc/270693?locale=6

## Editorial checks

The naturalist's observations and uses remain intact, including the approved
material notes. The Atlas retains the surveyor's voice. Riddles retain their
actual solution, rather than forcing English rhyme or phrasing into Spanish.
Wallace's clue distinguishes a spoken greeting from a wave. The firing-range
clue explicitly gives `/coverears`. The sleeping, listening, looking and
other gesture clues were checked against their authored action tokens.

Quoted game wording was taken from Spanish speech or readable records where
available, including Jordan's anvil, Opus, Tog, the dockside boys, Mannoroth's
armour and Terenas's tomb. Other quoted passages translate the English account.
Straight quotes are used throughout. The only semicolons in authored prose
are the game's gender-token terminators, removed before the player reads them.

## Verification

`bun run check` verifies complete interface coverage and formatting arguments,
all expedition fields and answer labels, canonical names and source freshness.
The simulations load both Spanish clients, both character genders and both
game accounts. They cover all available collection notes, regional names,
decoded solved notes and margins, and the absence of source markers or
unresolved gender tokens. The existing resolver tests exercise every authored
solution in all 12 client locales with modern and legacy emote APIs.

These checks do not replace a native Spanish editorial read or an in-game
layout check. No push or release is part of this translation step.
