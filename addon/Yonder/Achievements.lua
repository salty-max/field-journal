-- Milestones: the journal's achievements. Tallies (kinds slain, families,
-- creatures slain, trophies), one per creature type (every family of it met),
-- feats, one per zone (every rare of it slain), the Atlas's, and the fish and
-- herbs' (tallies, feats, every fish of a continent, every herb of a zone). Each character earns its
-- own, and each remembers when and at what level:
--   YonderChar.achievements[id] = { at, level, retro }
-- Earned as in the game's own achievements: a banner among its alerts
-- (Toasts.lua), its fanfare and a chat line with a link. Those already deserved when the addon
-- first looks (a journal from before milestones) are recorded quietly.
-- No spoilers: a type's or a zone's milestone stays out of the list until one
-- of its families or rares has been met.
local _, ns = ...
local L = ns.kit.L
local D = ns.data
local PREFIX = ns.PREFIX

local function char() return ns.journal() end
local function creatures()
  local c = char()
  return c and c.creatures or {}
end

-- ── what the journal holds ───────────────────────────────────────────────────
local function recordedCount()
  local n = 0
  for _ in pairs(creatures()) do
    n = n + 1
  end
  return n
end

local function familiesMet()
  local n = 0
  for _ in pairs(char() and char().families or {}) do
    n = n + 1
  end
  return n
end

local function slainCount()
  local n = 0
  for _, rec in pairs(creatures()) do
    n = n + (rec.slain or 0)
  end
  return n
end

local function trophyCount(rank)
  local n = 0
  for _, rec in pairs(creatures()) do
    if rec.trophy and (not rank or rec.trophy.rank == rank) then n = n + 1 end
  end
  return n
end

local familyIndex = {}
for i, f in ipairs(D.families) do
  familyIndex[f.id] = i
end

