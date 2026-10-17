# Yonder 0.12.0 release self-review

Reviewed 17 October 2026 against v0.11.6. This covers the entire unreleased
batch, not only the latest fixes. Player-data ingestion was reviewed in a
clean wow-data checkout so the owner's unfinished vendor and teaching changes
were neither committed nor used to produce the release databases.

## Findings fixed before release

| Finding | Effect | Correction and evidence |
| --- | --- | --- |
| Finds was not reinitialized after `/yonder reset yes` | Cloth and currently learned profession collections stayed locked until another scan | Restore current profession unlocks immediately after creating the new journal. A regression fails before the fix and passes afterward, also rejecting professions the character no longer knows |
| CI only ran the paragraph unit tests | Riddle solution, Spanish interface and source-validation tests could be skipped on GitHub | CI and both release paths now run all Bun tests, the Python data-join tests and locale freshness checks before publication |
| Authoring tests relied on the neighbouring wow-data checkout | The newly enabled CI suite exposed an import dependency hidden by the developer workspace | Load wow-data only when an actual query is needed. Pure authoring and join tests run from a standalone checkout without that repository |
| Database publisher used shallow history while addon jobs used full history | A merge could be published under an ID different from the one consumers requested | The publisher now fetches full history too. A regression covers both checkout configurations, and the final publication is verified against the computed input tag |
| New expedition subjects were absent from regenerated glossaries | Future name checks would lack five new NPC subjects | Regenerated all locale data through wow-data. French, German and Spanish glossaries gain the five subjects. Checked their existing translated prose against those game names |
| Descriptions and reset confirmation still named only fish and herbs | Players were not told the full scope of Finds | Updated the English, French, German and Spanish TOC descriptions, reset confirmation, package description and store copy. Explain bag quantities separately from recorded acquisitions |

## Runtime review

- Profession detection combines all available sources, including sparse and
  incomplete modern lists and localized folded skill panes. The re-entry
  guard prevents header changes recursively scanning professions. Unlocks and
  announcements are permanent per character. Cloth needs no profession.
- Existing fish and herb records keep their original tables, dates, counts,
  weights and methods. Already discovered collections remain readable and
  continue recording after a profession is dropped. Explicitly resetting the
  journal instead restores only current professions and universal cloth.
- New mineral, cloth and leather records use item IDs, not node IDs. Skinning
  requires a successful cast paired with that corpse. Ordinary leather loot
  does not become skinning. Inventory scans discover pages without inventing
  acquisition history. Live bag counts refresh even when the last stack is
  consumed or removed, and exclude bank stock.
- Navigation uses the existing kit and five journal tabs. Checked category
  filters, old fish/herb links, material links, Atlas links, unlock-banner
  links, undiscovered-page protection and achievement visibility. The kit
  copy is unchanged.
- Six material achievements count discovered item pages. The catalog has 62
  material pages on Classic and 66 on Forever. Every item has an English,
  French, German and Spanish note. Mexican Spanish borrows prose while
  retaining its own game names.

## Expedition review

Nine new riddles bring the catalog to 115 on Classic and 119 on Forever.
All authored solutions are exercised in twelve client locales, on both game
accounts and through both emote APIs. Tests cover wrong actions and targets,
combat/faction gates, camp/range separation and targeting outside a location.

The Dun Morogh camp uses the owner's 39.2, 67.6 report as an explicit reviewed
landmark. It does not borrow an NPC spawn. Rest at Dolanaar uses an untargeted
sleeping or lying-down gesture in a 40-yard inn vicinity, with no indoor flag.
The owner has confirmed both solutions and the Herbalism unlock in game.

Checked the Ancient Protector's recorded Classic route independently of its
compiled solution. Two waypoints just outside the map-hint circle remain
inside the accepted patrol tolerance and now have explicit regression cases.
A matching protector near Darnassus is rejected. Arrival at the Badlands
crypt uses the sword's corroborated position, with no unverified indoor gate.
The farm uses corroborated fixed ram positions and requires no live ram.

Limits: these checks do not constitute native playtests of every new site,
client or locale. The crypt does not distinguish floors at identical map
coordinates, and Forever's inherited patrol geometry is not independently
playtested. Stonetalon remains a draft, outside the book and completion totals.

## Player facts

The first waiting batch, [wow-data PR 5](https://github.com/salty-max/wow-data/pull/5),
contains 690 new archived observations: 518 Classic English, 148 Forever
English and 24 Forever Spanish value rows. The rebuilt databases add 75
unique NPC sightings and 12 gossip lines relative to the prior local build.
They add no new creature names, quest texts or loot records because those
facts are already covered by the higher-priority sources.

Keldamyr's recorded Classic welcome corroborates his invitation directly under
NPC 6736. The catalog's names match the submitted NPC names. Source gaps are
filled only, known facts are not replaced. Sightings stay observer positions
in `creature_sighting`, never exact world spawns or riddle anchors. Account
hashes remain per fact. Raw player identity is not added to addon data.

A final inbox refresh produced [PR 6](https://github.com/salty-max/wow-data/pull/6),
with another 45 observations: 13 Classic English, one Forever English and 31
Forever Spanish. Reviewed every added row. They corroborate known trainers,
a bear and its loot, plus another Dolanaar guard direction. All submitted
Spanish NPC names already match their existing source names. Both facts PRs
are merged, with 735 new observations archived in total.

The final clean build contains 54 Classic and 33 Forever player sightings,
plus nine Classic and four Forever gossip lines. Relative to the prior local
databases, that is 82 new distinct sightings and 13 gossip lines. The rest
confirm existing records. The newer Forever observations carry build 70450.
No new NPC names, quest texts or loot tables are invented from duplicates.

## Validation

- All Bun interaction, translation, authoring and paragraph tests.
- Python data-source join tests.
- Lua formatting and static checks, generated source and locale freshness.
- Complete Classic and Forever simulations, including the reset regression.
- The full addon check suite also passes in an archived standalone checkout,
  with no sibling wow-data repository or local cache available.
- wow-data typecheck and 63 tests against both clean rebuilt databases.
- All generators rerun against Classic 1.15.9.70003 and Forever 1.60.1.70450,
  including names, glossary subjects, material sources and expedition spots.
- TOC agreement and packaged bytes checked against the addon folders.

Publication uses 0.12.0 because this is a feature release: unified Finds,
material collections, Spanish and the new riddles. Unrelated unfinished
wow-data changes remain in the owner's working tree.
