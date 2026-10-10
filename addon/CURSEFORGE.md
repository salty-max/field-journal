# Explorer's Field Journal: Bestiary, Atlas & Fishing

<!-- Project description for curseforge.com (paste as the project's description).
The project's title on CurseForge: "Explorer's Field Journal: Bestiary, Atlas &
Fishing" (the addon's own name stays Explorer's Field Journal). -->

**A bestiary, an atlas, and a record of the fish you catch and the herbs you gather, filled in as you travel.** A naturalist of the Explorers' League has left you a field journal: slay a creature of the wild and it is written down, with where you first met it and what you have learned of it. Loot it, bring down the rare ones for a trophy, and the journal keeps the count.

For Classic Era (Hardcore, Season of Discovery), TBC Anniversary and World of Warcraft: Forever. A companion to [Lorekeeper's Codex](https://www.curseforge.com/wow/addons/lorekeepers-codex), in the same League's hand, and a sibling of [Hearthtale](https://github.com/salty-max/hearthtale): the three share one look, each in its own colours, and each stands alone.

## What's inside

- **Some 3,500 creatures in 96 families**: wolves, raptors and the great cats; kobolds, murlocs and the Defias; the dragonflights, the elementals, the Scourge, the Burning Legion, and every rare and boss of the original world.
- **A naturalist's note for every family**: what they are, where they live, how they fight and what the League has learned of them, true to the lore of the original game.
- **Your own record of each creature**: when and where you first met it, the levels it is found at, how many you have slain, what you took from it, and the day you took its trophy.

## How it works

- A creature joins your journal the first time you slay it, with where you first saw it and its levels. Only creatures you can fight are kept: no town folk, no critters.
- Each new creature is announced by a line in chat, with a link to its page. No banner, no sound: the journal stays out of your way.
- Kills count when you, your pet or your group land them, however they were dealt: a DoT, an area spell, a creature you never targeted. A creature you tagged that another player finished counts too, when a quest of yours counts it. Rares and bosses become trophies, with a sound.
- On World of Warcraft: Forever, creatures inside dungeons and raids are hidden from every addon by the game: they can't be recorded there.
- Each character keeps its own journal.
- Tooltips say when a creature is not yet in your journal, or how many you have slain.

## The book

- `/journal` (or `/fj`), or the book by the minimap, opens it: the creature types on the left, their families and the creatures in each; on the right, a family's note or a creature's page, with the game's own portrait of it.
- Search by family or creature name; types and families fold; sort a family's creatures by name, the most slain, the last slain or the order you met them.
- A Trophies page for the rares and bosses you have brought down.
- No spoilers: only what you have slain is listed, and nothing says how much remains.

## Fish and Plants

Two tabs for what the land and the water give. **Fish**: every catch, with where and when it bit, by day or by night, from a school or open water, and for the weighed catches (the 32 Pound Catfish...) the heaviest you landed. **Plants**: every herb that reaches your bags, gathered from its node, looted, bought or given. Each of the 30 herbs and 39 fish has a naturalist's note (where it grows or bites, what it is used for), and its page says where it is found once you have found it. Each zone's Atlas page lists what grows and bites there.

## The Atlas

Another book in the same journal: every zone you have entered, by continent (all of them, or one at a time), and how many of its places you have explored (filled in from the map you had already uncovered). Each zone has its page: a note by the League's surveyor (roads, water, dangers), the zone's own map with the parts you have explored and the places you died or came close, and your record of it: first visit, places, deaths, close calls, flights. Your deaths and close calls also show on the game's world map (a setting).

## Milestones

The last tab: tallies (kinds recorded, families, creatures slain, trophies), every family of a type, feats (Hogger's End, You No Take Candle, The Emerald Nightmare, The Firelord Falls...), the rares of each zone, for the Atlas: every place of a zone explored, every zone of a continent, flights, crossings and close calls survived; and for fishing and herbs: kinds and counts, Nat Pagle's four rare fish, a school of each kind, both seasons, Nightfin by night and Sunscale by day, the Black Lotus, every fish of a continent's waters, every herb of a zone. Earned like the game's achievements, with its alert, its fanfare and a line in chat, and each remembers the day and the level you earned it.

## Two packages

Each game has its own file: pick the one for yours (the CurseForge app does it for you).

- **Classic**: Classic Era, Hardcore, Season of Discovery, TBC Anniversary.
- **Forever**: World of Warcraft: Forever, with Zephras Isle in the Atlas and Forever's new rares in each zone's milestones. Forever closes the combat log to addons, so kills come from the game's own kill event.

## Settings

The first time each character logs in with the journal, a welcome page introduces it and offers its choices (`/journal welcome` shows it again). After that: Options → AddOns → Explorer's Field Journal (or `/journal settings`, or right-click the minimap button): chat announcements, the trophy sound, milestone alerts, deaths and close calls on the world map, tooltip hints, the minimap button.

Settings are each character's own, as in most interface addons. A character can take another's: choose one of your characters of the same game from a list (on the welcome page or the Options page), or bring them from anywhere with a code: `/journal export` on one character, `/journal import CODE` on the other.

Other commands: `/journal reset` starts a character's journal over (it asks first); `/journal minimap` shows or hides the button.

## Source

MIT licensed: [github.com/salty-max/field-journal](https://github.com/salty-max/field-journal). Creature data from the CMaNGOS project's Classic database; Forever's own rares from AllTheThings' Forever database. Not affiliated with Blizzard Entertainment.
