# Yonder: Riddles, Rare Hunts & an Explorer's Journal

Yonder gives you riddles to solve, rare creatures to hunt
and a record of what you find along the way. Follow a clue to a forgotten
grave, track down a rare you've never fought, or fill in your bestiary while
levelling. Notes from an Explorers' League naturalist accompany your finds.

For Classic Era, Hardcore, Season of Discovery, TBC Anniversary and World of
Warcraft: Forever. One download covers all of them.

Yonder was called Explorer's Field Journal until version 0.8.0: another
addon used the same folder. A character's old journal moves over on its own
at its first login with Yonder, through the small FieldJournal folder in the
download (Classic Era and TBC; a later update removes it).

## What's in the journal

- **Expeditions.** 106 riddles and 38 rare hunts across the original world.
  Forever adds four riddles and a hunt on Zephras Isle. Riddles lead to
  overlooked places and are solved by reaching a spot, speaking to someone,
  reading something or working out a gesture from the verse. They never
  require a kill.
- **Bestiary.** Around 3,500 creatures in 96 families, each with a
  naturalist's note. Creature pages keep your first sighting, observed levels,
  kill counts, loot and drop rates. Rares and bosses become trophies.
- **Fish and Plants.** Your catches and herbs, with notes on all 39 fish and
  30 herbs, and records of where you found them.
- **Atlas.** The zones you've visited, with maps, explored places, surveyor's
  notes, flights, deaths and close calls.
- **Achievements.** For exploring, completing expeditions, collecting
  trophies, fishing and gathering.

Each riddle has two optional hints: a clearer clue, then a location marked
on the world map. Solve it without hints for a gold seal and an extra piece
of the story. Rare hunts have posters describing the creature and its
haunts. Track a hunt to mark those haunts on your map, or complete it without
tracking for a gold seal. You can pin a riddle or a poster to your screen.

Creatures join the Bestiary when you first kill them. Kills by you, your pet
or your group count, including damage over time and area spells. A tagged
creature finished by another player also counts when your quest credits
the kill. A chat link announces each new creature, without a banner or sound.
Rares and bosses have a trophy sound.

Search by family or creature name, sort your records and browse trophies.
Tooltips show whether you've recorded a creature and how many you've killed.
Each character has its own journal. Undiscovered creatures stay hidden,
with no count showing how many remain.

Forever hides creatures inside dungeons and raids from addons, so the
journal cannot record them there.

## Opening the journal

Type `/yonder` or click the minimap button. The book opens on Expeditions.
Each login says in chat what the journal holds.
Settings are under **Options > AddOns > Yonder**, or `/yonder settings`.

- `/yonder welcome` reopens the welcome page.
- `/yonder where` shows your current map and position.
- `/yonder minimap` shows or hides the minimap button.
- `/yonder export` and `/yonder import CODE` transfer settings.
- `/yonder reset` clears this character's journal after confirmation.

The full store description is in [addon/CURSEFORGE.md](addon/CURSEFORGE.md).
[PLAN.md](PLAN.md) records the design decisions and expedition rules.

## Development

```bash
bun run build      # Build Data_Classic.lua and Data_Forever.lua
bun run check      # Run tests, Lua checks, data checks and both game simulations
bun run package    # Create dist/Yonder-<version>.zip
python3 scripts/expeditions.py   # Update locations after changing a riddle or hunt
bun run kit:sync   # Copy the shared kit from ../addon-kit
scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md   # Tag and publish a release
```

Family notes and matching rules live in `content/<type>/<family>.md`.
Surveyor's notes are in `atlas/`, fish and herb notes in `notes/`, and riddles,
hints, notes and hunt posters in `expeditions/<zone>.md`.

Creature data comes from the pinned CMaNGOS Classic database through
`scripts/creatures.py`. `scripts/rare_zones.py` assigns rares to zones using
the WoWWiki archive and spawn points. Forever rares come from
[AllTheThings](https://github.com/ATTWoWAddon/AllTheThings) through
`scripts/forever_rares.py`. Fish and herbs use `scripts/flora.py`, and zones
use `scripts/zones.py`.

`scripts/expeditions.py` checks locations against the CMaNGOS data and
Wowhead. On Zephras Isle, it uses pinned
[QuestieDB](https://github.com/Questie/QuestieDB) beta records and Wowhead's
Forever data. It rejects riddles that require a kill, repeat a deed in the
same zone or overlap Forever's new quests. `scripts/expeditions.ts` checks
the verse during the build and stores answers as fingerprints.

## License

[MIT](LICENSE) for code and text. World of Warcraft is a trademark of
Blizzard Entertainment, Inc. Not affiliated with Blizzard Entertainment.
