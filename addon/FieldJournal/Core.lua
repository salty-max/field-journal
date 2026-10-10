-- Explorer's Field Journal: this character's journal, the events every file
-- listens to (ns.on, ns.onUnit) and /journal. The records are kept by
-- Creatures.lua (the Bestiary), Atlas.lua, Flora.lua (fish and herbs) and
-- Achievements.lua (milestones); the book shows them (Book.lua).
--
--   FieldJournalChar (SavedVariablesPerCharacter), whose journal: guid
--     creatures[id] = {
--       name, type, family,      as the game named them (type and family for
--                                creatures Data.lua doesn't know)
--       first, last = { at, level, zone, sub, map, x, y }   met
--       low, high                levels seen
--       places = { "Zone: Sub" } where met (a few)
--       slain, firstSlain, lastSlain = { at, level }
--       loot = { [itemId] = count }
--       trophy = { at, level, rank }   a rare's or a boss's first kill
--       display                  its portrait's display id, asked of the game
--     }
--     families[familyId] = { at, level }    when each family was first slain
--                                (by the family's id, "wolves"; rebuilt from
--                                the creatures at each login)
--     seen[id] = { name, type, family, first, last, low, high, places }
--                                met but not yet slain: a creature joins the
--                                book (creatures, families) on its first kill,
--                                with what was seen of it before
--     killRule                   journals from before that rule, set right once
--     atlas = { ... }            the places explored, deaths, travels (Atlas.lua)
--     fish, plants               the catches and the herbs (Flora.lua)
--     achievements[id]           the milestones earned (Achievements.lua)
--     collapsed, open, atlasOpen the book's folds (types, families, zones)
local _, ns = ...
local PREFIX = "|cffc9a227Field Journal:|r "
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

frame:SetScript("OnEvent", function(_, event, ...)
  if event == "PLAYER_LOGIN" then ns.login() end
  if not char then return end
  for _, fn in ipairs(listeners[event] or {}) do
    fn(...)
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
        listener(...)
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
  FieldJournalChar = char
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
-- journal kept them by their place in Data.lua's list before 0.6 (which a
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

-- This character's journal, or a new one (a journal saved by another
-- character of the same name is not theirs).
function ns.login()
  local guid = UnitGUID("player")
  if ns.belongsTo(FieldJournalChar, guid) then
    char = FieldJournalChar
    char.creatures = char.creatures or {}
    char.families = char.families or {}
    if not char.killRule then killRule(char) end
    syncFamilies(char)
  else
    newJournal(guid)
  end
  ns.createMinimapButton()
  ns.createSettingsPanel()
  -- Milestones a journal already deserves: recorded quietly.
  ns.checkMilestones(true)
end

-- ── /journal ─────────────────────────────────────────────────────────────────
local USAGE = "/journal opens the book; /journal settings; /journal minimap shows or hides the button; "
  .. "/journal reset starts this character's journal over."

SLASH_FIELDJOURNAL1 = "/journal"
SLASH_FIELDJOURNAL2 = "/fj"
SlashCmdList.FIELDJOURNAL = function(msg)
  msg = strtrim((msg or ""):lower())
  if msg == "" then
    ns.toggle()
  elseif msg == "reset" then
    print(
      PREFIX
        .. "this forgets everything this character has recorded: its creatures, the Atlas, its fish and herbs, its "
        .. "milestones. Type /journal reset yes to do it."
    )
  elseif msg == "reset yes" then
    newJournal(char.guid)
    ns.refresh()
    print(PREFIX .. "the journal starts afresh.")
  elseif msg == "atlas" then
    ns.atlasReport()
  elseif msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
  elseif msg == "settings" or msg == "options" then
    if not ns.openSettings() then print(PREFIX .. "no settings page in this client.") end
  else
    print(PREFIX .. USAGE)
  end
end
