---
zone: 1420   # Tirisfal Glades
home: horde   # a starting zone: its riddles are its faction's alone
client: both
# the spots, pinned by the data (scripts/expeditions.py resolves them): object (every spawn of it on
# this map), creature (one that stands still, or found by targeting it), trigger (a quest's exploration
# trigger) or area (a sub-area of the game's; its hint placed by its map overlay, or an anchor inside
# it: a creature, an object, a graveyard). gestures: the emotes it accepts, the story's own first.
riddles:
  - id: tirisfal-glades-zapetta
    tier: near
    creature: 9566   # Zapetta, dump 60.7, 58.9, at the zeppelin tower
    found: target   # where every traveller waits: only by speaking to him
    hint_area: { x: 62.5, y: 61.0, r: 4 }
    danger: "Quiet"
    sources: "Zapetta's and Hin Denburg's own words (their gossip); the WoWWiki archive's Zapetta page"
  - id: tirisfal-glades-clyde
    tier: near
    gestures: [CURIOUS, PONDER, SCARED, SHIVER]
    creature: 5690   # Clyde Kellen, dump 67.2, 51.0
    hint_area: { x: 65.0, y: 53.5, r: 5 }
    danger: "Quiet"
    sources: "the deathguards' words (broadcast texts 6757, 6758); the WoWWiki archive's Clyde Kellen page"
  - id: tirisfal-glades-stillwater
    tier: off
    gestures: [SIGH, MOURN, CRY]
    area: Stillwater Pond   # placed: the client's overlay: 48.0, 51.3
    hint_area: { x: 50.0, y: 53.5, r: 6 }
    danger: "Quiet (darkhounds; Bayne, a rare one, roams near)"
    sources: "the WoWWiki archive's Stillwater Pond page"
  - id: tirisfal-glades-whispering-gardens
    tier: hidden
    gestures: [LISTEN]
    area: Whispering Gardens   # placed: the client's overlay: 84.8, 32.9 (the Terrace of Repose's too)
    hint_area: { x: 82.0, y: 36.0, r: 7 }
    danger: "Perilous (the Scarlet Crusade's elites, level 29 to 31)"
    sources: "the WoWWiki archive's Whispering Gardens page"
  - id: tirisfal-glades-terrace
    tier: hidden
    gestures: [DRINK]
    area: Terrace of Repose   # placed: the client's overlay: 84.8, 32.9 (the Whispering Gardens' too)
    hint_area: { x: 87.0, y: 30.0, r: 7 }
    danger: "Perilous (the Scarlet Crusade's elites, level 29 to 31)"
    sources: "the WoWWiki archive's Terrace of Repose page"
  - id: tirisfal-glades-faols-rest
    tier: hidden
    gestures: [PRAY, KNEEL, BOW]
    area: Faol's Rest   # placed: the server's graveyard 'Tirisfal Glades, Faol's Rest' (world_safe_locs 429): 79.2, 40.9
    anchor: { grave: 429 }   # what places its hint: the area has no overlay of its own
    hint_area: { x: 80.5, y: 38.5, r: 8 }
    danger: "Perilous (the Scarlet Crusade)"
    sources: "the game's Faol's Rest; Warcraft II: Tides of Darkness's manual (Faol and the Knights of the Silver Hand); object 177199"
quarry:
  id: 10357   # Ressan the Needler
  sources: "the WoWWiki archive's Ressan the Needler and Nightmare Vale pages (its colours, the vale's past); the dump's spawn"
---
## tirisfal-glades-zapetta
At the tower north of the city gate, where the airships come in over the sea,
a goblin takes the fares on the dead side of the water.
His brother promised good money in it, and never said which of them would live here.
Find him, and ask how he is getting on.
? The zeppelin tower north of the Undercity's gates: the goblin who sends the airship to Durotar.
= Zapetta, the zeppelin master: 'My brother said we could make great money with this trade route, but he didn't tell me I would be the one living on this side. If you come back this way on the Zeppelin, could you bring me something to eat?'
+ Hin Denburg, who sends the other airship south, has a low opinion of the gnomes' tram: if you believe in it, he has a statue in Stranglethorn to sell you.

## tirisfal-glades-clyde
East of the town of the dead, on the bank of the bright lake,
the village's bass master keeps his favourite spot.
The deathguards will tell you where to find him, and to mind the madmen in masks out there:
they had to shut down the children's summer camp last year.
? Brightwater Lake, east of Brill: the bass master's favourite spot on the south-western bank.
= Clyde Kellen, the local bass master, who teaches fishing on Brightwater Lake's south-western bank.
+ Elwynn tells a story of its own: a lake, a fisherman, a weird mask fished out of the water, and children camping by the shore. The two lakes are an ocean apart.

## tirisfal-glades-stillwater
West of the town of the dead, a little pond lies gray and still.
Before the plague, the folk of the glades came here to picnic,
and children too young for the deep lake learned to swim in it.
Only the dead and the hungry come now. Remember what it was.
? West of Brill, off the road to Deathknell: a gray pond, nearly forgotten.
= Stillwater Pond, once the glades' picnic ground. Darkhounds hunt its banks now.
+ Brightwater Lake, east of Brill, was for the older children: much larger, and much deeper.

## tirisfal-glades-whispering-gardens
On the hill south of the red crusaders' monastery,
a host of the dead once met the men who would become the Crusade.
Those who fell there have not gone quiet:
at twilight they can still be heard, if you will be still.
? South of the Scarlet Monastery, on its hill, in north-eastern Tirisfal.
= The Whispering Gardens, where those who would found the Scarlet Crusade fought the Scourge. Their dead whisper still.
+ The Crusade keeps its monastery a stone's throw away; to its zealots, every Forsaken is Scourge.

## tirisfal-glades-terrace
North of the red crusaders' monastery, the plague never came:
the hedges are green there, kept by the Crusade,
and a fountain runs with water that is fresh, as nothing else in these glades is.
Taste what the living keep for themselves.
? Behind the Scarlet Monastery, on its northern grounds: a garden the Crusade keeps.
= The Terrace of Repose: one of the very few places in northern Lordaeron the plague never reached.
+ Everywhere else in Tirisfal the water stands stagnant.

## tirisfal-glades-faols-rest
Near the monastery of the red crusaders,
a resting place bears the name of the archbishop
who gave the Light its first knights.
Do there what he taught a kingdom to do, if the Crusade lets you.
? South-west of the Scarlet Monastery, where its fallen come back.
= Faol's Rest, in sight of the zealots who claim his Light.
+ Stormwind remembers him too: a plaque in its cathedral calls him the 'benevolent patron of the Church of Light', who began his work in Stratholme and raised the funds to rebuild Stormwind after the Second War.

## quarry
In the withered vale of the south-west, where darkhounds and great bats
have eaten what the plague left alive, one bat is white,
with wings of pink, and the hunters who see it want it for their own.
It keeps to one small corner of the vale.
= Ressan the Needler, a white bat with pink wings, of Nightmare Vale.
+ Nightmare Vale was green once, and full of forest animals; the darkhounds and the vampire bats ate them.
