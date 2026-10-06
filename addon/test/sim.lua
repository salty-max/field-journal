-- Runs the addon against a fake WoW API and replays a dwarf's first hunts.
--   luajit addon/test/sim.lua              (from the repo root): Classic
--   FOREVER=1 luajit addon/test/sim.lua    the same on Forever's client: no
--                                          combat log (loot and dead targets count), secret values
local DIR = "addon/FieldJournal/"
local FOREVER = os.getenv("FOREVER") == "1"
function GetBuildInfo() return "1.15.8", "60000", "Oct 1 2026", FOREVER and 16001 or 11509 end
-- Values the game hides from addons on Forever.
local secrets = {}
if FOREVER then issecretvalue = function(v) return secrets[v] == true end end

-- ── a fake game ──────────────────────────────────────────────────────────────
local clock = 1790900000
function time() return clock end
date = os.date
local state = {
  level = 3, zone = "Dun Morogh", sub = "Anvilmar", target = nil,
  map = 1426, x = 0.3, y = 0.7,
  questsDone = { [7777] = true },
  standing = { [47] = 4 },
}
local printed = {}
function print(msg) table.insert(printed, msg) end
function strsplit(sep, s)
  local out = {}
  for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%-", "%%-")) do table.insert(out, part) end
  return unpack(out)
end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
tinsert = table.insert
function UnitLevel() return state.level end
local NAMES = { [1131] = "Winter Wolf", [1133] = "Starving Winter Wolf", [1132] = "Timber", [1123] = "Frostmane Headhunter", [10184] = "Onyxia", [99001] = "Skyborne Galestrider", [99002] = "Kharanos Villager", [99003] = "Snow Leopard Prowler", [99004] = "Snowy Hare" }
function UnitName(u)
  if u == "player" then return "Thorin" end
  local id = (u == "target" and state.target) or (u == "mouseover" and state.mouseover)
  return id and NAMES[id] or nil
end
local function creature(id) return ("Creature-0-4170-0-12-%d-0000ABCDEF"):format(id) end
local PLAYER, PET = "Player-6113-0ABCDEF0", "Pet-0-4170-0-12-1860-0100ABCDEF"
function UnitGUID(u)
  if u == "player" then return PLAYER end
  if u == "pet" then return PET end
  if u == "target" and state.target then return creature(state.target) end
  if u == "mouseover" and state.mouseover then return creature(state.mouseover) end
end
local combatLog
function CombatLogGetCurrentEventInfo() return unpack(combatLog) end
function GetRealZoneText() return state.zone end
function GetSubZoneText() return state.sub end
C_Map = {
  -- A French client would answer "Kharanos" too; Anvilmar stays unnamed here,
  -- to check the English fallback.
  GetAreaInfo = function(id) return ({ [131] = "Kharanos", [1] = "Dun Morogh" })[id] end,
  GetBestMapForUnit = function() return state.map end,
  GetPlayerMapPosition = function() return { x = state.x, y = state.y } end,
}
C_QuestLog = { IsQuestFlaggedCompleted = function(id) return state.questsDone[id] == true end }
if FOREVER then
  C_Reputation = { GetFactionDataByID = function(id) return { name = "Ironforge", reaction = state.standing[id] } end }
else
  function GetFactionInfoByID(id) return "Ironforge", "", state.standing[id] end
end
SOUNDKIT = { IG_QUEST_LOG_OPEN = 1 }
local sounds, lastSound = 0, nil
local played = {}
function PlaySound(id) sounds = sounds + 1; lastSound = id; played[id] = true; return true end
local ticker
local timers = {}
C_Timer = {
  NewTicker = function(_, fn) ticker = fn end,
  NewTimer = function(seconds, fn)
    local t = { seconds = seconds, fn = fn }
    t.Cancel = function(self) self.cancelled = true end
    table.insert(timers, t)
    return t
  end,
}
-- Run the newest live timer, as if its time had come.
local function elapse()
  for i = #timers, 1, -1 do
    local t = timers[i]
    if not t.cancelled then t.cancelled = true; t.fn(); return t.seconds end
  end
end
function UnitXP() return 0 end
function UnitRace() return "Dwarf", "Dwarf" end

-- UI: any method works and returns something sensible, scripts are kept.
local function ui()
  local o = { shown = false, scripts = {} }
  return setmetatable(o, {
    __index = function(t, k)
      if k == "SetScript" then return function(self, name, fn) self.scripts[name] = fn end end
      if k == "Show" then return function(self) self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end end
      if k == "Hide" then return function(self) self.shown = false end end
      if k == "SetShown" then return function(self, v) if v then self:Show() else self:Hide() end end end
      if k == "IsShown" then return function(self) return self.shown end end
      if k == "IsMouseOver" then return function(self) return self.mouseOver == true end end
      if k == "SetText" then return function(self, v) self.text = v end end
      if k == "GetText" then return function(self) return rawget(self, "text") or "" end end
      if k == "GetStringHeight" then return function() return 14 end end
      if k == "SetHeight" then return function(self, v) self.height = v end end
      if k == "SetID" then return function(self, v) self.idValue = v end end
      if k == "GetID" then return function(self) return rawget(self, "idValue") or 0 end end
      if k == "GetHeight" then return function(self) return rawget(self, "height") or 100 end end
      if k == "SetVerticalScroll" then return function(self, v) self.vscroll = v end end
      if k == "GetVerticalScrollRange" then return function() return 0 end end
      if k == "GetFrameLevel" then return function() return 1 end end
      if k == "GetVerticalScroll" then return function(self) return rawget(self, "vscroll") or 0 end end
      if k == "GetWidth" then return function() return 140 end end
      if k == "GetCenter" then return function() return 0, 0 end end
      if k == "GetEffectiveScale" then return function() return 1 end end
      if k == "CreateFontString" or k == "CreateTexture" then return function() return ui() end end
      return function() return t end
    end,
  })
