-- Yonder: this character's journal, the events every file
-- listens to (ns.on, ns.onUnit) and /yonder. The records are kept by
-- Creatures.lua (the Bestiary), Atlas.lua, Flora.lua (Finds),
-- Expeditions.lua (the riddles) and Achievements.lua (milestones); the book
-- shows them (Book.lua).
--
--   YonderChar (SavedVariablesPerCharacter), whose journal: guid
--     creatures[id] = {
--       typeId, familyId         for creatures the data file doesn't know, by
--                                the game's ids (type, family: a word the game
--                                gave no id; name: a creature no language's
--                                list names, as the game named it)
--       first, last = { at, level, zone, sub, map, x, y }   met (zone, sub:
--                                a place's key, "a<area id>" or "w<building
--                                area id>"; a name only where the game gave no id)
--       low, high                levels seen
--       places = { "zone|sub" }  where met (a few), by their keys
--       slain, firstSlain, lastSlain = { at, level }
--       loot = { [itemId] = count }
--       trophy = { at, level, rank }   a rare's or a boss's first kill
--       display                  its portrait's display id, asked of the game
--     }
--     families[familyId] = { at, level }    when each family was first slain
--                                (by the family's id, "wolves"; rebuilt from
--                                the creatures at each login)
--     seen[id] = { typeId, familyId, first, last, low, high, places }
--                                met but not yet slain: a creature joins the
--                                book (creatures, families) on its first kill,
--                                with what was seen of it before
--     killRule                   journals from before that rule, set right once
--     atlas = { ... }            the places explored, deaths, travels (Atlas.lua)
--     fish, plants               the catches and the herbs (Flora.lua)
--     materials[itemId]          ore, stone, gem, cloth, leather and hide records
--     finds = { unlocked, announced }  permanent collection flags by family
--     expeditions = { riddles }  the riddles solved, the hints taken (Expeditions.lua)
--     achievements[id]           the milestones earned (Achievements.lua)
--     collapsed, open, atlasOpen, expeditionsOpen   the book's folds (types,
--                                families, zones)
local _, ns = ...
local L = ns.kit.L
local PREFIX = "|cffc9a227Yonder:|r "
ns.PREFIX = PREFIX

-- Which game: World of Warcraft: Forever (the original world on the modern
-- client, interface 16xxx) or Classic (Era, TBC Anniversary).
local interface = select(4, GetBuildInfo()) or 0
ns.forever = interface >= 16000 and interface < 20000

-- Forever hides some values from addons ("secret values", in combat or
-- instances): never compare or print one.
ns.secret = issecretvalue or function() return false end

local char
function ns.journal() return char end

-- ── events ───────────────────────────────────────────────────────────────────
-- Every file listens through ns.on (an event a client doesn't know is never
-- heard), unit events through ns.onUnit (for one unit only: UNIT_HEALTH fires
-- for every unit in sight). Nothing is heard before the login.
local frame = CreateFrame("Frame")
local listeners = {}