-- Creatures of a family slain (by the family's id).
local function slainIn(familyId)
  local index, n = familyIndex[familyId], 0
  for id, rec in pairs(creatures()) do
    if D.creatures[id] == index then n = n + (rec.slain or 0) end
  end
  return n
end

-- (a creature joins the journal on its first kill: recorded is slain once)
local function recorded(id) return creatures()[id] ~= nil end
local function slain(id)
  local rec = creatures()[id]
  return rec ~= nil and (rec.slain or 0) > 0
end
local function count(ids, test)
  local n = 0
  for _, id in ipairs(ids) do
    if test(id) then n = n + 1 end
  end
  return n
end

-- A section's families (their ids), and how many of them have been met.
local function sectionFamilies(section)
  local out = {}
  for _, f in ipairs(D.families) do
    if f.section == section then table.insert(out, f.id) end
  end
  return out
end
local function familiesMetIn(ids)
  local families = char() and char().families or {}
  local n = 0
  for _, id in ipairs(ids) do
    if families[id] then n = n + 1 end
  end
  return n
end

-- ── the milestones ───────────────────────────────────────────────────────────
-- progress() returns what is done and what is needed.
local list = {}
ns.milestones = list
ns.milestoneById = {}
local function add(group, id, title, text, progress, extra)
  local m = { group = group, id = id, title = title, text = text, progress = progress }
  for k, v in pairs(extra or {}) do
    m[k] = v
  end
  table.insert(list, m)
  ns.milestoneById[id] = m
end

-- Tallies: a milestone at each step (need, title) of a count.
local function tiers(prefix, text, counted, steps)
  for _, step in ipairs(steps) do
    local need, title = step[1], step[2]
    add("tally", prefix .. need, title, text:format(need), function() return counted(), need end)
  end
end
tiers("met-", L["Record %d kinds of creature."], recordedCount, {
  { 10, L["First Sketches"] },
  { 50, L["A Notebook Half Full"] },
  { 100, L["A Hundred Kinds"] },
  { 250, L["Naturalist"] },
  { 500, L["Five Hundred Kinds"] },
  { 1000, L["A Thousand Kinds"] },
})
tiers("families-", L["Slay creatures of %d families."], familiesMet, {
  { 10, L["Branches of the Tree"] },
  { 25, L["Twenty-Five Families"] },
  { 50, L["Half a Hundred Families"] },
  { 75, L["The Great Tree of Life"] },
})
tiers("slain-", L["Slay %d creatures."], slainCount, {
  { 100, L["Blooded"] },
  { 500, L["Hunter"] },
  { 1000, L["A Thousand Kills"] },
  { 5000, L["Scourge of the Wild"] },
  { 10000, L["Ten Thousand Kills"] },
})
tiers("trophies-", L["Take %d trophies (rares and bosses slain)."], trophyCount, {
  { 1, L["First Trophy"] },
  { 10, L["A Wall of Trophies"] },
  { 25, L["Big Game Hunter"] },
  { 50, L["Master of the Hunt"] },
  { 100, L["Legend of the Hunt"] },
})

-- One per creature type: every family of it met.
local SECTION_TITLES = {
  beasts = L["Every Beast in the Book"],
  dragonkin = L["Scales and Wings"],
  demons = L["Know Thy Enemy"],
  elementals = L["Earth, Fire, Air and Water"],
  undead = L["Grave Matters"],
  giants = L["In the Giants' Shadow"],
  machines = L["Gears and Grinding"],
  peoples = L["Peoples of the World"],
  oddities = L["Curiosities"],
}
local SECTION_TEXTS = {
  beasts = L["Slay a creature of every family of beasts."],
  dragonkin = L["Slay a creature of every family of dragonkin."],
  demons = L["Slay a creature of every family of demons."],
  elementals = L["Slay a creature of every family of elementals."],
  undead = L["Slay a creature of every family of the undead."],
  giants = L["Slay a creature of every family of giants."],
  machines = L["Slay a creature of every family of machines."],
  peoples = L["Slay a creature of every family of humanoids."],
  oddities = L["Slay a creature of every family of oddities."],
}
for _, s in ipairs(D.sections) do
  local ids = sectionFamilies(s.id)
  if #ids > 0 then
    add(
      "type",
      "type-" .. s.id,
      SECTION_TITLES[s.id] or s.title,
      SECTION_TEXTS[s.id] or L["Slay a creature of every family of this kind."],
      function() return familiesMetIn(ids), #ids end,
      { visible = function() return familiesMetIn(ids) > 0 end }
    )
  end
end

-- Feats.
local NIGHTMARE = { 14887, 14888, 14889, 14890 } -- Ysondre, Lethon, Emeriss, Taerar
local DRAGONFLIGHTS =
  { "black-dragonflight", "red-dragonflight", "green-dragonflight", "blue-dragonflight", "bronze-dragonflight" }
add(
  "feat",
  "hogger",
  L["Hogger's End"],
  L["Slay Hogger, the terror of Elwynn."],
  function() return slain(448) and 1 or 0, 1 end
)
add("feat", "kobolds-50", L["You No Take Candle"], L["Slay 50 kobolds."], function() return slainIn("kobolds"), 50 end)
add("feat", "murlocs-100", L["Mrrgllglrgl!"], L["Slay 100 murlocs."], function() return slainIn("murlocs"), 100 end)
add("feat", "rare-elites-10", L["Elite Company"], L["Slay 10 rare elites."], function() return trophyCount("R"), 10 end)
add("feat", "every-type", L["A Little of Everything"], L["Slay a creature of every type in the book."], function()
  local n = 0
  for _, s in ipairs(D.sections) do
    if familiesMetIn(sectionFamilies(s.id)) > 0 then n = n + 1 end
  end
  return n, #D.sections
end)
add(
  "feat",
  "dragonflights",
  L["Every Colour of Dragon"],
  L["Slay a dragon of each of the five dragonflights."],
  function()
    local families = char() and char().families or {}
    local n = 0
    for _, f in ipairs(DRAGONFLIGHTS) do
      if families[f] then n = n + 1 end
    end
    return n, #DRAGONFLIGHTS
  end
)
add(
  "feat",
  "nightmare",
  L["The Emerald Nightmare"],
  L["Slay the four dragons of the Nightmare: Ysondre, Lethon, Emeriss and Taerar."],
  function() return count(NIGHTMARE, recorded), #NIGHTMARE end
)
add(
  "feat",
  "world-terror",
  L["Terror of the Wild"],
  L["Slay Azuregos or Lord Kazzak."],
  function() return (slain(6109) or slain(12397)) and 1 or 0, 1 end
)
add("feat", "onyxia", L["Into the Lair"], L["Slay Onyxia."], function() return slain(10184) and 1 or 0, 1 end)
add("feat", "ragnaros", L["The Firelord Falls"], L["Slay Ragnaros."], function() return slain(11502) and 1 or 0, 1 end)

-- One per zone: every rare of it slain (shown once one of them is).
local function zoneName(uiMap, zone)
  local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(uiMap)
  return info and info.name or zone.name
end
local zones = {}
for uiMap, zone in pairs(D.rareZones or {}) do
  table.insert(zones, { uiMap, zone })
end
table.sort(zones, function(a, b) return a[2].name < b[2].name end)
for _, z in ipairs(zones) do
  local uiMap, zone = z[1], z[2]
  local name = zoneName(uiMap, zone)
  add(
    "zone",
    "zone-" .. uiMap,
    L["The Rares of %s"]:format(name),
    L["Slay every rare creature of %s."]:format(name),
    function() return count(zone, slain), #zone end,
    { visible = function() return count(zone, recorded) > 0 end }
  )
end

-- The Atlas: every place of a zone (shown once entered), every zone of a
-- continent, flights, and a few feats of travel.
local A = D.atlas or { zones = {}, continents = {} }
local function atlas() return ns.atlas and ns.atlas() end
local function enteredZone(uiMap)
  local z = atlas() and atlas().zones[uiMap]
  return z ~= nil and (z.first ~= nil or z.retro ~= nil or next(z.places or {}) ~= nil)
end
local explorable = {}
for uiMap, zone in pairs(A.zones) do
  if #zone.places > 0 then table.insert(explorable, { uiMap, zone }) end
end
table.sort(explorable, function(a, b) return a[2].name < b[2].name end)
for _, z in ipairs(explorable) do
  local uiMap = z[1]
  local name = ns.zoneName and ns.zoneName(uiMap) or z[2].name
  add(
    "explore",
    "explore-" .. uiMap,
    L["Explore %s"]:format(name),
    L["Explore every place of %s."]:format(name),
    function() return ns.zoneProgress(uiMap) end,
    { visible = function() return enteredZone(uiMap) end }
  )
end
local continents = {}
for id, name in pairs(A.continents) do
  table.insert(continents, { id, name })
end
table.sort(continents, function(a, b) return a[2] < b[2] end)
for _, c in ipairs(continents) do
  local inContinent = {}
  for uiMap, zone in pairs(A.zones) do
    if zone.continent == c[1] then table.insert(inContinent, uiMap) end
  end
  add(
    "travel",
    "continent-" .. c[1],
    L["Wanderer of %s"]:format(c[2]),
    L["Set foot in every zone and city of %s."]:format(c[2]),
    function() return count(inContinent, enteredZone), #inContinent end
  )
end
local function flights() return #(atlas() and atlas().flights or {}) end
for _, t in ipairs({ { 10, L["Wings for Hire"] }, { 50, L["Frequent Flyer"] }, { 100, L["Master of the Skies"] } }) do
  add("travel", "flights-" .. t[1], t[2], L["Take %d flights."]:format(t[1]), function() return flights(), t[1] end)
end
add(
  "travel",
  "crossing",
  L["Across the Sea"],
  L["Cross from one continent to the other."],
  function() return math.min(#(atlas() and atlas().crossings or {}), 1), 1 end
)
add("travel", "binds-5", L["Many Hearths"], L["Make your home in five different inns."], function()
  local places, n = {}, 0
  for _, b in ipairs(atlas() and atlas().binds or {}) do
    if not places[b.place] then
      places[b.place], n = true, n + 1
    end
  end
  return n, 5
end)
add(
  "feat",
  "close-calls-10",
  L["Living Dangerously"],
  L["Survive ten close calls (a tenth of your health or less)."],
  function() return #(atlas() and atlas().closeCalls or {}), 10 end
)

-- The expeditions (Expeditions.lua): the first riddle and the first quarry,
-- every riddle and the quarry of a zone (shown once the zone is entered), of
-- a tier and all of a continent, the gold seals, the quarries never tracked,
-- and every riddle that asks a gesture, a reading, the night. A faction's
-- riddles and quarries (its capitals', its starting zones', its towns') count
-- for that faction alone.
local X = D.expeditions or {}
local function riddles(test)
  local done, total = 0, 0
  for _, r in pairs(ns.riddleById or {}) do
    if ns.riddleOpen(r) and (not test or test(r)) then
      total = total + 1
      if ns.riddleSolved(r.id) then done = done + 1 end
    end
  end
  return done, total
end
local function quarries(test)
  local done, total = 0, 0
  for _, q in pairs(ns.quarryById or {}) do
    if ns.quarryOpen(q) and (not test or test(q)) then
      total = total + 1
      if ns.quarryDown(q.id) then done = done + 1 end
    end
  end
  return done, total
end
-- (riddles and quarries together)
local function both(test)
  local d1, t1 = riddles(test)
  local d2, t2 = quarries(test)
  return d1 + d2, t1 + t2
end
-- (the riddles the book holds now: a record of one since rewritten counts no more)
local function goldSeals()
  local n = 0
  for id, r in pairs(ns.riddleById or {}) do
    local rec = ns.riddleOpen(r) and ns.riddleRecord(id)
    if rec and rec.at and (rec.hints or 0) == 0 then n = n + 1 end
  end
  return n
end
local function untracked()
  local n = 0
  for id, rec in pairs(ns.expeditions() and ns.expeditions().hunts or {}) do
    if rec.at and ns.huntSeal(rec) == "gold" and ns.quarryById[id] then n = n + 1 end
  end
  return n
end
local function onContinent(c)
  return function(x) return A.zones[x.zone] and A.zones[x.zone].continent == c end
end
add(
  "expeditions",
  "riddle-first",
  L["A Riddle Read Aright"],
  L["Solve a riddle of the expeditions."],
  function() return math.min((riddles()), 1), 1 end
)
add(
  "expeditions",
  "quarry-first",
  L["First Quarry"],
  L["Bring down a quarry of the expeditions."],
  function() return math.min((quarries()), 1), 1 end
)
local expeditionZones = {}
for uiMap in pairs(X) do
  if A.zones[uiMap] then table.insert(expeditionZones, uiMap) end
end
local function nameOf(uiMap) return ns.zoneName and ns.zoneName(uiMap) or A.zones[uiMap].name end
table.sort(expeditionZones, function(a, b) return nameOf(a) < nameOf(b) end)
for _, uiMap in ipairs(expeditionZones) do
  local name = nameOf(uiMap)
  local function here(x) return x.zone == uiMap end
  add(
    "expeditions",
    "expedition-" .. uiMap,
    -- ("The Barrens Expedition", "The Durotar Expedition")
    (name:find("^The ") and L["%s Expedition"] or L["The %s Expedition"]):format(name),
    (X[uiMap].quarry and L["Solve every riddle of %s and bring down its quarry."] or L["Solve every riddle of %s."]):format(
      name
    ),
    function() return both(here) end,
    { visible = function() return enteredZone(uiMap) and select(2, both(here)) > 0 end }
  )
end
local TIER_MILESTONES = {
  { "near", L["The Roads of %s"], L["Solve every riddle near the road in %s."] },
  { "off", L["Off the Roads of %s"], L["Solve every riddle off the road in %s."] },
  { "hidden", L["Nothing Hidden in %s"], L["Solve every hidden riddle of %s."] },
}
for _, c in ipairs(continents) do
  local here = onContinent(c[1])
  for _, t in ipairs(TIER_MILESTONES) do
    add("expeditions", ("riddles-%s-%d"):format(t[1], c[1]), t[2]:format(c[2]), t[3]:format(c[2]), function()
      return riddles(function(r) return r.tier == t[1] and here(r) end)
    end, { visible = function() return select(2, riddles(here)) > 0 end })
  end
  add(
    "expeditions",
    "expeditions-" .. c[1],
    L["The Expeditions of %s"]:format(c[2]),
    L["Complete every expedition of %s: its riddles, its towns' and capitals' with them, and its quarries."]:format(
      c[2]
    ),
    function() return both(here) end,
    { visible = function() return select(2, both(here)) > 0 end }
  )
end
add("expeditions", "gold-10", L["By Your Own Light"], L["Earn ten gold seals."], function() return goldSeals(), 10 end)
add("expeditions", "gold-50", L["Clear Sight"], L["Earn fifty gold seals."], function() return goldSeals(), 50 end)
add(
  "expeditions",
  "gold-all",
  L["Nothing Asked"],
  L["Earn the gold seal of every riddle."],
  function() return goldSeals(), select(2, riddles()) end
)
add(
  "expeditions",
  "untracked-5",
  L["Without a Map"],
  L["Bring down five quarries without tracking them."],
  function() return untracked(), 5 end
)
add(
  "expeditions",
  "untracked-all",
  L["No Trail Given"],
  L["Bring down every quarry without tracking it."],
  function() return untracked(), select(2, quarries()) end
)
add("expeditions", "gestures", L["Respects Paid"], L["Solve every riddle that asks something of you there."], function()
  return riddles(function(r) return r.asks == "gesture" end)
end)
add("expeditions", "readings", L["Well Read"], L["Solve every riddle that asks for a reading."], function()
  return riddles(function(r) return r.asks == "reading" end)
end)
-- (shown only while a riddle asks the night: none does now)
local function byNight(r) return r.night end
add(
  "expeditions",
  "night",
  L["After Dark"],
  L["Solve every riddle that only the night answers."],
  function() return riddles(byNight) end,
  { visible = function() return select(2, riddles(byNight)) > 0 end }
)

-- Fish and herbs (Flora.lua): tallies, feats, every fish of a continent's
-- waters and every herb of a zone (shown once one of them is found there).
local F = D.flora or { fish = {}, herbs = {}, fishOrder = {}, herbOrder = {} }
local function fishRecs()
  local c = char()
  return c and c.fish or {}
end
local function plantRecs()
  local c = char()
  return c and c.plants or {}
end
local function caught(id) return fishRecs()[id] ~= nil end
local function have(id) return plantRecs()[id] ~= nil end
-- The fish of the waters, the reagents and the rare catches: the kinds one
-- can set out to catch (not the quest fish, nor the weighed catches).
local KINDS = { food = true, reagent = true, special = true }
local species = {}
for _, id in ipairs(F.fishOrder) do
  if KINDS[F.fish[id].kind] then table.insert(species, id) end
end
local function sum(recs, field)
  local n = 0
  for _, rec in pairs(recs) do
    n = n + (rec[field] or 0)
  end
  return n
end
local function kindsOf(recs)
  local n = 0
  for _ in pairs(recs) do
    n = n + 1
  end
  return n
end

add(
  "fishing",
  "fish-first",
  L["First Catch"],
  L["Catch a fish."],
  function() return math.min(sum(fishRecs(), "n"), 1), 1 end
)
for _, t in ipairs({ { 10, L["A Full Creel"] }, { 20, L["Twenty Kinds of Fish"] } }) do
  add(
    "fishing",
    "fish-kinds-" .. t[1],
    t[2],
    L["Catch %d kinds of fish."]:format(t[1]),
    function() return count(species, caught), t[1] end
  )
end
add(
  "fishing",
  "fish-all",
  L["Every Fish in the Sea"],
  L["Catch every kind of fish of the waters, every reagent and the Deviate Fish."],
  function() return count(species, caught), #species end
)
for _, t in ipairs({ { 100, L["A Hundred Fish"] }, { 1000, L["Master Angler"] } }) do
  add(
    "fishing",
    "fish-n-" .. t[1],
    t[2],
    L["Catch %d fish."]:format(t[1]),
    function() return sum(fishRecs(), "n"), t[1] end
  )
end
local PAGLE = { 16967, 16970, 16968, 16969 } -- Feralas Ahi, Misty Reed Mahi Mahi, Sar'theris Striker, Savage Coast Blue Sailfin
add(
  "fishing",
  "pagle",
  L["Nat Pagle's Catch"],
  L["Catch the four rare fish Nat Pagle asks for."],
  function() return count(PAGLE, caught), #PAGLE end
)
local SCHOOLED = { 6358, 6359, 13422, 6522 } -- Oily Blackmouth, Firefin Snapper, Stonescale Eel, Deviate Fish
add(
  "fishing",
  "schools",
  L["Schools of Every Kind"],
  L["Catch from a school of Oily Blackmouth, Firefin Snapper, Stonescale Eel and Deviate Fish."],
  function()
    return count(SCHOOLED, function(id)
      local r = fishRecs()[id]
      return r ~= nil and (r.school or 0) > 0
    end),
      #SCHOOLED
  end
)
add(
  "fishing",
  "seasons",
  L["Every Season"],
  L["Catch a Winter Squid and a Raw Summer Bass."],
  function() return count({ 13755, 13756 }, caught), 2 end
)
add(
  "fishing",
  "night-day",
  L["By Moon and by Sun"],
  L["Catch a Raw Nightfin Snapper by night and a Raw Sunscale Salmon by day."],
  function()
    local night, day = fishRecs()[13759], fishRecs()[13760]
    return ((night and (night.night or 0) > 0) and 1 or 0) + ((day and (day.day or 0) > 0) and 1 or 0), 2
  end
)
add(
  "fishing",
  "heavy",
  L["The One That Didn't Get Away"],
  L["Land a weighed catch of a hundred pounds or more."],
  function()
    local most = 0
    for _, rec in pairs(fishRecs()) do
      most = math.max(most, rec.heaviest or 0)
    end
    return math.min(most, 100), 100
  end
)
-- Every fish of a continent's waters (those of its zones).
for _, c in ipairs(continents) do
  local ids, there = {}, {}
  for uiMap, zone in pairs(A.zones) do
    if zone.continent == c[1] then there[uiMap] = true end
  end
  for _, id in ipairs(species) do
    for _, z in ipairs(F.fish[id].zones) do
      if there[z] then
        table.insert(ids, id)
        break
      end
    end
  end
  if #ids > 0 then
    add(
      "fishing",
      "fish-continent-" .. c[1],
      L["The Waters of %s"]:format(c[2]),
      L["Catch every kind of fish of the waters of %s."]:format(c[2]),
      function() return count(ids, caught), #ids end,
      { visible = function() return count(ids, caught) > 0 end }
    )
  end
end

add(
  "herbs",
  "herb-first",
  L["First Herb"],
  L["Gather or find an herb."],
  function() return math.min(kindsOf(plantRecs()), 1), 1 end
)
for _, t in ipairs({ { 10, L["An Herbalist's Satchel"] }, { 20, L["Twenty Herbs"] } }) do
  add(
    "herbs",
    "herb-kinds-" .. t[1],
    t[2],
    L["Find %d kinds of herb."]:format(t[1]),
    function() return count(F.herbOrder, have), t[1] end
  )
end
add(
  "herbs",
  "herb-all",
  L["The Complete Herbarium"],
  L["Find every herb of the world."],
  function() return count(F.herbOrder, have), #F.herbOrder end
)
for _, t in ipairs({ { 100, L["Green Thumb"] }, { 1000, L["Master Herbalist"] } }) do
  add(
    "herbs",
    "herb-gathered-" .. t[1],
    t[2],
    L["Gather %d herbs."]:format(t[1]),
    function() return sum(plantRecs(), "gathered"), t[1] end
  )
end
add(
  "herbs",
  "black-lotus",
  L["The Black Lotus"],
  L["Find a Black Lotus."],
  function() return have(13468) and 1 or 0, 1 end
)
add(
  "herbs",
  "lotuses",
  L["Every Lotus"],
  L["Find a Purple Lotus and a Black Lotus."],
  function() return count({ 8831, 13468 }, have), 2 end
)
add(
  "herbs",
  "plague-flora",
  L["What Grows in the Plague"],
  L["Find Plaguebloom and Arthas' Tears."],
  function() return count({ 13466, 8836 }, have), 2 end
)
-- Every herb of a zone (shown once one is found there).
local herbZones = {}
for _, id in ipairs(F.herbOrder) do
  for _, z in ipairs(F.herbs[id].zones) do
    herbZones[z] = herbZones[z] or {}
    table.insert(herbZones[z], id)
  end
end
local hz = {}
for uiMap, ids in pairs(herbZones) do
  if A.zones[uiMap] then table.insert(hz, { uiMap, ids }) end
end
table.sort(hz, function(a, b) return A.zones[a[1]].name < A.zones[b[1]].name end)
for _, z in ipairs(hz) do
  local uiMap, ids = z[1], z[2]
  local name = ns.zoneName and ns.zoneName(uiMap) or A.zones[uiMap].name
  add(
    "herbs",
    "herbs-" .. uiMap,
    L["The Herbs of %s"]:format(name),
    L["Find every herb that grows in %s."]:format(name),
    function() return count(ids, have), #ids end,
    {
      visible = function()
        for _, id in ipairs(ids) do
          local rec = plantRecs()[id]
          if rec and rec.zones and rec.zones[uiMap] then return true end
        end
        return false
      end,
    }
  )
end

-- ── earning ──────────────────────────────────────────────────────────────────
function ns.milestoneVisible(m) return not m.visible or m.visible() or ns.earnedMilestone(m.id) ~= nil end

function ns.earnedMilestone(id)
  local c = char()
  return c and c.achievements and c.achievements[id]
end

-- Earned, and listed (what this character may know of).
function ns.milestoneCount()
  local n, shown = 0, 0
  for _, m in ipairs(list) do
    if ns.earnedMilestone(m.id) then n = n + 1 end
    if ns.milestoneVisible(m) then shown = shown + 1 end
  end
  return n, shown
end

-- The fanfare of the game's achievements; the trophy sound where the client
-- has none.
local FANFARE = 12891
function ns.achievementFanfare()
  local ok, willPlay = pcall(PlaySound, FANFARE, "Master")
  if not (ok and willPlay) then ns.playSound() end
end

-- The expeditions' milestones follow the riddles as the book holds them: one
-- that a rewritten riddle or a new one leaves undone is withdrawn (at the
-- login, quietly), to be earned again, with its alert.
local function withdraw(c)
  for _, m in ipairs(list) do
    if m.group == "expeditions" and c.achievements[m.id] then
      local done, need = m.progress()
      if need == 0 or done < need then c.achievements[m.id] = nil end
    end
  end
end

-- quiet: record without a word (reached before the addon looked), and
-- withdraw what the expeditions no longer grant (the login).
function ns.checkMilestones(quiet)
  local c = char()
  if not c then return end
  c.achievements = c.achievements or {}
  if quiet then withdraw(c) end
  local earned = false
  for _, m in ipairs(list) do
    if not c.achievements[m.id] then
      local done, need = m.progress()
      if need > 0 and done >= need then
        c.achievements[m.id] = { at = time(), level = UnitLevel("player"), retro = quiet or nil }
        earned = true
        if not quiet then
          local link = ("|cffffd100|Hyonder:m%s|h[%s]|h|r"):format(m.id, m.title)
          print(PREFIX .. L["achievement earned: %s"]:format(link))
          ns.achievementFanfare()
          ns.toast("milestone", m.id)
        end
      end
    end
  end
  if earned and ns.onMilestone then ns.onMilestone() end
end
