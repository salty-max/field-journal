-- Explorer's Field Journal: the Bestiary's records. Every creature this
-- character meets (targets or mouses over), slays and loots, kept per
-- creature id with when, where and at what level; sorted into the families of
-- Data.lua (built from content/ by scripts/build.ts, one file per game).
local _, ns = ...
local D = ns.data
local PREFIX = "|cffc9a227Field Journal:|r "
ns.PREFIX = PREFIX

-- Which game: World of Warcraft: Forever (the original world on the modern
-- client, interface 16xxx) or Classic (Era, TBC Anniversary).
local interface = select(4, GetBuildInfo()) or 0
ns.forever = interface >= 16000 and interface < 20000
ns.client = ns.forever and "forever" or "classic"

-- Forever hides some values from addons ("secret values", in combat or
-- instances): never compare or print one.
local function secret(v) return issecretvalue ~= nil and issecretvalue(v) end
ns.secret = secret

-- This character's journal (SavedVariablesPerCharacter FieldJournalChar):
--   guid                       whose journal it is
--   creatures[id] = {
--     name, type, family,      as the game named them (type and family for
--                              creatures Data.lua doesn't know)
--     first, last = { at, level, zone, sub, map, x, y }   met
--     low, high                levels seen
--     places = { "Zone: Sub" } where met (a few)
--     slain, firstSlain, lastSlain = { at, level }
--     loot = { [itemId] = count }
--     trophy = { at, level, rank }   a rare's or a boss's first kill
--   }
--   families[familyKey] = { at, level }   when each family was first slain
--   seen[id] = { name, type, family, first, last, low, high, places }
--                              met but not yet slain: a creature joins the
--                              book (creatures, families) on its first kill,
--                              with what was seen of it before
--   killRule                   journals from before that rule, set right once
local char

local MAX_PLACES = 6

-- ── what a creature is ───────────────────────────────────────────────────────
local function creatureId(guid)
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind == "Creature" then return tonumber(id) end
end
ns.creatureId = creatureId

-- Creatures the data doesn't know (Forever's new ones) are filed by what the
-- game says of them: a beast by its family (Cat: the great cats), anything
-- else in its type's catch-all page. The game's names are localized: they are
-- matched through its own lookups, with the English names as a fallback.
local TYPES = {
  Beast = 1,
  Dragonkin = 2,
  Demon = 3,
  Elemental = 4,
  Giant = 5,
  Undead = 6,
  Humanoid = 7,
  Mechanical = 9,
  NotSpecified = 10,
}
local TYPE_NAMES = { NotSpecified = "Not specified" }
local BEAST_NAMES = {
  [1] = "Wolf",
  [2] = "Cat",
  [3] = "Spider",
  [4] = "Bear",
  [5] = "Boar",
  [6] = "Crocolisk",
  [7] = "Carrion Bird",
  [8] = "Crab",
  [9] = "Gorilla",
  [11] = "Raptor",
  [12] = "Tallstrider",
  [20] = "Scorpid",
  [21] = "Turtle",
  [24] = "Bat",
  [25] = "Hyena",
  [26] = "Owl",
  [27] = "Wind Serpent",
}
local byBeast, byType
local function lookups()
  if byBeast then return end
  byBeast, byType = {}, {}
  local info = C_CreatureInfo or {}
  for familyId, index in pairs(D.beasts or {}) do
    if BEAST_NAMES[familyId] then byBeast[BEAST_NAMES[familyId]] = index end
    local f = info.GetCreatureFamilyInfo and info.GetCreatureFamilyInfo(familyId)
    if f and f.name then byBeast[f.name] = index end
  end
  for typeName, index in pairs(D.fallbacks or {}) do
    byType[TYPE_NAMES[typeName] or typeName] = index
    local t = TYPES[typeName] and info.GetCreatureTypeInfo and info.GetCreatureTypeInfo(TYPES[typeName])
    if t and t.name then byType[t.name] = index end
  end
end

-- The family a creature belongs to: Data.lua's index, else by what the game
-- said of it when met; a "?type/family" key if even that fails.
function ns.familyKey(id, rec)
  local index = D.creatures[id]
  if index then return index end
  rec = rec or (char and char.creatures[id])
  if not (rec and rec.type) then return end
  lookups()
  index = (rec.family and byBeast[rec.family]) or byType[rec.type]
  if index then return index end
  return "?" .. rec.type .. (rec.family and ("/" .. rec.family) or "")
end

-- Can the journal file a creature of this type the data doesn't know?
-- (Not critters, wild pets, totems...)
function ns.knownType(ctype)
  lookups()
  return ctype ~= nil and byType[ctype] ~= nil
end

