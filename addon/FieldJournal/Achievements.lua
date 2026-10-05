-- Milestones: the journal's achievements. Tallies (kinds met, families met,
-- creatures slain, trophies), one per creature type (every family of it met),
-- feats, one per zone (every rare of it slain), the Atlas's, and the fish and
-- herbs' (tallies, feats, every fish of a continent, every herb of a zone). Each character earns its
-- own, and each remembers when and at what level:
--   FieldJournalChar.achievements[id] = { at, level, retro }
-- Earned as in the game's own achievements: its achievement toast, its
-- fanfare and a chat line with a link. Those already deserved when the addon
-- first looks (a journal from before milestones) are recorded quietly.
-- No spoilers: a type's or a zone's milestone stays out of the list until one
-- of its families or rares has been met.
local _, ns = ...
local D = ns.data
local PREFIX = "|cffc9a227Field Journal:|r "

local function char() return ns.journal() end
local function creatures() local c = char(); return c and c.creatures or {} end

-- ── what the journal holds ───────────────────────────────────────────────────
local function metCount()
  local n = 0
  for _ in pairs(creatures()) do n = n + 1 end
  return n
end

local function familiesMet()
  local n = 0
  for _ in pairs(char() and char().families or {}) do n = n + 1 end
  return n
end

local function slainCount()
  local n = 0
  for _, rec in pairs(creatures()) do n = n + (rec.slain or 0) end
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
for i, f in ipairs(D.families) do familyIndex[f.id] = i end

