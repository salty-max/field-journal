# Finds data readiness

Reviewed 16 October 2026. This is the data audit for the Finds plan in
`PLAN.md`, not an implementation or release of the new tab.

## Verdict

**Enough data to begin the original-world collections. Not enough to promise
complete Forever coverage.** No new wow-data schema is required for the basic
profession gates, item identities, mining sources, cloth drops or skinning
sources. The missing work is a curated item catalogue, authored notes,
generation and runtime integration. Some newer Forever materials need more
evidence before joining completion totals.

The published databases were audited read-only. Existing local changes to
wow-data's recipe schema and builder were left untouched.

## Snapshot and reproduction

- Published snapshot: `db-ede763da4a7f`.
- Classic client: `1.15.9.70003`, database built `2026-10-16T11:44:53.094Z`.
- Forever client: `1.60.1.70425`, database built `2026-10-16T11:45:26.487Z`.
- QuestieDB: `57931281737632202e9838f17efd5c3618d10f55`.
- CMaNGOS Classic database: `28ef6259c782928b08a8dc9cacf6bc02e64f2b29`.
- These match the current wow-data pins. The default local database cache
  was older, so the audit used the published files in a separate cache.

Run from Yonder, using wow-data's Python database API:

```sh
WOW_DATA_CACHE=/path/to/published-cache python3 scripts/finds-audit.py
python3 -m unittest discover -s scripts -p 'finds_audit_test.py'
```

The first command writes `.cache/finds-audit.json`, an ignored research
inventory. Candidate items are deliberately broader than the final collection.
The checks cover loot ID collisions, shared templates, nested references,
missing/cyclic references, zero skill requirements, the last lock slot and
profession parent IDs.

## What is available

| Requirement | Evidence | Readiness |
| --- | --- | --- |
| Existing fish and plants | Committed flora has 39 fish entries, 31 herbs and 33 school templates | Preserve existing identities, notes and progress |
| Profession identities | Fishing 356, Herbalism 182, Mining 186, Skinning 393 | Ready, with Forever aliases below |
| Mining | 41 templates with a Mining skill lock in each database, all with yields | Ready to curate |
| Mining locations | 34 of those 41 templates have spawn rows | Partial static coverage, do not invent the rest |
| Mining yields | 41 distinct items in Classic, 43 in Forever | Raw candidates, includes quest and other exceptional materials |
| Ordinary cloth | Linen 2589, Wool 2592, Silk 4306, Mageweave 4338, Runecloth 14047, Felcloth 14256 | All have creature drop evidence |
| Skinning | 924 creatures with skinning templates, 48 distinct terminal yields in each game | Ready to curate, some yields are unsuitable |
| Item names and icons | All 94 Classic and 96 Forever raw candidate IDs have item rows and icons | Names recorded in EN, FR, DE, esES and esMX for every candidate |

These counts describe database coverage, not proof that every entry is active
or obtainable in the current game. Forever inherits reconstruction data for
much of the original world. No broken reference links were found in the
examined mining and skinning graphs.

Cloth source counts, identical in both databases, are respectively 734, 792,
1,079, 641, 738 and 42 creature templates. Some have no spawn rows, especially
Runecloth sources. Ten of the 924 skinnable creatures also lack spawn rows.
Count templates rather than deduplicating them by translated name. Source
locations remain partial and inherited probabilities must not be described as
Forever measurements.

All 11 stored item-name locales cover the Classic raw candidates. Forever
Italian lacks Ebonhold Boots 8269 and Pristine Hide of the Beast 12731. The
boots should be excluded anyway. Name records are not a prose translation
review. New naturalist notes and interface strings still need authoring and
translation.

## Rules the generator must respect

1. **Loot identifiers depend on their provider.** ClassicDB `loot.source_id`
   is a template ID, joined through `object.loot_id`, `creature.loot_id` or
   `creature.skin_loot_id`. Questie rows use entity IDs. For example,
   Questie's Pyrite row for object 1731 belongs to Copper Vein. Fadeleaf's
   Classic loot template also happens to be 1731. A join that ignores the
   provider incorrectly puts Pyrite in Fadeleaf. The audit handles these
   separately and recursively expands reference tables.
2. **Class/subclass is not a portable catalogue.** Classic files cloth,
   leather, ore and gems together under trade goods subtype 0. Forever
   separates these, but its cloth/leather subtypes also include crafted
   goods, salt, feathers and client-only entries. Use reviewed item IDs and
   acquisition evidence. Do not discard legitimate quest or miscellaneous
   mining yields solely because they are outside class 7.
3. **A zero skill requirement is valid.** Copper has requirement 0 in Classic
   and 1 in Forever. Read all eight lock slots and generate each game's
   requirements independently. The tables also contain requirements above
   300, so do not silently clamp them.
4. **A node is not an item page.** Rich, small, ooze-covered and dungeon
   variants can supply the same item. Keep one item identity with several
   source nodes, rather than duplicating collection pages.
