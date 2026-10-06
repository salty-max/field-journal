# Explorer's Field Journal: Bestiary, Atlas & Fishing

A World of Warcraft addon: **an Explorers' League field journal that fills in
as you travel.** The first book is the **Bestiary**: every creature you meet,
slay and loot, sorted into families, each with a League naturalist's note.
Then **Fish** and **Plants** (every catch and every herb, each with a note),
the **Atlas** (places, roads, flights, deaths) and the **Milestones**.

For Classic Era (Hardcore, Season of Discovery), TBC Anniversary and World of
Warcraft: Forever. Each game has its own package.

## In game

- Target or mouse over a creature of the wild: it's recorded, with its level
  and where you met it, and a chat line links to its entry (no sound, no
  banner).
- Slain counts, loot taken from each kind of creature, and trophies for rares
  and bosses (with a sound). On Forever, which closes the combat log to
  addons, a kill counts when you loot the corpse, or target the corpse of a
  creature you fought.
- `/journal` (or `/fj`, or the book by the minimap) opens the Bestiary:
  creature types and the families you've met, a page per family with the
  naturalist's note and an entry per creature: its 3D portrait, its levels,
  where you met it, how many you've slain and what it dropped. Search, folding,
  trophies. No spoilers: only what you've met.
- Tooltips say "not yet recorded" or how many you've slain.
- Settings: Options → AddOns → Explorer's Field Journal (`/journal settings`).
  `/journal reset` starts a character's journal over.

## Develop

```bash
bun run build      # content + data → Data_Classic.lua, Data_Forever.lua
bun run check      # both up to date + simulation on both games
bun run package    # dist/classic, dist/forever, zipped
```

Creature data: `scripts/creatures.py` (the CMaNGOS Classic database, pinned);
rares by zone: `scripts/rare_zones.py` (the WoWWiki archive's list, spawn points
otherwise).
Families: `content/<type>/<family>.md` (rules + the naturalist's note).

## License

[MIT](LICENSE): code and text. World of Warcraft is a trademark of Blizzard
Entertainment, Inc. Not affiliated with Blizzard Entertainment.
