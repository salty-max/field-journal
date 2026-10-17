# Finds implementation

Implemented locally on 17 October 2026. Not released.

The earlier test zip contained the data and translated notes but still loaded
Fish and Plants as separate tabs. This change connects that prepared content
to the runtime and the book.

## The book

Five top-level tabs: Expeditions, Bestiary, Finds, Atlas and Achievements.
Finds uses the existing kit list and page, with the same category selector
under search as the Bestiary and Atlas. Its default overview links to the
available categories: Fish, Plants, Ores & Gems, and Cloth & Leather.

Only discovered item names and pages appear. Fish retain their original
school, time and weight figures. Herbs retain their gathering and loot
figures. The new material pages show the approved notes, records, first
acquisition method, source zones and Atlas links. Nodes are source metadata,
never pages. Material icons and names have localized, generated fallbacks
while the client item cache is cold.

## Unlocks and records

Fishing opens fish, Herbalism opens plants, Mining opens ores, stones and
gems, and Skinning opens leather and hides. Cloth is universal. These are
permanent per-character unlocks, independent of which professions are held
later. Cloth and leather share navigation but have separate unlocks.

`fish` and `plants` keep their old saved tables. New items are in
`materials[itemId]`. `finds.unlocked` and `finds.announced` hold family flags.
An old fish or herb record opens its family on upgrade even without the
current profession. Dates, counts, weights, schools and earned achievements
are retained. Already carried materials are noted with unknown quantity,
with retrospective first-item achievements recorded quietly.

Every newly available family gets the kit's banner and a clickable chat
message once, including the first upgrade. Rank changes, reloads and
relearning a trade do not replay the announcement. Both links open the
relevant category. The existing banner switch covers collection unlocks too,
and its settings and welcome text now say so.

Modern profession slots are read by id, including Forever aliases. Sparse
slots support Fishing without primary professions. A legacy skills-pane
fallback reads localized profession names, temporarily expands folded
headers and restores them, with a re-entry guard for synchronous events.

## Acquisition and progress

Mining nodes and herb nodes establish actual gathering for their families.
Leather is credited as skinned only after a successful player Skinning spell
paired with the same corpse GUID. The cast-start event preserves that source
if the target is cleared before success. Ambiguous or missing source evidence
stays ordinary loot. A short expiry and closing the loot window prevent a
later corpse from inheriting the method. Receiving materials in bags opens
pages but supplies neither a gathered/skinned count nor an invented quantity.

Loot is read at LOOT_READY and LOOT_OPENED, deduplicated within a window.
Once a family opens, acquisition keeps recording after its profession is
unlearned. Ordinary fish loot remains distinct from a fishing catch.

Six new achievements cover the first item and full collection of minerals,
cloth and leather. Totals come from this client's catalog, not node counts.
The new material pages number 62 in Classic (38 minerals, six cloth,
18 leather/hides) and 66 in Forever (40, six, 20). Locked profession families
contribute no apparent missing achievement progress. Existing fish and herb
achievement ids and earned records remain intact.

Discovered materials link from their Atlas zones back to Finds. Existing
fish and herb chat and Atlas links still use the original entry points.
`yonder:i<id>` opens a material and `yonder:finds/<family>` its category.

## Languages and verification

Finds, its notifications, controls, settings, welcome text and material
achievements are translated in French, German and Spanish. Mexican Spanish
shares the words and keeps its own material names. The existing approved
item notes are exposed without rewriting them.

Both game simulations exercise the real selector clicks, migration,
profession learning and unlearning, sparse Fishing slots, localized legacy
skills and folded headers, unlock notifications and links, item-level
completion, acquisition provenance, and Atlas return links. The existing
suite also checks all riddle solutions and every generated translation.
The shared kit is unchanged.

This is not an in-game visual playtest. In particular, verify the selector
on the native client, the actual Skinning spell/loot sequence and the
first-upgrade notifications in the new iCloud build before release.
