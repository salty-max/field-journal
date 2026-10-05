-- The Atlas: where this character has been. Each character records its own:
--   FieldJournalChar.atlas = {
--     zones[uiMap] = { first, last = { at, level }, visits, retro,
--                      places[areaId] = { at, level, retro } },
--     deaths[], closeCalls[] = { at, level, zone, x, y, by },
--     flights[] = { from, to, at, level }, routes["from > to"] = count,
--     crossings[] = { from, to, at, level }   (zone uiMaps: boats, zeppelins, portals)
--     binds[] = { place, at, level }           (each new hearthstone bind)
--   }
-- A zone's places are its map's explorable parts (D.atlas, from the client's
-- own tables): a place is explored once the game lifts its part of the fog,
-- which C_MapExplorationInfo reports. The fog a character had already lifted
-- before the Atlas is recorded quietly at its first login (retro).
local _, ns = ...
local D = ns.data
local A = D.atlas or { zones = {}, continents = {} }
local PREFIX = "|cffc9a227Field Journal:|r "
local secret = ns.secret

-- Each zone's places, by the overlay's offset on the map art and by area id.
local byOffset, byArea = {}, {}
for uiMap, zone in pairs(A.zones) do
  byOffset[uiMap], byArea[uiMap] = {}, {}
  for _, place in ipairs(zone.places) do
    byOffset[uiMap][place[2] .. "," .. place[3]] = place
    for i = 4, #place do byArea[uiMap][place[i]] = place end
  end
end
-- A place is keyed by its first area id (stable across game builds).
local function placeKey(place) return place[4] end

local function stamp() return { at = time(), level = UnitLevel("player") } end

function ns.atlas()
  local c = ns.journal()
  if not c then return end
  local a = c.atlas
  if not a then
    a = { zones = {}, deaths = {}, closeCalls = {}, flights = {}, routes = {}, crossings = {}, binds = {} }
    c.atlas = a
  end
  return a
end

local function keep(list, entry, most)
  table.insert(list, entry)
  if #list > most then table.remove(list, 1) end
end

-- ── where the player is ──────────────────────────────────────────────────────
-- The zone (a map of the Atlas: the best map, or the nearest of its parents)
-- and the position on it. Nothing while the game hides it (secret values).
local function zoneOf(uiMap)
  for _ = 1, 6 do
    if not uiMap or uiMap == 0 then return end
    if A.zones[uiMap] then return uiMap end
    local info = C_Map.GetMapInfo and C_Map.GetMapInfo(uiMap)
    uiMap = info and info.parentMapID
  end
end

local function here()
  local best = C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  if not best or secret(best) then return end
  local zone = zoneOf(best)
  if not zone then return end
  local pos = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(zone, "player")
  local x, y
  if pos and not secret(pos) then
    if pos.GetXY then x, y = pos:GetXY() else x, y = pos.x, pos.y end
    if secret(x) or secret(y) then x, y = nil, nil end
  end
  return zone, x and math.floor(x * 1000 + 0.5) / 10, y and math.floor(y * 1000 + 0.5) / 10
end
ns.atlasHere = here

-- ── places ───────────────────────────────────────────────────────────────────
local function zoneRecord(uiMap)
  local a = ns.atlas()
  local z = a.zones[uiMap]
  if not z then
    z = { places = {} }
    a.zones[uiMap] = z
  end
  return z
end

-- Records the places of a zone the game shows as explored. quiet: lifted
-- before the Atlas looked (no date of discovery).
local function syncZone(uiMap, quiet)
  local textures = C_MapExplorationInfo and C_MapExplorationInfo.GetExploredMapTextures
    and C_MapExplorationInfo.GetExploredMapTextures(uiMap)
  if not textures or secret(textures) then return 0 end
  local found = 0
  for _, t in ipairs(textures) do
    local place = byOffset[uiMap][t.offsetX .. "," .. t.offsetY]
    if place then
      local z = zoneRecord(uiMap)
      local key = placeKey(place)
      if not z.places[key] then
        z.places[key] = quiet and { retro = true } or stamp()
        found = found + 1
        if quiet and not z.first then z.retro = true end
      end
    end
  end
  return found
end
ns.syncAtlasZone = syncZone

-- The first time a character's Atlas is opened: every zone's fog, quietly.
local function seed()
  local a = ns.atlas()
  if not a or a.seeded then return end
  for uiMap in pairs(A.zones) do syncZone(uiMap, true) end
  a.seeded = true
end

