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
function PlaySound(id) sounds = sounds + 1; lastSound = id end
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

-- ── load the addon ───────────────────────────────────────────────────────────
local ns = {}
assert(loadfile(DIR .. (FOREVER and "Data_Forever.lua" or "Data_Classic.lua")))("FieldJournal", ns)
for _, f in ipairs({ "Core.lua", "Book.lua", "Minimap.lua", "Settings.lua", "Hints.lua" }) do
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
check(said("a trophy: |cffffd100|Hfieldjournal:c1132|h[Timber]|h|r") and sounds == 1, "… announced in chat, with the trophy sound")

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
check(wolves[1131].name.text == "Winter Wolf" and wolves[1131].facts.text:find("level 7", 1, true) and wolves[1131].facts.text:find("slain", 1, true), "… with its name and a line of its record")
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

SlashCmdList.FIELDJOURNAL("reset yes")
check(next(FieldJournalChar.creatures) == nil and FieldJournalChar.guid == PLAYER, "/journal reset yes starts the journal over")
io.write(FOREVER and "all good (Forever)\n" or "all good\n")
