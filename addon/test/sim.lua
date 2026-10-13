-- Runs the addon against a fake WoW API and replays a dwarf's first hunts.
--   luajit addon/test/sim.lua              (from the repo root): Classic
--   FOREVER=1 luajit addon/test/sim.lua    the same on Forever's client: no
--                                          combat log (kills from PARTY_KILL), secret values
local DIR = "addon/Yonder/"
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
  if u == "npc" and state.npc then return creature(state.npc) end
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
      -- (a texture's tint and greying: a ring's colour)
      if k == "SetVertexColor" then
        return function(self, r, g, b) self.vertex = { r, g, b } end
      end
      if k == "SetDesaturated" then
        return function(self, v) self.desaturated = v end
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
      if k == "SetFrameLevel" then
        return function(self, v) self.level = v end
      end
      if k == "GetFrameLevel" then
        return function(self) return rawget(self, "level") or 1 end
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
-- The minimap: its zoom (0, the widest, by default), a mask for what is drawn
-- on it; whether the reader is indoors, where they face, the setting that
-- turns the minimap with them; Forever's span (the game's own, in yards).
Minimap.GetZoom = function() return state.zoom or 0 end
Minimap.CreateMaskTexture = function() return ui() end
function IsIndoors() return state.indoors == true end
function GetPlayerFacing() return state.facing or 0 end
local cvars = { rotateMinimap = "0" }
function GetCVar(k) return cvars[k] end
if FOREVER then C_Minimap = { GetViewRadius = function() return 200 end } end
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
-- The levels it gives its layers (the game's: its places explored at 2001,
-- its quests' areas at 2004, its points of interest at 2016).
local mapLevels =
  { PIN_FRAME_LEVEL_MAP_EXPLORATION = 2001, PIN_FRAME_LEVEL_QUEST_BLOB = 2004, PIN_FRAME_LEVEL_AREA_POI = 2016 }
WorldMapFrame.GetPinFrameLevelsManager = function()
  return { GetValidFrameLevel = function(_, kind) return mapLevels[kind] or 2000 end }
end

-- The game's alert container: a frame joins its stack, and it places those
-- shown, each on top of the one under it (AlertFrameAutoAnchoredMixin's way).
AlertFrame = { subs = {}, updates = 0 }
function AlertFrame:AddAutoAnchoredSubSystem(f)
  f:SetAlertContainer(self)
  table.insert(self.subs, f)
end
function AlertFrame:UpdateAnchors()
  self.updates = self.updates + 1
  local rel = self
  for _, f in ipairs(self.subs) do
    if f:IsShown() then
      f:ClearAllPoints()
      f:SetPoint("BOTTOM", rel, "TOP", 0, 0)
      f:OnAlertAnchorUpdated()
      rel = f
    end
  end
end
C_XMLUtil = { GetTemplateInfo = function() return {} end }
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
assert(loadfile(DIR .. (FOREVER and "Data_Forever.lua" or "Data_Classic.lua")))("Yonder", ns)
-- The files in the order of the game's own TOC (its data file loaded above).
for line in io.lines(DIR .. (FOREVER and "Yonder_Camelot.toc" or "Yonder_Vanilla.toc")) do
  -- (the language file as the game picks it, [TextLocale]: English here)
  local f = line:gsub("%[TextLocale%]", "enUS"):match("^([%w_]+%.lua)%s*$")
  if f and not f:match("^Data_") then assert(loadfile(DIR .. f))("Yonder", ns) end
end
local D = ns.data
-- The banners shown (what each said, its kind and id), and the kit's banners
-- themselves, to clear them between scenes.
local toasted, banners = {}, nil
do
  local make = ns.kit.banners
  ns.kit.banners = function(o)
    banners = make(o)
    local show = banners.show
    banners.show = function(self, b)
      table.insert(toasted, b)
      return show(self, b)
    end
    return banners
  end
end
-- A tab of the book clicked, by its name (ns.TAB).
local function clickTab(n)
  local tab = _G["YonderFrameTab" .. n]
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
local function rec(id) return YonderChar.creatures[id] end
local function target(id)
  state.target = id
  fire("PLAYER_TARGET_CHANGED")
end

-- ── a session ────────────────────────────────────────────────────────────────
YonderChar = { guid = "Player-6113-0DEAD000", creatures = { [1131] = { name = "Winter Wolf" } }, families = {} }
fire("PLAYER_LOGIN")
check(YonderChar.guid == PLAYER and not rec(1131), "a new character named like a deleted one starts a fresh journal")
check(
  said("the journal is empty for now. Type /yonder or click the button by the minimap to open the journal."),
  "a line in chat at login: an empty journal, how to open it"
)
ns.setOption("minimapHidden", true)
ns.loginLine()
check(
  printed[#printed] == "|cffc9a227Yonder:|r the journal is empty for now. Type /yonder to open the journal.",
  "… which leaves out the minimap's button when it's hidden"
)
ns.setOption("minimapHidden", false)
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

local function seen(id) return YonderChar.seen and YonderChar.seen[id] end
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
  said("|cffffd100|Hyonder:c1131|h[Winter Wolf]|h|r recorded (Wolves, a new family).") and sounds == 0,
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
  said("a trophy: |cffffd100|Hyonder:c1132|h[Timber]|h|r") and played[3175],
  "… announced in chat, with the trophy sound"
)
check(
  ns.earnedMilestone("trophies-1")
    and said("you have earned the milestone |cffffd100|Hyonder:mtrophies-1|h[First Trophy]|h|r!")
    and played[12891],
  "… and the first trophy earns a milestone, with the game's achievement fanfare and a chat line"
)
local function toastOf(kind, id)
  for _, b in ipairs(toasted) do
    if b.kind == kind and b.id == id then return b end
  end
end
-- The banner card showing a title, if any.
local function bannerShowing(title)
  for i = 1, 2 do
    local f = _G["YonderBanner" .. i]
    if f and f.shown and f.title.text == title then return f end
  end
end
local trophyToast, trophyCard = toastOf("milestone", "trophies-1"), bannerShowing("First Trophy")
check(
  trophyToast and trophyToast.title == "First Trophy" and trophyCard and trophyCard.joined and AlertFrame.updates > 0,
  "… and its banner, among the game's own alerts"
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
  local saved = YonderChar
  YonderChar = {
    guid = PLAYER,
    creatures = { [1131] = { name = "Winter Wolf", slain = 4 }, [1135] = { name = "Old Sighting" } },
    families = { [ns.familyKey(1131)] = { at = 1 }, ["only-met"] = { at = 2 } },
  }
  fire("PLAYER_LOGIN")
  local j = YonderChar
  check(
    j.creatures[1131]
      and not j.creatures[1135]
      and j.seen[1135]
      and j.families[ns.familyKey(1131)]
      and not j.families["only-met"]
      and j.killRule,
    "an older journal: creatures never slain become sightings, their families with them, once"
  )
  YonderChar = saved
  fire("PLAYER_LOGIN")
end

-- The families met are kept by their id and rebuilt from the creatures at
-- each login: an older journal's places in the data file's list go, a family kept
-- by its id keeps its date, and one a creature has moved into (the Stagwings,
-- hippogryphs once filed with the grazers) comes, dated by its first kill.
do
  local saved = YonderChar
  YonderChar = {
    guid = PLAYER,
    killRule = true,
    creatures = {
      [1131] = { name = "Winter Wolf", slain = 4, firstSlain = { at = 100, level = 6 } },
      [5304] = { name = "Frayfeather Stagwing", slain = 1, firstSlain = { at = 200, level = 44 } },
    },
    families = { wolves = { at = 50, level = 5 }, [3] = { at = 1 }, [17] = { at = 2 } },
  }
  fire("PLAYER_LOGIN")
  local f = YonderChar.families
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
  YonderChar = saved
  fire("PLAYER_LOGIN")
end

-- A journal kept under the addon's old name (Explorer's Field Journal): its
-- saved files copied to Yonder's set the old globals; the login takes them,
-- once, under the new names. Another addon's FieldJournalDB stays as it is.
do
  local saved, settings = YonderChar, YonderSettings
  YonderChar, YonderSettings = nil, nil
  FieldJournalChar = {
    guid = PLAYER,
    killRule = true,
    creatures = { [1131] = { name = "Winter Wolf", slain = 2 } },
    families = {},
  }
  FieldJournalSettings = { profiles = {} }
  FieldJournalDB = { theirs = true }
  printed = {}
  fire("PLAYER_LOGIN")
  check(
    YonderChar
      and YonderChar.creatures[1131].slain == 2
      and FieldJournalChar == nil
      and FieldJournalSettings == nil
      and type(YonderSettings) == "table"
      and FieldJournalDB.theirs,
    "a journal kept under the old name (the handover's, or its files copied) is taken at login; another addon's left alone"
  )
  check(printed[1] and printed[1]:find("now called Yonder", 1, true), "… and the chat says so, and why")
  check(
    printed[2]
      == "|cffc9a227Yonder:|r 1 creature in the Bestiary. Type /yonder or click the button by the minimap to open the journal.",
    "… then the login's line: what the journal holds, how to open it"
  )
  printed = {}
  fire("PLAYER_LOGIN")
  check(not said("now called Yonder"), "… once")
  FieldJournalDB = nil
  -- the old addon itself still running beside it: turned off, for every
  -- character, and said
  local titles, running, off = { FieldJournal = "Explorer's Field Journal" }, { FieldJournal = true }, {}
  C_AddOns = {
    GetAddOnMetadata = function(name, key) return key == "Title" and titles[name] or nil end,
    IsAddOnLoaded = function(name) return running[name] == true end,
    DisableAddOn = function(name, character) off[name] = character or "all" end,
  }
  printed = {}
  fire("PLAYER_LOGIN")
  check(
    off.FieldJournal == "all" and said("still running beside it: it is turned off"),
    "the old name still running beside it: turned off for every character, and said"
  )
  titles.FieldJournal, printed, off = "Field Journal", {}, {}
  fire("PLAYER_LOGIN")
  check(not said("still running") and not off.FieldJournal, "… never another addon of that folder")
  titles.FieldJournal, running.FieldJournal, printed = "Explorer's Field Journal", nil, {}
  fire("PLAYER_LOGIN")
  check(not said("still running") and not off.FieldJournal, "… nor the old one installed but not running")
  C_AddOns = nil
  YonderChar, YonderSettings = saved, settings
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
local atlas = YonderChar.atlas
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
  atlas.zones[1429] and said("|Hyonder:z1429|h[Elwynn Forest]|h|r added to the atlas."),
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
local saved = YonderChar.atlas
YonderChar.atlas = {
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
YonderChar.achievements["explore-1450"] = { at = clock, level = 3, retro = true }
fire("PLAYER_ENTERING_WORLD")
local migrated = YonderChar.atlas
check(
  not migrated.zones[1450] and not YonderChar.achievements["explore-1450"],
  "an atlas from 0.3.0 loses the zones it never discovered, and their milestones"
)
check(
  migrated.zones[1426].places[key(dun[1])].retro and migrated.zones[1426].places[key(dun[2])].at,
  "… and keeps what is truly discovered"
)
YonderChar.atlas = saved
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
check(
  marks["Died here"].level == mapLevels.PIN_FRAME_LEVEL_AREA_POI,
  "… at the level of the game's points of interest, above the places explored and the circles"
)
WorldMapFrame.mapID = 1426
ns.refreshWorldMapPins()
local shownPins = 0
for _, p in ipairs(mapProvider.pins) do
  if p.shown then shownPins = shownPins + 1 end
end
check(shownPins == 0, "… and only there")

-- ── the book ─────────────────────────────────────────────────────────────────
SlashCmdList.YONDER("")
check(YonderFrame.shown and YonderFrame.selectedTab == ns.TAB.expeditions, "/yonder opens the book, at the Expeditions")
clickTab(ns.TAB.bestiary)
local creatures, families, slain = ns.counts()
check(
  YonderFrame.count.text == ("%d creatures, %d families, %d slain"):format(creatures, families, slain),
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
local filter = YonderFrame.filter
check(filter.shown and filter.text:GetText() == "Sorted by name", "the Bestiary's select: by name at first")
local function order()
  local out = {}
  for _, e in ipairs(ns.pageEntries) do
    if e.shown then table.insert(out, e.id) end
  end
  return out
end
local slainBefore = YonderChar.creatures[1133].slain
YonderChar.creatures[1133].slain = 99
filter.scripts.OnClick(filter)
filter.rows[2].scripts.OnClick(filter.rows[2])
ns.openFamily(D.creatures[1131])
check(order()[1] == 1133 and filter.text:GetText() == "The most slain first", "… the most slain first, chosen")
filter.rows[1].scripts.OnClick(filter.rows[1])
YonderChar.creatures[1133].slain = slainBefore
shown("Winter Wolf").scripts.OnClick(shown("Winter Wolf"))
local record = {}
for _, p in ipairs(ns.pagePairs) do
  if p.shown then record[p.label.text] = p.value.text end
end
check(
  YonderPage.title.text == "Winter Wolf"
    and YonderPage.portrait.display == D.models[1131]
    and YonderPage.sub.text:find("Wolves", 1, true),
  "a creature has its own page: portrait, name, family"
)
check(
  record["First met"]
    and record["Where"]:find("Coldridge Pass", 1, true)
    and record["Slain"] == tostring(rec(1131).slain),
  "… and its record: when and where it was met, its kills"
)
local creatureFigures = {}
for _, t in ipairs(YonderPage.tiles) do
  if t.shown then creatureFigures[t.label.text] = t.value.text end
end
check(
  creatureFigures.slain == tostring(rec(1131).slain)
    and YonderPage.modelFrame.shown
    and YonderPage.modelFrame.creature.display == D.models[1131],
  "… its figures, and the creature itself turning in its frame"
)
check(
  ns.pageLoot[1] and ns.pageLoot[1].shown and ns.pageLoot[2].shown and not ns.pageLoot[3],
  "… and what it gave, an icon per item"
)
check(not ns.pageEntries[1].shown, "… without the family's entries")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(YonderPage.title.text == "Wolves" and shown("Winter Wolf"), "the family's row opens its page again")
shown("Wolves").scripts.OnClick(shown("Wolves"))
check(not shown("Winter Wolf"), "… and, once open, folds it")
wolves[1132].scripts.OnClick(wolves[1132])
check(YonderPage.title.text:find("^Timber"), "an entry on a family's page opens the creature's")
YonderSearch:SetText("timber")
ns.refresh()
check(
  shown("Wolves") and not shown("Ice Trolls") and not shown("Winter Wolf"),
  "search finds a family by a creature's name, with just the creatures found"
)
YonderSearch:SetText("")
ns.refresh()
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(not shown("Wolves") and YonderChar.collapsed.beasts, "a click on a type folds it")
shown("Beasts").scripts.OnClick(shown("Beasts"))
check(shown("Wolves"), "… and unfolds it")
YonderFrame:Hide()
linkHandlers.yonder("yonder:c1132")
check(
  YonderFrame.shown and YonderPage.title.text:find("^Timber"),
  "a link in chat opens the book at the creature's page"
)
check(
  YonderPage.portrait.ring.desaturated and YonderPage.portrait.ring.vertex[1] == 1,
  "… Timber, a rare: its ring silver, as the target frame marks a rare"
)
linkHandlers.yonder("yonder:murlocs")
check(
  YonderPage.title.text == "Murlocs",
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
YonderFrame:Hide()
linkHandlers.yonder("yonder:z1426")
local atlasRecord = {}
for _, p in ipairs(ns.atlasPairs) do
  if p.shown then atlasRecord[p.label.text] = p.value.text end
end
check(
  YonderFrame.selectedTab == ns.TAB.atlas and YonderAtlasPage.title.text == "Dun Morogh" and YonderAtlasPage.map.shown,
  "a zone's link opens the Atlas at its page, with its map"
)
check(
  YonderAtlasPage.note.shown and YonderAtlasPage.note.text:find("^Snow, stone and dwarves"),
  "… the surveyor's note"
)
local placeChips = {}
for _, b in ipairs(YonderAtlasPage.chipPool) do
  if b.shown then placeChips[b.text.text] = b end
end
check(
  placeChips[dun[1][1]] and placeChips[dun[2][1]] and not placeChips[dun[3][1]],
  "… the places explored, by name, none other"
)
local figures = {}
for _, t in ipairs(YonderAtlasPage.tiles) do
  if t.shown then figures[t.label.text] = t.value.text end
end
check(figures["places found"] == ("2/%d"):format(#dun), "… and its figures: the places explored, the visits")
placeChips[dun[1][1]].scripts.OnClick(placeChips[dun[1][1]])
check(YonderAtlasPage.map.pick.shown, "… a place's name clicked: its area outlined on the map")
check(YonderAtlasPage.sub.text:find(("2 of %d places explored"):format(#dun), 1, true), "… and how many remain")
check(
  YonderFrame.filter.shown and YonderFrame.filter.text:GetText() == "Every land" and #YonderFrame.filter.options >= 2,
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
  local f = YonderFrame.filter
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
  YonderAtlasPage.map.pick.shown and discoveredLine and discoveredLine:find("level 3", 1, true),
  "a click on a place picks it out on the zone's map, with the day and level it was found"
)
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
zoneRows["Dun Morogh"].scripts.OnClick(zoneRows["Dun Morogh"])
local placeShown = false
for _, r in ipairs(ns.atlasRows) do
  if r.shown and r.kind == "place" and r.zone == 1426 then placeShown = true end
end
check(not placeShown and YonderChar.atlasOpen[1426] == false, "the open zone's row folds it")
YonderSearch:SetText(dun[2][1]:sub(1, 5))
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do
  if r.shown then zoneRows[r.text.text] = r end
end
check(
  zoneRows["Dun Morogh"] and zoneRows[dun[2][1]] and not zoneRows.Durotar and not zoneRows.Travels,
  "search finds places by name, with their zone"
)
YonderSearch:SetText("")
ns.refresh()
zoneRows = {}
for _, r in ipairs(ns.atlasRows) do
  if r.shown then zoneRows[r.text.text] = r end
end
zoneRows.Travels.scripts.OnClick(zoneRows.Travels)
check(YonderAtlasPage.title.text == "Travels", "the travels page sums them up")
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
YonderFrame:Hide()
linkHandlers.yonder("yonder:mtrophies-1")
local row
for _, r in ipairs(ns.milestoneRows) do
  if r.shown and r.id == "trophies-1" then row = r end
end
check(
  YonderFrame.shown
    and YonderFrame.selectedTab == ns.TAB.milestones
    and row
    and row.status.text:find("^Level")
    and row.picture.ring.vertex[2] == ns.kit.RINGS.gold[1][2]
    and not row.picture.ring.desaturated,
  "a milestone's link opens the Milestones tab, the milestone earned with its level, its ring gold"
)
check(YonderFrame.count.text == ("%d of %d milestones"):format(ns.milestoneCount()), "… which counts them")
clickTab(ns.TAB.bestiary)
check(
  YonderFrame.selectedTab == ns.TAB.bestiary and YonderPage and shown("Wolves"),
  "the Bestiary tab brings the book back"
)
-- A journal from before milestones: what it deserves is recorded quietly.
YonderChar.achievements = nil
printed = {}
ns.checkMilestones(true)
check(ns.earnedMilestone("trophies-1").retro and #printed == 0, "milestones already deserved are recorded quietly")

-- Tooltip hints.
local function hover(id)
  tipLines, tipUnit, state.mouseover = {}, "mouseover", id
  tipHooks.OnTooltipSetUnit(GameTooltip)
  return table.concat(tipLines, "|")
end
check(hover(1123) == "Yonder: not yet recorded", "a creature not yet met says so on its tooltip")
check(hover(1124) == "", "… but not one that can't be fought (a foe still friendly)")
check(hover(1132):find("1 slain (trophy)", 1, true), "… one met tells how many were slain")
if FOREVER then
  secrets[creature(1123)] = true
  check(hover(1123) == "", "Forever: a secret creature id gets no hint, and no error")
  secrets[creature(1123)] = nil
end

tipLines = {}
YonderMinimapButton.scripts.OnEnter(YonderMinimapButton)
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
local fish = function(id) return YonderChar.fish and YonderChar.fish[id] end
local plant = function(id) return YonderChar.plants and YonderChar.plants[id] end
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
  said("a new catch: |cffffd100|Hyonder:f6291|h[Raw Brilliant Smallfish]|h|r"),
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
check(said("a new herb: |cffffd100|Hyonder:h2447|h[Peacebloom]|h|r"), "… announced in chat")
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
YonderFrame:Show()
clickTab(ns.TAB.fish)
fpage = YonderFloraPage
check(
  YonderFrame.selectedTab == ns.TAB.fish
    and fpage.shown
    and fpage.title.text == "The catch so far"
    and YonderFrame.count.text == "3 kinds of fish, 4 caught",
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
-- A page's figures (by their label) and names to pick.
local function figureNamed(label)
  for _, t in ipairs(fpage.tiles) do
    if t.shown and t.label.text == label then return t.value.text end
  end
end
local function chipNamed(text)
  for _, b in ipairs(fpage.chipPool) do
    if b.shown and b.text.text == text then return b end
  end
end
check(
  fpage.title.text == "Catfish"
    and figureNamed("the heaviest") == "32 lb"
    and figureNamed("caught") == "2"
    and chipNamed("Westfall")
    and pairNamed("Where") == "Elwynn Forest (2)",
  "a kind's page: its figures (the catches, the heaviest), where it bites (the data), where you caught it"
)
local westfall = chipNamed("Westfall")
westfall.scripts.OnClick(westfall)
check(
  YonderFrame.selectedTab == ns.TAB.atlas and YonderAtlasPage.title.text == "Westfall",
  "… a zone where it bites opens its Atlas page"
)
clickTab(ns.TAB.fish)
rowNamed("Oily Blackmouth").scripts.OnClick(rowNamed("Oily Blackmouth"))
check(
  figureNamed("from schools") == "1" and figureNamed("day / night") == "0 / 1" and fpage.sub.text == "A reagent",
  "… from a school, by night"
)
clickTab(ns.TAB.plants)
check(
  YonderFrame.selectedTab == ns.TAB.plants
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
    and figureNamed("gathered") == "2"
    and figureNamed("looted") == "1"
    and pairNamed("First"):find("(gathered)", 1, true),
  "an herb's page: its rank, how it was taken"
)
check(
  fpage.note.shown and fpage.note.text == table.concat(D.flora.herbs[2447].note, "\n\n"),
  "… and the naturalist's note"
)
YonderFrame:Hide()
linkHandlers.yonder("yonder:f6291")
check(
  YonderFrame.shown and YonderFrame.selectedTab == ns.TAB.fish and fpage.title.text == "Raw Brilliant Smallfish",
  "a catch's link opens its page"
)
linkHandlers.yonder("yonder:h3820")
check(YonderFrame.selectedTab == ns.TAB.plants and fpage.title.text == "Stranglekelp", "an herb's link opens its page")
clickTab(ns.TAB.fish)
fishing = true
lootWindow({ { link(13755, "Winter Squid"), { BOBBER, 1 } } })
fishing = false
check(rowNamed("Winter Squid"), "a new catch shows in the open tab at once")
rowNamed("Winter Squid").scripts.OnClick(rowNamed("Winter Squid"))
check(fpage.sub.text == "A fish of the waters  -  only in winter", "… a seasonal one says its season")
-- A character who never fished: the Fish tab is empty, never its herbs.
do
  local caught = YonderChar.fish
  YonderChar.fish = nil
  clickTab(ns.TAB.plants)
  clickTab(ns.TAB.fish)
  check(
    fpage.title.text == "The catch so far"
      and YonderFrame.count.text == "0 kinds of fish, 0 caught"
      and not rowNamed("Peacebloom")
      and not rowNamed("Stranglekelp"),
    "a character with herbs and no fish: the Fish tab shows no herb"
  )
  YonderChar.fish = { [6291] = caught[6291] }
  clickTab(ns.TAB.plants)
  clickTab(ns.TAB.fish)
  check(YonderFrame.count.text == "1 kind of fish, 1 caught", "… one kind is one kind")
  YonderChar.fish = caught
end
clickTab(ns.TAB.bestiary)
check(not fpage.shown and YonderPage.shown, "the Bestiary tab hides them again")
YonderFrame:Hide()

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
linkHandlers.yonder("yonder:z1429")
local found, foundText = {}, {}
for _, b in ipairs(YonderAtlasPage.itemPool) do
  if b.shown then found[b.name] = true end
end
for _, p in ipairs(YonderAtlasPage.paragraphs) do
  if p.shown then table.insert(foundText, p.text) end
end
foundText = table.concat(foundText, "\n")
check(
  found.Peacebloom
    and foundText:find("more herbs to find here", 1, true)
    and found["Raw Brilliant Smallfish"]
    and not found["Raw Longjaw Mud Snapper"],
  "a zone's Atlas page: the herbs and fish found there as their icons, the rest counted"
)
local expeditionCard
for _, c in ipairs(YonderAtlasPage.cards) do
  if c.shown and c.name.text == "The Elwynn Forest Expedition" then expeditionCard = c end
end
check(
  expeditionCard and expeditionCard.facts.text:find("done"),
  "… its expedition, as a card, and how much of it is done"
)
expeditionCard.scripts.OnClick(expeditionCard)
check(
  YonderFrame.selectedTab == ns.TAB.expeditions and YonderExpeditionsPage.title.text == "Elwynn Forest",
  "… a click opens the expedition's own page"
)
YonderFrame:Hide()

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
-- (/yonder probe: the next loot window, as each event finds it)
SlashCmdList.YONDER("probe")
fishing = true
lootWindow({ { link(6291, "Raw Brilliant Smallfish"), { BOBBER, 1 } } })
fishing = false
check(
  said("LOOT_READY: 1 slots, fishing: Raw Brilliant Smallfish (GameObject)") and said("LOOT_CLOSED"),
  "/yonder probe: the next loot window described, event by event"
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
      "a riddle read aright: |cffffd100|Hyonder:xthe-barrens-ratchet-book|h[Exile of the High Elves]|h|r, The Barrens, with a gold seal"
    ),
  "the book read where it stands: solved, with a gold seal and a line in chat"
)
check(ns.earnedMilestone("riddle-first"), "… the first riddle's milestone")
local riddleToast, firstToast = toastOf("riddle", "the-barrens-ratchet-book"), toastOf("milestone", "riddle-first")
check(
  riddleToast
    and riddleToast.kicker == "A riddle read aright"
    and riddleToast.title == "Exile of the High Elves"
    and riddleToast.medal
    and firstToast,
  "… a banner for the riddle, its seal a medal on it, and the milestone's beside it, not in its place"
)
-- Shown, among the game's alerts; a click opens the riddle, the cross closes it.
banners:clear()
ns.toast("riddle", "the-barrens-ratchet-book")
local card = YonderBanner1
check(
  card.shown and card.joined and card.title.text == "Exile of the High Elves" and card.medal.shown,
  "… shown among the game's alerts"
)
card.close.scripts.OnClick(card.close)
check(not card.shown, "… closed by its cross")
ns.toast("riddle", "the-barrens-ratchet-book")
YonderFrame:Hide()
card.scripts.OnClick(card, "LeftButton")
check(
  not card.shown and YonderFrame.shown and YonderFrame.selectedTab == ns.TAB.expeditions,
  "… a click opens it in the journal"
)
local toastsBefore = #toasted
SlashCmdList.YONDER("toast")
check(
  #toasted == toastsBefore + 1 and said("among the game's own alerts"),
  "/yonder toast shows a riddle's banner, and where"
)
-- The riddles' and quarries' banners, the milestones' alerts: a switch each.
local milestone = next(ns.milestoneById)
ns.setOption("banner", false)
toastsBefore = #toasted
ns.toast("riddle", "the-barrens-ratchet-book")
ns.toast("milestone", milestone)
check(
  #toasted == toastsBefore + 1 and toasted[#toasted].kicker == "Yonder milestone",
  "the banners off: no riddle's, a milestone's alert still (a switch of its own)"
)
ns.setOption("milestoneToast", false)
ns.toast("milestone", milestone)
check(#toasted == toastsBefore + 1, "… which turns those off")
ns.setOption("banner", true)
ns.setOption("milestoneToast", true)
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
check(not solvedRiddle("duskwood-darkshire"), "… nor targeting her beside her")
state.npc = 11040
fire("QUEST_GREETING")
state.npc = nil
check(
  solvedRiddle("duskwood-darkshire") and not ns.earnedMilestone("expedition-1431"),
  "… speaking to her does; Duskwood's expedition still waits for its quarry"
)
-- The hunt: Commander Felstrom's poster, tracked (its haunts on the map, the
-- gold seal lost), untracked, brought down.
linkHandlers.yonder("yonder:q771")
local function rowsOf()
  local out = {}
  for _, x in ipairs(ns.expeditionPairs) do
    if x.shown then out[x.label.text] = x.value.text end
  end
  return out
end
check(
  YonderExpeditionsPage.title.text == "Commander Felstrom" and rowsOf()["Its haunts"] == "untracked",
  "a quarry's link opens its poster, untracked"
)
local poster = YonderExpeditionsPage.modelFrame
check(
  poster and poster.shown and poster.creature.fogFar == 0.1 and not YonderExpeditionsPage.portrait.badge.shown,
  "… still at large: only its shape in the frame, its portrait in shadow"
)
local track = YonderExpeditionsPage.buttons[1]
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
    and said("a quarry brought down: |cffffd100|Hyonder:q771|h[Commander Felstrom]|h|r, Duskwood, with a plain seal"),
  "a quarry brought down as the Bestiary tells the kill: tracked once, a plain seal"
)
local quarryToast = toastOf("quarry", 771)
check(
  quarryToast and quarryToast.kicker == "A quarry brought down" and quarryToast.title == "Commander Felstrom",
  "… and its banner"
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
-- A keeper who walks: Zixil, met by speaking to him, wherever his road has
-- taken him; never by a look at him, near or under the mouse.
at(1424, 0.10, 0.10)
state.target, state.mouseover, state.near = 3537, 3537, true
ns.expeditionAttempt()
check(not solvedRiddle("hillsbrad-foothills-zixil"), "a keeper targeted near, under the mouse: not yet")
state.target, state.mouseover = nil, nil
state.npc = 3538
fire("GOSSIP_SHOW")
check(not solvedRiddle("hillsbrad-foothills-zixil"), "… speaking to someone else: not yet")
state.npc = 3537
fire("MERCHANT_SHOW")
check(solvedRiddle("hillsbrad-foothills-zixil"), "… a word with him (his wares opened): solved")
state.npc = nil
-- The keeper of the Great Forge: the same, a word with him.
at(1455, 0.517, 0.414)
state.target, state.near = 11145, true
ns.expeditionAttempt()
check(not solvedRiddle("ironforge-great-forge"), "the forge's keeper targeted beside him: not yet")
state.npc = 11145
fire("GOSSIP_SHOW")
check(solvedRiddle("ironforge-great-forge"), "… spoken to: solved")
state.npc, state.target = nil, nil
-- Dun Morogh's practice range: ears minded beside the riflemen; and Fluffy,
-- settled wherever it has run to.
at(1426, 0.4066, 0.6488)
DoEmote("CHEER")
check(not solvedRiddle("dun-morogh-range"), "the practice range: cheering the riflemen is not what it asks")
DoEmote("COVEREARS")
check(solvedRiddle("dun-morogh-range"), "… minding one's ears beside them is")
at(1426, 0.64, 0.49)
state.mouseover, state.near = 1352, true
DoEmote("SOOTHE")
check(not solvedRiddle("dun-morogh-fluffy"), "Fluffy under the mouse only: a gesture to no one")
state.mouseover, state.target = nil, 1352
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
-- … above the art of the places explored, at the level the game gives its
-- quests' areas (a level under it, and an explored place hid the circle).
check(
  circle.level == mapLevels.PIN_FRAME_LEVEL_QUEST_BLOB and circle.level > mapLevels.PIN_FRAME_LEVEL_MAP_EXPLORATION,
  "… above the places explored, at the level of the game's own quest areas"
)
-- … what the world map drew, for /yonder where; an error of its own said
-- once in chat (Forever's map would swallow it) and kept for /yonder where.
check(
  ns.mapLayer.map == 1429 and ns.mapLayer.circles >= 1 and not ns.mapLayer.err,
  "… the world map's layer keeps what it drew last: the map and its circles"
)
do
  local hint = ns.hintCircles
  ns.hintCircles = function() error("a broken circle") end
  ns.refreshWorldMapPins()
  ns.refreshWorldMapPins()
  ns.hintCircles = hint
  local n = 0
  for _, p in ipairs(printed) do
    if p:find("failed to draw", 1, true) then n = n + 1 end
  end
  check(
    n == 1 and ns.mapLayer.err and ns.mapLayer.err:find("a broken circle", 1, true),
    "… a layer's error said once in chat and kept, never swallowed"
  )
  ns.mapLayer.err = nil
  ns.refreshWorldMapPins()
end
-- … and on the minimap: around the reader standing at its centre, following
-- them, turning with a turning minimap, out of sight far away; the minimap's
-- span its zoom's (Classic) or the game's own (Forever).
do
  local mini = ns.minimapLayer
  local made = {}
  mini.frame.CreateTexture = function()
    local t = ui()
    t.SetPoint = function(self, _, _, _, x, y)
      self.x, self.y = x, y
    end
    t.SetSize = function(self, w) self.size = w end
    t.AddMaskTexture = function(self, m) self.mask = m end
    t.SetSnapToPixelGrid = function(self, v) self.snap = v end
    table.insert(made, t)
    return t
  end
  local cats = ns.riddleById["elwynn-forest-cats"]
  local i
  for k, c in ipairs(ns.hintCircles(1429)) do
    if c.text == cats.verse[1] then i = k end
  end
  local zw = ns.zoneYards(1429)
  local scale = 70 / (FOREVER and 200 or (466 + 2 / 3) / 2) -- (the minimap 140 wide)
  local function frame()
    mini.frame.scripts.OnUpdate(mini.frame, 1)
    return made[i]
  end
  local near = function(a, b) return a and math.abs(a - b) < 1e-6 end
  local back = { state.map, state.x, state.y, state.sub }
  at(1429, cats.circle[1] / 100, cats.circle[2] / 100)
  local t = frame()
  check(
    i
      and t
      and t.shown
      and t.mask
      and near(t.x, 0)
      and near(t.y, 0)
      and near(t.size, 2 * cats.circle[3] / 100 * zw * scale),
    "the map's hint on the minimap: its circle around the reader at its centre, the minimap's span "
      .. (FOREVER and "the game's" or "its zoom's")
  )
  at(1429, cats.circle[1] / 100 - 50 / zw, cats.circle[2] / 100)
  t = frame()
  check(near(t.x, 50 * scale) and near(t.y, 0), "… 50 yards west of it, the circle 50 yards east on the minimap")
  at(1429, cats.circle[1] / 100 - 51 / zw, cats.circle[2] / 100)
  mini.frame.scripts.OnUpdate(mini.frame, 0.004)
  check(
    near(t.x, 51 * scale) and t.snap == false,
    "… placed again at every frame, never snapped to whole pixels: no jiggle as the reader moves"
  )
  at(1429, cats.circle[1] / 100 - 50 / zw, cats.circle[2] / 100)
  cvars.rotateMinimap, state.facing = "1", math.pi / 2
  t = frame()
  check(
    near(t.x, 0) and near(t.y, -50 * scale),
    "… facing west on a turning minimap: the circle behind, under the reader"
  )
  if FOREVER then
    state.facing = 1.25
    secrets[1.25] = true
    check(not frame().shown, "… Forever hiding where the reader faces: no circle on a turning minimap")
    secrets[1.25] = nil
  end
  cvars.rotateMinimap, state.facing = "0", nil
  at(1429, 0.02, 0.02)
  check(not frame().shown and mini.seen < mini.circles, "… far from it: out of sight, still the zone's")
  at(1426, 0.5, 0.5)
  frame()
  check(mini.circles == #ns.hintCircles(1426) and not made[i].shown, "… in another zone: that zone's circles only")
  at(unpack(back))
  frame()
end
-- The book: the Expeditions tab, a riddle's page, the seals and the margin.
linkHandlers.yonder("yonder:xthe-barrens-ratchet-book")
local function pageRows()
  local out = {}
  for _, x in ipairs(ns.expeditionPairs) do
    if x.shown then out[x.label.text] = x.value.text end
  end
  return out
end
local parts = YonderExpeditionsPage.parts
local function paragraphs()
  local out = {}
  for _, p in ipairs(YonderExpeditionsPage.paragraphs) do
    if p.shown then table.insert(out, p.text) end
  end
  return table.concat(out, "\n")
end
check(
  YonderFrame.selectedTab == ns.TAB.expeditions
    and YonderExpeditionsPage.title.text == "Exile of the High Elves"
    and parts.verse.shown
    and parts.seal.shown
    and parts.seal.name.text == "The gold seal"
    and parts.seal.detail.text:find("^Read from the verse alone, on ")
    and parts.margin.shown
    and parts.margin.text.text == ns.riddleMargin(ns.riddleById["the-barrens-ratchet-book"])
    and paragraphs():find(ns.riddleNote(ns.riddleById["the-barrens-ratchet-book"]), 1, true),
  "a riddle's link opens its page: its verse, its answer, the gold seal, the note and the margin"
)
local header = YonderExpeditionsPage.portrait
local gold = ns.kit.RINGS.gold[1]
check(
  rawget(header.tex, "display") == nil
    and not header.badge.shown
    and header.ring.vertex[2] == gold[2]
    and not header.ring.desaturated,
  "… its picture what it led to (a book read), the gold seal its ring, no medal"
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
  YonderExpeditionsPage.title.text == TIERS[ns.riddleById["elwynn-forest-cats"].tier],
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
local ask = YonderExpeditionsPage.buttons[1]
check(ask and ask.shown, "an unsolved riddle's page offers its clue")
ask.scripts.OnClick(ask)
check(
  state.popup and state.popup:find("gold seal") and ns.riddleRecord(vigil.id).hints == 1,
  "… asked for after the game's confirmation"
)
-- Pinned to the screen: a card of its own, dragged anywhere, closed by its cross.
local pinIt = YonderExpeditionsPage.buttons[2]
check(pinIt.shown and pinIt.text == "Pin to the screen", "an unsolved riddle's page offers to pin it to the screen")
pinIt.scripts.OnClick(pinIt)
local pinCard = YonderPinnedCard
check(
  ns.pinned() == vigil.id
    and pinCard.shown
    and pinCard.verse.text == table.concat(vigil.verse, "\n")
    and pinCard.extra.text:find("^The clue: ")
    and pinCard.picture.ring.desaturated
    and pinCard.picture.ring.vertex[1] == ns.kit.RINGS.iron[1][1],
  "… pinned: its card shows the verse and the clue taken, its ring iron till solved"
)
pinCard.scripts.OnDragStop(pinCard)
check(ns.expeditions().pinAt ~= nil, "… dragged, it stays where it was left")
check(YonderExpeditionsPage.buttons[2].text == "Unpin from the screen", "… and the page offers to unpin it")
pinCard.close.scripts.OnClick(pinCard.close)
check(not pinCard.shown and ns.pinned() == nil, "… closed by its cross, unpinned")
-- A zone's page: its riddles in words, a card for each riddle and its
-- quarry, a click on one opens it; its map, where each riddle was read.
for _, r in ipairs(ns.expeditionRows) do
  if r.shown and r.zone == 1431 then r.scripts.OnClick(r) end
end
local cards = {}
for _, c in ipairs(YonderExpeditionsPage.cards) do
  if c.shown then cards[c.name.text] = c end
end
check(
  YonderExpeditionsPage.title.text == "Duskwood"
    and YonderExpeditionsPage.note.text:find("^Duskwood keeps %a+ riddles for you")
    and cards["Watcher Callahan"]
    and cards["Commander Felstrom"],
  "a zone's page: its riddles in words, a card for each riddle and its quarry"
)
local map = YonderExpeditionsPage.map
check(map.shown and map.pins[1] and map.pins[1].shown, "… its map, where each riddle was read")
cards["Commander Felstrom"].scripts.OnClick(cards["Commander Felstrom"])
check(
  YonderExpeditionsPage.title.text == "Commander Felstrom"
    and YonderExpeditionsPage.modelFrame.shown
    and rawget(YonderExpeditionsPage.modelFrame.creature, "fogFar") == nil
    and YonderExpeditionsPage.parts.seal.name.text == "No seal",
  "… a card opens its page: the quarry's poster, brought down, the creature itself turning in its frame"
)
YonderFrame:Hide()
SlashCmdList.YONDER("where")
check(said("(map 1434): 24.70, 8.93."), "/yonder where tells the map and the position")
check(
  said("  hint circles: ") and said(" when last drawn; minimap: "),
  "… and the maps' circles: this zone's, the world map's last drawing, the minimap's"
)

SlashCmdList.YONDER("reset yes")
check(next(YonderChar.creatures) == nil and YonderChar.guid == PLAYER, "/yonder reset yes starts the journal over")
-- Settings are each character's own (the kit's profiles); the welcome page
-- offers them once per character, and another character's to take.
local P = ns.profiles
check(
  P:key() == "Thorin - Nightslayer" and YonderSettings.profiles["Thorin - Nightslayer"],
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
YonderSettings.profiles["Brann - Nightslayer"] = { banner = false, sound = 0, minimapAngle = 90 }
SlashCmdList.YONDER("welcome")
local pick = W.picker.select
check(pick.rows[1].text:GetText() == "Brann - Nightslayer", "… another character of this game, in its select")
pick.rows[1].scripts.OnClick(pick.rows[1])
W.picker.copy.scripts.OnClick(W.picker.copy)
check(
  ns.option("banner") == false
    and ns.option("sound") == 0
    and ns.option("minimapAngle") == 90
    and ns.option("worldMapPins") == true,
  "… its choices copied (what it lacks: the defaults)"
)
local code = P:export()
check(code == "YD1:b0:s0:m1:w1:t1:h0:a90", "… a code for them: " .. code)
SlashCmdList.YONDER("import FJ1:c1:s3175")
check(
  ns.option("sound") == 3175 and ns.option("minimapAngle") == 90 and ns.option("banner") == false,
  "… /yonder import CODE (an old FJ1 one too, its c, the chat lines, left out)"
)
check(not P:import("LC1:c1") and ns.option("sound") == 3175, "… another addon's code refused")
local copyFrom = panel.settings.YONDER_COPYFROM
check(
  copyFrom and copyFrom.options()[2].value == "Brann - Nightslayer",
  "… the Options page offers the other characters too"
)
W.frame:Hide()

-- A translation: its words and plural rule, the sections' and families'
-- titles and notes (this game's paragraphs), the Atlas's, the fish's waters,
-- a riddle's verse, clue, danger and what its solving reads (veiled as the
-- English, whatever its letters), a quarry's name and poster; the reader's
-- gender; on Classic, its own names for the places Forever renamed.
do
  local L, K = ns.kit.L, ns.kit
  check(
    L["Expeditions"] == "Expeditions" and K.plural(0, "%d riddle solved", "%d riddles solved") == "%d riddles solved",
    "English by default"
  )
  local veil = ns.expeditionVeil -- (the build's veil, for the test's own texts)
  local r = D.expeditions[1426].riddles[1]
  UnitSex = function() return 3 end -- (a woman reads)
  ns.translate({
    locale = "frFR",
    plural = "fr",
    words = {
      ["Expeditions"] = "Expéditions",
      ["%d riddle solved"] = "%d énigme résolue",
      ["%d riddles solved"] = "%d énigmes résolues",
    },
    sections = { beasts = "Bêtes" },
    families = {
      wolves = {
        title = "Loups",
        note = { { "Un hurlement." }, { client = "forever", "Pour Forever." }, { client = "classic", "Pour Classic." } },
      },
    },
    atlas = { [1426] = { { "Les neiges autour de Forgefer." } } },
    places = { ["Cliffspring Falls"] = "Chutes de Sourcefalaise" },
    expeditions = {
      [1426] = {
        riddles = {
          [r.id] = {
            verse = { "Sous les grandes portes,", "une enclume a un maître." },
            hint = "Au pied de la route de Forgefer.",
            danger = "Calme",
            name = veil("Note gravée", r.id),
            note = veil("Votre note, $gcher voyageur:chère voyageuse;, à Forgefer.", r.id),
            margin = veil("Une marge.", r.id),
          },
        },
        quarry = {
          name = "Grumeux",
          verse = { "Un loup", "plus grand que les autres." },
          note = veil("Sa note.", "quarry-1132"),
        },
      },
    },
    classic = { { "Forgefer", "Ironforge" } },
  })
  local wolves = ns.familyById.wolves
  check(
    L["Expeditions"] == "Expéditions" and K.plural(0, "%d riddle solved", "%d riddles solved") == "%d énigme résolue",
    "a translation: its words, its plural rule (French: 0 is singular)"
  )
  check(D.sections[1].title == "Bêtes" and wolves.title == "Loups", "… the sections' and families' titles")
  check(
    #wolves.note == 2 and wolves.note[2] == (FOREVER and "Pour Forever." or "Pour Classic."),
    "… a family's note, this game's paragraphs"
  )
  check(
    D.atlas.zones[1426].note[1] == (FOREVER and "Les neiges autour de Forgefer." or "Les neiges autour de Ironforge."),
    "… the Atlas's notes, Classic's own names swapped in on Classic"
  )
  check(D.flora.fish[6718].subzones[1] == "Chutes de Sourcefalaise", "… the fish's waters")
  check(
    r.verse[2] == "une enclume a un maître."
      and r.hint == (FOREVER and "Au pied de la route de Forgefer." or "Au pied de la route de Ironforge.")
      and r.danger == "Calme",
    "… a riddle's verse, clue and danger"
  )
  check(
    ns.riddleName(r) == "Note gravée"
      and ns.riddleNote(r) == (FOREVER and "Votre note, chère voyageuse, à Forgefer." or "Votre note, chère voyageuse, à Ironforge.")
      and ns.riddleMargin(r) == "Une marge.",
    "… what its solving reads, veiled whatever its letters, the reader's gender"
  )
  local quarry = D.expeditions[1426].quarry
  check(
    quarry.name == "Grumeux" and quarry.verse[1] == "Un loup" and ns.quarryNote(quarry) == "Sa note.",
    "… a quarry's name and poster"
  )
end

-- The French the package ships (Text_frFR.lua, from i18n/frFR): it loads, and
-- every riddle and quarry reads as French, whole (veiled and unveiled byte by
-- byte, accents kept), its gender tokens resolved; Classic's names on Classic.
do
  assert(loadfile(DIR .. "Text_frFR.lua"))("Yonder", ns)
  local function utf8(s)
    local i, n = 1, #s
    while i <= n do
      local c = s:byte(i)
      local len = c < 0x80 and 1 or c >= 0xF0 and 4 or c >= 0xE0 and 3 or c >= 0xC2 and c < 0xE0 and 2 or nil
      if not len or (c < 0x20 and c ~= 10) then return false end
      for j = i + 1, i + len - 1 do
        local b = s:byte(j)
        if not b or b < 0x80 or b > 0xBF then return false end
      end
      i = i + len
    end
    return true
  end
  local bad = {}
  local function read(s, what)
    if s and (not utf8(s) or s:find("%$[gG]")) then table.insert(bad, what) end
  end
  for _, e in pairs(D.expeditions) do
    for _, r in ipairs(e.riddles or {}) do
      read(ns.riddleName(r), r.id .. " name")
      read(ns.riddleNote(r), r.id .. " note")
      read(ns.riddleMargin(r), r.id .. " margin")
      for _, line in ipairs(r.verse or {}) do
        read(line, r.id .. " verse")
      end
    end
    if e.quarry then
      read(ns.quarryNote(e.quarry), e.quarry.name .. " note")
      read(ns.quarryMargin(e.quarry), e.quarry.name .. " margin")
    end
  end
  local etched
  for _, r in ipairs(D.expeditions[1426].riddles) do
    if r.id == "dun-morogh-etched-note" then etched = r end
  end
  check(#bad == 0, "the shipped French: every riddle and quarry reads whole (" .. table.concat(bad, ", ") .. ")")
  check(
    ns.riddleName(etched) == "Note gravée"
      and ns.riddleNote(etched):find(FOREVER and "Forgefer compte" or "Ironforge compte", 1, true)
      and ns.kit.L["Expeditions"] ~= "Expeditions",
    "… its words, a riddle's answer and note, Classic's own names on Classic"
  )
end

io.write(FOREVER and "all good (Forever)\n" or "all good\n")
