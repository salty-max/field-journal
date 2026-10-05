-- Milestones: the journal's achievements. Tallies (kinds met, families met,
-- creatures slain, trophies), one per creature type (every family of it met),
-- feats, and one per zone (every rare of it slain). Each character earns its
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
