-- The Bestiary's records: every creature this character meets (targets or
-- mouses over) is a sighting; it joins the journal on its first kill, with
-- what was seen of it, filed in its family (Data.lua's, else by what the game
-- says of it). Kills, loot and trophies too. The journal: Core.lua.
local _, ns = ...
local D = ns.data
local PREFIX, secret = ns.PREFIX, ns.secret

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

-- The families by their id ("wolves"), the key the journal keeps them by:
-- never their place in Data.lua's list, which a new family would shift.
local byId = {}
for _, f in ipairs(D.families) do
  byId[f.id] = f
end
ns.familyById = byId

-- The family a creature belongs to (its id): Data.lua's, else by what the
-- game said of it when met; a "?type/family" key if even that fails.
function ns.familyKey(id, rec)
  local index = D.creatures[id]
  if index then return D.families[index].id end
  local c = ns.journal()
  rec = rec or (c and c.creatures[id])
  if not (rec and rec.type) then return end
  lookups()
  index = (rec.family and byBeast[rec.family]) or byType[rec.type]
  if index then return D.families[index].id end
  return "?" .. rec.type .. (rec.family and ("/" .. rec.family) or "")
end

-- Can the journal file a creature of this type the data doesn't know?
-- (Not critters, wild pets, totems...)
function ns.knownType(ctype)
  lookups()
  return ctype ~= nil and byType[ctype] ~= nil
end

function ns.familyTitle(key)
  if byId[key] then return byId[key].title end
  local t, f = key:match("^%?([^/]+)/?(.*)$")
  if f and f ~= "" then return ("Unrecorded %s: %s"):format(t or "?", f) end
  return ("Unrecorded: %s"):format(t or "?")
end

local function here()
  local map = C_Map.GetBestMapForUnit("player")
  local pos = map and C_Map.GetPlayerMapPosition(map, "player")
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
  local char = ns.journal()
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

-- Corpses already counted: a kill told twice (the event and its log line, a
-- corpse looted twice) counts once.
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
  local char = ns.journal()
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

