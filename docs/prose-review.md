# Prose and timeline follow-up, 10 October 2026

Reviewed against `c24cd64`. Revised 91 of 96 bestiary notes, 43 of 47 Atlas
notes, and all 30 herb and 39 fish/catch notes. The five bestiary notes and four
Atlas notes left alone already had the clarity and character this pass sought.

## Three writers, three jobs

The Codex archivist connects history. The journal's naturalist observes
creatures with curiosity, including the peoples encountered as enemies. The
Atlas's dwarf surveyor notices terrain, routes and bearings. Keep their
interests distinct even when they describe the same place.

Cut invented interviews, unsupported ecology, blanket judgements about whole
peoples, and the habit of ending every note with a danger warning. Keep danger
where the subject warrants it. Let some notes end plainly; neither every plant
nor every fish needs to supply a lesson about life.

Murlocs, before:

> They are not clever, but they are many, and they come at once.

After:

> Their speech is difficult for most travellers to understand. That is a
> difficulty in translation, not evidence that there is nothing being said.

The village's tools, nets and shared defence give the naturalist concrete
things to notice. The earlier invented conversation with a murloc is gone.

Moonglade, before:

> Nobody fights here. Nobody would dare.

After:

> The Cenarion Circle welcomes both factions here, and the Lunar Festival
> brings visitors from much farther away. The quiet is real, though the
> struggle around the Emerald Dream has reached even this valley.

Its quiet matters without denying the original game's conflict there or
inventing a reliable location for Malfurion's sleeping body.

The yeti note now uses Umi's actual invention instead of attributing it to
generic Everlook goblins. Gaffer Jacks and Electropellers are identified as
Wizbang's lost equipment, with the latter lost during his exploding-duck-decoy
experiment. The humour was already in the quest.

Herb and fish notes no longer transcribe the whole location list supplied by
the page. They retain representative gathering places and original-game
recipes. Plain descriptions of uses alternate with an occasional observation.
Removed physical properties inferred only from a plant's name and an
unsubstantiated explanation of when Arthas' Tears acquired its name.

## Classic and Forever

Added `[classic]` and `[forever]` paragraph selection to family, Atlas and
flora notes. Shared paragraphs remain unmarked. Selection happens during the
build, so installed notes contain neither markers nor the other game's story.

| Note | Difference |
| --- | --- |
| Alterac | Separate Dalaran accounts. |
| Azshara; Furbolgs | Blackmaw and Timbermaw remain distinct. |
| Ironforge | The Hall of Thanes appears on Forever. |
| Wetlands | Forever's new excavation supplements the older dig. |
| Un'Goro | Forever includes the Shapers' Terrace. |

Unknown client markers, empty marked paragraphs and variants leaving an
available note empty cause a failed build. Atlas notes may name a zone present
in either game; a typo naming a zone in neither fails. Validation completes
before either generated file is written.

## Research

The original-world boundary is Vanilla, using period game texts and the
Codex's pre-Wrath history. Forever's own quests and announcements establish its
additions. Datamined names alone do not establish events, motives or dungeon
endings. The following are the online cross-checks for the corrections and
historical details, not a claim to have researched every creature's ecology
afresh.

| Subject | Evidence used |
| --- | --- |
| Dalaran | [An Alarming Request, Forever 92432](https://www.wowhead.com/forever/quest=92432/an-alarming-request) |
| Ironforge | [Old Ironforge Incursion, Forever 96393](https://www.wowhead.com/forever/quest=96393/old-ironforge-incursion) |
| Wetlands | [Lost Relic Carry, Forever 95810](https://www.wowhead.com/forever/quest=95810/lost-relic-carry) |
| Shapers' Terrace | [Blizzard's what's-next recap](https://news.blizzard.com/en-us/article/24303862/world-of-warcraft-forever-whats-next-panel-recap) |
| Blackmaw distinction | [Published developer quotations](https://www.icy-veins.com/wow-forever/news/everything-we-know-about-blackmaw-hold-in-wow-forever/); the linked video was not independently viewed |
| Skyborne context | [Blizzard's introduction](https://news.blizzard.com/en-us/article/24302071/wow-forever-meet-the-new-skyborne); retained detailed place names from the existing beta map/notes |
| Moonglade | [The Nightmare Manifests, Classic 8736](https://www.wowhead.com/classic/quest=8736/the-nightmare-manifests) |
| Centaur clans | [Gelkis Alliance, Classic 1368](https://www.wowhead.com/classic/quest=1368/gelkis-alliance); [Broken Tears, 1369](https://www.wowhead.com/classic/quest=1369/broken-tears) |
| Frostmane homeland | [Blizzard's original Townhall bestiary, preserved text](https://warcraft.wiki.gg/wiki/The_World_of_Warcraft_Bestiary), Frostmane Troll section; not its later Cataclysm story |
| Separate worgen accounts | [Velinde's Journal, Classic item 5520](https://www.wowhead.com/classic/item=5520/velindes-journal), original readable text; Arugal's existing period quest history |
| Faerie dragons; chimaeras | Blizzard's Warcraft III [faerie dragon](https://classic.battle.net/war3/nightelf/units/faeriedragon.shtml) and [chimaera](https://classic.battle.net/war3/nightelf/units/chimaera.shtml) descriptions; no promise that RTS mechanics apply in WoW |
| Yeti horns and invention | [Are We There, Yeti?, Classic 5163](https://www.wowhead.com/classic/quest=5163/are-we-there-yeti); [the horn collection, 977](https://classicdb.ch/?quest=977) |
| Courser antlers | [Courser Antlers, Classic 8153](https://www.wowhead.com/classic/quest=8153/courser-antlers) |
| Lost equipment | [Gaffer Jacks, Classic 1579](https://www.wowhead.com/classic/quest=1579/gaffer-jacks); [Electropellers, 1580](https://www.wowhead.com/classic/quest=1580/electropellers) |
| Glossy mightfish | [Cooked Glossy Mightfish, Classic item 13927](https://www.wowhead.com/classic/item=13927/cooked-glossy-mightfish), including stamina |

Wowhead and ClassicDB mirror game text. The Wiki is used for preserved texts
and source routing, with later-era sections excluded. Local gathering places
remain those in `data/flora.json`; recipe ingredients were cross-checked
against the cached spell-name/reagent tables, joined by SpellID, and restricted
to original-game preparations. The pinned CMaNGOS database is a community
reconstruction, not official Blizzard data. No new Forever gathering locations
are claimed from it.

## Remaining catalogue issues

Two existing classifications deserve a separate data pass. The catch list
includes quest equipment alongside fish. The grazer matcher also catches
Frayfeather and Thunderhead Stagwings, which are hippogryphs. The prose no
longer calls them flying deer, but the matcher is unchanged. Correcting these
should account for existing per-character records and milestones rather than
silently moving entries in a prose change.

## Validation

Rebuilt both generated files. `bun run check` passes: paragraph parser checks,
Lua formatting/linting and the complete Classic and Forever simulations.
Integration checks cover the real timeline variants and confirm that every
compiled note is readable and free of editorial markers. All 96 family notes
retain two to four paragraphs in either game.

A separate recursive comparison against the baseline's compiled data found
every value outside `note` unchanged: creature membership, IDs, matching,
models, ranks, map data, flora locations, order and milestones. Front matter
and all herb/fish section IDs and names are unchanged as well.
