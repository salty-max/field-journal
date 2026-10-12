-- Runs the addon against a fake WoW API and replays a dwarf's first hunts.
--   luajit addon/test/sim.lua              (from the repo root): Classic
--   FOREVER=1 luajit addon/test/sim.lua    the same on Forever's client: no
--                                          combat log (kills from PARTY_KILL), secret values
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
  level = 3,
  zone = "Dun Morogh",
  sub = "Anvilmar",
  target = nil,
  map = 1426,
  x = 0.3,
  y = 0.7,
  questsDone = { [7777] = true },
  standing = { [47] = 4 },
}
local printed = {}
function print(msg) table.insert(printed, msg) end
-- The game's error handler: an error raised again here, so a check fails on it.
local errorHandler = function(e) error(e, 0) end
function geterrorhandler() return errorHandler end
function strsplit(sep, s)
  local out = {}
  for part in (s .. sep):gmatch("(.-)" .. sep:gsub("%-", "%%-")) do
    table.insert(out, part)
  end
  return unpack(out)
end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
function GetRealmName() return "Nightslayer" end
function InCombatLockdown() return false end
tinsert = table.insert
function UnitLevel() return state.level end
function GetLocale() return "enUS" end
local NAMES = {
  [1131] = "Winter Wolf",
  [1133] = "Starving Winter Wolf",
  [1132] = "Timber",
  [1123] = "Frostmane Headhunter",
  [10184] = "Onyxia",
  [99001] = "Skyborne Galestrider",
  [99002] = "Kharanos Villager",
  [99003] = "Snow Leopard Prowler",
  [99005] = "Frost Lynx",
  [99004] = "Snowy Hare",
  [99006] = "Minor Ice Elemental",
  [99007] = "Unsettled Shape",
  [259398] = "Galemender Delanea",
  [771] = "Commander Felstrom",
}
function UnitName(u)
  if u == "player" then return "Thorin" end
  local id = (u == "target" and state.target) or (u == "mouseover" and state.mouseover)
  return id and NAMES[id] or nil
end
local function creature(id, n) return ("Creature-0-4170-0-12-%d-%010X"):format(id, n or 0xABCDEF) end
local PLAYER, PET = "Player-6113-0ABCDEF0", "Pet-0-4170-0-12-1860-0100ABCDEF"
-- the unit a GUID is now, if any (the target or the mouseover, by creature)
function UnitTokenFromGUID(guid)
  local id = tonumber(guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)"))
  if id and id == state.target then return "target" end
  if id and id == state.mouseover then return "mouseover" end
end
function UnitGUID(u)
  if u == "player" then return PLAYER end
  if state.party and state.party[u] then return state.party[u] end
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
  GetAreaInfo = function(id)
    return ({
      [131] = "Kharanos",
      [1] = "Dun Morogh",
      [856] = "Twilight Grove",
      [1098] = "Manor Mistmantle",
      [204] = "Pyrewood Village",
    })[id]
  end,
  GetBestMapForUnit = function() return state.map end,
  GetPlayerMapPosition = function() return { x = state.x, y = state.y } end,
  GetMapInfo = function() return nil end, -- (the maps, below)
  GetMapArtLayers = function() return nil end, -- (the map's art: the Atlas's book, below)
  GetMapArtLayerTextures = function() return {} end,
}
-- What every client has, before the scenes that use it set it.
function IsFishingLoot() return false end
function GetGameTime() return 12, 0 end
-- The quest log: state.quests = { { id, objectives = { { type, text } } } }.
QUEST_MONSTERS_KILLED = FOREVER and "%2$d/%3$d %1$s slain" or "%s slain: %d/%d"
C_QuestLog = {
  IsQuestFlaggedCompleted = function(id) return state.questsDone[id] == true end,
  GetNumQuestLogEntries = function() return #(state.quests or {}) end,
  GetInfo = function(i) return { questID = state.quests[i].id, isHeader = false } end,
  GetQuestObjectives = function(id)
    for _, q in ipairs(state.quests or {}) do
      if q.id == id then return q.objectives end
    end
  end,
}
-- A group: state.party = { party1 = guid... }.
function GetNumGroupMembers()
  local n = 0
  for _ in pairs(state.party or {}) do
    n = n + 1
  end
  return n > 0 and n + 1 or 0
end
function IsInRaid() return false end
function IsInGroup() return GetNumGroupMembers() > 0 end
-- A corpse's loot: state.empty[guid], a corpse that holds nothing for me.
state.empty = {}
function CanLootUnit(guid) return not state.empty[guid], not state.empty[guid] end
if FOREVER then
  C_Reputation = { GetFactionDataByID = function(id) return { name = "Ironforge", reaction = state.standing[id] } end }
else
  function GetFactionInfoByID(id) return "Ironforge", "", state.standing[id] end
end
SOUNDKIT = { IG_QUEST_LOG_OPEN = 1 }
local sounds, lastSound = 0, nil
local played = {}
function PlaySound(id)
  sounds = sounds + 1
  lastSound = id
  played[id] = true
  return true