end
UIParent, UISpecialFrames, SlashCmdList = ui(), {}, {}
Minimap, GameTooltip = ui(), ui()
-- The tooltip: keep hooks, lines and the unit it shows.
local tipHooks, tipLines, tipUnit = {}, {}, nil
GameTooltip.HookScript = function(self, name, fn) tipHooks[name] = fn end
GameTooltip.GetUnit = function() return "Someone", tipUnit end
GameTooltip.AddLine = function(self, text) table.insert(tipLines, text) end
function UnitIsPlayer(u) return u == "player" end
function GetCursorPosition() return 0, 0 end
local linkHandlers = {}
LinkUtil = { RegisterLinkHandler = function(kind, fn) linkHandlers[kind] = fn end }
LinkProcessorResponse = { Handled = 2 }
MinimalSliderWithSteppersMixin = { Label = { Right = 2 } }
-- The game's settings panel: keep what the addon registers.
local panel = { settings = {}, opened = nil }
Settings = {
  VarType = { Boolean = "boolean", Number = "number" },
  RegisterVerticalLayoutCategory = function(name) panel.name = name; return { GetID = function() return 42 end } end,
  RegisterProxySetting = function(_, variable, _, name, default, get, set)
    local s = { variable = variable, name = name, default = default, get = get, set = set }
    panel.settings[variable] = s
    return s
  end,
  CreateCheckbox = function() end,
  CreateDropdown = function(_, _, options) panel.options = options end,
  CreateSliderOptions = function(min, max, step) return { min = min, max = max, step = step, SetLabelFormatter = function(self, _, fn) self.format = fn end } end,
  CreateSlider = function(_, _, options) panel.slider = options end,
  CreateControlTextContainer = function()
    local data = {}
    return { Add = function(_, v, l) table.insert(data, { value = v, label = l }) end, GetData = function() return data end }
  end,
  RegisterAddOnCategory = function() panel.registered = true end,
  OpenToCategory = function(id) panel.opened = id end,
}
local events
local frames = {}
function CreateFrame(kind, name)
  local f = ui()
  f.registered = {}
  f.RegisterEvent = function(self, e)
    if FOREVER and e == "COMBAT_LOG_EVENT_UNFILTERED" then error("COMBAT_LOG_EVENT_UNFILTERED: forbidden") end
    self.registered[e] = true
  end
  table.insert(frames, f)
  if not events and kind == "Frame" and not name then events = f end
  if name then _G[name] = f end
  return f
end
local function fire(e, ...)
  assert(events.registered[e], "not registered: " .. e)
  events.scripts.OnEvent(events, e, ...)
end

-- Units: what the game says about the creatures.
local unitInfo = {
  [1131] = { level = 7, type = "Beast", family = "Wolf" },
  [1133] = { level = 8, type = "Beast", family = "Wolf" },
  [1132] = { level = 10, type = "Beast", family = "Wolf", class = "rare" },
  [1123] = { level = 9, type = "Humanoid" },
  [10184] = { level = 63, type = "Dragonkin", class = "worldboss" },
  [99001] = { level = 5, type = "Beast", family = "Galestrider" },   -- unknown to the data (Forever's)
  [99002] = { level = 5, type = "Humanoid", friendly = true },       -- unknown, not attackable
  [99003] = { level = 6, type = "Beast", family = "Cat" },           -- unknown, of a known beast family
  [99004] = { level = 1, type = "Critter" },                         -- unknown critter
  [1124] = { level = 9, type = "Humanoid", friendly = true },        -- known, but friendly now (a scripted foe)
}
local function unitId(u) return (u == "target" and state.target) or (u == "mouseover" and state.mouseover) end
local function info(u) return unitInfo[unitId(u) or 0] end
function UnitExists(u) return u == "player" or unitId(u) ~= nil end
function UnitCanAttack(_, u) local i = info(u); return i ~= nil and not i.friendly end
function UnitCreatureType(u) local i = info(u); return i and i.type end
function UnitCreatureFamily(u) local i = info(u); return i and i.family end
function UnitClassification(u) local i = info(u); return i and i.class or "normal" end
local deadTarget = false
function UnitIsDead(u) return u == "target" and deadTarget end
local inCombat = false
function UnitAffectingCombat(u) return inCombat and not (u == "target" and deadTarget) end
function UnitIsTapDenied() return false end
local realUnitLevel = UnitLevel
function UnitLevel(u)
  if u == "player" then return state.level end
  local i = info(u)
  return i and i.level or 0
end
-- Loot window: { link, { guid, count, ... } } per slot.
local loot = {}
function GetNumLootItems() return #loot end
function GetLootSlotLink(slot) return loot[slot][1] end
function GetLootSourceInfo(slot) return unpack(loot[slot][2]) end
C_Timer.After = function(_, fn) fn() end

-- The Atlas: maps, the fog lifted, health, taxis.
local MAPS = {
  [1426] = { name = "Dun Morogh", parentMapID = 1415 }, [1429] = { name = "Elwynn Forest", parentMapID = 1415 },
  [1411] = { name = "Durotar", parentMapID = 1414 }, [1415] = { name = "Eastern Kingdoms", parentMapID = 947 },
  [1414] = { name = "Kalimdor", parentMapID = 947 },
}
C_Map.GetMapInfo = function(id) return MAPS[id] end
state.explored = {}
-- What the character has discovered: area ids (the game answers by position;
-- here, wherever asked), and the overlays the map draws (for the book).
state.discovered = {}
C_MapExplorationInfo = {
  GetExploredMapTextures = function(id) return state.explored[id] end,
  GetExploredAreaIDsAtPosition = function() local ids = {} for id in pairs(state.discovered) do table.insert(ids, id) end return ids end,
}
function CreateVector2D(x, y) return { x = x, y = y } end
state.health = 100
function UnitHealth() return state.health end
function UnitHealthMax() return 100 end
function UnitIsDeadOrGhost() return state.health <= 0 end
function UnitOnTaxi() return false end
function hooksecurefunc(name, fn)
  local original = _G[name]
  _G[name] = function(...) local r = original(...); fn(...); return r end
end
local TAXI = { "Ironforge", "Thelsamar", "Menethil Harbor" }
function NumTaxiNodes() return #TAXI end
function TaxiNodeName(i) return TAXI[i] end
function TaxiNodeGetType(i) return i == 1 and "CURRENT" or "REACHABLE" end
function TakeTaxiNode() end
function GetBindLocation() return "Kharanos" end

-- The game's world map: it takes data providers, as for its own layers.
local mapProvider
MapCanvasDataProviderMixin = {}
function CreateFromMixins(...) local o = {} for _, m in ipairs({ ... }) do for k, v in pairs(m) do o[k] = v end end return o end
WorldMapFrame = {
  mapID = 1426,
  AddDataProvider = function(self, p) p.GetMap = function() return self end; mapProvider = p end,
  GetMapID = function(self) return self.mapID end,
}
local worldCanvas
WorldMapFrame.GetCanvas = function() return worldCanvas end

-- The game's alert system and its achievement toast (whose points shield
-- needs the achievement window, loaded on demand).
local toasted, loadedAddOns = {}, {}
AlertFrame = { AddQueuedAlertFrameSubSystem = function(_, template, setUp)
  return { AddAlert = function(_, ...)
    local f = ui()
    f.Icon, f.Unlocked, f.Name, f.Shield = ui(), ui(), ui(), ui()
    f.Icon.Texture = ui()
    setUp(f, ...)
    table.insert(toasted, f)
  end }
end }
C_XMLUtil = { GetTemplateInfo = function() return {} end }
-- The shield's OnLoad: Classic Era has no achievement window, and Forever's
-- doesn't define it (its own game type): the addon stands one in at load.
C_AddOns = { LoadAddOn = function(name) loadedAddOns[name] = true end }

