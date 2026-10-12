# Explorer's Field Journal: Expeditions, Bestiary & Atlas

A World of Warcraft addon: **an Explorers' League field journal that fills in
as you travel, with riddles in its margins.** The first book is the
**Expeditions**: riddles that lead you to the world's overlooked corners (a
grave beside a path, a statue nobody explains, a book left on a shelf) and,
in each land with rare creatures, a quarry to hunt. Then the **Bestiary**:
every creature you meet, slay and loot, sorted into families, each with a
League naturalist's note; **Fish** and **Plants** (every catch and every herb,
each with a note), the **Atlas** (places, roads, flights, deaths) and the
**Milestones**.

For Classic Era (Hardcore, Season of Discovery), TBC Anniversary and World of
Warcraft: Forever, in one package: each game loads its own part.

## In game

- 106 riddles in the zones, capitals and faction towns (Zephras Isle adds four
  on Forever), each solved where it leads: by being there, by a gesture the
  verse hints at, or by reading what is written there; never a kill, never
  where a quest already sends you. Two hints, each asked for, and a seal
  (gold without one). 38 quarries, rares no quest names, each on a poster;
  tracked, its haunts are shaded on the world map. A riddle or a quarry can
  be pinned to the screen.
- Slay a creature of the wild and it joins the journal, with its level and
  where you first saw it, and a chat line links to its entry (no sound, no
  banner). Your kills and your pet's count however they were dealt: a DoT,
  an area spell, a creature you never targeted.
- Slain counts, loot taken from each kind of creature, and trophies for rares
  and bosses (with a sound). On Forever, creatures inside dungeons and raids
  are hidden from every addon: they can't be recorded there.
- `/journal` (or `/fj`, or the book by the minimap) opens the book at the
  Expeditions. Its Bestiary: creature types and the families you've met, a
  page per family with the naturalist's note and a card per creature, a page
  per creature: the creature turning in its frame, its levels, where you met
  it, how many you've slain and what it dropped. Search, folding, trophies.
  No spoilers: only what you've slain.
- Tooltips say "not yet recorded" or how many you've slain.
- Settings: Options → AddOns → Explorer's Field Journal (`/journal settings`).
  `/journal reset` starts a character's journal over.

## Develop

```bash
bun run build      # content, atlas, notes, expeditions + data → Data_Classic.lua, Data_Forever.lua
bun run check      # tests, lint, both up to date, the simulation on both games
bun run package    # dist/FieldJournal-<version>.zip: one package for every game
python3 scripts/expeditions.py   # after changing a riddle's spot or a quarry: data/expeditions.json
scripts/release.sh [--version X.Y.Z] [--hold] NOTES.md   # tag and push; Actions publish it
bun run kit:sync   # after changing the shared kit (~/code/addon-kit)
```

Creature data: `scripts/creatures.py` (the CMaNGOS Classic database, pinned);
rares by zone: `scripts/rare_zones.py` (the WoWWiki archive's list, spawn points
otherwise); Forever's own rares: `scripts/forever_rares.py`
([AllTheThings](https://github.com/ATTWoWAddon/AllTheThings)' Forever database, MIT, pinned).
Fish and herbs: `scripts/flora.py`; zones and their places: `scripts/zones.py`.
Families: `content/<type>/<family>.md` (rules + the naturalist's note); zones'
surveyor's notes: `atlas/`; fish and herbs' notes: `notes/`.

Expeditions: `expeditions/<zone>.md` (the riddles, their verses, hints, notes
and margins, and the zone's quarry). `scripts/expeditions.py` places each
riddle from the CMaNGOS dump and Wowhead agreeing (on Forever's own Zephras
Isle, the [QuestieDB](https://github.com/Questie/QuestieDB) traces of the beta,
pinned, and Wowhead's Forever database agreeing), and refuses a riddle that
asks for a kill, a deed asked twice in a zone, or one on the road of
Forever's new quests (AllTheThings and QuestieDB, pinned).
`scripts/expeditions.ts` (for the build) checks the verses and writes the
answers as fingerprints only. The rules and decisions: PLAN.md, "Expeditions".

## License

[MIT](LICENSE): code and text. World of Warcraft is a trademark of Blizzard
Entertainment, Inc. Not affiliated with Blizzard Entertainment.