end
local ticker
local timers = {}
C_Timer = {
  After = function(_, fn) fn() end,
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
    if not t.cancelled then
      t.cancelled = true
      t.fn()
      return t.seconds
    end
  end
end
function UnitXP() return 0 end
function UnitRace() return "Dwarf", "Dwarf" end

-- UI: any method works and returns something sensible, scripts are kept.
local function ui()
  local o = { shown = false, scripts = {} }
  return setmetatable(o, {
    __index = function(t, k)
      if k == "SetScript" then
        return function(self, name, fn) self.scripts[name] = fn end
      end
      if k == "Show" then
        return function(self)
          -- (OnShow on a showing only, as in the game: not on a shown frame)
          local was = self.shown
          self.shown = true
          if not was and self.scripts.OnShow then self.scripts.OnShow(self) end
        end
      end
      if k == "Hide" then
        return function(self)
          local was = self.shown
          self.shown = false
          if was and self.scripts.OnHide then self.scripts.OnHide(self) end
        end
      end
      if k == "SetChecked" then
        return function(self, v) self.checked = v and true or false end
      end
      if k == "GetChecked" then
        return function(self) return rawget(self, "checked") or false end
      end
      if k == "SetShown" then
        return function(self, v)
          if v then
            self:Show()
          else
            self:Hide()
          end
        end
      end
      if k == "IsShown" then
        return function(self) return self.shown end
      end
      if k == "IsMouseOver" then
        return function(self) return self.mouseOver == true end
      end
      if k == "SetText" then
        return function(self, v) self.text = v end
      end
      if k == "SetTexture" then
        -- (a texture drawn: what it shows, no creature's portrait any more)
        return function(self, v)
          self.texture, self.display = v, nil
        end
      end
      if k == "GetText" then
        return function(self) return rawget(self, "text") or "" end
      end
      if k == "GetStringHeight" then
        return function() return 14 end
      end
      if k == "SetHeight" then
        return function(self, v) self.height = v end
      end
      if k == "SetID" then
        return function(self, v) self.idValue = v end
      end
      if k == "GetID" then
        return function(self) return rawget(self, "idValue") or 0 end
      end
      if k == "GetHeight" then
        return function(self) return rawget(self, "height") or 100 end
      end
      if k == "SetVerticalScroll" then
        return function(self, v) self.vscroll = v end
      end
      if k == "GetVerticalScrollRange" then
        return function() return 0 end
      end
      if k == "GetFrameLevel" then
        return function() return 1 end
      end
      if k == "GetVerticalScroll" then
        return function(self) return rawget(self, "vscroll") or 0 end
      end
      if k == "GetWidth" then
        return function() return 140 end
      end
      if k == "GetCenter" then
        return function() return 0, 0 end
      end
      if k == "GetEffectiveScale" then
        return function() return 1 end
      end
      if k == "CreateFontString" or k == "CreateTexture" then
        return function() return ui() end
      end
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
  VarType = { Boolean = "boolean", Number = "number", String = "string" },
  RegisterVerticalLayoutCategory = function(name)
    panel.name = name
    return { GetID = function() return 42 end }
  end,
  RegisterProxySetting = function(_, variable, _, name, default, get, set)
    local s = { variable = variable, name = name, default = default, get = get, set = set }
    panel.settings[variable] = s
    return s
  end,
  CreateCheckbox = function() end,
  CreateDropdown = function(_, setting, options)
    setting.options = options
    panel.options = panel.options or options -- (the first: the sound's)
  end,
  CreateSliderOptions = function(min, max, step)
    return { min = min, max = max, step = step, SetLabelFormatter = function(self, _, fn) self.format = fn end }
  end,
  CreateSlider = function(_, _, options) panel.slider = options end,
  CreateControlTextContainer = function()
    local data = {}
    return {
      Add = function(_, v, l) table.insert(data, { value = v, label = l }) end,
      GetData = function() return data end,
    }
  end,
  RegisterAddOnCategory = function() panel.registered = true end,
  OpenToCategory = function(id) panel.opened = id end,
}
local frames = {}
-- A creature's portrait drawn on a texture: which display it shows.
function SetPortraitTextureFromCreatureDisplayID(tex, display) tex.display = display end
function CreateFrame(kind, name)
  local f = ui()
  f.shown = true -- (a new frame is shown, as in the game)
  if kind == "PlayerModel" then
    -- (the model's fog: a shape only while it is near)
    f.SetFogFar = function(self, v) self.fogFar = v end
    f.ClearFog = function(self) self.fogFar = nil end
    f.SetDisplayInfo = function(self, v) self.display = v end
  end
  f.registered, f.unitsOf = {}, {}
  f.RegisterEvent = function(self, e)
    if FOREVER and e == "COMBAT_LOG_EVENT_UNFILTERED" then error("COMBAT_LOG_EVENT_UNFILTERED: forbidden") end
    -- (PARTY_KILL, an event of its own on Forever; the Classic run plays a
    -- client without it, its kills from the combat log)
    if not FOREVER and e == "PARTY_KILL" then error('Attempt to register unknown event "PARTY_KILL"') end
    self.registered[e] = true
  end
  f.UnregisterEvent = function(self, e) self.registered[e] = nil end
  -- a unit's event, heard for that unit only
  f.RegisterUnitEvent = function(self, e, ...)
    self:RegisterEvent(e)
    self.unitsOf[e] = {}
    for _, unit in ipairs({ ... }) do
      self.unitsOf[e][unit] = true
    end
  end
  table.insert(frames, f)
  if name then _G[name] = f end
  return f
end
-- Is the event registered by any frame of the addon?
local function registered(e)
  for _, f in ipairs(frames) do
    if f.registered[e] then return true end
  end
  return false
end
local function fire(e, ...)
  assert(registered(e), "not registered: " .. e)
  local unit = ...
  for _, f in ipairs(frames) do
    if f.registered[e] and not (f.unitsOf[e] and not f.unitsOf[e][unit]) then f.scripts.OnEvent(f, e, ...) end
  end
end

-- Units: what the game says about the creatures.
local unitInfo = {
  [1131] = { level = 7, type = "Beast", family = "Wolf" },
  [1133] = { level = 8, type = "Beast", family = "Wolf" },
  [1132] = { level = 10, type = "Beast", family = "Wolf", class = "rare" },
  [1123] = { level = 9, type = "Humanoid" },
  [10184] = { level = 63, type = "Dragonkin", class = "worldboss" },
  [99001] = { level = 5, type = "Beast", family = "Galestrider" }, -- unknown to the data (Forever's)
  [99002] = { level = 5, type = "Humanoid", friendly = true }, -- unknown, not attackable
  [99003] = { level = 6, type = "Beast", family = "Cat" }, -- unknown, of a known beast family
  [99004] = { level = 1, type = "Critter" }, -- unknown critter
  [99005] = { level = 7, type = "Beast", family = "Cat" }, -- unknown, a quest's quarry
  [99006] = { level = 8, type = "Elemental" }, -- unknown, filed by its name (ice: water)
  [99007] = { level = 8, type = "Elemental" }, -- unknown, no family's words in its name
  [259398] = { level = 10, type = "Humanoid", class = "rare" }, -- Forever's own rare (Zephras Isle)
  [1124] = { level = 9, type = "Humanoid", friendly = true }, -- known, but friendly now (a scripted foe)
}
local function unitId(u) return (u == "target" and state.target) or (u == "mouseover" and state.mouseover) end
local function info(u) return unitInfo[unitId(u) or 0] end
function UnitExists(u) return u == "player" or unitId(u) ~= nil end
function UnitCanAttack(_, u)
  local i = info(u)
  return i ~= nil and not i.friendly
end
function UnitCreatureType(u)
  local i = info(u)
  return i and i.type
end
function UnitCreatureFamily(u)
  local i = info(u)
  return i and i.family
end
function UnitClassification(u)
  local i = info(u)
  return i and i.class or "normal"
end
local deadTarget = false
function UnitIsDead(u) return u == "target" and deadTarget end
local inCombat = false
function UnitAffectingCombat(u) return inCombat and not (u == "target" and deadTarget) end
function UnitIsTapDenied(u) return u == "target" and state.tapped == true end
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
  [1426] = { name = "Dun Morogh", parentMapID = 1415 },
  [1429] = { name = "Elwynn Forest", parentMapID = 1415 },
  [1411] = { name = "Durotar", parentMapID = 1414 },
  [1415] = { name = "Eastern Kingdoms", parentMapID = 947 },
  [1414] = { name = "Kalimdor", parentMapID = 947 },
}
C_Map.GetMapInfo = function(id) return MAPS[id] end
state.explored = {}
-- What the character has discovered: area ids (the game answers by position;
-- here, wherever asked), and the overlays the map draws (for the book).
state.discovered = {}
C_MapExplorationInfo = {
  GetExploredMapTextures = function(id) return state.explored[id] end,
  GetExploredAreaIDsAtPosition = function()
    local ids = {}
    for id in pairs(state.discovered) do
      table.insert(ids, id)
    end
    return ids
  end,
}
function CreateVector2D(x, y) return { x = x, y = y } end
state.health = 100
function UnitHealth() return state.health end
function UnitHealthMax() return 100 end
function UnitIsDeadOrGhost() return state.health <= 0 end
function UnitOnTaxi() return state.taxi == true end
function hooksecurefunc(t, name, fn)
  if type(t) ~= "table" then
    t, name, fn = _G, t, name
  end
  local original = t[name]
  t[name] = function(...)
    local r = original(...)
    fn(...)
    return r
  end
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
function CreateFromMixins(...)
  local o = {}
  for _, m in ipairs({ ... }) do
    for k, v in pairs(m) do
      o[k] = v
    end
  end
  return o
end
WorldMapFrame = {
  mapID = 1426,
  AddDataProvider = function(self, p)
    p.GetMap = function() return self end
    mapProvider = p
  end,
  GetMapID = function(self) return self.mapID end,
}
local worldCanvas
WorldMapFrame.GetCanvas = function() return worldCanvas end

-- The game's alert system and its achievement toast (whose points shield
-- needs the achievement window, loaded on demand).
local toasted, loadedAddOns = {}, {}
AlertFrame = {
  AddQueuedAlertFrameSubSystem = function(_, template, setUp)
    return {
      AddAlert = function(_, ...)
        local f = ui()
        f.Icon, f.Unlocked, f.Name, f.Shield, f.Title = ui(), ui(), ui(), ui(), ui()
        f.Icon.Texture = ui()
        setUp(f, ...)
        table.insert(toasted, f)
      end,
    }
  end,
}
C_XMLUtil = { GetTemplateInfo = function() return {} end }
-- The shield's OnLoad: Classic Era has no achievement window, and Forever's
-- doesn't define it (its own game type): the addon stands one in at load.
C_AddOns = { LoadAddOn = function(name) loadedAddOns[name] = true end }
-- The expeditions: the emotes (the chat's and the menu's go through
-- C_ChatInfo.PerformEmote; DoEmote is the game's wrapper around it), the
-- faction, a target's reach, the game's confirmation (accepted at once).
C_ChatInfo = { PerformEmote = function() return true end }
function DoEmote(token, target) return C_ChatInfo.PerformEmote(token, target) end
state.faction = "Alliance"
function UnitFactionGroup(u) return u == "player" and state.faction or nil end
state.near = true
function CheckInteractDistance() return state.near end
StaticPopupDialogs = {}
YES, NO = "Yes", "No"
function StaticPopup_Show(which, text, _, data)
  state.popup = text
  StaticPopupDialogs[which].OnAccept(nil, data)
end

-- ── load the addon ───────────────────────────────────────────────────────────
local ns = {}
assert(loadfile(DIR .. (FOREVER and "Data_Forever.lua" or "Data_Classic.lua")))("FieldJournal", ns)
-- The files in the order of the game's own TOC (its data file loaded above).
for line in io.lines(DIR .. (FOREVER and "FieldJournal_Camelot.toc" or "FieldJournal_Vanilla.toc")) do
  local f = line:match("^([%w_]+%.lua)%s*$")
  if f and not f:match("^Data_") then assert(loadfile(DIR .. f))("FieldJournal", ns) end
end
local D = ns.data
-- A tab of the book clicked, by its name (ns.TAB).
local function clickTab(n)
  local tab = _G["FieldJournalFrameTab" .. n]
  tab.scripts.OnClick(tab)
end
local function check(cond, msg)
  assert(cond, msg)
  io.write("✓ " .. msg .. "\n")
end
local function said(text)
  for _, p in ipairs(printed) do
    if p:find(text, 1, true) then return p end
  end
end
local function rec(id) return FieldJournalChar.creatures[id] end
local function target(id)
  state.target = id
  fire("PLAYER_TARGET_CHANGED")
end

-- ── a session ────────────────────────────────────────────────────────────────
FieldJournalChar = { guid = "Player-6113-0DEAD000", creatures = { [1131] = { name = "Winter Wolf" } }, families = {} }
fire("PLAYER_LOGIN")
check(
  FieldJournalChar.guid == PLAYER and not rec(1131),
  "a new character named like a deleted one starts a fresh journal"
)
check(
  ns.partyKill == FOREVER and FOREVER == not registered("COMBAT_LOG_EVENT_UNFILTERED"),
  FOREVER and "Forever: kills come from PARTY_KILL (no combat log)"
    or "Classic (a client without PARTY_KILL): kills come from the combat log"
)
check(D.client == (FOREVER and "forever" or "classic"), "each game's data file is its own")
local function hasNote(notes, text) return table.concat(notes, " "):find(text, 1, true) ~= nil end
local alterac, azshara = D.atlas.zones[1416].note, D.atlas.zones[1447].note
check(
  hasNote(alterac, "Archmage Modera") == FOREVER
    and hasNote(alterac, "violet dome") == not FOREVER
    and hasNote(azshara, "Blackmaw Hold") == FOREVER
    and hasNote(D.atlas.zones[1455].note, "Hall of Thanes") == FOREVER,
  "the Atlas contains this world's history only, with its shared routes"
)
local furbolgs
for _, family in ipairs(D.families) do
  if family.id == "furbolgs" then furbolgs = family.note end
end
check(
  furbolgs and hasNote(furbolgs, "Blackmaw Hold") == FOREVER and hasNote(furbolgs, "Timbermaw"),
  "the Bestiary keeps the Timbermaw distinct from Forever's Blackmaw tribe"
)
local function readable(notes)
  if not notes or #notes == 0 then return false end
  for _, paragraph in ipairs(notes) do
    if paragraph == "" or paragraph:match("^%[") then return false end
  end
  return true
end
for _, family in ipairs(D.families) do
  assert(readable(family.note), family.id .. ": an unreadable note")
end
for _, zone in pairs(D.atlas.zones) do
  if zone.note then assert(readable(zone.note), zone.name .. ": an unreadable note") end
end
for _, kinds in ipairs({ D.flora.herbs, D.flora.fish }) do
  for _, kind in pairs(kinds) do
    assert(readable(kind.note), kind.name .. ": an unreadable note")
  end
end
check(true, "every compiled note is nonempty and free of editorial game markers")

local function seen(id) return FieldJournalChar.seen and FieldJournalChar.seen[id] end
target(1131)
check(
  seen(1131)
    and seen(1131).name == "Winter Wolf"
    and seen(1131).low == 7
    and seen(1131).first.zone == "Dun Morogh"
    and not rec(1131)
    and not said("recorded"),
  "targeting a creature notes it (its level, where), not yet in the book: it joins on its first kill"
)
state.mouseover = 1133
fire("UPDATE_MOUSEOVER_UNIT")
check(seen(1133) and not rec(1133), "… and so does mousing over one")
state.sub = "Coldridge Pass"
target(1131)
check(
  #seen(1131).places == 2 and seen(1131).places[2] == "Dun Morogh: Coldridge Pass",
  "a creature remembers the places it was met"
)

-- Slaying: my killing blow or my pet's, however dealt.
local spawn = 0
local function kill(id, tapped)
  spawn = spawn + 1
  local guid = creature(id, spawn)
  if FOREVER then
    -- as it's played: chosen first, then the fight, and it dies; PARTY_KILL
    -- names the killer (not this character when another hit it first)
    state.target = id
    fire("PLAYER_TARGET_CHANGED")
    if not tapped then fire("PARTY_KILL", PLAYER, guid) end
    return
  end
  combatLog =
    { clock, "PARTY_KILL", false, tapped and "Player-6113-0FFFFFFF" or PLAYER, "Thorin", 0, 0, guid, "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
kill(1131)
check(
  rec(1131) and rec(1131).slain == 1 and rec(1131).firstSlain.level == 3 and not seen(1131),
  "slaying a creature puts it in the book, counted, with when and at what level"
)
check(rec(1131).first.zone == "Dun Morogh" and #rec(1131).places == 2, "… with what was seen of it before")
check(
  said("|cffffd100|Hfieldjournal:c1131|h[Winter Wolf]|h|r recorded (Wolves, a new family).") and sounds == 0,
  "… announced in chat with a link to its page (and its new family), without a sound"
)
printed = {}
kill(1133)
check(
  rec(1133) and said("[Starving Winter Wolf]|h|r recorded (Wolves).") and sounds == 0,
  "every new creature gets its line, the family only once"
)
printed = {}
kill(1131)
check(#printed == 0 and rec(1131).slain == 2, "… and only the first time it's slain")
kill(1134, true)
check(not rec(1134), "a creature someone else killed isn't this character's")
if FOREVER then
  -- a DoT's kill, the creature no longer targeted; my pet's
  state.target = 1131
  fire("PLAYER_TARGET_CHANGED")
  spawn = spawn + 1
  fire("PARTY_KILL", PLAYER, creature(1133, spawn))
  spawn = spawn + 1
  fire("PARTY_KILL", PET, creature(1133, spawn))
  check(rec(1133).slain == 3, "Forever: a DoT's kill, the creature not targeted, counts, and a pet's")
else
  combatLog = { clock, "PARTY_KILL", false, PET, "Pet", 0, 0, creature(1131, 99), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
  check(rec(1131).slain == 3, "your pet's kill counts")
end
local before = rec(1131).slain

-- Loot: the loot window names the corpse.
loot = {
  { "|cffffffff|Hitem:2672::::::::3:::::|h[Stringy Wolf Meat]|h|r", { creature(1131, 1), 1 } },
  { "|cff9d9d9d|Hitem:3300::::::::3:::::|h[Rabbit's Foot]|h|r", { creature(1131, 1), 2 } },
}
fire("LOOT_OPENED")
fire("LOOT_OPENED")
check(
  rec(1131).loot[2672] == 1 and rec(1131).loot[3300] == 2,
  "looting records what each creature gave, once per corpse"
)
check(rec(1131).slain == before, "… and a corpse looted isn't another kill")

-- Drop rates: of my kills looted or found empty, each item once a corpse;
-- a corpse left unlooted, or opened again (skinned), counts for nothing.
local drops = rec(1131).drops
check(
  drops and drops.corpses == 1 and drops.items[2672] == 1 and drops.items[3300] == 1,
  "a kill looted counts for the drop rates, each item once a corpse (the window read twice)"
)
local MEAT = "|cffffffff|Hitem:2672::::::::3:::::|h[Stringy Wolf Meat]|h|r"
kill(1131)
local meaty = creature(1131, spawn)
state.empty[creature(1131, spawn + 1)] = true
kill(1131)
kill(1131) -- (left where it fell)
loot = { { MEAT, { meaty, 1 } } }
fire("LOOT_READY", true)
fire("LOOT_OPENED", true)
fire("LOOT_CLOSED")
loot = { { "|cffffffff|Hitem:2318::::::::3:::::|h[Light Leather]|h|r", { meaty, 1 } } }
fire("LOOT_READY", true)
fire("LOOT_CLOSED")
check(
  drops.corpses == 3 and drops.items[2672] == 2 and drops.items[3300] == 1 and not drops.items[2318],
  "… a corpse found empty counts, one left unlooted doesn't, nor one skinned"
)
local meat, foot = ns.dropRate(rec(1131), 2672), ns.dropRate(rec(1131), 3300)
check(
  meat.rate == "67%" and meat.detail == "in 2 of 3 kills looted or found empty" and foot.rate == "33%",
  "… its rate in words, for the item's tooltip"
)
check(ns.dropRate(rec(1131), 2318).rate == "0%" and ns.dropRate(rec(1133), 2672) == nil, "… none counted, none said")
-- (the game read a corpse as empty, too early or too far, then it was looted:
-- its items count, the corpse once; an item that dropped only outside the
-- count says so, not a bare 0%)
local misread = creature(1133, spawn + 1) -- (the next kill's)
state.empty[misread] = true
kill(1133)
check(rec(1133).drops.corpses == 1, "… a corpse that holds nothing counts, as a kill without the item")
state.empty[misread] = nil
loot = { { "|cff9d9d9d|Hitem:1811::::::::3:::::|h[Blunt Claymore]|h|r", { misread, 1 } } }
fire("LOOT_READY", true)
fire("LOOT_CLOSED")
check(
  rec(1133).drops.corpses == 1 and rec(1133).drops.items[1811] == 1 and ns.dropRate(rec(1133), 1811).rate == "100%",
  "… a corpse read as empty, then looted: its items counted, the corpse once"
)
rec(1133).loot[2589] = 2 -- (Linen Cloth, from a kill before the count began)
check(
  ns.dropRate(rec(1133), 2589).before and not ns.dropRate(rec(1133), 1811).before,
  "… an item looted only outside the count says so (not a bare 0%)"
)
state.party = { party1 = "Player-1-0000000A" }
state.empty[creature(1131, spawn + 1)] = true
kill(1131)
check(drops.corpses == 3, "… in a group, a corpse that reads empty may be another's turn: not counted")
state.party = nil

-- A rare: a trophy.
printed = {}
target(1132)
kill(1132)
check(rec(1132).trophy and rec(1132).trophy.rank == "r", "slaying a rare (Timber) makes a trophy")
check(
  said("a trophy: |cffffd100|Hfieldjournal:c1132|h[Timber]|h|r") and played[3175],
  "… announced in chat, with the trophy sound"
)
check(
  ns.earnedMilestone("trophies-1")
    and said("you have earned the milestone |cffffd100|Hfieldjournal:mtrophies-1|h[First Trophy]|h|r!")
    and played[12891],
  "… and the first trophy earns a milestone, with the game's achievement fanfare and a chat line"
)
local shield = {}
AchievementShield_OnLoad(shield)
local function toastOf(kind, id)
  for _, f in ipairs(toasted) do
    if f.journalKind == kind and f.journalId == id then return f end
  end
end
local trophyToast = toastOf("milestone", "trophies-1")
check(
  trophyToast and trophyToast.Name.text == "First Trophy" and shield.Saturate and shield.Desaturate,
  "… and the game's achievement toast, its shield's OnLoad stood in at load (the game's own toasts need it too)"
)

-- Creatures the data doesn't know (Forever's new ones): filed by what was seen.
target(99003)
kill(99003)
check(
  rec(99003) and ns.familyTitle(ns.familyKey(99003)) == "Great Cats",
  "a creature the data doesn't know is filed by its beast family (a Cat: the great cats)"
)
check(said("[Snow Leopard Prowler]|h|r recorded (Great Cats, a new family)."), "… and announced under it")
target(99001)
kill(99001)
check(
  ns.familyTitle(ns.familyKey(99001)) == "Other Beasts",
  "… a beast of a family the book has no page for, with the other beasts"
)
target(99006)
kill(99006)
check(
  ns.familyTitle(ns.familyKey(99006)) == "Water Elementals",
  "… another type, by its name as the families' rules read it (a Minor Ice Elemental: the water elementals)"
)
target(99007)
kill(99007)
check(ns.familyTitle(ns.familyKey(99007)) == "Other Elementals", "… and with its type's others when no rule names it")
target(99004)
check(not seen(99004), "… and no critter")
target(99002)
check(not seen(99002), "… unless it can't be fought (friendly folk)")
target(1124)
check(not seen(1124), "a creature the data knows isn't noted while it can't be fought either")
-- Forever's own rares (data/rare-zones-forever.json): a zone's milestone,
-- counted once met and slain, though the data can't file them.
if FOREVER then
  check(ns.milestoneById["zone-2521"] ~= nil, "Forever: the rares of Zephras Isle have their milestone")
  target(259398)
  kill(259398)
  local done, need = ns.milestoneById["zone-2521"].progress()
  check(
    done == 1 and need == 1 and ns.rank(259398) == nil,
    "… earned by slaying Galemender Delanea, unknown to the data"
  )
else
  check(ns.milestoneById["zone-2521"] == nil, "Classic: no milestone for Forever's Zephras Isle")
end

-- Kills credited: a quest's count gone up for a creature no kill told
-- (another's blow on one I tagged: the game credits me), and my group's.
target(99005)
state.target = nil
local count = FOREVER and "%d/1 Frost Lynx slain" or "Frost Lynx slain: %d/1"
state.quests = { { id = 500, objectives = { { type = "monster", text = count:format(0) } } } }
fire("QUEST_LOG_UPDATE")
kill(99005, true)
state.quests[1].objectives[1].text = count:format(1)
fire("QUEST_LOG_UPDATE")
check(rec(99005) and rec(99005).slain == 1, "a kill a quest credits me with, another's blow, joins the book")
kill(99005)
state.quests[1].objectives[1].text = count:format(2)
fire("QUEST_LOG_UPDATE")
check(rec(99005).slain == 2, "… and one told and counted, once")
state.quests = nil
state.party = { party1 = "Player-6113-0AAAAAAA" }
spawn = spawn + 1
if FOREVER then
  fire("PARTY_KILL", "Player-6113-0AAAAAAA", creature(99005, spawn))
else
  combatLog = { clock, "PARTY_KILL", false, "Player-6113-0AAAAAAA", "Brannor", 0, 0, creature(99005, spawn), "?", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
check(rec(99005).slain == 3, "a groupmate's killing blow is a kill of ours")
state.party = nil

-- A journal from before (creatures joined on meeting): the ones never slain
-- go back to what was seen, once.
do
  local saved = FieldJournalChar
  FieldJournalChar = {
    guid = PLAYER,
    creatures = { [1131] = { name = "Winter Wolf", slain = 4 }, [1135] = { name = "Old Sighting" } },
    families = { [ns.familyKey(1131)] = { at = 1 }, ["only-met"] = { at = 2 } },
  }
  fire("PLAYER_LOGIN")
  local j = FieldJournalChar
  check(
    j.creatures[1131]
      and not j.creatures[1135]
      and j.seen[1135]
      and j.families[ns.familyKey(1131)]
      and not j.families["only-met"]
      and j.killRule,
    "an older journal: creatures never slain become sightings, their families with them, once"
  )
  FieldJournalChar = saved
  fire("PLAYER_LOGIN")
end

-- The families met are kept by their id and rebuilt from the creatures at
-- each login: an older journal's places in the data file's list go, a family kept
-- by its id keeps its date, and one a creature has moved into (the Stagwings,
-- hippogryphs once filed with the grazers) comes, dated by its first kill.
do
  local saved = FieldJournalChar
  FieldJournalChar = {
    guid = PLAYER,
    killRule = true,
    creatures = {
      [1131] = { name = "Winter Wolf", slain = 4, firstSlain = { at = 100, level = 6 } },
      [5304] = { name = "Frayfeather Stagwing", slain = 1, firstSlain = { at = 200, level = 44 } },
    },
    families = { wolves = { at = 50, level = 5 }, [3] = { at = 1 }, [17] = { at = 2 } },
  }
  fire("PLAYER_LOGIN")
  local f = FieldJournalChar.families
  check(
    ns.familyKey(1131) == "wolves"
      and ns.familyKey(5304) == "birds"
      and f.wolves.at == 50
      and f.birds
      and f.birds.at == 200
      and f.birds.level == 44
      and not f[3]
      and not f[17]
      and not f["stags-and-steeds"],
    "families kept by their id, rebuilt from the creatures at login: a moved creature brings its new family"
  )
  FieldJournalChar = saved
  fire("PLAYER_LOGIN")
end

-- ── the atlas ────────────────────────────────────────────────────────────────
-- Only places a character can discover: not the capitals drawn on their zone's
-- map, not Forever's Dalaran behind its dome.
local function hasPlace(zone, name)
  for _, p in ipairs(D.atlas.zones[zone].places) do
    if p[1] == name then return true end
  end
end
check(
  not hasPlace(1411, "Orgrimmar")
    and (FOREVER and not hasPlace(1416, "Dalaran") or not FOREVER and hasPlace(1416, "Dalaran")),
  FOREVER and "Forever: no Orgrimmar in Durotar's places, no Dalaran in Alterac's"
    or "no Orgrimmar in Durotar's places; Dalaran is one of Alterac's"
)
local dun = D.atlas.zones[1426].places
local function texture(place)
  return {
    offsetX = place[2],
    offsetY = place[3],
    textureWidth = 300,
    textureHeight = 200,
    fileDataIDs = { 1, 2, 3, 4 },
    isShownByMouseOver = false,
  }
end
local function key(place) return place[6] end
-- Moonglade's map draws its one overlay for everyone: no discovery for all that.
state.explored[1450] = { texture(D.atlas.zones[1450].places[1]) }
state.map, state.explored[1426], state.discovered[key(dun[1])] = 1426, { texture(dun[1]) }, true
printed = {}
fire("PLAYER_ENTERING_WORLD")
local atlas = FieldJournalChar.atlas
check(
  atlas.seeded and atlas.zones[1426].places[key(dun[1])].retro,
  "the places a character had already discovered fill its atlas quietly"
)
check(not atlas.zones[1450], "… and not a zone the map merely draws (Moonglade), never discovered")
check(
  atlas.zones[1426].first and atlas.zones[1426].visits == 1 and #printed == 0,
  "… and the zone it stands in is visited, without a word"
)
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
check(
  place and place.at and not place.retro and place.level == state.level,
  "a place newly explored is recorded, with the day and level"
)
local done, total = ns.zoneProgress(1426)
check(done == 2 and total == #dun and total > 10, "a zone counts its places explored, of all it has")
state.map = 1429
fire("ZONE_CHANGED_NEW_AREA")
check(
  atlas.zones[1429] and said("|Hfieldjournal:z1429|h[Elwynn Forest]|h|r added to the atlas."),
  "a new zone is announced in chat, with a link"
)
state.map = 1411
fire("ZONE_CHANGED_NEW_AREA")
local crossing = atlas.crossings[#atlas.crossings]
check(crossing and crossing.from == 1429 and crossing.to == 1411, "crossing to another continent is recorded")
TakeTaxiNode(2)
check(
  atlas.flights[1].from == "Ironforge"
    and atlas.flights[1].to == "Thelsamar"
    and atlas.routes["Ironforge > Thelsamar"] == 1,
  "a flight is recorded, with its route"
)
fire("HEARTHSTONE_BOUND")
check(atlas.binds[1].place == "Kharanos", "a new hearthstone bind is recorded")
state.target = 1133
fire("PLAYER_TARGET_CHANGED")
state.health = 5
fire("UNIT_HEALTH", "player")
check(
  atlas.closeCalls[1] and atlas.closeCalls[1].zone == 1411 and atlas.closeCalls[1].x == 30,
  "a close call: under a tenth of your health and alive after"
)
if not FOREVER then
  combatLog = { clock, "SWING_DAMAGE", false, creature(1131), "Winter Wolf", 0, 0, PLAYER, "Thorin", 0, 0 }
  fire("COMBAT_LOG_EVENT_UNFILTERED")
end
state.health = 0
fire("PLAYER_DEAD")
check(
  atlas.deaths[1] and atlas.deaths[1].by == (FOREVER and "Starving Winter Wolf" or "Winter Wolf"),
  FOREVER and "Forever: a death names the last foe targeted" or "a death names what last hurt you (the combat log)"
)
state.health, state.map, state.target = 100, 1426, nil
-- An atlas recorded by 0.3.0, which trusted the overlays the map draws.
local saved = FieldJournalChar.atlas
FieldJournalChar.atlas = {
  zones = {
    [1450] = { retro = true, places = { [key(D.atlas.zones[1450].places[1])] = { retro = true } } },
    [1426] = {
      first = { at = clock, level = 3 },
      places = { [key(dun[1])] = { retro = true }, [key(dun[2])] = { at = clock, level = 3 } },
    },
  },
  seeded = true,
  deaths = {},
  closeCalls = {},
  flights = {},
  routes = {},
  crossings = {},
  binds = {},
}
FieldJournalChar.achievements["explore-1450"] = { at = clock, level = 3, retro = true }
fire("PLAYER_ENTERING_WORLD")
local migrated = FieldJournalChar.atlas
check(
  not migrated.zones[1450] and not FieldJournalChar.achievements["explore-1450"],
  "an atlas from 0.3.0 loses the zones it never discovered, and their milestones"
)
check(
  migrated.zones[1426].places[key(dun[1])].retro and migrated.zones[1426].places[key(dun[2])].at,
  "… and keeps what is truly discovered"
)
FieldJournalChar.atlas = saved
check(ns.earnedMilestone("crossing") and said("[Across the Sea]"), "crossing the sea earns a milestone")
check(
  ns.milestoneVisible(ns.milestoneById["explore-1426"]) and not ns.milestoneVisible(ns.milestoneById["explore-1446"]),
  "a zone's exploration milestone shows once the zone is entered (Dun Morogh), not before (Tanaris)"
)
local exploredNow, placesAll = ns.milestoneById["explore-1426"].progress()
check(exploredNow == 2 and placesAll == #dun, "… counting its places explored")
worldCanvas = worldCanvas or CreateFrame("Frame")
WorldMapFrame.mapID = 1411
ns.refreshWorldMapPins()
local marks = {}
for _, p in ipairs(mapProvider and mapProvider.pins or {}) do
  if p.shown then marks[p.title] = p end
end
check(
  marks["Died here"] and marks["A close call"],
  "deaths and close calls are marked on the game's world map, on their zone"
)
WorldMapFrame.mapID = 1426
ns.refreshWorldMapPins()
local shownPins = 0
for _, p in ipairs(mapProvider.pins) do
  if p.shown then shownPins = shownPins + 1 end
end
check(shownPins == 0, "… and only there")

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.FIELDJOURNAL("")
check(
  FieldJournalFrame.shown and FieldJournalFrame.selectedTab == ns.TAB.expeditions,
  "/journal opens the book, at the Expeditions"
)
clickTab(ns.TAB.bestiary)
local creatures, families, slain = ns.counts()
check(
  FieldJournalFrame.count.text == ("%d creatures, %d families, %d slain"):format(creatures, families, slain),
  "it counts what was recorded"
)
local function shown(text)
  for _, r in ipairs(ns.listRows) do
    if r.shown and r.text.text == text then return r end
  end
end
check(
  shown("Wolves") and shown("Beasts") and shown("Trophies") and shown("Other Beasts"),
  "the list shows the families met, under their type, and the trophies"
)
check(not shown("Unrecorded"), "… and nothing left unrecorded")
check(not shown("Spiders"), "… and no family not yet met")
ns.openFamily(D.creatures[1131])
local wolves = {}
for _, e in ipairs(ns.pageEntries) do
  if e.shown then wolves[e.id] = e end
end
check(wolves[1131] and wolves[1133] and wolves[1132], "a family's page has an entry per creature met")
check(
  wolves[1131].name.text == "Winter Wolf"
    and wolves[1131].facts.text:find("levels 7-8", 1, true)
    and wolves[1131].facts.text:find("slain", 1, true),
  "… with its name and a line of its record (its levels in the world, not just the one seen)"
)
check(D.models[1131] and wolves[1131].portrait.display == D.models[1131], "… and its portrait, from its display id")
check(shown("Winter Wolf") and shown("Starving Winter Wolf"), "an open family lists its creatures under it")
-- The Bestiary's select, under the search box: its creatures' order.
local filter = FieldJournalFrame.filter
check(filter.shown and filter.text:GetText() == "Sorted by name", "the Bestiary's select: by name at first")
local function order()
  local out = {}
  for _, e in ipairs(ns.pageEntries) do
    if e.shown then table.insert(out, e.id) end
  end
  return out
end
local slainBefore = FieldJournalChar.creatures[1133].slain
FieldJournalChar.creatures[1133].slain = 99
filter.scripts.OnClick(filter)
filter.rows[2].scripts.OnClick(filter.rows[2])
ns.openFamily(D.creatures[1131])
check(order()[1] == 1133 and filter.text:GetText() == "The most slain first", "… the most slain first, chosen")
filter.rows[1].scripts.OnClick(filter.rows[1])
FieldJournalChar.creatures[1133].slain = slainBefore
shown("Winter Wolf").scripts.OnClick(shown("Winter Wolf"))
local record = {}
for _, p in ipairs(ns.pagePairs) do
  if p.shown then record[p.label.text] = p.value.text end
end
check(
  FieldJournalPage.title.text == "Winter Wolf"
    and FieldJournalPage.portrait.display == D.models[1131]
    and FieldJournalPage.sub.text:find("Wolves", 1, true),
  "a creature has its own page: portrait, name, family"
)
check(
  record["First met"]
    and record["Where"]:find("Coldridge Pass", 1, true)
    and record["Slain"] == tostring(rec(1131).slain),
  "… and its record: when and where it was met, its kills"
)
check(
  ns.pageLoot[1] and ns.pageLoot[1].shown and ns.pageLoot[2].shown and not ns.pageLoot[3],
  "… and what it gave, an icon per item"
)
check(not ns.pageEntries[1].shown, "… without the family's entries")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(FieldJournalPage.title.text == "Wolves" and shown("Winter Wolf"), "the family's row opens its page again")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(not shown("Winter Wolf"), "… and, once open, folds it")
wolves[1132].scripts.OnClick(wolves[1132])
check(FieldJournalPage.title.text:find("^Timber"), "an entry on a family's page opens the creature's")
FieldJournalSearch:SetText("timber")
ns.refresh()
check(
  shown("Wolves") and not shown("Ice Trolls") and not shown("Winter Wolf"),
  "search finds a family by a creature's name, with just the creatures found"
)
FieldJournalSearch:SetText("")
ns.refresh()
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(not shown("Wolves") and FieldJournalChar.collapsed.beasts, "a click on a type folds it")
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(shown("Wolves"), "… and unfolds it")
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:c1132")
check(
  FieldJournalFrame.shown and FieldJournalPage.title.text:find("^Timber"),
  "a link in chat opens the book at the creature's page"
)
linkHandlers.fieldjournal("fieldjournal:murlocs")
check(
  FieldJournalPage.title.text == "Murlocs",
  "… a family's link by its id, even one beginning like a creature's or a milestone's"
)

-- The atlas in the book.
C_Map.GetMapArtLayers = function()
  return { { layerWidth = 1002, layerHeight = 668, tileWidth = 256, tileHeight = 256 } }
end
C_Map.GetMapArtLayerTextures = function()
  local t = {}
  for i = 1, 12 do
    t[i] = 1000 + i
  end
  return t
end
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:z1426")
local atlasRecord = {}
for _, p in ipairs(ns.atlasPairs) do
  if p.shown then atlasRecord[p.label.text] = p.value.text end
end
check(
  FieldJournalFrame.selectedTab == ns.TAB.atlas
    and FieldJournalAtlasPage.title.text == "Dun Morogh"
    and FieldJournalAtlasPage.map.shown,
  "a zone's link opens the Atlas at its page, with its map"
)
check(
  FieldJournalAtlasPage.note.shown and FieldJournalAtlasPage.note.text:find("^Snow, stone and dwarves"),
  "… the surveyor's note"
)
check(
  atlasRecord.Explored:find(dun[1][1], 1, true) and atlasRecord.Explored:find(dun[2][1], 1, true),
  "… the places explored, by name"
)
check(FieldJournalAtlasPage.sub.text:find(("2 of %d places explored"):format(#dun), 1, true), "… and how many remain")
check(
  FieldJournalFrame.filter.shown
    and FieldJournalFrame.filter.text:GetText() == "Every land"
    and #FieldJournalFrame.filter.options >= 2,
  "the Atlas's select: every land, or a continent entered"
)
local zoneRows = {}
for _, r in ipairs(ns.atlasRows) do
  if r.shown then zoneRows[r.text.text] = r end
end
check(
  zoneRows["Eastern Kingdoms"] and zoneRows["Dun Morogh"] and zoneRows.Durotar and not zoneRows.Tanaris,
  "the list: continents, the zones entered, none other"
)
check(
  zoneRows["Dun Morogh"].bar.shown and zoneRows["Dun Morogh"].count.text == ("2/%d"):format(#dun),
  "a zone's row carries a bar and a count of its places"
)
do
  local f = FieldJournalFrame.filter
  local ek
  for k, o in ipairs(f.options) do
    if o.text == "Eastern Kingdoms" then ek = k end
  end
  f.rows[ek].scripts.OnClick(f.rows[ek])
  local only = {}
  for _, r in ipairs(ns.atlasRows) do
    if r.shown then only[r.text.text] = true end
  end
  check(only["Dun Morogh"] and not only.Durotar, "… one continent chosen: its zones alone")
  f.rows[1].scripts.OnClick(f.rows[1])
end
check(
  zoneRows[dun[1][1]] and zoneRows[dun[2][1]] and zoneRows[dun[1][1]].kind == "place" and not zoneRows[dun[3][1]],
  "… and, open, the places discovered under it, none other"
)
zoneRows[dun[2][1]].scripts.OnClick(zoneRows[dun[2][1]])
local discoveredLine
for _, p in ipairs(ns.atlasPairs) do
  if p.shown and p.label.text == "Discovered" then discoveredLine = p.value.text end
end
check(
  FieldJournalAtlasPage.map.pick.shown and discoveredLine and discoveredLine:find("level 3", 1, true),
  "a click on a place picks it out on the zone's map, with the day and level it was found"
)
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
local placeShown = false
for _, r in ipairs(ns.atlasRows) do
  if r.shown and r.kind == "place" and r.zone == 1426 then placeShown = true end
end
check(not placeShown and FieldJournalChar.atlasOpen[1426] == false, "the open zone's row folds it")
FieldJournalSearch:SetText(dun[2][1]:sub(1, 5))
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do
  if r.shown then zoneRows[r.text.text] = r end
end
check(
  zoneRows["Dun Morogh"] and zoneRows[dun[2][1]] and not zoneRows.Durotar and not zoneRows.Travels,
  "search finds places by name, with their zone"
)
FieldJournalSearch:SetText("")
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do
  if r.shown then zoneRows[r.text.text] = r end
end
zoneRows.Travels.scripts.OnClick(zoneRows.Travels)
check(FieldJournalAtlasPage.title.text == "Travels", "the travels page sums them up")
clickTab(ns.TAB.bestiary)

-- Milestones.
check(
  ns.milestoneById["zone-1426"] and ns.milestoneVisible(ns.milestoneById["zone-1426"]),
  "Timber met: the rares of Dun Morogh have their milestone in the list"
)
check(
  not ns.milestoneVisible(ns.milestoneById["zone-1429"]),
  "… the rares of Elwynn, none met yet, don't (no spoilers)"
)
check(
  ns.milestoneVisible(ns.milestoneById["type-beasts"]) and not ns.milestoneVisible(ns.milestoneById["type-demons"]),
  "… nor the families of a type not met yet"
)
local done, need = ns.milestoneById["zone-1426"].progress()
check(done == 1 and need >= 5, "a zone's milestone counts its rares slain")
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:mtrophies-1")
local row
for _, r in ipairs(ns.milestoneRows) do
  if r.shown and r.id == "trophies-1" then row = r end
end
check(
  FieldJournalFrame.shown
    and FieldJournalFrame.selectedTab == ns.TAB.milestones
    and row
    and row.status.text:find("^Level"),
  "a milestone's link opens the Milestones tab, the milestone earned with its level"
)
check(FieldJournalFrame.count.text == ("%d of %d milestones"):format(ns.milestoneCount()), "… which counts them")
clickTab(ns.TAB.bestiary)
check(
  FieldJournalFrame.selectedTab == ns.TAB.bestiary and FieldJournalPage and shown("Wolves"),
  "the Bestiary tab brings the book back"
)
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
local BOBBER, SCHOOL, NODE =
  "GameObject-0-1-0-0-35591-0000000001", "GameObject-0-1-0-0-180682-0000000002", "GameObject-0-1-0-0-1618-0000000003"
-- A loot window as the game sends it: looting begins (LOOT_READY), the
-- window opens (reported twice, as the game can), it closes.
local function lootWindow(slots)
  loot = slots
  fire("LOOT_READY", true)
  fire("LOOT_OPENED", true)
  fire("LOOT_OPENED", true) -- the game can report a window twice
  fire("LOOT_CLOSED")
end
local fish = function(id) return FieldJournalChar.fish and FieldJournalChar.fish[id] end
local plant = function(id) return FieldJournalChar.plants and FieldJournalChar.plants[id] end
state.map, state.sub = 1429, "Crystal Lake"
fishing = true
lootWindow({ { link(6291, "Raw Brilliant Smallfish"), { BOBBER, 1 } } })
local smallfish = fish(6291)
check(
  smallfish
    and smallfish.n == 1
    and smallfish.day == 1
    and smallfish.school == 0
    and smallfish.first.zone == 1429
    and smallfish.first.sub == "Crystal Lake"
    and smallfish.zones[1429] == 1,
  "a catch in open water: where, when, by day, once per window"
)
check(
  said("a new catch: |cffffd100|Hfieldjournal:f6291|h[Raw Brilliant Smallfish]|h|r"),
  "… announced in chat, with a link"
)
state.hour = 19 -- night from 6 PM, the Nightfin's hours
lootWindow({ { link(6358, "Oily Blackmouth"), { SCHOOL, 1 } } })
check(fish(6358) and fish(6358).school == 1 and fish(6358).night == 1, "a catch from a school, by night")
lootWindow({ { link(6364, "32 Pound Catfish"), { BOBBER, 1 } } })
lootWindow({ { link(6309, "17 Pound Catfish"), { BOBBER, 1 } } })
check(
  fish(6309) and fish(6309).n == 2 and fish(6309).heaviest == 32 and not fish(6364),
  "weighed catches count for their kind, the heaviest kept"
)
lootWindow({ { link(6297, "Old Skull"), { BOBBER, 1 } } })
check(not fish(6297), "junk from the water isn't a fish")
fishing = false
lootWindow({ { link(6303, "Raw Slitherskin Mackerel"), { creature(1131), 1 } } })
check(not fish(6303), "a fish looted from a corpse isn't a catch")
lootWindow({ { link(2447, "Peacebloom"), { NODE, 2 }, 2 } })
local bloom = plant(2447)
check(
  bloom and bloom.gathered == 2 and bloom.n == 2 and bloom.first.how == "gathered" and bloom.zones[1429] == 2,
  "an herb from its node: gathered, the stack counted"
)
check(said("a new herb: |cffffd100|Hfieldjournal:h2447|h[Peacebloom]|h|r"), "… announced in chat")
lootWindow({ { link(2447, "Peacebloom"), { creature(1131), 1 } } })
check(bloom.looted == 1 and bloom.n == 3, "the same herb from a corpse: looted")
state.bags = { [1] = 2447, [2] = 3820 }
fire("BAG_UPDATE_DELAYED")
check(
  plant(3820)
    and plant(3820).first.how == "other"
    and plant(3820).n == 0
    and bloom.n == 3
    and said("[Stranglekelp]|h|r"),
  "an herb found in the bags (bought, a reward...): noted once, its count unknown, announced"
)
state.bags = { [1] = 785 }
fire("PLAYER_ENTERING_WORLD")
check(plant(785) and not said("[Mageroyal]|h|r"), "… but the herbs already carried at login are noted quietly")

-- The Fish and Plants tabs.
local frows, fpage = ns.floraRows, nil
local function rowNamed(text)
  for _, r in ipairs(frows) do
    if r.shown and r.text.text == text then return r end
  end
end
local function pairNamed(label)
  for _, p in ipairs(ns.floraPairs) do
    if p.shown and p.label.text == label then return p.value.text end
  end
end
FieldJournalFrame:Show()
clickTab(ns.TAB.fish)
fpage = FieldJournalFloraPage
check(
  FieldJournalFrame.selectedTab == ns.TAB.fish
    and fpage.shown
    and fpage.title.text == "The catch so far"
    and FieldJournalFrame.count.text == "3 kinds of fish, 4 caught",
  "the Fish tab: the catch so far"
)
check(
  rowNamed("Fish of the waters")
    and rowNamed("Reagents")
    and rowNamed("Weighed catches")
    and rowNamed("Raw Brilliant Smallfish")
    and rowNamed("Raw Brilliant Smallfish").count.text == "1"
    and not rowNamed("Raw Slitherskin Mackerel")
    and not rowNamed("Quest catches"),
  "… lists what was caught, in groups, with counts: nothing else (no spoilers)"
)
rowNamed("Catfish").scripts.OnClick(rowNamed("Catfish"))
check(
  fpage.title.text == "Catfish"
    and pairNamed("Heaviest") == "32 pounds"
    and pairNamed("Caught") == "2"
    and pairNamed("Zones"):find("Westfall", 1, true)
    and pairNamed("Where") == "Elwynn Forest (2)",
  "a kind's page: where it bites (the data), the catches, the heaviest"
)
rowNamed("Oily Blackmouth").scripts.OnClick(rowNamed("Oily Blackmouth"))
check(
  pairNamed("From schools") == "1" and pairNamed("By day, by night") == "0, 1" and fpage.sub.text == "A reagent",
  "… from a school, by night"
)
clickTab(ns.TAB.plants)
check(
  FieldJournalFrame.selectedTab == ns.TAB.plants
    and fpage.title.text == "The herbs so far"
    and rowNamed("Apprentice")
    and rowNamed("Peacebloom").count.text == "3"
    and rowNamed("Stranglekelp")
    and rowNamed("Journeyman"),
  "the Plants tab: by Herbalism rank"
)
rowNamed("Peacebloom").scripts.OnClick(rowNamed("Peacebloom"))
check(
  fpage.sub.text == "Herbalism 1"
    and pairNamed("Gathered") == "2"
    and pairNamed("Looted") == "1"
    and pairNamed("First"):find("(gathered)", 1, true),
  "an herb's page: its rank, how it was taken"
)
check(
  fpage.note.shown and fpage.note.text == table.concat(D.flora.herbs[2447].note, "\n\n"),
  "… and the naturalist's note"
)
FieldJournalFrame:Hide()
linkHandlers.fieldjournal("fieldjournal:f6291")
check(
  FieldJournalFrame.shown
    and FieldJournalFrame.selectedTab == ns.TAB.fish
    and fpage.title.text == "Raw Brilliant Smallfish",
  "a catch's link opens its page"
)
linkHandlers.fieldjournal("fieldjournal:h3820")
check(
  FieldJournalFrame.selectedTab == ns.TAB.plants and fpage.title.text == "Stranglekelp",
  "an herb's link opens its page"
)
clickTab(ns.TAB.fish)
fishing = true
lootWindow({ { link(13755, "Winter Squid"), { BOBBER, 1 } } })
fishing = false
check(rowNamed("Winter Squid"), "a new catch shows in the open tab at once")
rowNamed("Winter Squid").scripts.OnClick(rowNamed("Winter Squid"))
check(fpage.sub.text == "A fish of the waters  -  only in winter", "… a seasonal one says its season")
clickTab(ns.TAB.bestiary)
check(not fpage.shown and FieldJournalPage.shown, "the Bestiary tab hides them again")
FieldJournalFrame:Hide()

-- Their milestones, and the Atlas's zone pages.
check(
  ns.earnedMilestone("fish-first")
    and said("[First Catch]")
    and ns.earnedMilestone("herb-first")
    and said("[First Herb]"),
  "the first catch and the first herb are milestones, announced"
)
local function progress(id) return ns.milestoneById[id].progress() end
local done, need = progress("seasons")
check(
  not ns.earnedMilestone("seasons") and done == 1 and need == 2,
  "Every Season: the Winter Squid, the Summer Bass still to catch"
)
local elwynn = ns.milestoneById["herbs-1429"]
local d2, n2 = elwynn.progress()
check(
  elwynn
    and ns.milestoneVisible(elwynn)
    and d2 >= 1
    and n2 > d2
    and not ns.milestoneVisible(ns.milestoneById["herbs-1411"]),
  "every herb of a zone: shown once one is found there (Elwynn), hidden elsewhere (Durotar)"
)
local anyContinent = false
for _, m in ipairs(ns.milestones) do
  if m.id:find("^fish%-continent%-") and ns.milestoneVisible(m) then anyContinent = true end
end
check(anyContinent, "every fish of a continent's waters: shown once one is caught there")
linkHandlers.fieldjournal("fieldjournal:z1429")
local function atlasPair(label)
  for _, p in ipairs(ns.atlasPairs) do
    if p.shown and p.label.text == label then return p.value.text end
  end
end
check(
  atlasPair("Herbs")
    and atlasPair("Herbs"):find("Peacebloom", 1, true)
    and atlasPair("Herbs"):find("more to find", 1, true)
    and atlasPair("Fish")
    and atlasPair("Fish"):find("Raw Brilliant Smallfish", 1, true)
    and not atlasPair("Fish"):find("Raw Longjaw", 1, true),
  "a zone's Atlas page: the herbs and fish found there named, the rest counted"
)
FieldJournalFrame:Hide()

-- (auto loot or a fast-loot addon: the slots emptied before the window opens)
fishing = true
loot = { { link(6291, "Raw Brilliant Smallfish"), { "GameObject-0-1-0-0-35591-0000000009", 1 } } }
fire("LOOT_READY", true)
loot = {}
fire("LOOT_OPENED", true)
fire("LOOT_CLOSED")
fishing = false
check(fish(6291).n == 2, "a catch taken as looting begins, before auto loot empties the window")
loot = { { link(2447, "Peacebloom"), { "GameObject-0-1-0-0-1618-0000000009", 1 } } }
fire("LOOT_READY", true)
fire("LOOT_CLOSED")
check(bloom.gathered == 3, "… an herb too, the window never opened")
-- (one listener's error: reported, the others still hear the event)
local reported
errorHandler = function(e) reported = e end
local heard = false
ns.on("FJ_TEST_EVENT", function() error("a listener's fault") end)
ns.on("FJ_TEST_EVENT", function() heard = true end)
fire("FJ_TEST_EVENT")
errorHandler = function(e) error(e, 0) end
check(heard and reported and reported:find("a listener's fault"), "a listener's error is reported, the next still runs")
-- (/journal probe: the next loot window, as each event finds it)
SlashCmdList.FIELDJOURNAL("probe")
fishing = true
lootWindow({ { link(6291, "Raw Brilliant Smallfish"), { BOBBER, 1 } } })
fishing = false
check(
  said("LOOT_READY: 1 slots, fishing: Raw Brilliant Smallfish (GameObject)") and said("LOOT_CLOSED"),
  "/journal probe: the next loot window described, event by event"
)

-- ── the expeditions ──────────────────────────────────────────────────────────
-- Duskwood's riddles, solved where they lead (a gesture at a lonely post, a
-- sub-area, an unseen household, a watcher found by speaking to her) and its
-- quarry; a reading in the Barrens; a tomb found by arriving (never from a
-- taxi); a walking keeper found by targeting; a riddle of the night.
local function at(map, x, y, sub)
  state.map, state.x, state.y, state.sub = map, x, y, sub or ""
  fire("ZONE_CHANGED_NEW_AREA")
end
local function solvedRiddle(id) return ns.riddleSolved(id) end
check(
  ns.expeditionPrint("duskwood-naraxis", "npc", 574) == 2852124916,
  "the riddles' fingerprints are the build's (32-bit FNV-1a)"
)
check(
  ns.riddleName(ns.riddleById["duskwood-darkshire"]) == "Watcher Brownell",
  "… and their veiled names read as the build's"
)
local DATA = io.open(DIR .. (FOREVER and "Data_Forever.lua" or "Data_Classic.lua")):read("*a")
check(
  not DATA:find("Watcher Brownell", 1, true) and not DATA:find("74.6", 1, true),
  "… the data holds neither an answer's name nor its spot"
)
check(
  #ns.riddlesOf(1431) == 4 and #ns.riddlesOf(1453) == 3,
  "an Alliance reader: Duskwood's four riddles (Darkshire's and the Night Watch's too), Stormwind's three"
)
state.faction = "Horde"
check(
  #ns.riddlesOf(1431) == 2 and #ns.riddlesOf(1453) == 0,
  "… a Horde reader: two (none of the Alliance's town or of a watcher who attacks the Horde), and none in Stormwind"
)
state.faction = "Alliance"
-- A reading: a history book in Ratchet, read where it stands (never elsewhere,
-- never in combat).
at(1413, 0.50, 0.50)
fire("ITEM_TEXT_BEGIN")
check(not solvedRiddle("the-barrens-ratchet-book"), "a reading elsewhere solves nothing")
at(1413, 0.6194, 0.3867)
inCombat = true
fire("ITEM_TEXT_BEGIN")
inCombat = false
check(not solvedRiddle("the-barrens-ratchet-book"), "… nor one in combat")
fire("ITEM_TEXT_BEGIN")
local book = ns.riddleRecord("the-barrens-ratchet-book")
check(
  book
    and book.at
    and said(
      "a riddle read aright: |cffffd100|Hfieldjournal:xthe-barrens-ratchet-book|h[Exile of the High Elves]|h|r, The Barrens, with a gold seal"
    ),
  "the book read where it stands: solved, with a gold seal and a line in chat"
)
check(ns.earnedMilestone("riddle-first"), "… the first riddle's milestone")
local riddleToast, firstToast = toastOf("riddle", "the-barrens-ratchet-book"), toastOf("milestone", "riddle-first")
check(
  riddleToast
    and riddleToast.Title.text == "A riddle read aright"
    and riddleToast.Name.text == "Exile of the High Elves"
    and firstToast,
  "… a toast for the riddle, and the milestone's beside it, not in its place"
)
-- A gesture: the Night Watch's lonely post, after asking for the clue (the silver seal).
ns.takeHint("duskwood-callahan", 1)
check(state.popup == nil and ns.riddleRecord("duskwood-callahan").hints == 1, "a clue taken is kept, unsolved")
at(1431, 0.8192, 0.1969)
DoEmote("DANCE")
check(not solvedRiddle("duskwood-callahan"), "a gesture the story doesn't ask for solves nothing")
DoEmote("salute")
check(
  solvedRiddle("duskwood-callahan") and ns.riddleSeal(ns.riddleRecord("duskwood-callahan")) == "silver",
  "… the one it asks for does (any of its own), with a silver seal after the clue"
)
-- A sub-area with a gesture (Twilight Grove); a household no eye sees, by
-- looking harder.
at(1431, 0.46, 0.40, "Twilight Grove")
DoEmote("SLEEP")
check(solvedRiddle("duskwood-twilight-grove"), "a sub-area's riddle: its gesture made in it")
at(1431, 0.1921, 0.5376)
ns.expeditionAttempt()
check(not solvedRiddle("duskwood-unseen"), "the unseen household asks something: being there is not enough")
DoEmote("PEER")
check(solvedRiddle("duskwood-unseen"), "… looking harder solves it")
-- A watcher found only by speaking to her: standing beside her solves nothing.
check(not ns.earnedMilestone("expedition-1431"), "Duskwood's expedition not yet complete")
at(1431, 0.746, 0.454, "Darkshire")
ns.expeditionAttempt()
check(not solvedRiddle("duskwood-darkshire"), "a watcher of the town square: passing by her solves nothing")
state.target, state.near = 11040, true
ns.expeditionAttempt()
state.target = nil
check(
  solvedRiddle("duskwood-darkshire") and not ns.earnedMilestone("expedition-1431"),
  "… speaking to her does; Duskwood's expedition still waits for its quarry"
)
-- The hunt: Commander Felstrom's poster, tracked (its haunts on the map, the
-- gold seal lost), untracked, brought down.
linkHandlers.fieldjournal("fieldjournal:q771")
local function rowsOf()
  local out = {}
  for _, x in ipairs(ns.expeditionPairs) do
    if x.shown then out[x.label.text] = x.value.text end
  end
  return out
end
check(
  FieldJournalExpeditionsPage.title.text == "Commander Felstrom" and rowsOf()["Its haunts"] == "untracked",
  "a quarry's link opens its poster, untracked"
)
local poster = FieldJournalExpeditionsPage.parts.model
check(
  poster and poster.shown and poster.creature.fogFar == 0.1 and not FieldJournalExpeditionsPage.portrait.badge.shown,
  "… still at large: only its shape in the frame, its portrait in shadow"
)
local track = FieldJournalExpeditionsPage.buttons[1]
track.scripts.OnClick(track)
check(
  state.popup:find("gold seal") and ns.huntTarget() and ns.huntTarget().id == 771 and ns.huntRecord(771).tracked,
  "… tracked after the game's confirmation"
)
WorldMapFrame.mapID = 1431
ns.refreshWorldMapPins()
local haunt = mapProvider.circles[1]
check(haunt.shown and haunt.title == "Commander Felstrom", "… its haunts shaded on Duskwood's world map")
ns.setHuntTarget(nil)
ns.refreshWorldMapPins()
check(not mapProvider.circles[1].shown, "… and no longer once untracked")
kill(771)
check(
  ns.quarryDown(771)
    and ns.huntSeal(ns.huntRecord(771)) == "plain"
    and said(
      "a quarry brought down: |cffffd100|Hfieldjournal:q771|h[Commander Felstrom]|h|r, Duskwood, with a plain seal"
    ),
  "a quarry brought down as the Bestiary tells the kill: tracked once, a plain seal"
)
local quarryToast = toastOf("quarry", 771)
check(
  quarryToast and quarryToast.Title.text == "A quarry brought down" and quarryToast.Name.text == "Commander Felstrom",
  "… and its toast"
)
check(
  ns.earnedMilestone("expedition-1431") and said("[The Duskwood Expedition]") and ns.earnedMilestone("quarry-first"),
  "… Duskwood's expedition complete, and the first quarry's milestone"
)
-- A riddle rewritten after the expedition was earned (here: a record taken
-- away): its milestone withdrawn at the login, quietly; earned again once done.
local callahan = ns.expeditions().riddles["duskwood-callahan"]
ns.expeditions().riddles["duskwood-callahan"] = nil
local quietBefore = #printed
ns.checkMilestones(true)
check(
  not ns.earnedMilestone("expedition-1431") and #printed == quietBefore,
  "an expedition the riddles' changes left undone: its milestone withdrawn at the login, quietly"
)
ns.expeditions().riddles["duskwood-callahan"] = callahan
ns.checkMilestones()
check(ns.earnedMilestone("expedition-1431"), "… and earned again once its riddles are done")
-- A quarry slain before the journal kept the hunts (here: its record taken
-- away again): stamped quietly at the login.
ns.expeditions().hunts[771] = nil
local before = #printed
ns.expeditionsLogin()
check(
  ns.huntRecord(771).retro and ns.huntSeal(ns.huntRecord(771)) == "before" and #printed == before,
  "a quarry slain before the hunts were kept: stamped quietly, no seal"
)
-- A keeper who walks: Zixil, found by targeting him near (never too far).
at(1424, 0.10, 0.10)
state.target, state.near = 3537, false
ns.expeditionAttempt()
check(not solvedRiddle("hillsbrad-foothills-zixil"), "a walking keeper targeted from afar: not yet")
state.near = true
ns.expeditionAttempt()
check(solvedRiddle("hillsbrad-foothills-zixil"), "… targeted near him, wherever his road has taken him")
state.target = nil
-- Dun Morogh's practice range: ears minded beside the riflemen; and Fluffy,
-- settled wherever it has run to.
at(1426, 0.4066, 0.6488)
DoEmote("CHEER")
check(not solvedRiddle("dun-morogh-range"), "the practice range: cheering the riflemen is not what it asks")
DoEmote("COVEREARS")
check(solvedRiddle("dun-morogh-range"), "… minding one's ears beside them is")
at(1426, 0.64, 0.49)
state.target, state.near = 1352, true
DoEmote("SOOTHE")
state.target = nil
check(solvedRiddle("dun-morogh-fluffy"), "Fluffy, the rabbit Yarlyn chases round the ranch: calmed where it ran")
-- A place found by arriving: the Emperor's Tomb at Zul'Kunda, never from a
-- taxi flying over it; and, made a riddle of the night here (none of the
-- book's is one now), answering only after dark.
local tomb = ns.riddleById["stranglethorn-vale-emperors-tomb"]
at(1434, 0.247, 0.0893)
state.taxi = true
ns.expeditionAttempt()
check(not solvedRiddle(tomb.id), "a place flown over on a taxi: nothing")
state.taxi = false
tomb.night, state.hour = true, 12
ns.expeditionAttempt()
check(not solvedRiddle(tomb.id), "a night's riddle by day: nothing")
state.hour = 22
ns.expeditionAttempt()
check(solvedRiddle(tomb.id), "… by night, by being there: solved")
tomb.night, state.hour = nil, 12
-- Forever's own isle (Data_Forever alone): Zephras Isle's riddles and its
-- quarry, a creature the data doesn't know; the children in the tree, looked
-- at with them.
if FOREVER then
  check(
    #ns.riddlesOf(2521) == 4 and ns.quarryById[256028] and ns.quarryById[256028].name == "The Lost One",
    "Forever: Zephras Isle's four riddles, and its quarry, a creature of Forever's own"
  )
  local back = { state.map, state.x, state.y, state.sub }
  at(2521, 0.4165, 0.2328)
  DoEmote("WAVE")
  check(not solvedRiddle("zephras-isle-thendal-tree"), "… a gesture the children's riddle doesn't ask for: nothing")
  DoEmote("LOOK")
  check(solvedRiddle("zephras-isle-thendal-tree"), "… looking where they look, up the tree: solved")
  at(unpack(back))
else
  check(#ns.riddlesOf(2521) == 0 and not ns.quarryById[256028], "Classic: no Zephras Isle")
end
-- The map: a riddle's place shaded on the world map once asked for.
state.popup = nil
ns.takeHint("elwynn-forest-cats", 2)
check(state.popup == nil, "(a hint taken from the code asks nothing)")
WorldMapFrame.mapID = 1429
ns.refreshWorldMapPins()
local circle = mapProvider.circles and mapProvider.circles[1]
check(
  circle and circle.shown and circle.text == ns.riddleById["elwynn-forest-cats"].verse[1],
  "the map's hint: a circle on the zone's world map, the riddle's first line on it"
)
-- The book: the Expeditions tab, a riddle's page, the seals and the margin.
linkHandlers.fieldjournal("fieldjournal:xthe-barrens-ratchet-book")
local function pageRows()
  local out = {}
  for _, x in ipairs(ns.expeditionPairs) do
    if x.shown then out[x.label.text] = x.value.text end
  end
  return out
end
local parts = FieldJournalExpeditionsPage.parts
local function paragraphs()
  local out = {}
  for _, p in ipairs(FieldJournalExpeditionsPage.paragraphs) do
    if p.shown then table.insert(out, p.text) end
  end
  return table.concat(out, "\n")
end
check(
  FieldJournalFrame.selectedTab == ns.TAB.expeditions
    and FieldJournalExpeditionsPage.title.text == "Exile of the High Elves"
    and parts.verse.shown
    and parts.seal.shown
    and parts.seal.name.text == "The gold seal"
    and parts.seal.detail.text:find("^Read from the verse alone, on ")
    and parts.margin.shown
    and parts.margin.text.text == ns.riddleMargin(ns.riddleById["the-barrens-ratchet-book"])
    and paragraphs():find(ns.riddleNote(ns.riddleById["the-barrens-ratchet-book"]), 1, true),
  "a riddle's link opens its page: its verse, its answer, the gold seal, the note and the margin"
)
local header = FieldJournalExpeditionsPage.portrait
check(
  rawget(header.tex, "display") == nil and header.badge.shown and header.badge.tex.texture == ns.SEAL_ICON.gold,
  "… its picture what it led to (a book read), the gold seal a medal on it, not in its place"
)
ns.openRiddle("duskwood-callahan")
check(
  rawget(header.tex, "display") == ns.riddleFace(ns.riddleById["duskwood-callahan"]) and header.tex.display > 0,
  "… a keeper's riddle: the keeper's face, once solved"
)
local rows = pageRows()
check(
  parts.seal.name.text == "The silver seal"
    and not parts.margin.shown
    and paragraphs():find("Only a gold seal opens the margin", 1, true)
    and rows["The clue"],
  "… a silver seal's page: the clue it took, the margin closed"
)
ns.openRiddle("elwynn-forest-cats")
rows = pageRows()
local TIERS = { near = "Near the road", off = "Off the road", hidden = "Hidden", town = "In town" }
check(
  FieldJournalExpeditionsPage.title.text == TIERS[ns.riddleById["elwynn-forest-cats"].tier],
  "an unsolved riddle's page: its tier, never its answer"
)
check(rows["The map"] and rows["The map"]:find("is shaded"), "… the map asked for")
local listed = {}
for _, r in ipairs(ns.expeditionRows) do
  if r.shown then listed[r.text.text] = true end
end
check(listed.Duskwood and listed["Watcher Callahan"], "the list: the zones entered, their riddles solved by name")
-- Asking from the page: the game's confirmation, then the clue.
local vigil = ns.riddleById["elwynn-forest-heroes-vigil"]
ns.openRiddle(vigil.id)
local ask = FieldJournalExpeditionsPage.buttons[1]
check(ask and ask.shown, "an unsolved riddle's page offers its clue")
ask.scripts.OnClick(ask)
check(
  state.popup and state.popup:find("gold seal") and ns.riddleRecord(vigil.id).hints == 1,
  "… asked for after the game's confirmation"
)
-- Pinned to the screen: a card of its own, dragged anywhere, closed by its cross.
local pinIt = FieldJournalExpeditionsPage.buttons[2]
check(pinIt.shown and pinIt.text == "Pin to the screen", "an unsolved riddle's page offers to pin it to the screen")
pinIt.scripts.OnClick(pinIt)
local pinCard = FieldJournalPinnedCard
check(
  ns.pinned() == vigil.id
    and pinCard.shown
    and pinCard.verse.text == table.concat(vigil.verse, "\n")
    and pinCard.extra.text:find("^The clue: "),
  "… pinned: its card shows the verse and the clue taken"
)
pinCard.scripts.OnDragStop(pinCard)
check(ns.expeditions().pinAt ~= nil, "… dragged, it stays where it was left")
check(FieldJournalExpeditionsPage.buttons[2].text == "Unpin from the screen", "… and the page offers to unpin it")
pinCard.close.scripts.OnClick(pinCard.close)
check(not pinCard.shown and ns.pinned() == nil, "… closed by its cross, unpinned")
-- A zone's page: its riddles in words, a card for each riddle and its
-- quarry, a click on one opens it; its map, where each riddle was read.
for _, r in ipairs(ns.expeditionRows) do
  if r.shown and r.zone == 1431 then r.scripts.OnClick(r) end
end
local cards = {}
for _, c in ipairs(FieldJournalExpeditionsPage.cards) do
  if c.shown then cards[c.name.text] = c end
end
check(
  FieldJournalExpeditionsPage.title.text == "Duskwood"
    and FieldJournalExpeditionsPage.note.text:find("^Duskwood keeps %a+ riddles for you")
    and cards["Watcher Callahan"]
    and cards["Commander Felstrom"],
  "a zone's page: its riddles in words, a card for each riddle and its quarry"
)
local map = FieldJournalExpeditionsPage.map
check(map.shown and map.pins[1] and map.pins[1].shown, "… its map, where each riddle was read")
cards["Commander Felstrom"].scripts.OnClick(cards["Commander Felstrom"])
check(
  FieldJournalExpeditionsPage.title.text == "Commander Felstrom"
    and FieldJournalExpeditionsPage.parts.model.shown
    and rawget(FieldJournalExpeditionsPage.parts.model.creature, "fogFar") == nil
    and FieldJournalExpeditionsPage.parts.seal.name.text == "No seal",
  "… a card opens its page: the quarry's poster, brought down, the creature itself turning in its frame"
)
FieldJournalFrame:Hide()
SlashCmdList.FIELDJOURNAL("where")
check(said("(map 1434): 24.70, 8.93."), "/journal where tells the map and the position")

SlashCmdList.FIELDJOURNAL("reset yes")
check(
  next(FieldJournalChar.creatures) == nil and FieldJournalChar.guid == PLAYER,
  "/journal reset yes starts the journal over"
)
-- Settings are each character's own (the kit's profiles); the welcome page
-- offers them once per character, and another character's to take.
local P = ns.profiles
check(
  P:key() == "Thorin - Nightslayer" and FieldJournalSettings.profiles["Thorin - Nightslayer"],
  "settings: this character's own profile"
)
fire("PLAYER_ENTERING_WORLD", true, false)
local W = ns.welcome
check(W.frame and W.frame.shown and #W.rows == 6, "the first login: the welcome page and its six choices")
local soundRow = W.rows[2]
check(soundRow.select and soundRow.select:GetValue() == 3175, "… the trophy's sound in a select, as it is")
soundRow.select.scripts.OnClick(soundRow.select)
soundRow.select.rows[2].scripts.OnClick(soundRow.select.rows[2])
check(ns.option("sound") == 878 and lastSound == 878, "… a sound chosen there is heard and kept")
W.rows[4].scripts.OnClick(W.rows[4])
check(ns.option("worldMapPins") == false and not W.rows[4].box:GetChecked(), "… a box's words untick it")
W.frame:Hide()
fire("PLAYER_ENTERING_WORLD", true, false)
check(not W.frame.shown and ns.option("welcomed"), "… seen once")
FieldJournalSettings.profiles["Brann - Nightslayer"] = { chat = false, sound = 0, minimapAngle = 90 }
SlashCmdList.FIELDJOURNAL("welcome")
local pick = W.picker.select
check(pick.rows[1].text:GetText() == "Brann - Nightslayer", "… another character of this game, in its select")
pick.rows[1].scripts.OnClick(pick.rows[1])
W.picker.copy.scripts.OnClick(W.picker.copy)
check(
  ns.option("chat") == false
    and ns.option("sound") == 0
    and ns.option("minimapAngle") == 90
    and ns.option("worldMapPins") == true,
  "… its choices copied (what it lacks: the defaults)"
)
local code = P:export()
check(code == "FJ1:c0:s0:m1:w1:t1:h0:a90", "… a code for them: " .. code)
SlashCmdList.FIELDJOURNAL("import FJ1:c1:s3175")
check(ns.option("chat") and ns.option("sound") == 3175 and ns.option("minimapAngle") == 90, "… /journal import CODE")
check(not P:import("LC1:c1") and ns.option("chat"), "… another addon's code refused")
local copyFrom = panel.settings.FIELDJOURNAL_COPYFROM
check(
  copyFrom and copyFrom.options()[2].value == "Brann - Nightslayer",
  "… the Options page offers the other characters too"
)
W.frame:Hide()

io.write(FOREVER and "all good (Forever)\n" or "all good\n")