-- ── load the addon ───────────────────────────────────────────────────────────
local ns = {}
assert(loadfile(DIR .. (FOREVER and "Data_Forever.lua" or "Data_Classic.lua")))("FieldJournal", ns)
for _, f in ipairs({ "Core.lua", "Atlas.lua", "Flora.lua", "Achievements.lua", "Book.lua", "AtlasBook.lua", "FloraBook.lua", "WorldMapPins.lua", "Minimap.lua", "Settings.lua", "Hints.lua" }) do
  assert(loadfile(DIR .. f))("FieldJournal", ns)
end
local D = ns.data
local function check(cond, msg) assert(cond, msg); io.write("✓ " .. msg .. "\n") end
local function said(text) for _, p in ipairs(printed) do if p:find(text, 1, true) then return p end end end
local function rec(id) return FieldJournalChar.creatures[id] end
local function target(id) state.target = id; fire("PLAYER_TARGET_CHANGED") end

-- ── a session ────────────────────────────────────────────────────────────────
FieldJournalChar = { guid = "Player-6113-0DEAD000", creatures = { [1131] = { name = "Winter Wolf" } }, families = {} }
fire("PLAYER_LOGIN")
check(FieldJournalChar.guid == PLAYER and not rec(1131), "a new character named like a deleted one starts a fresh journal")
check(FOREVER == (ns.meetKills == true) and FOREVER == (events.registered.COMBAT_LOG_EVENT_UNFILTERED == nil),
  FOREVER and "Forever: no combat log, loot and dead targets count" or "Classic: kills come from the combat log")
check(D.client == (FOREVER and "forever" or "classic"), "each game's data file is its own")

target(1131)
check(rec(1131) and rec(1131).name == "Winter Wolf" and rec(1131).low == 7 and rec(1131).first.zone == "Dun Morogh", "targeting a creature records it, with its level and where")
check(said("|cffffd100|Hfieldjournal:c1131|h[Winter Wolf]|h|r recorded (Wolves, a new family).") and sounds == 0,
  "a new creature is announced in chat with a link to its page (and its new family), without a sound")