-- (one listener's error is reported, and the others still hear the event)
local function run(fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then geterrorhandler()(err) end
end

frame:SetScript("OnEvent", function(_, event, ...)
  -- (a step of the login gone wrong is reported, and the login's listeners,
  -- the world map's layer and the riddles' clock, still start)
  if event == "PLAYER_LOGIN" then run(ns.login) end
  if not char then return end
  for _, fn in ipairs(listeners[event] or {}) do
    run(fn, ...)
  end
end)
frame:RegisterEvent("PLAYER_LOGIN")

function ns.on(event, fn)
  if not listeners[event] then
    listeners[event] = {}
    pcall(frame.RegisterEvent, frame, event)
  end
  table.insert(listeners[event], fn)
end

local units = {} -- unit = its frame, with its own listeners
function ns.onUnit(event, unit, fn)
  local f = units[unit]
  if not f then
    f = CreateFrame("Frame")
    f.listeners = {}
    f:SetScript("OnEvent", function(_, e, ...)
      if not char then return end
      for _, listener in ipairs(f.listeners[e]) do
        run(listener, ...)
      end
    end)
    units[unit] = f
  end
  if not f.listeners[event] then
    f.listeners[event] = {}
    f:RegisterUnitEvent(event, unit)
  end
  table.insert(f.listeners[event], fn)
end

-- Does this client have the event? (registering an unknown one throws)
local probe = CreateFrame("Frame")
function ns.knows(event)
  local ok = pcall(probe.RegisterEvent, probe, event)
  if ok then probe:UnregisterEvent(event) end
  return ok
end

-- ── the login ────────────────────────────────────────────────────────────────
function ns.belongsTo(saved, guid) return type(saved) == "table" and saved.guid == guid end

local function newJournal(guid)
  char = { guid = guid, creatures = {}, families = {}, killRule = true }
  YonderChar = char
end

-- From before a creature joined on its first kill (it joined on meeting):
-- the ones never slain go back to what was seen (their families with them,
-- by syncFamilies).
local function killRule(c)
  c.seen = c.seen or {}
  for id, rec in pairs(c.creatures) do
    if not rec.slain then
      c.seen[id], c.creatures[id] = rec, nil
    end
  end
  c.killRule = true
end

-- The families met, rebuilt from the creatures recorded at each login: a
-- journal kept them by their place in the data file's list before 0.6 (which a
-- new family would shift), and a creature may move to another family between
-- versions. A family keeps its date, else takes its first creature's kill.
local function syncFamilies(c)
  local families = {}
  for id, rec in pairs(c.creatures) do
    local key = ns.familyKey(id, rec)
    if key then
      local was, first = families[key], rec.firstSlain or rec.first or {}
      if type(c.families[key]) == "table" then
        families[key] = c.families[key]
      elseif not was or (first.at or 0) < (was.at or 0) then
        families[key] = { at = first.at, level = first.level }
      end
    end
  end
  c.families = families
end

-- A journal kept under the addon's old name, Explorer's Field Journal (until
-- 0.8.0), taken once and saved under the new names: the handover folder
-- (addon/FieldJournal, Classic Era and TBC) has the game load its saved files
-- again, or a player copied them (in WTF, SavedVariables/FieldJournal.lua to
-- Yonder.lua). (FieldJournalDB is another addon's, never touched.) Whether a
-- journal was taken: said once the login knows it is this character's.
local function adopt()
  local took
  if YonderChar == nil and type(FieldJournalChar) == "table" and FieldJournalChar.guid then
    YonderChar, FieldJournalChar, took = FieldJournalChar, nil, true
  end
  if YonderSettings == nil and type(FieldJournalSettings) == "table" then
    YonderSettings, FieldJournalSettings = FieldJournalSettings, nil
  end
  return took
end

-- The old name still running beside it (a manual install keeps the old
-- folder's files, its Forever TOC among them): two journals at once, two
-- buttons. Told by its title (never another addon's FieldJournal, Field
-- Journal: Forever's, nor the handover), turned off for every character of
-- this game, from the next reload; its journal is Yonder's already (adopt).
local function oldSelf()
  local api = C_AddOns or {}
  local get, loaded = api.GetAddOnMetadata or GetAddOnMetadata, api.IsAddOnLoaded or IsAddOnLoaded
  local ok, title = pcall(get or error, "FieldJournal", "Title")
  if not (ok and title == "Explorer's Field Journal" and loaded and loaded("FieldJournal")) then return end
  local disable = api.DisableAddOn or DisableAddOn
  if disable then pcall(disable, "FieldJournal") end
  print(
    PREFIX
      .. L["Explorer's Field Journal, Yonder's old name, was still running beside it: it is turned off from your next /reload, and your journal is Yonder's. Its FieldJournal folder among your addons can go."]
  )
end

-- This character's journal, or a new one (a journal saved by another
-- character of the same name is not theirs).
-- A journal kept by names (before 15 October 2026: places, types, families,
-- flights in the client's language of the day, or this morning's English): by
-- their ids, where today's language or English knows the name; a name of
-- another language waits for a client of its own.
local function mendNames(c)
  local A = ns.data.atlas or {}
  local english = {}
  for id, n in pairs(A.areaNames or {}) do
    if not english[n] or id < english[n] then english[n] = id end
  end
  local function key(name)
    if type(name) ~= "string" or name == "" or name:match("^[aw]%d+$") then return name end
    return ns.areaKey(name) or (english[name] and "a" .. english[name]) or name
  end
  local function place(p)
    if type(p) ~= "string" or p:find("|", 1, true) then return p end
    local zone, sub = p:match("^(.-): (.+)$")
    if zone then return key(zone) .. "|" .. key(sub) end
    return key(p)
  end
  local function stamps(rec)
    for _, h in ipairs({ rec.first or false, rec.last or false }) do
      if h then
        if type(h.zone) == "string" then h.zone = key(h.zone) end
        if type(h.sub) == "string" then h.sub = key(h.sub) end
      end
    end
  end
  for _, list in ipairs({ c.creatures or {}, c.seen or {} }) do
    for id, rec in pairs(list) do
      if type(rec) == "table" then
        -- (a name only for a creature no language's list names)
        if ns.creatureNames and ns.creatureNames[id] then rec.name = nil end
        for i, p in ipairs(rec.places or {}) do
          rec.places[i] = place(p)
        end
        stamps(rec)
        local typeId = rec.typeId or ns.typeIdOf(rec.type)
        if typeId then
          rec.typeId, rec.type = typeId, nil
        end
        local familyId = rec.familyId or ns.familyIdOf(rec.family)
        if familyId then
          rec.familyId, rec.family = familyId, nil
        end
      end
    end
  end
  for _, kind in ipairs({ c.fish or {}, c.plants or {}, c.materials or {} }) do
    for _, rec in pairs(kind) do
      if type(rec) == "table" then stamps(rec) end
    end
  end
  local a = c.atlas
  if not a then return end
  for _, b in ipairs(a.binds or {}) do
    b.place = key(b.place)
  end
  for _, list in ipairs({ a.deaths or {}, a.closeCalls or {} }) do
    for _, e in ipairs(list) do
      if e.byId then e.by = nil end
    end
  end
  -- (flights and routes: their points by id; two languages' names of one
  -- route made one)
  for _, f in ipairs(a.flights or {}) do
    f.fromId, f.toId = f.fromId or ns.taxiId(f.from), f.toId or ns.taxiId(f.to)
    if f.fromId then f.from = nil end
    if f.toId then f.to = nil end
  end
  if a.routes then
    local routes = {}
    for route, n in pairs(a.routes) do
      local from, to = route:match("^(.-) > (.+)$")
      local fromId, toId = from and ns.taxiId(from), to and ns.taxiId(to)
      local kept = (fromId and toId) and (fromId .. ">" .. toId) or route
      routes[kept] = (routes[kept] or 0) + n
    end
    a.routes = routes
  end
end

function ns.login()
  ns.localNames()
  local took = adopt()
  oldSelf()
  local guid = UnitGUID("player")
  local before = ns.belongsTo(YonderChar, guid)
  if took and before then
    print(
      PREFIX
        .. L["Explorer's Field Journal is now called Yonder (another addon uses its old folder name). Your journal came along: everything you recorded is here. /yonder opens it."]
    )
  end
  if before then
    char = YonderChar
    char.creatures = char.creatures or {}
    char.families = char.families or {}
    if not char.killRule then killRule(char) end
    mendNames(char)
    syncFamilies(char)
  else
    newJournal(guid)
  end
  ns.loadProfile(before)
  ns.collect:start()
  ns.createMinimapButton()
  ns.createSettingsPanel()
  ns.expeditionsLogin()
  -- Milestones a journal already deserves: recorded quietly.
  ns.checkMilestones(true)
  ns.loginLine()
end

-- At each login and /reload, a line in chat: what the journal holds (never
-- what remains: no spoilers), and how to open it, the only reminder of it (as
-- the Codex's).
local function counted(n, one, many) return n > 0 and ns.kit.plural(n, one, many):format(n) or nil end
function ns.loginLine()
  local e = ns.expeditions() or {}
  local riddles, hunts = 0, 0
  for _, rec in pairs(e.riddles or {}) do
    if rec.at then riddles = riddles + 1 end
  end
  for _, rec in pairs(e.hunts or {}) do
    if rec.at then hunts = hunts + 1 end
  end
  local creatures = ns.counts()
  local held = {}
  for _, part in ipairs({
    { riddles, "%d riddle solved", "%d riddles solved" },
    { hunts, "%d quarry brought down", "%d quarries brought down" },
    { creatures, "%d creature in the Bestiary", "%d creatures in the Bestiary" },
  }) do
    local text = counted(unpack(part))
    if text then table.insert(held, text) end -- (none of a kind: left out)
  end
  local open = ns.option("minimapHidden") and L["Type /yonder"] or L["Type /yonder or click the button by the minimap"]
  print(
    PREFIX
      .. (L["%s. %s to open the journal."]):format(
        #held > 0 and table.concat(held, ", ") or L["the journal is empty for now"],
        open
      )
  )
end

-- ── /yonder ─────────────────────────────────────────────────────────────────
local USAGE =
  L["/yonder opens the book, /yonder settings its settings. /yonder minimap shows or hides the button. /yonder welcome shows the welcome page again. /yonder export gives this character's settings as a code, and /yonder import CODE takes them. /yonder reset starts this character's journal over. /yonder where tells the map and your position on it. /yonder probe describes the next loot window, as the game shows it. /yonder toast shows a riddle's banner, as it would come."]

SLASH_YONDER1 = "/yonder"
SlashCmdList.YONDER = function(msg)
  local raw = strtrim(msg or "")
  msg = raw:lower()
  if msg == "" then
    ns.toggle()
  elseif msg == "reset" then
    print(
      PREFIX
        .. L["this forgets everything this character has recorded: its creatures, the Atlas, its finds, its riddles, its achievements. Type /yonder reset yes to do it."]
    )
  elseif msg == "reset yes" then
    newJournal(char.guid)
    ns.refreshFindsProfessions()
    ns.refresh()
    print(PREFIX .. L["the journal starts afresh."])
  elseif msg == "welcome" then
    ns.showWelcome()
  elseif msg == "export" then
    ns.showWelcome("export")
  elseif msg:match("^import%s") then
    if ns.profiles:import(raw:match("^%a+%s+(.+)$")) then
      print(PREFIX .. L["settings imported for this character."])
    else
      print(PREFIX .. L["that isn't a Yonder settings code (/yonder export makes one)."])
    end
  elseif msg == "atlas" then
    ns.atlasReport()
  elseif msg == "where" then
    ns.whereReport()
  elseif msg == "probe" then
    ns.lootProbe()
  elseif msg == "toast achievement" then
    ns.toastTest("milestone")
  elseif msg == "toast" then
    ns.toastTest()
  elseif msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
  elseif msg == "settings" or msg == "options" then
    if not ns.openSettings() then print(PREFIX .. L["no settings page in this client."]) end
  else
    print(PREFIX .. USAGE)
  end
end