function ns.familyTitle(key)
  if type(key) == "number" then return D.families[key].title end
  local t, f = key:match("^%?([^/]+)/?(.*)$")
  if f and f ~= "" then return ("Unrecorded %s: %s"):format(t or "?", f) end
  return ("Unrecorded: %s"):format(t or "?")
end

local function here()
  local map = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local pos = map and C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(map, "player")
  return {
    at = time(),
    level = UnitLevel("player"),
    zone = GetRealZoneText(),
    sub = GetSubZoneText(),
    map = map,
    x = pos and math.floor(pos.x * 1000 + 0.5) / 10,
    y = pos and math.floor(pos.y * 1000 + 0.5) / 10,
  }
end

local function addPlace(rec, h)
  local place = (h.zone or "?") .. ((h.sub and h.sub ~= "" and h.sub ~= h.zone) and (": " .. h.sub) or "")
  rec.places = rec.places or {}
  for _, p in ipairs(rec.places) do
    if p == place then return end
  end
  if #rec.places < MAX_PLACES then table.insert(rec.places, place) end
end

-- ── meeting ──────────────────────────────────────────────────────────────────
-- Can this character fight it now? A hidden answer (Forever) counts as yes.
local function attackable(unit)
  local ok = UnitCanAttack("player", unit)
  return secret(ok) or ok == true
end

-- Meets the unit's creature (target or mouseover): what is seen of it (where,
-- its levels) is noted; it joins the book on its first kill (slay). Returns
-- the creature's id.
local function meet(unit)
  if not char or not UnitExists(unit) or UnitIsPlayer(unit) then return end
  local id = creatureId(UnitGUID(unit))
  if not id then return end
  local known = D.creatures[id] ~= nil
  local rec = char.creatures[id]
  if not rec then
    char.seen = char.seen or {}
    rec = char.seen[id]
    if not rec then
      -- Only creatures this character could fight: a stable's mounts, a town's
      -- folk or a foe still friendly before its script turns it aren't game.
      if not attackable(unit) then return end
      local name = UnitName(unit)
      rec = { name = not secret(name) and name or nil }
      if not known then
        local ctype, cfam = UnitCreatureType(unit), UnitCreatureFamily(unit)
        if secret(ctype) or not ns.knownType(ctype) then return end
        rec.type = ctype
        rec.family = not secret(cfam) and cfam or nil
      end
      rec.first = here()
      char.seen[id] = rec
    end
  end
  local h = here()
  rec.last = h
  local level = UnitLevel(unit)
  if level and not secret(level) and level > 0 then
    rec.low = math.min(rec.low or level, level)
    rec.high = math.max(rec.high or level, level)
  end
  addPlace(rec, h)
  if ns.onRecord and char.creatures[id] then ns.onRecord(id) end
  return id
end
ns.meet = meet

-- ── slaying ──────────────────────────────────────────────────────────────────
-- A creature's rank mark: r rare, R rare elite, b boss (Data.lua), else what
-- the game says now.
function ns.rank(id, unit)
  local r = D.ranks[id]
  if r then return r end
  if unit then
    local c = UnitClassification(unit)
    if not secret(c) then
      if c == "rare" then
        return "r"
      elseif c == "rareelite" then
        return "R"
      elseif c == "worldboss" then
        return "b"
      end
    end
  end
end

-- Forever: the creatures this character fought (targeted or moused over while
-- both were in combat), so a dead target only counts if it was one of them:
-- other people's kills lying about don't.
local engaged, engagedOrder = {}, {}
local function engage(unit)
  if not UnitExists(unit) or UnitIsDead(unit) then return end
  local mine, theirs = UnitAffectingCombat("player"), UnitAffectingCombat(unit)
  if secret(mine) or secret(theirs) or not (mine and theirs) or not attackable(unit) then return end
  -- (one someone else hit first isn't this character's to claim)
  local claimed = UnitIsTapDenied and UnitIsTapDenied(unit)
  if claimed and not secret(claimed) then return end
  local guid = UnitGUID(unit)
  if not guid or secret(guid) or engaged[guid] then return end
  engaged[guid] = true
  table.insert(engagedOrder, guid)
  if #engagedOrder > 200 then engaged[table.remove(engagedOrder, 1)] = nil end
end

-- Corpses already counted (Forever: a kill is counted once, at its first loot
-- or dead target), so a corpse looted twice counts once.
local counted, countedOrder = {}, {}
local function once(guid)
  if counted[guid] then return false end
  counted[guid] = true
  table.insert(countedOrder, guid)
  if #countedOrder > 400 then counted[table.remove(countedOrder, 1)] = nil end
  return true
end