-- Creatures of a family slain (by the family's id).
local function slainIn(familyId)
  local index, n = familyIndex[familyId], 0
  for id, rec in pairs(creatures()) do
    if D.creatures[id] == index then n = n + (rec.slain or 0) end
  end
  return n
end

local function met(id) return creatures()[id] ~= nil end
local function slain(id) local rec = creatures()[id]; return rec ~= nil and (rec.slain or 0) > 0 end
local function count(ids, test)
  local n = 0
  for _, id in ipairs(ids) do if test(id) then n = n + 1 end end
  return n
end

-- A section's families, and how many of them have been met.
local function sectionFamilies(section)
  local out = {}
  for i, f in ipairs(D.families) do
    if f.section == section then table.insert(out, i) end
  end
  return out
end
local function familiesMetIn(indexes)
  local families = char() and char().families or {}
  local n = 0
  for _, i in ipairs(indexes) do if families[i] then n = n + 1 end end
  return n
end

-- ── the milestones ───────────────────────────────────────────────────────────
-- progress() returns what is done and what is needed.
local list = {}
ns.milestones = list
ns.milestoneById = {}
local function add(group, id, title, text, progress, extra)
  local m = { group = group, id = id, title = title, text = text, progress = progress }
  for k, v in pairs(extra or {}) do m[k] = v end
  table.insert(list, m)
  ns.milestoneById[id] = m
end

-- Tallies.
for _, t in ipairs({ { 10, "First Sketches" }, { 50, "A Notebook Half Full" }, { 100, "A Hundred Kinds" },
  { 250, "Naturalist" }, { 500, "Five Hundred Kinds" }, { 1000, "A Thousand Kinds" } }) do
  add("tally", "met-" .. t[1], t[2], ("Record %d kinds of creature."):format(t[1]), function() return metCount(), t[1] end)
end
for _, t in ipairs({ { 10, "Branches of the Tree" }, { 25, "Twenty-Five Families" }, { 50, "Half a Hundred Families" },
  { 75, "The Great Tree of Life" } }) do
  add("tally", "families-" .. t[1], t[2], ("Meet creatures of %d families."):format(t[1]), function() return familiesMet(), t[1] end)
end
for _, t in ipairs({ { 100, "Blooded" }, { 500, "Hunter" }, { 1000, "A Thousand Kills" },
  { 5000, "Scourge of the Wild" }, { 10000, "Ten Thousand Kills" } }) do
  add("tally", "slain-" .. t[1], t[2], ("Slay %d creatures."):format(t[1]), function() return slainCount(), t[1] end)
end
for _, t in ipairs({ { 1, "First Trophy" }, { 10, "A Wall of Trophies" }, { 25, "Big Game Hunter" },
  { 50, "Master of the Hunt" }, { 100, "Legend of the Hunt" } }) do
  add("tally", "trophies-" .. t[1], t[2], ("Take %d trophies (rares and bosses slain)."):format(t[1]),
    function() return trophyCount(), t[1] end)
end

-- One per creature type: every family of it met.
local SECTION_TITLES = {
  beasts = "Every Beast in the Book", dragonkin = "Scales and Wings", demons = "Know Thy Enemy",
  elementals = "Earth, Fire, Air and Water", undead = "Grave Matters", giants = "In the Giants' Shadow",
  machines = "Gears and Grinding", peoples = "Peoples of the World", oddities = "Curiosities",
}
for _, s in ipairs(D.sections) do
  local indexes = sectionFamilies(s.id)
  if #indexes > 0 then
    add("type", "type-" .. s.id, SECTION_TITLES[s.id] or s.title,
      ("Meet a creature of every family of %s."):format(s.title == "Humanoids" and "humanoids" or s.title:lower()),
      function() return familiesMetIn(indexes), #indexes end,
      { visible = function() return familiesMetIn(indexes) > 0 end })
  end
end

-- Feats.
local NIGHTMARE = { 14887, 14888, 14889, 14890 } -- Ysondre, Lethon, Emeriss, Taerar
local DRAGONFLIGHTS = { "black-dragonflight", "red-dragonflight", "green-dragonflight", "blue-dragonflight", "bronze-dragonflight" }
add("feat", "hogger", "Hogger's End", "Slay Hogger, the terror of Elwynn.", function() return slain(448) and 1 or 0, 1 end)
add("feat", "kobolds-50", "You No Take Candle", "Slay 50 kobolds.", function() return slainIn("kobolds"), 50 end)
add("feat", "murlocs-100", "Mrrgllglrgl!", "Slay 100 murlocs.", function() return slainIn("murlocs"), 100 end)
add("feat", "rare-elites-10", "Elite Company", "Slay 10 rare elites.", function() return trophyCount("R"), 10 end)
add("feat", "every-type", "A Little of Everything", "Meet a creature of every type in the book.", function()
  local n = 0
  for _, s in ipairs(D.sections) do
    if familiesMetIn(sectionFamilies(s.id)) > 0 then n = n + 1 end
  end
  return n, #D.sections
end)
add("feat", "dragonflights", "Every Colour of Dragon", "Meet a dragon of each of the five dragonflights.", function()
  local families = char() and char().families or {}
  local n = 0
  for _, f in ipairs(DRAGONFLIGHTS) do if familyIndex[f] and families[familyIndex[f]] then n = n + 1 end end
  return n, #DRAGONFLIGHTS
end)
add("feat", "nightmare", "The Emerald Nightmare", "Meet the four dragons of the Nightmare: Ysondre, Lethon, Emeriss and Taerar.",
  function() return count(NIGHTMARE, met), #NIGHTMARE end)
add("feat", "world-terror", "Terror of the Wild", "Slay Azuregos or Lord Kazzak.",
  function() return (slain(6109) or slain(12397)) and 1 or 0, 1 end)
add("feat", "onyxia", "Into the Lair", "Slay Onyxia.", function() return slain(10184) and 1 or 0, 1 end)
add("feat", "ragnaros", "The Firelord Falls", "Slay Ragnaros.", function() return slain(11502) and 1 or 0, 1 end)

-- One per zone: every rare of it slain (shown once one of them is met).
local function zoneName(uiMap, zone)
  local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(uiMap)
  return info and info.name or zone.name
end
local zones = {}
for uiMap, zone in pairs(D.rareZones or {}) do table.insert(zones, { uiMap, zone }) end
table.sort(zones, function(a, b) return a[2].name < b[2].name end)
for _, z in ipairs(zones) do
  local uiMap, zone = z[1], z[2]
  local name = zoneName(uiMap, zone)
  add("zone", "zone-" .. uiMap, ("The Rares of %s"):format(name), ("Slay every rare creature of %s."):format(name),
    function() return count(zone, slain), #zone end,
    { visible = function() return count(zone, met) > 0 end })
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
  add("explore", "explore-" .. uiMap, ("Explore %s"):format(name), ("Explore every place of %s."):format(name),
    function() return ns.zoneProgress(uiMap) end,
    { visible = function() return enteredZone(uiMap) end })
end
local continents = {}
for id, name in pairs(A.continents) do table.insert(continents, { id, name }) end
table.sort(continents, function(a, b) return a[2] < b[2] end)
for _, c in ipairs(continents) do
  local zones = {}
  for uiMap, zone in pairs(A.zones) do
    if zone.continent == c[1] then table.insert(zones, uiMap) end
  end
  add("travel", "continent-" .. c[1], ("Wanderer of %s"):format(c[2]), ("Set foot in every zone and city of %s."):format(c[2]),
    function() return count(zones, enteredZone), #zones end)
end
local function flights() return #(atlas() and atlas().flights or {}) end
for _, t in ipairs({ { 10, "Wings for Hire" }, { 50, "Frequent Flyer" }, { 100, "Master of the Skies" } }) do
  add("travel", "flights-" .. t[1], t[2], ("Take %d flights."):format(t[1]), function() return flights(), t[1] end)
end
add("travel", "crossing", "Across the Sea", "Cross from one continent to the other.",
  function() return math.min(#(atlas() and atlas().crossings or {}), 1), 1 end)
add("travel", "binds-5", "Many Hearths", "Make your home in five different inns.", function()
  local places, n = {}, 0
  for _, b in ipairs(atlas() and atlas().binds or {}) do
    if not places[b.place] then places[b.place], n = true, n + 1 end
  end
  return n, 5
end)
add("feat", "close-calls-10", "Living Dangerously", "Survive ten close calls (a tenth of your health or less).",
  function() return #(atlas() and atlas().closeCalls or {}), 10 end)

-- Fish and herbs (Flora.lua): tallies, feats, every fish of a continent's
-- waters and every herb of a zone (shown once one of them is found there).
local F = D.flora or { fish = {}, herbs = {}, fishOrder = {}, herbOrder = {} }
local function fishRecs() local c = char(); return c and c.fish or {} end
local function plantRecs() local c = char(); return c and c.plants or {} end
local function caught(id) return fishRecs()[id] ~= nil end
local function have(id) return plantRecs()[id] ~= nil end
-- The fish of the waters, the reagents and the rare catches: the kinds one
-- can set out to catch (not the quest fish, nor the weighed catches).
local KINDS = { food = true, reagent = true, special = true }
local species = {}
for _, id in ipairs(F.fishOrder) do if KINDS[F.fish[id].kind] then table.insert(species, id) end end
local function sum(recs, field)
  local n = 0
  for _, rec in pairs(recs) do n = n + (rec[field] or 0) end
  return n
end
local function kindsOf(recs)
  local n = 0
  for _ in pairs(recs) do n = n + 1 end
  return n
end

add("fishing", "fish-first", "First Catch", "Catch a fish.", function() return math.min(sum(fishRecs(), "n"), 1), 1 end)
for _, t in ipairs({ { 10, "A Full Creel" }, { 20, "Twenty Kinds of Fish" } }) do
  add("fishing", "fish-kinds-" .. t[1], t[2], ("Catch %d kinds of fish."):format(t[1]),
    function() return count(species, caught), t[1] end)
end
add("fishing", "fish-all", "Every Fish in the Sea", "Catch every kind of fish of the waters, every reagent and the Deviate Fish.",
  function() return count(species, caught), #species end)
for _, t in ipairs({ { 100, "A Hundred Fish" }, { 1000, "Master Angler" } }) do
  add("fishing", "fish-n-" .. t[1], t[2], ("Catch %d fish."):format(t[1]), function() return sum(fishRecs(), "n"), t[1] end)
end
local PAGLE = { 16967, 16970, 16968, 16969 } -- Feralas Ahi, Misty Reed Mahi Mahi, Sar'theris Striker, Savage Coast Blue Sailfin
add("fishing", "pagle", "Nat Pagle's Catch", "Catch the four rare fish Nat Pagle asks for.", function() return count(PAGLE, caught), #PAGLE end)
local SCHOOLED = { 6358, 6359, 13422, 6522 } -- Oily Blackmouth, Firefin Snapper, Stonescale Eel, Deviate Fish
add("fishing", "schools", "Schools of Every Kind", "Catch from a school of Oily Blackmouth, Firefin Snapper, Stonescale Eel and Deviate Fish.",
  function() return count(SCHOOLED, function(id) local r = fishRecs()[id]; return r ~= nil and (r.school or 0) > 0 end), #SCHOOLED end)
add("fishing", "seasons", "Every Season", "Catch a Winter Squid and a Raw Summer Bass.", function() return count({ 13755, 13756 }, caught), 2 end)
add("fishing", "night-day", "By Moon and by Sun", "Catch a Raw Nightfin Snapper by night and a Raw Sunscale Salmon by day.", function()
  local night, day = fishRecs()[13759], fishRecs()[13760]
  return ((night and (night.night or 0) > 0) and 1 or 0) + ((day and (day.day or 0) > 0) and 1 or 0), 2
end)
add("fishing", "heavy", "The One That Didn't Get Away", "Land a weighed catch of a hundred pounds or more.", function()
  local most = 0
  for _, rec in pairs(fishRecs()) do most = math.max(most, rec.heaviest or 0) end
  return math.min(most, 100), 100
end)
-- Every fish of a continent's waters (those of its zones).
for _, c in ipairs(continents) do
  local ids, there = {}, {}
  for uiMap, zone in pairs(A.zones) do if zone.continent == c[1] then there[uiMap] = true end end
  for _, id in ipairs(species) do
    for _, z in ipairs(F.fish[id].zones) do
      if there[z] then table.insert(ids, id) break end
    end
  end
  if #ids > 0 then
    add("fishing", "fish-continent-" .. c[1], ("The Waters of %s"):format(c[2]), ("Catch every kind of fish of the waters of %s."):format(c[2]),
      function() return count(ids, caught), #ids end,
      { visible = function() return count(ids, caught) > 0 end })
  end
end

add("herbs", "herb-first", "First Herb", "Gather or find an herb.", function() return math.min(kindsOf(plantRecs()), 1), 1 end)
for _, t in ipairs({ { 10, "An Herbalist's Satchel" }, { 20, "Twenty Herbs" } }) do
  add("herbs", "herb-kinds-" .. t[1], t[2], ("Find %d kinds of herb."):format(t[1]),
    function() return count(F.herbOrder, have), t[1] end)
end
add("herbs", "herb-all", "The Complete Herbarium", "Find every herb of the world.", function() return count(F.herbOrder, have), #F.herbOrder end)
for _, t in ipairs({ { 100, "Green Thumb" }, { 1000, "Master Herbalist" } }) do
  add("herbs", "herb-gathered-" .. t[1], t[2], ("Gather %d herbs."):format(t[1]), function() return sum(plantRecs(), "gathered"), t[1] end)
end
add("herbs", "black-lotus", "The Black Lotus", "Find a Black Lotus.", function() return have(13468) and 1 or 0, 1 end)
add("herbs", "lotuses", "Every Lotus", "Find a Purple Lotus and a Black Lotus.", function() return count({ 8831, 13468 }, have), 2 end)
add("herbs", "plague-flora", "What Grows in the Plague", "Find Plaguebloom and Arthas' Tears.", function() return count({ 13466, 8836 }, have), 2 end)
-- Every herb of a zone (shown once one is found there).
local herbZones = {}
for _, id in ipairs(F.herbOrder) do
  for _, z in ipairs(F.herbs[id].zones) do
    herbZones[z] = herbZones[z] or {}
    table.insert(herbZones[z], id)
  end
end
local hz = {}
for uiMap, ids in pairs(herbZones) do if A.zones[uiMap] then table.insert(hz, { uiMap, ids }) end end
table.sort(hz, function(a, b) return (A.zones[a[1]].name) < (A.zones[b[1]].name) end)
for _, z in ipairs(hz) do
  local uiMap, ids = z[1], z[2]
  local name = ns.zoneName and ns.zoneName(uiMap) or A.zones[uiMap].name
  add("herbs", "herbs-" .. uiMap, ("The Herbs of %s"):format(name), ("Find every herb that grows in %s."):format(name),
    function() return count(ids, have), #ids end,
    { visible = function()
      for _, id in ipairs(ids) do
        local rec = plantRecs()[id]
        if rec and rec.zones and rec.zones[uiMap] then return true end
      end
      return false
    end })
end

-- ── earning ──────────────────────────────────────────────────────────────────
function ns.milestoneVisible(m)
  return not m.visible or m.visible() or ns.earnedMilestone(m.id) ~= nil
end

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

-- The game's achievement toast, with the journal's book.
local toasts

-- The achievement toast's points shield runs AchievementShield_OnLoad, from
-- the game's achievement window, loaded on demand. Classic Era has no such
-- window, and Forever's (its own game type) doesn't define it: any achievement
-- toast then warns, ours and the game's own alike, the first one before ours
-- had a chance to help. So at load, where the game hasn't defined it, a
-- stand-in does what it does (the shield's two methods); the game's own
-- replaces it whenever its window loads.
if not AchievementShield_OnLoad then
  function AchievementShield_OnLoad(self)
    self.Desaturate = AchievementShield_Desaturate or function() end
    self.Saturate = AchievementShield_Saturate or function() end
  end
end

local function toast(id)
  if toasts == nil then
    toasts = false
    if AlertFrame and AlertFrame.AddQueuedAlertFrameSubSystem and C_XMLUtil and C_XMLUtil.GetTemplateInfo
      and C_XMLUtil.GetTemplateInfo("AchievementAlertFrameTemplate") then
      toasts = AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", function(frame, mid)
        local m = ns.milestoneById[mid]
        frame.milestone = mid
        frame.Icon.Texture:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
        frame.Unlocked:SetText("Field Journal milestone")
        frame.Name:SetText(m.title)
        frame.Shield:Hide() -- no points
        frame:SetScript("OnClick", function(self, button, down)
          if AlertFrame_OnClick and AlertFrame_OnClick(self, button, down) then return end -- right-click: dismissed
          if ns.openMilestones then ns.openMilestones(self.milestone) end
        end)
      end, 2, 6)
    end
  end
  if toasts then toasts:AddAlert(id) end
end

-- The fanfare of the game's achievements; the trophy sound where the client
-- has none.
local FANFARE = 12891
local function fanfare()
  local ok, willPlay = pcall(PlaySound, FANFARE, "Master")
  if not (ok and willPlay) then ns.playSound() end
end

-- quiet: record without a word (reached before the addon looked).
function ns.checkMilestones(quiet)
  local c = char()
  if not c then return end
  c.achievements = c.achievements or {}
  local earned = false
  for _, m in ipairs(list) do
    if not c.achievements[m.id] then
      local done, need = m.progress()
      if need > 0 and done >= need then
        c.achievements[m.id] = { at = time(), level = UnitLevel("player"), retro = quiet or nil }
        earned = true
        if not quiet then
          if ns.option("chat") then
            print(PREFIX .. ("you have earned the milestone |cffffd100|Hfieldjournal:m%s|h[%s]|h|r!"):format(m.id, m.title))
          end
          fanfare()
          if ns.option("milestoneToast") then toast(m.id) end
        end
      end
    end
  end
  if earned and ns.onMilestone then ns.onMilestone() end
end
