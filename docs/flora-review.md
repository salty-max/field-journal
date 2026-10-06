# Review of the naturalist's notes on herbs and fish (6 October 2026)

69 notes (30 herbs, 32 fish, 7 kinds of weighed catch), checked with the
method of the family notes (docs/notes-review.md): the original game only.

## Method

- **Places**: every zone, water and dungeon a note names is in the species'
  data (data/flora.json: the herb nodes' spawns, the fishing loot tables of
  the CMaNGOS Classic database). Nothing named that the data doesn't have,
  except where a source corrects the database (below).
- **Uses**: every recipe a note names is in the game's own reagent table
  (SpellReagents, Classic Era client, wago.tools), and existed in the original
  game: the Classic Era tables also hold Season of Discovery recipes (Elixir
  of Coalesced Regret, Specklefin Feast, Darkclaw Bisque...) and recipes never
  learnable before later expansions, left out.
- **Quests**: the quest fish's quests and givers from the database
  (quest_template, creature_questrelation).
- **Lore and fishing hours**: the Warcraft Wiki and the classic-era fishing
  pages.

## Corrected

| Note | Was | Now | Source |
|---|---|---|---|
| Gromsblood | named for Grom Hellscream | (removed: the wiki calls it speculation) | Warcraft Wiki, Gromsblood |
| Gromsblood | Felwood, Desolace, Dire Maul | the Blasted Lands added (a third of its nodes in the original game; the database has none): also added to the data | Warcraft Wiki, Gromsblood |
| Dreamfoil | greater protection potions against holy too | holy removed (the recipe was never learnable before Cataclysm) | Warcraft Wiki, Greater Holy Protection Potion |
| Ghost Mushroom | tailors make Ghost Dye | alchemists make it, tailors buy it | the game's recipes |
| Grave Moss | the graveyards of each zone named | where the dead lie, in those zones | (unconfirmed per zone) |
| Purple Lotus | often near old ruins | removed | (unconfirmed) |
| Dreamfoil | grows where the veil to the Dream is thin | removed | (unconfirmed) |
| Raw Loch Frenzy | cooked by the dwarves of Thelsamar | it cooks into Loch Frenzy Delight | (unconfirmed) |
| Gaffer Jack | Wizbang Cranktoggle, a goblin | the goblin removed | (unconfirmed) |
| Nightfin Snapper | bites best by night | the evening and night, best in the small hours, never in the afternoon | Warcraft Wiki (6 PM to 6 AM); the classic-era fishing guide |
| Sunscale Salmon | bites best while the sun is up | morning to evening, best in the afternoon, never in the small hours | the classic-era fishing guide |

And in the addon: a catch counts as by night from 6 PM to 6 AM (it was 8 PM),
the Nightfin's hours.

## Confirmed

- Arthas' Tears is named after Arthas Menethil; Khadgar's Whisker after the
  archmage Khadgar (Warcraft Wiki, stated as fact).
- Nat Pagle of Dustwallow Marsh asks for the four rare fish in "Nat Pagle,
  Angler Extreme"; Dockmaster Baren of Lakeshire for ten Spotted Sunfish
  ("Selling Fish"); Wizbang Cranktoggle of Darkshore for Gaffer Jacks and
  Electropellers; Gubber Blump of Auberdine for six Darkshore Groupers ("The
  Family and the Fishing Pole") (the database).
- Winter Squid in winter and Summer Bass in summer (the database's fishing
  season events).

## Sources

- Warcraft Wiki: https://warcraft.wiki.gg/wiki/Gromsblood,
  https://warcraft.wiki.gg/wiki/Raw_Nightfin_Snapper,
  https://warcraft.wiki.gg/wiki/Raw_Sunscale_Salmon,
  https://warcraft.wiki.gg/wiki/Greater_Holy_Protection_Potion,
  https://warcraft.wiki.gg/wiki/Arthas%27_Tears,
  https://warcraft.wiki.gg/wiki/Khadgar%27s_Whisker
- Classic WoW archive, Fishing: https://classic-wow-archive.fandom.com/wiki/Fishing