-- A creature's first kill: it joins the book, with what was seen of it
-- (else, for one the data knows, from here and now), its family with it,
-- announced in chat (a link to its page; no sound).
local function join(id, unit)
  if unit then meet(unit) end
  local rec = char.seen and char.seen[id]
  if not rec then
    if not D.creatures[id] then return end -- (one the data doesn't know, never seen: nothing to file it by)
    rec = { first = here() }
  end
  if char.seen then char.seen[id] = nil end
  char.creatures[id] = rec
  local key = ns.familyKey(id, rec)
  local newFamily = key and not char.families[key]
  if newFamily then char.families[key] = { at = time(), level = UnitLevel("player") } end
  if ns.option("chat") and key then
    print(
      PREFIX
        .. ("|cffffd100|Hfieldjournal:c%d|h[%s]|h|r recorded (%s%s)."):format(
          id,
          rec.name or "?",
          ns.familyTitle(key),
          newFamily and ", a new family" or ""
        )
    )
  end
  return rec
end

local function slay(id, unit)
  local rec = char.creatures[id] or join(id, unit)
  if not rec then return end
  local stamp = { at = time(), level = UnitLevel("player") }
  rec.slain = (rec.slain or 0) + 1
  rec.firstSlain = rec.firstSlain or stamp
  rec.lastSlain = stamp
  local rank = ns.rank(id, unit)
  if rank and not rec.trophy then
    rec.trophy = { at = stamp.at, level = stamp.level, rank = rank }
    if ns.option("chat") then
      print(PREFIX .. ("a trophy: |cffffd100|Hfieldjournal:c%d|h[%s]|h|r"):format(id, rec.name or "?"))
    end
    ns.playSound()
  end
  if ns.checkMilestones then ns.checkMilestones() end
  if ns.onRecord then ns.onRecord(id) end
end
ns.slay = slay

-- ── events ───────────────────────────────────────────────────────────────────
local frame = CreateFrame("Frame")
local handlers = {}

function ns.belongsTo(saved, guid) return type(saved) == "table" and saved.guid == guid end

local function newJournal(guid)
  FieldJournalChar = { guid = guid, creatures = {}, families = {} }
  char = FieldJournalChar
end

function handlers.PLAYER_LOGIN()
  local guid = UnitGUID("player")
  if ns.belongsTo(FieldJournalChar, guid) then
    char = FieldJournalChar
    char.creatures = char.creatures or {}
    char.families = char.families or {}
    -- From before a creature joined on its first kill (it joined on meeting):
    -- the ones never slain go back to what was seen, the families with them.
    if not char.killRule then
      char.seen = char.seen or {}
      for id, rec in pairs(char.creatures) do
        if not rec.slain then
          char.seen[id], char.creatures[id] = rec, nil
        end
      end
      local kept = {}
      for id, rec in pairs(char.creatures) do
        local key = ns.familyKey(id, rec)
        if key then kept[key] = true end
      end
      for key in pairs(char.families) do
        if not kept[key] then char.families[key] = nil end
      end
    end
    char.killRule = true
  else
    newJournal(guid)
  end
  if ns.createMinimapButton then ns.createMinimapButton() end
  if ns.createSettingsPanel then ns.createSettingsPanel() end
  -- Milestones a journal already deserves: recorded quietly.
  if ns.checkMilestones then ns.checkMilestones(true) end
end

-- Forever (no combat log): a creature this character fought, seen dead as its
-- target, counts as slain, once per corpse. The target is watched through
-- the fight (its health, its flags), not only when chosen: mostly it is
-- chosen before the fight and dies still chosen.
local function watchTarget()
  if not ns.meetKills then return end
  engage("target")
  if UnitExists("target") and UnitIsDead("target") then
    local guid = UnitGUID("target")
    local id = creatureId(guid)
    if id and engaged[guid] and once(guid) then slay(id, "target") end
  end
end
handlers.PLAYER_TARGET_CHANGED = function()
  meet("target")
  watchTarget()
end
handlers.UNIT_HEALTH = function(unit)
  if unit == "target" then watchTarget() end
end
handlers.UNIT_FLAGS = function(unit)
  if unit == "target" then watchTarget() end
end
handlers.UPDATE_MOUSEOVER_UNIT = function()
  meet("mouseover")
  if ns.meetKills then engage("mouseover") end
end
-- Entering combat with something already targeted.
handlers.PLAYER_REGEN_DISABLED = function()
  if ns.meetKills then engage("target") end
end

-- Kills: yours or your pet's, however dealt (a DoT, an area spell, a creature
-- never targeted, one with no loot). PARTY_KILL (killer, victim) is an event
-- of its own where the client has it (Forever, Classic since 1.15.9), else a
-- line of the combat log; secret only in a Forever instance, where no creature
-- can be told from another.
local function killed(attacker, victim)
  if not attacker or secret(attacker) or (attacker ~= UnitGUID("player") and attacker ~= UnitGUID("pet")) then
    return
  end
  local id = creatureId(victim)
  if not id or not once(victim) then return end
  -- (the unit it still is, if any: for a creature the data doesn't know)
  local unit = UnitTokenFromGUID and UnitTokenFromGUID(victim)
  slay(id, (unit and not secret(unit)) and unit or nil)
end
handlers.PARTY_KILL = killed
function handlers.COMBAT_LOG_EVENT_UNFILTERED()
  if ns.partyKill then return end -- (told by the event of its own)
  local _, sub, _, source, _, _, _, dest = CombatLogGetCurrentEventInfo()
  if sub ~= "PARTY_KILL" or (source ~= UnitGUID("player") and source ~= UnitGUID("pet")) then return end
  local id = creatureId(dest)
  if id then slay(id) end
end

-- Loot: what each corpse gave (the loot window names its source). On Forever,
-- the first loot of a corpse also counts its kill.
local looted, lootedOrder = {}, {}
function handlers.LOOT_OPENED()
  if not (GetNumLootItems and GetLootSourceInfo) then return end
  for slot = 1, GetNumLootItems() do
    local link = GetLootSlotLink(slot)
    local itemId = link and tonumber(link:match("item:(%d+)"))
    local sources = { GetLootSourceInfo(slot) }
    for i = 1, #sources, 2 do
      local guid, count = sources[i], sources[i + 1] or 1
      local id = creatureId(guid)
      if id then
        if ns.meetKills and once(guid) then slay(id) end
        local rec = char.creatures[id]
        local key = guid .. ":" .. slot
        if rec and itemId and not looted[key] then
          looted[key] = true
          table.insert(lootedOrder, key)
          if #lootedOrder > 400 then looted[table.remove(lootedOrder, 1)] = nil end
          rec.loot = rec.loot or {}
          rec.loot[itemId] = (rec.loot[itemId] or 0) + count
        end
      end
    end
  end
end

-- Other files listen through this frame too (ns.on): the Atlas.
local listeners = {}
frame:SetScript("OnEvent", function(_, event, ...)
  if event ~= "PLAYER_LOGIN" and not char then return end
  if handlers[event] then handlers[event](...) end
  for _, fn in ipairs(listeners[event] or {}) do
    fn(...)
  end
end)
function ns.on(event, fn)
  if not listeners[event] then
    listeners[event] = {}
    -- An event a client doesn't know is simply never heard.
    if not handlers[event] then pcall(frame.RegisterEvent, frame, event) end
  end
  table.insert(listeners[event], fn)
end
-- Kills: PARTY_KILL where the client has it; else the combat log (not on
-- Forever, which forbids it: registering it throws); with neither, loot and
-- dead targets count instead.
for event in pairs(handlers) do
  if event == "PARTY_KILL" then
    ns.partyKill = pcall(frame.RegisterEvent, frame, event)
  elseif event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
    frame:RegisterEvent(event)
  end
end
if not ns.partyKill then
  local log = not ns.forever and pcall(frame.RegisterEvent, frame, "COMBAT_LOG_EVENT_UNFILTERED")
  if not log then ns.meetKills = true end
end

-- ── counts ───────────────────────────────────────────────────────────────────
function ns.journal() return char end

-- Creatures met per family key, and the families met, in the book's order.
function ns.metByFamily()
  local by = {}
  for id, rec in pairs(char and char.creatures or {}) do
    local key = ns.familyKey(id, rec)
    if key then
      by[key] = by[key] or {}
      table.insert(by[key], id)
    end
  end
  return by
end

function ns.counts()
  local creatures, families, slain = 0, 0, 0
  for _, rec in pairs(char and char.creatures or {}) do
    creatures = creatures + 1
    slain = slain + (rec.slain or 0)
  end
  for _ in pairs(char and char.families or {}) do
    families = families + 1
  end
  return creatures, families, slain
end

-- ── /journal ─────────────────────────────────────────────────────────────────
SLASH_FIELDJOURNAL1 = "/journal"
SLASH_FIELDJOURNAL2 = "/fj"
SlashCmdList.FIELDJOURNAL = function(msg)
  msg = strtrim((msg or ""):lower())
  if msg == "reset" then
    print(PREFIX .. "this forgets every creature this character has recorded. Type /journal reset yes to do it.")
    return
  end
  if msg == "reset yes" then
    newJournal(char.guid)
    if ns.refresh then ns.refresh() end
    print(PREFIX .. "the journal starts afresh.")
    return
  end
  if msg == "atlas" then
    if ns.atlasReport then ns.atlasReport() end
    return
  end
  if msg == "minimap" then
    ns.setOption("minimapHidden", not ns.option("minimapHidden"))
    return
  end
  if msg == "settings" or msg == "options" then
    if not ns.openSettings() then print(PREFIX .. "no settings page in this client.") end
    return
  end
  if ns.toggle then ns.toggle() end
end