state.mouseover = 1133
fire("UPDATE_MOUSEOVER_UNIT")
check(rec(1133) and said("[Starving Winter Wolf]|h|r recorded (Wolves).") and sounds == 0, "every new creature gets its line, the family only once")
printed = {}
fire("UPDATE_MOUSEOVER_UNIT")
check(#printed == 0, "… and only the first time it's met")
state.sub = "Coldridge Pass"
target(1131)
check(#rec(1131).places == 2 and rec(1131).places[2] == "Dun Morogh: Coldridge Pass", "a creature remembers the places it was met")

-- Slaying.
local function kill(id)
  if FOREVER then
    -- the fight: targeted alive while both are in combat, then the corpse
    state.target = id; inCombat = true
    fire("PLAYER_TARGET_CHANGED")
    inCombat = false; deadTarget = true
    fire("PLAYER_TARGET_CHANGED")
    deadTarget = false
    return
  end
  combatLog = { clock, "PARTY_KILL", false, PLAYER, "Thorin", 0, 0, creature(id), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
if FOREVER then
  -- someone else's kill lying about: never fought, targeted dead
  state.target = 1131; deadTarget = true
  fire("PLAYER_TARGET_CHANGED")
  deadTarget = false
  check(not rec(1131).slain, "Forever: a corpse this character didn't fight doesn't count")
end
kill(1131)
check(rec(1131).slain == 1 and rec(1131).firstSlain.level == 3, "slaying a creature counts it, with when and at what level")
if not FOREVER then
  combatLog = { clock, "PARTY_KILL", false, "Player-6113-0FFFFFFF", "Other", 0, 0, creature(1131), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
  check(rec(1131).slain == 1, "someone else's kill doesn't count")
  combatLog = { clock, "PARTY_KILL", false, PET, "Pet", 0, 0, creature(1131), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
  check(rec(1131).slain == 2, "your pet's does")
end
local before = rec(1131).slain

-- Loot: the loot window names the corpse.
local corpse = creature(1131) .. "-corpse"
loot = { { "|cffffffff|Hitem:2672::::::::3:::::|h[Stringy Wolf Meat]|h|r", { corpse, 1 } }, { "|cff9d9d9d|Hitem:3300::::::::3:::::|h[Rabbit's Foot]|h|r", { corpse, 2 } } }
-- the GUID parser takes the 6th field: keep the corpse a valid creature GUID
loot[1][2][1] = creature(1131); loot[2][2][1] = creature(1131)
fire("LOOT_OPENED")
fire("LOOT_OPENED")
check(rec(1131).loot[2672] == 1 and rec(1131).loot[3300] == 2, "looting records what each creature gave, once per corpse")
if FOREVER then
  check(rec(1131).slain == before, "Forever: the dead target and its loot count as one kill")
end

-- A rare: a trophy.
printed = {}
target(1132)
kill(1132)
check(rec(1132).trophy and rec(1132).trophy.rank == "r", "slaying a rare (Timber) makes a trophy")
check(said("a trophy: |cffffd100|Hfieldjournal:c1132|h[Timber]|h|r") and played[3175], "… announced in chat, with the trophy sound")
check(ns.earnedMilestone("trophies-1") and said("you have earned the milestone |cffffd100|Hfieldjournal:mtrophies-1|h[First Trophy]|h|r!") and played[12891],
  "… and the first trophy earns a milestone, with the game's achievement fanfare and a chat line")
local shield = {}
AchievementShield_OnLoad(shield)
check(toasted[1] and toasted[1].Name.text == "First Trophy" and shield.Saturate and shield.Desaturate,
  "… and the game's achievement toast, its shield's OnLoad stood in at load (the game's own toasts need it too)")

-- Creatures the data doesn't know (Forever's new ones).
target(99003)
check(rec(99003) and ns.familyTitle(ns.familyKey(99003)) == "Great Cats", "a creature the data doesn't know is filed by its beast family (a Cat: the great cats)")
check(said("[Snow Leopard Prowler]|h|r recorded (Great Cats, a new family)."), "… and announced under it")
target(99001)
check(ns.familyTitle(ns.familyKey(99001)) == "Other Beasts", "… a beast of a family the book has no page for, with the other beasts")
target(99004)
check(not rec(99004), "… and no critter")
target(99002)
check(not rec(99002), "… unless it can't be fought (friendly folk)")
target(1124)
check(not rec(1124), "a creature the data knows isn't recorded while it can't be fought either")

-- ── the atlas ────────────────────────────────────────────────────────────────
-- Only places a character can discover: not the capitals drawn on their zone's
-- map, not Forever's Dalaran behind its dome.
local function hasPlace(zone, name)
  for _, p in ipairs(D.atlas.zones[zone].places) do if p[1] == name then return true end end
end
check(not hasPlace(1411, "Orgrimmar") and (FOREVER and not hasPlace(1416, "Dalaran") or not FOREVER and hasPlace(1416, "Dalaran")),
  FOREVER and "Forever: no Orgrimmar in Durotar's places, no Dalaran in Alterac's" or "no Orgrimmar in Durotar's places; Dalaran is one of Alterac's")
local dun = D.atlas.zones[1426].places
local function texture(place) return { offsetX = place[2], offsetY = place[3], textureWidth = 300, textureHeight = 200, fileDataIDs = { 1, 2, 3, 4 }, isShownByMouseOver = false } end
local function key(place) return place[6] end
-- Moonglade's map draws its one overlay for everyone: no discovery for all that.
state.explored[1450] = { texture(D.atlas.zones[1450].places[1]) }
state.map, state.explored[1426], state.discovered[key(dun[1])] = 1426, { texture(dun[1]) }, true
printed = {}
fire("PLAYER_ENTERING_WORLD")
local atlas = FieldJournalChar.atlas
check(atlas.seeded and atlas.zones[1426].places[key(dun[1])].retro, "the places a character had already discovered fill its atlas quietly")
check(not atlas.zones[1450], "… and not a zone the map merely draws (Moonglade), never discovered")
check(atlas.zones[1426].first and atlas.zones[1426].visits == 1 and #printed == 0, "… and the zone it stands in is visited, without a word")
if FOREVER then
  -- Forever draws Moonglade's overlay for everyone: the game would report it
  -- explored; it counts once visited.
  state.discovered[493] = true
  ns.syncAtlasZone(1450, true)
  check(not atlas.zones[1450], "Forever: a place the map draws for everyone is never taken from the game's word")
  state.discovered[493] = nil
  MAPS[1450] = { name = "Moonglade", parentMapID = 1414 }
  state.map, state.zone, state.sub = 1450, "Moonglade", "Nighthaven"
  fire("ZONE_CHANGED_NEW_AREA")
  check(atlas.zones[1450] and atlas.zones[1450].places[key(D.atlas.zones[1450].places[1])], "… but once visited")
  state.map, state.zone, state.sub = 1426, "Dun Morogh", "Coldridge Pass"
  fire("ZONE_CHANGED_NEW_AREA")
end
table.insert(state.explored[1426], texture(dun[2]))
state.discovered[key(dun[2])] = true
fire("MAP_EXPLORATION_UPDATED")
local place = atlas.zones[1426].places[key(dun[2])]
check(place and place.at and not place.retro and place.level == state.level, "a place newly explored is recorded, with the day and level")
local done, total = ns.zoneProgress(1426)
check(done == 2 and total == #dun and total > 10, "a zone counts its places explored, of all it has")
state.map = 1429
fire("ZONE_CHANGED_NEW_AREA")
check(atlas.zones[1429] and said("|Hfieldjournal:z1429|h[Elwynn Forest]|h|r added to the atlas."), "a new zone is announced in chat, with a link")
state.map = 1411
fire("ZONE_CHANGED_NEW_AREA")
local crossing = atlas.crossings[#atlas.crossings]
check(crossing and crossing.from == 1429 and crossing.to == 1411, "crossing to another continent is recorded")
TakeTaxiNode(2)
check(atlas.flights[1].from == "Ironforge" and atlas.flights[1].to == "Thelsamar" and atlas.routes["Ironforge > Thelsamar"] == 1, "a flight is recorded, with its route")
fire("HEARTHSTONE_BOUND")
check(atlas.binds[1].place == "Kharanos", "a new hearthstone bind is recorded")
state.target = 1133
fire("PLAYER_TARGET_CHANGED")
state.health = 5
fire("UNIT_HEALTH", "player")
check(atlas.closeCalls[1] and atlas.closeCalls[1].zone == 1411 and atlas.closeCalls[1].x == 30, "a close call: under a tenth of your health and alive after")
if not FOREVER then
  combatLog = { clock, "SWING_DAMAGE", false, creature(1131), "Winter Wolf", 0, 0, PLAYER, "Thorin", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
state.health = 0
fire("PLAYER_DEAD")
check(atlas.deaths[1] and atlas.deaths[1].by == (FOREVER and "Starving Winter Wolf" or "Winter Wolf"),
  FOREVER and "Forever: a death names the last foe targeted" or "a death names what last hurt you (the combat log)")
state.health, state.map, state.target = 100, 1426, nil
-- An atlas recorded by 0.3.0, which trusted the overlays the map draws.
local saved = FieldJournalChar.atlas
FieldJournalChar.atlas = {
  zones = {
    [1450] = { retro = true, places = { [key(D.atlas.zones[1450].places[1])] = { retro = true } } },
    [1426] = { first = { at = clock, level = 3 }, places = { [key(dun[1])] = { retro = true }, [key(dun[2])] = { at = clock, level = 3 } } },
  },
  seeded = true, deaths = {}, closeCalls = {}, flights = {}, routes = {}, crossings = {}, binds = {},
}
FieldJournalChar.achievements["explore-1450"] = { at = clock, level = 3, retro = true }
fire("PLAYER_ENTERING_WORLD")
local migrated = FieldJournalChar.atlas
check(not migrated.zones[1450] and not FieldJournalChar.achievements["explore-1450"],
  "an atlas from 0.3.0 loses the zones it never discovered, and their milestones")
check(migrated.zones[1426].places[key(dun[1])].retro and migrated.zones[1426].places[key(dun[2])].at,
  "… and keeps what is truly discovered")
FieldJournalChar.atlas = saved
check(ns.earnedMilestone("crossing") and said("[Across the Sea]"), "crossing the sea earns a milestone")
check(ns.milestoneVisible(ns.milestoneById["explore-1426"]) and not ns.milestoneVisible(ns.milestoneById["explore-1446"]),
  "a zone's exploration milestone shows once the zone is entered (Dun Morogh), not before (Tanaris)")
local exploredNow, placesAll = ns.milestoneById["explore-1426"].progress()
check(exploredNow == 2 and placesAll == #dun, "… counting its places explored")
worldCanvas = worldCanvas or CreateFrame("Frame")
WorldMapFrame.mapID = 1411
ns.refreshWorldMapPins()
local marks = {}
for _, p in ipairs(mapProvider and mapProvider.pins or {}) do if p.shown then marks[p.title] = p end end
check(marks["Died here"] and marks["A close call"], "deaths and close calls are marked on the game's world map, on their zone")
WorldMapFrame.mapID = 1426
ns.refreshWorldMapPins()
local shownPins = 0
for _, p in ipairs(mapProvider.pins) do if p.shown then shownPins = shownPins + 1 end end
check(shownPins == 0, "… and only there")

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.FIELDJOURNAL("")
check(FieldJournalFrame.shown, "/journal opens the book")
local creatures, families, slain = ns.counts()
check(FieldJournalFrame.count.text == ("%d creatures, %d families, %d slain"):format(creatures, families, slain), "it counts what was recorded")
local function shown(text)
  for _, r in ipairs(ns.listRows) do if r.shown and r.text.text == text then return r end end
end
check(shown("Wolves") and shown("Beasts") and shown("Trophies") and shown("Other Beasts"), "the list shows the families met, under their type, and the trophies")
check(not shown("Unrecorded"), "… and nothing left unrecorded")
check(not shown("Spiders"), "… and no family not yet met")
ns.openFamily(D.creatures[1131])
local wolves = {}
for _, e in ipairs(ns.pageEntries) do if e.shown then wolves[e.id] = e end end
check(wolves[1131] and wolves[1133] and wolves[1132], "a family's page has an entry per creature met")
check(wolves[1131].name.text == "Winter Wolf" and wolves[1131].facts.text:find("levels 7-8", 1, true) and wolves[1131].facts.text:find("slain", 1, true), "… with its name and a line of its record (its levels in the world, not just the one seen)")
check(D.models[1131] and wolves[1131].portrait.display == D.models[1131], "… and its portrait, from its display id")
check(shown("Winter Wolf") and shown("Starving Winter Wolf"), "an open family lists its creatures under it")
shown("Winter Wolf").scripts.OnClick(shown("Winter Wolf"))
local record = {}
for _, p in ipairs(ns.pagePairs) do if p.shown then record[p.label.text] = p.value.text end end
check(FieldJournalPage.title.text == "Winter Wolf" and FieldJournalPage.portrait.display == D.models[1131] and FieldJournalPage.sub.text:find("Wolves", 1, true),
  "a creature has its own page: portrait, name, family")
check(record["First met"] and record["Where"]:find("Coldridge Pass", 1, true) and record["Slain"] == tostring(rec(1131).slain),
  "… and its record: when and where it was met, its kills")
check(ns.pageLoot[1] and ns.pageLoot[1].shown and ns.pageLoot[2].shown and not ns.pageLoot[3], "… and what it gave, an icon per item")
check(not ns.pageEntries[1].shown, "… without the family's entries")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(FieldJournalPage.title.text == "Wolves" and shown("Winter Wolf"), "the family's row opens its page again")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(not shown("Winter Wolf"), "… and, once open, folds it")
wolves[1132].scripts.OnClick(wolves[1132])
check(FieldJournalPage.title.text:find("^Timber"), "an entry on a family's page opens the creature's")
FieldJournalSearch:SetText("timber")
ns.refresh()
check(shown("Wolves") and not shown("Ice Trolls") and not shown("Winter Wolf"), "search finds a family by a creature's name, with just the creatures found")
FieldJournalSearch:SetText("")
ns.refresh()
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(not shown("Wolves") and FieldJournalChar.collapsed.beasts, "a click on a type folds it")
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(shown("Wolves"), "… and unfolds it")
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:c1132")
check(FieldJournalFrame.shown and FieldJournalPage.title.text:find("^Timber"), "a link in chat opens the book at the creature's page")

-- The atlas in the book.
C_Map.GetMapArtLayers = function() return { { layerWidth = 1002, layerHeight = 668, tileWidth = 256, tileHeight = 256 } } end
C_Map.GetMapArtLayerTextures = function() local t = {} for i = 1, 12 do t[i] = 1000 + i end return t end
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:z1426")
local atlasRecord = {}
for _, p in ipairs(ns.atlasPairs) do if p.shown then atlasRecord[p.label.text] = p.value.text end end
check(FieldJournalFrame.selectedTab == ns.TAB.atlas and FieldJournalAtlasPage.title.text == "Dun Morogh" and FieldJournalAtlasPage.map.shown,
  "a zone's link opens the Atlas at its page, with its map")
check(FieldJournalAtlasPage.note.shown and FieldJournalAtlasPage.note.text:find("^Snow, stone and dwarves"), "… the surveyor's note")
check(atlasRecord.Explored:find(dun[1][1], 1, true) and atlasRecord.Explored:find(dun[2][1], 1, true), "… the places explored, by name")
check(FieldJournalAtlasPage.sub.text:find(("2 of %d places explored"):format(#dun), 1, true), "… and how many remain")
local zoneRows = {}
for _, r in ipairs(ns.atlasRows) do if r.shown then zoneRows[r.text.text] = r end end
check(zoneRows["Eastern Kingdoms"] and zoneRows["Dun Morogh"] and zoneRows.Durotar and not zoneRows.Tanaris, "the list: continents, the zones entered, none other")
check(zoneRows["Dun Morogh"].bar.shown and zoneRows["Dun Morogh"].count.text == ("2/%d"):format(#dun), "a zone's row carries a bar and a count of its places")
check(zoneRows[dun[1][1]] and zoneRows[dun[2][1]] and zoneRows[dun[1][1]].kind == "place" and not zoneRows[dun[3][1]],
  "… and, open, the places discovered under it, none other")
zoneRows[dun[2][1]].scripts.OnClick(zoneRows[dun[2][1]])
local discoveredLine
for _, p in ipairs(ns.atlasPairs) do if p.shown and p.label.text == "Discovered" then discoveredLine = p.value.text end end
check(FieldJournalAtlasPage.map.pick.shown and discoveredLine and discoveredLine:find("level 3", 1, true), "a click on a place picks it out on the zone's map, with the day and level it was found")
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
local placeShown = false
for _, r in ipairs(ns.atlasRows) do if r.shown and r.kind == "place" and r.zone == 1426 then placeShown = true end end
check(not placeShown and FieldJournalChar.atlasOpen[1426] == false, "the open zone's row folds it")
FieldJournalSearch:SetText(dun[2][1]:sub(1, 5))
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do if r.shown then zoneRows[r.text.text] = r end end
check(zoneRows["Dun Morogh"] and zoneRows[dun[2][1]] and not zoneRows.Durotar and not zoneRows.Travels, "search finds places by name, with their zone")
FieldJournalSearch:SetText("")
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do if r.shown then zoneRows[r.text.text] = r end end
zoneRows.Travels.scripts.OnClick(zoneRows.Travels)
check(FieldJournalAtlasPage.title.text == "Travels", "the travels page sums them up")
FieldJournalFrameTab1.scripts.OnClick(FieldJournalFrameTab1)

-- Milestones.
check(ns.milestoneById["zone-1426"] and ns.milestoneVisible(ns.milestoneById["zone-1426"]), "Timber met: the rares of Dun Morogh have their milestone in the list")
check(not ns.milestoneVisible(ns.milestoneById["zone-1429"]), "… the rares of Elwynn, none met yet, don't (no spoilers)")
check(ns.milestoneVisible(ns.milestoneById["type-beasts"]) and not ns.milestoneVisible(ns.milestoneById["type-demons"]), "… nor the families of a type not met yet")
local done, need = ns.milestoneById["zone-1426"].progress()
check(done == 1 and need >= 5, "a zone's milestone counts its rares slain")
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:mtrophies-1")
local row
for _, r in ipairs(ns.milestoneRows) do if r.shown and r.id == "trophies-1" then row = r end end
check(FieldJournalFrame.shown and FieldJournalFrame.selectedTab == ns.TAB.milestones and row and row.status.text:find("^Level"), "a milestone's link opens the Milestones tab, the milestone earned with its level")
check(FieldJournalFrame.count.text == ("%d of %d milestones"):format(ns.milestoneCount()), "… which counts them")
FieldJournalFrameTab1.scripts.OnClick(FieldJournalFrameTab1)
check(FieldJournalFrame.selectedTab == 1 and FieldJournalPage and shown("Wolves"), "the Bestiary tab brings the book back")
-- A journal from before milestones: what it deserves is recorded quietly.
FieldJournalChar.achievements = nil
printed = {}
ns.checkMilestones(true)
check(ns.earnedMilestone("trophies-1").retro and #printed == 0, "milestones already deserved are recorded quietly")

-- Tooltip hints.
local function hover(id)
  tipLines, tipUnit, state.mouseover = {}, "mouseover", id
  tipHooks.OnTooltipSetUnit(GameTooltip)
  return table.concat(tipLines, "|")
end
check(hover(1123) == "Field Journal: not yet recorded", "a creature not yet met says so on its tooltip")
check(hover(1124) == "", "… but not one that can't be fought (a foe still friendly)")
check(hover(1132):find("1 slain (trophy)", 1, true), "… one met tells how many were slain")
if FOREVER then
  secrets[creature(1123)] = true
  check(hover(1123) == "", "Forever: a secret creature id gets no hint, and no error")
  secrets[creature(1123)] = nil
end

tipLines = {}
FieldJournalMinimapButton.scripts.OnEnter(FieldJournalMinimapButton)
check(table.concat(tipLines, "|"):find("creatures in", 1, true), "the minimap button's tooltip shows the counts")

-- ── Fish and Plants ──────────────────────────────────────────────────────────
local function link(id, name) return ("|cffffffff|Hitem:%d::::::::|h[%s]|h|r"):format(id, name) end
function GetLootSlotInfo(slot) return nil, nil, loot[slot][3] or 1 end
local fishing = false
function IsFishingLoot() return fishing end
state.hour = 12
function GetGameTime() return state.hour, 0 end
state.bags = {}
C_Container = {
  GetContainerNumSlots = function(bag) return bag == 0 and 16 or 0 end,
  GetContainerItemID = function(bag, slot) return bag == 0 and state.bags[slot] or nil end,
}
local BOBBER, SCHOOL, NODE = "GameObject-0-1-0-0-35591-0000000001", "GameObject-0-1-0-0-180682-0000000002", "GameObject-0-1-0-0-1618-0000000003"
local function lootWindow(slots)
  loot = slots
  fire("LOOT_OPENED")
  fire("LOOT_OPENED") -- the game can report a window twice
  fire("LOOT_CLOSED")
end
local fish = function(id) return FieldJournalChar.fish and FieldJournalChar.fish[id] end
local plant = function(id) return FieldJournalChar.plants and FieldJournalChar.plants[id] end
state.map, state.sub = 1429, "Crystal Lake"
fishing = true
lootWindow({ { link(6291, "Raw Brilliant Smallfish"), { BOBBER, 1 } } })
local smallfish = fish(6291)
check(smallfish and smallfish.n == 1 and smallfish.day == 1 and smallfish.school == 0 and smallfish.first.zone == 1429
  and smallfish.first.sub == "Crystal Lake" and smallfish.zones[1429] == 1, "a catch in open water: where, when, by day, once per window")
check(said("a new catch: |cffffd100|Hfieldjournal:f6291|h[Raw Brilliant Smallfish]|h|r"), "… announced in chat, with a link")
state.hour = 19 -- night from 6 PM, the Nightfin's hours
lootWindow({ { link(6358, "Oily Blackmouth"), { SCHOOL, 1 } } })
check(fish(6358) and fish(6358).school == 1 and fish(6358).night == 1, "a catch from a school, by night")
lootWindow({ { link(6364, "32 Pound Catfish"), { BOBBER, 1 } } })
lootWindow({ { link(6309, "17 Pound Catfish"), { BOBBER, 1 } } })
check(fish(6309) and fish(6309).n == 2 and fish(6309).heaviest == 32 and not fish(6364), "weighed catches count for their kind, the heaviest kept")
lootWindow({ { link(6297, "Old Skull"), { BOBBER, 1 } } })
check(not fish(6297), "junk from the water isn't a fish")
fishing = false
lootWindow({ { link(6303, "Raw Slitherskin Mackerel"), { creature(1131), 1 } } })
check(not fish(6303), "a fish looted from a corpse isn't a catch")
lootWindow({ { link(2447, "Peacebloom"), { NODE, 2 }, 2 } })
local bloom = plant(2447)
check(bloom and bloom.gathered == 2 and bloom.n == 2 and bloom.first.how == "gathered" and bloom.zones[1429] == 2,
  "an herb from its node: gathered, the stack counted")
check(said("a new herb: |cffffd100|Hfieldjournal:h2447|h[Peacebloom]|h|r"), "… announced in chat")
lootWindow({ { link(2447, "Peacebloom"), { creature(1131), 1 } } })
check(bloom.looted == 1 and bloom.n == 3, "the same herb from a corpse: looted")
state.bags = { [1] = 2447, [2] = 3820 }
fire("BAG_UPDATE_DELAYED")
check(plant(3820) and plant(3820).first.how == "other" and plant(3820).n == 0 and bloom.n == 3 and said("[Stranglekelp]|h|r"),
  "an herb found in the bags (bought, a reward...): noted once, its count unknown, announced")
state.bags = { [1] = 785 }
fire("PLAYER_ENTERING_WORLD")
check(plant(785) and not said("[Mageroyal]|h|r"), "… but the herbs already carried at login are noted quietly")

-- The Fish and Plants tabs.
local frows, fpage = ns.floraRows, nil
local function rowNamed(text) for _, r in ipairs(frows) do if r.shown and r.text.text == text then return r end end end
local function pairNamed(label) for _, p in ipairs(ns.floraPairs) do if p.shown and p.label.text == label then return p.value.text end end end
FieldJournalFrame:Show()
FieldJournalFrameTab2.scripts.OnClick(FieldJournalFrameTab2)
fpage = FieldJournalFloraPage
check(FieldJournalFrame.selectedTab == ns.TAB.fish and fpage.shown and fpage.title.text == "The catch so far"
  and FieldJournalFrame.count.text == "3 kinds of fish, 4 caught", "the Fish tab: the catch so far")
check(rowNamed("Fish of the waters") and rowNamed("Reagents") and rowNamed("Weighed catches") and rowNamed("Raw Brilliant Smallfish")
  and rowNamed("Raw Brilliant Smallfish").count.text == "1" and not rowNamed("Raw Slitherskin Mackerel") and not rowNamed("Quest fish"),
  "… lists what was caught, in groups, with counts: nothing else (no spoilers)")
rowNamed("Catfish").scripts.OnClick(rowNamed("Catfish"))
check(fpage.title.text == "Catfish" and pairNamed("Heaviest") == "32 pounds" and pairNamed("Caught") == "2"
  and pairNamed("Zones"):find("Westfall", 1, true) and pairNamed("Where") == "Elwynn Forest (2)", "a kind's page: where it bites (the data), the catches, the heaviest")
rowNamed("Oily Blackmouth").scripts.OnClick(rowNamed("Oily Blackmouth"))
check(pairNamed("From schools") == "1" and pairNamed("By day, by night") == "0, 1" and fpage.sub.text == "A reagent", "… from a school, by night")
FieldJournalFrameTab3.scripts.OnClick(FieldJournalFrameTab3)
check(FieldJournalFrame.selectedTab == ns.TAB.plants and fpage.title.text == "The herbs so far" and rowNamed("Apprentice")
  and rowNamed("Peacebloom").count.text == "3" and rowNamed("Stranglekelp") and rowNamed("Journeyman"), "the Plants tab: by Herbalism rank")
rowNamed("Peacebloom").scripts.OnClick(rowNamed("Peacebloom"))
check(fpage.sub.text == "Herbalism 1" and pairNamed("Gathered") == "2" and pairNamed("Looted") == "1"
  and pairNamed("First"):find("(gathered)", 1, true), "an herb's page: its rank, how it was taken")
check(fpage.note.shown and fpage.note.text:find("The first flower most herbalists ever pick", 1, true), "… and the naturalist's note")
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:f6291")
check(FieldJournalFrame.shown and FieldJournalFrame.selectedTab == ns.TAB.fish and fpage.title.text == "Raw Brilliant Smallfish",
  "a catch's link opens its page")
linkHandlers.fieldjournal("fieldjournal:h3820")
check(FieldJournalFrame.selectedTab == ns.TAB.plants and fpage.title.text == "Stranglekelp", "an herb's link opens its page")
FieldJournalFrameTab2.scripts.OnClick(FieldJournalFrameTab2)
fishing = true
lootWindow({ { link(13755, "Winter Squid"), { BOBBER, 1 } } })
fishing = false
check(rowNamed("Winter Squid"), "a new catch shows in the open tab at once")
rowNamed("Winter Squid").scripts.OnClick(rowNamed("Winter Squid"))
check(fpage.sub.text == "A fish of the waters  -  only in winter", "… a seasonal one says its season")
FieldJournalFrameTab1.scripts.OnClick(FieldJournalFrameTab1)
check(not fpage.shown and FieldJournalPage.shown, "the Bestiary tab hides them again")
FieldJournalFrame:Hide()

-- Their milestones, and the Atlas's zone pages.
check(ns.earnedMilestone("fish-first") and said("[First Catch]") and ns.earnedMilestone("herb-first") and said("[First Herb]"),
  "the first catch and the first herb are milestones, announced")
local function progress(id) return ns.milestoneById[id].progress() end
local done, need = progress("seasons")
check(not ns.earnedMilestone("seasons") and done == 1 and need == 2, "Every Season: the Winter Squid, the Summer Bass still to catch")
local elwynn = ns.milestoneById["herbs-1429"]
local d2, n2 = elwynn.progress()
check(elwynn and ns.milestoneVisible(elwynn) and d2 >= 1 and n2 > d2 and not ns.milestoneVisible(ns.milestoneById["herbs-1411"]),
  "every herb of a zone: shown once one is found there (Elwynn), hidden elsewhere (Durotar)")
local anyContinent = false
for _, m in ipairs(ns.milestones) do
  if m.id:find("^fish%-continent%-") and ns.milestoneVisible(m) then anyContinent = true end
end
check(anyContinent, "every fish of a continent's waters: shown once one is caught there")
linkHandlers.fieldjournal("fieldjournal:z1429")
local function atlasPair(label) for _, p in ipairs(ns.atlasPairs) do if p.shown and p.label.text == label then return p.value.text end end end
check(atlasPair("Herbs") and atlasPair("Herbs"):find("Peacebloom", 1, true) and atlasPair("Herbs"):find("more to find", 1, true)
  and atlasPair("Fish") and atlasPair("Fish"):find("Raw Brilliant Smallfish", 1, true) and not atlasPair("Fish"):find("Raw Longjaw", 1, true),
  "a zone's Atlas page: the herbs and fish found there named, the rest counted")
FieldJournalFrame:Hide()

SlashCmdList.FIELDJOURNAL("reset yes")
check(next(FieldJournalChar.creatures) == nil and FieldJournalChar.guid == PLAYER, "/journal reset yes starts the journal over")
io.write(FOREVER and "all good (Forever)\n" or "all good\n")