-- ── entering zones ───────────────────────────────────────────────────────────
local lastZone
local function enter()
  seed() -- a journal just reset starts again from the fog lifted
  local zone = here()
  if not zone then return end
  local z = zoneRecord(zone)
  local new = not z.first and not z.retro
  local now = stamp()
  if zone ~= lastZone then
    z.first = z.first or now
    z.visits = (z.visits or 0) + 1
    -- A crossing: another continent, not by flight (boats, zeppelins, portals).
    local from = lastZone and A.zones[lastZone]
    if from and from.continent ~= 0 and A.zones[zone].continent ~= 0 and from.continent ~= A.zones[zone].continent
      and not (UnitOnTaxi and UnitOnTaxi("player")) then
      keep(ns.atlas().crossings, { from = lastZone, to = zone, at = now.at, level = now.level }, 200)
    end
    lastZone = zone
    if new and ns.option("chat") then
      print(PREFIX .. ("|cffffd100|Hfieldjournal:z%d|h[%s]|h|r added to the atlas."):format(zone, ns.zoneName(zone)))
    end
  end
  z.last = now
  syncZone(zone)
  if ns.onAtlas then ns.onAtlas() end
end

function ns.zoneName(uiMap)
  local info = C_Map.GetMapInfo and C_Map.GetMapInfo(uiMap)
  return (info and info.name) or (A.zones[uiMap] and A.zones[uiMap].name) or "?"
end

-- How many of a zone's places this character has explored, of how many.
function ns.zoneProgress(uiMap)
  local zone, z = A.zones[uiMap], ns.atlas() and ns.atlas().zones[uiMap]
  local n = 0
  for _ in pairs(z and z.places or {}) do n = n + 1 end
  return n, zone and #zone.places or 0
end

-- ── deaths and close calls ───────────────────────────────────────────────────
-- What hurt the player last: the combat log's damage on Classic; on Forever,
-- which closes the combat log, the last foe targeted in a fight.
local lastHit, lastFoe
local function foe()
  if lastHit and time() - lastHit.at <= 10 then return lastHit.name end
  return lastFoe
end

if not ns.forever then
  ns.on("COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, sub, _, _, sourceName, _, _, dest = CombatLogGetCurrentEventInfo()
    if dest == UnitGUID("player") and sourceName and (sub == "SWING_DAMAGE" or sub:find("_DAMAGE$")) then
      lastHit = { name = sourceName, at = time() }
    end
  end)
end
ns.on("PLAYER_TARGET_CHANGED", function()
  if not UnitExists("target") or UnitIsPlayer("target") then return end
  local canAttack, name = UnitCanAttack("player", "target"), UnitName("target")
  if not secret(canAttack) and canAttack and name and not secret(name) then lastFoe = name end
end)

local function mark(list, most)
  local zone, x, y = here()
  local s = stamp()
  keep(list, { at = s.at, level = s.level, zone = zone, x = x, y = y, by = foe() }, most)
end

ns.on("PLAYER_DEAD", function()
  mark(ns.atlas().deaths, 500)
  if ns.onAtlas then ns.onAtlas() end
end)

-- A close call: under a tenth of your health, and still alive five seconds
-- later. One a minute at most.
local pending, lastClose = false, 0
ns.on("UNIT_HEALTH", function(unit)
  if unit ~= "player" or pending or time() - lastClose < 60 then return end
  local h, max = UnitHealth("player"), UnitHealthMax("player")
  if secret(h) or secret(max) or not max or max == 0 or h <= 0 or h / max >= 0.1 then return end
  pending = true
  local function check()
    pending = false
    if UnitIsDeadOrGhost("player") then return end
    lastClose = time()
    mark(ns.atlas().closeCalls, 500)
    if ns.onAtlas then ns.onAtlas() end
  end
  if C_Timer then C_Timer.After(5, check) else check() end
end)

-- ── travel ───────────────────────────────────────────────────────────────────
-- A flight: the taxi map names where you are (the current node) and where you
-- asked to go.
if hooksecurefunc and TakeTaxiNode then
  hooksecurefunc("TakeTaxiNode", function(index)
    local to = TaxiNodeName(index)
    local from
    for i = 1, NumTaxiNodes() do
      if TaxiNodeGetType(i) == "CURRENT" then from = TaxiNodeName(i) end
    end
    if not (to and from) then return end
    local a, s = ns.atlas(), stamp()
    keep(a.flights, { from = from, to = to, at = s.at, level = s.level }, 300)
    local route = from .. " > " .. to
    a.routes[route] = (a.routes[route] or 0) + 1
    if ns.onAtlas then ns.onAtlas() end
  end)
end

ns.on("HEARTHSTONE_BOUND", function()
  local place = GetBindLocation and GetBindLocation()
  if not place then return end
  local s = stamp()
  keep(ns.atlas().binds, { place = place, at = s.at, level = s.level }, 100)
end)

-- ── events ───────────────────────────────────────────────────────────────────
ns.on("PLAYER_ENTERING_WORLD", function()
  seed()
  enter()
end)
for _, event in ipairs({ "ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS" }) do
  ns.on(event, enter)
end
ns.on("MAP_EXPLORATION_UPDATED", function()
  local zone = here()
  if zone and syncZone(zone) > 0 and ns.onAtlas then ns.onAtlas() end
end)