local told = {} -- name = when kills of it were told (a quest's count credits the others)
local function slay(id, unit)
  local rec = ns.journal().creatures[id] or join(id, unit)
  if not rec then return end
  if rec.name then
    told[rec.name] = told[rec.name] or {}
    table.insert(told[rec.name], time())
  end
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

-- ── kills ────────────────────────────────────────────────────────────────────
-- Yours, your pet's or your group's, however dealt (a DoT, an area spell, a
-- creature never targeted, one with no loot). PARTY_KILL (killer, victim) is an event of its
-- own where the client has it (Forever, Classic since 1.15.9), secret only in
-- a Forever instance, where no creature can be told from another; else a
-- line of the combat log (Classic before 1.15.9; Forever forbids it).
local function mine(guid)
  if guid == UnitGUID("player") or guid == UnitGUID("pet") then return true end
  local raid, n = IsInRaid(), GetNumGroupMembers()
  if secret(raid) or secret(n) then return false end
  local unit = raid and "raid" or "party"
  for i = 1, raid and n or n - 1 do
    if guid == UnitGUID(unit .. i) or guid == UnitGUID(unit .. "pet" .. i) then return true end
  end
  return false
end

local function killed(attacker, victim)
  if not attacker or secret(attacker) or not mine(attacker) then return end
  local id = creatureId(victim)
  if not id or not once(victim) then return end
  -- (the unit it still is, if any: for a creature the data doesn't know)
  local unit = UnitTokenFromGUID and UnitTokenFromGUID(victim)
  slay(id, (unit and not secret(unit)) and unit or nil)
end

local function fromLog()
  local _, sub, _, source, _, _, _, dest = CombatLogGetCurrentEventInfo()
  if sub ~= "PARTY_KILL" or not mine(source) then return end
  local id = creatureId(dest)
  if id then slay(id) end
end

ns.partyKill = ns.knows("PARTY_KILL")
if ns.partyKill then
  ns.on("PARTY_KILL", killed)
elseif not ns.forever then
  ns.on("COMBAT_LOG_EVENT_UNFILTERED", fromLog)
end

ns.on("PLAYER_TARGET_CHANGED", function() meet("target") end)
ns.on("UPDATE_MOUSEOVER_UNIT", function() meet("mouseover") end)

-- ── kills a quest credits ────────────────────────────────────────────────────
-- A quest's count of a creature gone up ("Snow Leopard Prowler slain: 1/1")
-- with no kill told: another's killing blow on one this character tagged,
-- which the game credits it with. Known by its name: the creature met by it.
local function idByName(name)
  local c = ns.journal()
  for _, recs in ipairs({ c.creatures, c.seen or {} }) do
    for id, rec in pairs(recs) do
      if rec.name == name then return id end
    end
  end
end

-- "%s slain: %d/%d", or numbered ("%2$d/%3$d %1$s slain"): the name and
-- the count, wherever the game's format puts them.
local function slainPattern()
  local format = QUEST_MONSTERS_KILLED or "%s slain: %d/%d"
  local order = {}
  local p = format:gsub("%%(%d*)%$?([sd])", function(at, kind)
    order[#order + 1] = tonumber(at) or #order + 1
    return kind == "s" and "\1" or "\2"
  end)
  p = p:gsub("([%%%(%)%.%+%-%*%?%[%]%^%$])", "%%%1"):gsub("\1", "(.+)"):gsub("\2", "(%%d+)")
  return "^" .. p .. "$", order
end

-- The quests in the log: their ids.
local function questIds()
  local ids = {}
  if C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo then
    for i = 1, C_QuestLog.GetNumQuestLogEntries() do
      local info = C_QuestLog.GetInfo(i)
      if info and not info.isHeader and info.questID then table.insert(ids, info.questID) end
    end
  elseif GetNumQuestLogEntries and GetQuestLogTitle then
    for i = 1, GetNumQuestLogEntries() do
      local _, _, _, header, _, _, _, id = GetQuestLogTitle(i)
      if not header and id then table.insert(ids, id) end
    end
  end
  return ids
end

-- What the quests in the log count so far: "quest:name" = count.
local function questCounts()
  local p, order = slainPattern()
  local counts = {}
  for _, id in ipairs(questIds()) do
    local ok, objectives = pcall(C_QuestLog.GetQuestObjectives, id)
    for _, o in ipairs(ok and objectives or {}) do
      if o.type == "monster" and o.text and not secret(o.text) then
        local got, out = { o.text:match(p) }, {}
        for i, v in ipairs(got) do
          out[order[i] or i] = v
        end
        local name, have = out[1], tonumber(out[2])
        if name and have then counts[id .. ":" .. name] = have end
      end
    end
  end
  return counts
end

local function credited(name, n)
  C_Timer.After(2, function()
    local times, now, left = told[name] or {}, time(), n
    for i = #times, 1, -1 do
      if now - times[i] > 10 then
        table.remove(times, i)
      elseif left > 0 then
        table.remove(times, i)
        left = left - 1
      end
    end
    local id = left > 0 and idByName(name)
    for _ = 1, id and left or 0 do
      slay(id)
      table.remove(told[name]) -- (not a kill the event told)
    end
  end)
end

local lastCounts
ns.on("QUEST_LOG_UPDATE", function()
  local counts = questCounts()
  for key, have in pairs(counts) do
    local before = lastCounts and lastCounts[key]
    if before and have > before then credited(key:match("^%d+:(.+)$"), have - before) end
  end
  lastCounts = counts
end)

-- ── loot ─────────────────────────────────────────────────────────────────────
-- What each corpse gave (the loot window names its source).
local looted, lootedOrder = {}, {}
ns.on("LOOT_OPENED", function()
  local creatures = ns.journal().creatures
  for slot = 1, GetNumLootItems() do
    local link = GetLootSlotLink(slot)
    local itemId = link and tonumber(link:match("item:(%d+)"))
    local sources = { GetLootSourceInfo(slot) }
    for i = 1, #sources, 2 do
      local guid, count = sources[i], sources[i + 1] or 1
      local id = creatureId(guid)
      if id then
        local rec = creatures[id]
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
end)

-- ── counts ───────────────────────────────────────────────────────────────────
-- The creatures recorded, by family key.
function ns.metByFamily()
  local by = {}
  for id, rec in pairs(ns.journal().creatures) do
    local key = ns.familyKey(id, rec)
    if key then
      by[key] = by[key] or {}
      table.insert(by[key], id)
    end
  end
  return by
end

-- Creatures recorded, families, kills.
function ns.counts()
  local c = ns.journal()
  local creatures, families, slain = 0, 0, 0
  for _, rec in pairs(c and c.creatures or {}) do
    creatures, slain = creatures + 1, slain + (rec.slain or 0)
  end
  for _ in pairs(c and c.families or {}) do
    families = families + 1
  end
  return creatures, families, slain
end