5. **Profession names are display text.** Follow SkillLine parent IDs.
   Forever adds Fishing 2943 -> 356, Herbalism 2944 -> 182, Mining 2946 ->
   186 and Skinning 2947 -> 393. Localized profession labels are available.
   Verify the actual client APIs when implementing detection, including
   collapsed skill headers and temporarily unavailable skill data.
6. **Spell effect 95 does not always mean Skinning.** Forever also uses it
   for Mining 1235230, Herb Gathering 1235236 and Engineering 1235244.
   Open-lock gathering spells have additional Forever IDs too. Use the
   profession and spell identity, not that effect number alone.
7. **Receiving material is not evidence of gathering it.** Preserve the
   distinction between acquired and mined/skinned. A Creature loot GUID
   alone cannot distinguish a corpse's ordinary loot from its skinning
   window. Gathering event correlation needs runtime tests on both clients.
   Exact per-creature Skinning requirements are not normalized here. Do not
   fabricate requirements for special creatures from their levels.

## Gaps and exclusions

### Unresolved Forever object candidates

The English-name search here is a research aid, not proof of profession or
availability. None of these six objects has a normalized lock requirement.

| Object | Recorded spawns | Recorded yields | Missing evidence |
| --- | --- | --- | --- |
| 439628 Fool's Gold Vein | 17 | None | Profession, skill and yields |
| 439778 Starsilver Vein | 14 | None | Profession, skill and yields |
| 562111 Poor Copper Vein | 201 | None | Profession, skill and yields |
| 566779 Heavy Thorium Vein | None | None | Profession, skill, locations and yields |
| 656332 Chunk of Amber | 21 | Fossilized Insect 275842, Tuft of Hair 275843 | Profession and skill |
| 656333 Large Chunk of Amber | 44 | Those two items and Pyrite 249391 | Profession and skill |

The amber objects have English fallback names in esES. Heavy Thorium lacks
FR/DE/ES names too. Keep unresolved objects out of guaranteed mining sources
and completion requirements until better evidence arrives.

Pyrite 249391 also has a Questie source at known Copper Vein 1731. Bauxite
249425 has one at Gold Vein 1734. Both can be considered separately from the
unresolved nodes, without inventing a required skill or a drop probability
for the new items.

Seven recognized mining templates lack static spawn rows in both games:
73939 Ooze Covered Iron Deposit, 181068 Small Obsidian Chunk, 181069 Large
Obsidian Chunk, 181108 Truesilver Deposit, 181109 Gold Vein, 181248 Copper
Vein and 181249 Tin Vein. Missing static spawns do not establish that an
object is unused. Keep this distinct from a missing yield or unknown skill.

### Leather and skinning

- Forever's Pristine Leather 249427 has 105 Questie creature drop rows,
  Pristine Hide 249428 has 11. Questie's `npcDrops` does not distinguish
  ordinary drops from skinning, so these are source candidates, not verified
  skinning tables or probabilities.
- Fel Hide 248824, Fel Leather 248825 and Pristine Scale 249429 have names
  and client classifications but no recorded loot sources in this snapshot.
  Do not make them required discoveries on that evidence alone.
- Client files also contain items such as Faintly Glowing Leather 213369 and
  Irradiated Leather Scraps 213370 with no loot evidence. Presence in a
  client file does not establish current Forever content.
- Raw skinning yields include Wool Cloth 2592 from Sheep 1933, Zesty Clam
  Meat 7974 from Great Wavethrasher 6349 and Ebonhold Boots 8269 from
  Narillasanz 2447 in the pinned ClassicDB data. Keep the upstream records
  intact, but do not turn these into leather pages or claims about live
  skinning behavior.
- Quest hides, scales and chitin need explicit scope decisions. Ordinary
  drops such as Raptor Hide, Thin Kodo Leather and spider silks should not
  quietly become Skinning rewards. Crafted bolts and cured hides are also
  separate from raw finds.

## Implementation order

1. Curate the baseline ore/stone/gem, cloth and leather/hide item IDs with
   explicit exceptions. Keep uncertain Forever materials outside completion
   totals. Generate separate source metadata for each game.
2. Generate localized item names, icons, profession aliases and source
   locations through wow-data. Preserve the existing flora identities and
   avoid changing discoveries as a side effect of this data work.
3. Author and translate the naturalist notes against those sources.
4. Implement Finds navigation, profession gates, record migration and the
   one-time category announcements already agreed in PLAN.md. Cloth remains
   available to everyone. Dropping a profession keeps discovered pages.
5. Test profession learning/unlearning, upgrade migration, direct links,
   unlock announcements, ordinary acquisition and real gathering on both
   clients. New-discovery policy after unlearning and first-upgrade banner
   presentation remain open design questions in the plan.

Full coverage of unreleased Forever content is not a prerequisite for this
baseline. Unknown sources should remain unknown rather than becoming claims
in the book.

## Validation

- Audit regenerated successfully against both published databases.
- Four focused audit regression tests passed.
- Additional snapshot assertions verified Copper's per-game skill, cloth
  creature sources and that Forever Pyrite belongs to Copper rather than
  any herbalism node.
- Full `bun run check` passed, including both client simulations.
- No generated addon data or runtime files changed. wow-data's pre-existing
  edits retained the same checksums before and after the audit.
