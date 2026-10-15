-- The Atlas: where this character has been. Each character records its own:
--   YonderChar.atlas = {
--     zones[uiMap] = { first, last = { at, level }, visits, retro,
--                      places[areaId] = { at, level, retro } },
--     deaths[], closeCalls[] = { at, level, zone, x, y, by },
--     flights[] = { from, to, at, level }, routes["from > to"] = count,
--     crossings[] = { from, to, at, level }   (zone uiMaps: boats, zeppelins, portals)
--     binds[] = { place, at, level }           (each new hearthstone bind)
--   }
-- A zone's places are its map's explorable parts (D.atlas, from the client's
-- own tables: name, hover rectangle on the map art, the areas it covers). A
-- place is explored once the character has discovered one of its areas, as
-- the game reports at points inside it (C_MapExplorationInfo's
-- GetExploredAreaIDsAtPosition: the character's own discoveries, not the
-- overlays the map draws, some of which it draws for everyone). What a
-- character had already discovered before the Atlas is recorded quietly at
-- its first login (retro).
local _, ns = ...
local L = ns.kit.L
local D = ns.data
local A = D.atlas or { zones = {}, continents = {} }
local PREFIX = ns.PREFIX
local secret = ns.secret

-- A place: { name, left, top, right, bottom, area ids... }, keyed by its
-- first area id (stable across game builds).
local FIRST_AREA = 6
local function placeKey(place) return place[FIRST_AREA] end
ns.placeKey = placeKey

local function stamp() return { at = time(), level = UnitLevel("player") } end

function ns.atlas()
  local c = ns.journal()
  if not c then return end
  local a = c.atlas
  if not a then
    a = { zones = {}, deaths = {}, closeCalls = {}, flights = {}, routes = {}, crossings = {}, binds = {}, version = 4 }
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
    local info = C_Map.GetMapInfo(uiMap)
    uiMap = info and info.parentMapID
  end
end

local function here()
  local best = C_Map.GetBestMapForUnit("player")
  if not best or secret(best) then return end
  local zone = zoneOf(best)
  if not zone then return end
  local pos = C_Map.GetPlayerMapPosition(zone, "player")
  local x, y
  if pos and not secret(pos) then
    if pos.GetXY then
      x, y = pos:GetXY()
    else
      x, y = pos.x, pos.y
    end
    if secret(x) or secret(y) then
      x, y = nil, nil
    end
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

-- The map art's size (the places' rectangles are in its pixels).
local function artSize(uiMap)
  local layers = C_Map.GetMapArtLayers(uiMap)
  local layer = layers and not secret(layers) and layers[1]
  if layer and layer.layerWidth and layer.layerWidth > 0 then return layer.layerWidth, layer.layerHeight end
  return 1002, 668
end

-- Points inside a place's rectangle where to ask: the centre, then around it.
local SAMPLES = { { 0.5, 0.5 }, { 0.3, 0.3 }, { 0.7, 0.3 }, { 0.3, 0.7 }, { 0.7, 0.7 } }

-- Has the character discovered one of the place's areas? Never asked of a
-- place the map draws for everyone (visit: Forever's Moonglade and a few
-- others): the game would say yes; those count once visited (below).
local function discovered(uiMap, place, w, h)
  if place.visit then return false end
  local ask = C_MapExplorationInfo and C_MapExplorationInfo.GetExploredAreaIDsAtPosition
  if not (ask and CreateVector2D) then return false end
  local areas = {}
  for i = FIRST_AREA, #place do
    areas[place[i]] = true
  end
  for _, s in ipairs(SAMPLES) do
    local x = place[2] + (place[4] - place[2]) * s[1]
    local y = place[3] + (place[5] - place[3]) * s[2]
    local ids = ask(uiMap, CreateVector2D(x / w, y / h))
    if ids and not secret(ids) then
      for _, id in ipairs(ids) do
        if areas[id] then return true end
      end
    end
  end
  return false
end
ns.placeDiscovered = discovered

-- Records the places of a zone the character has discovered. quiet: before
-- the Atlas looked (no date of discovery).
local function syncZone(uiMap, quiet)
  local zone = A.zones[uiMap]
  if not zone or #zone.places == 0 then return 0 end
  local known = ns.atlas().zones[uiMap]
  local w, h = artSize(uiMap)
  local found = 0
  for _, place in ipairs(zone.places) do
    local key = placeKey(place)
    if not (known and known.places[key]) and discovered(uiMap, place, w, h) then
      local z = zoneRecord(uiMap)
      known = z
      z.places[key] = quiet and { retro = true } or stamp()
      found = found + 1
      if quiet and not z.first then z.retro = true end
    end
  end
  return found
end
ns.syncAtlasZone = syncZone

-- Versions 0.3.0 and 0.3.1 counted places the game shows as explored for
-- everyone (Moonglade's overlay, Forever's Dalaran): what they imported is
-- cleared, and the milestones of exploration they gave that no longer hold
-- are withdrawn; then the Atlas is seeded again from the character's own
-- discoveries.
local VERSION = 4 -- 3: places only of the areas a character can discover; 4: visit-only places
local function migrate(a)
  for uiMap, z in pairs(a.zones) do
    for key, p in pairs(z.places or {}) do
      if p.retro then z.places[key] = nil end
    end
    if z.retro and not z.first then z.retro = nil end
    if not z.first and not next(z.places or {}) then a.zones[uiMap] = nil end
  end
  a.seeded, a.version = nil, VERSION
end

local function withdraw()
  local c = ns.journal()
  for id in pairs(c and c.achievements or {}) do
    local m = ns.milestoneById and ns.milestoneById[id]
    if m and (m.group == "explore" or id:find("^continent%-")) then
      local done, need = m.progress()
      if done < need then c.achievements[id] = nil end
    end
  end
end

-- The first time a character's Atlas is opened: every zone's discoveries,
-- quietly.
local function seed()
  local a = ns.atlas()
  if not a then return end
  if a.version ~= VERSION then
    local old = a.seeded
    migrate(a)
    if old then
      for uiMap in pairs(A.zones) do
        syncZone(uiMap, true)
      end
      a.seeded = true
      withdraw()
      ns.checkMilestones(true)
      return
    end
  end
  if a.seeded then return end
  for uiMap in pairs(A.zones) do
    syncZone(uiMap, true)
  end
  a.seeded = true
  -- milestones already deserved by the fog lifted: quietly
  ns.checkMilestones(true)
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
    if
      from
      and from.continent ~= 0
      and A.zones[zone].continent ~= 0
      and from.continent ~= A.zones[zone].continent
      and not UnitOnTaxi("player")
    then
      keep(ns.atlas().crossings, { from = lastZone, to = zone, at = now.at, level = now.level }, 200)
    end
    lastZone = zone
    if new then
      local link = ("|cffffd100|Hyonder:z%d|h[%s]|h|r"):format(zone, ns.zoneName(zone))
      print(PREFIX .. L["%s added to the atlas."]:format(link))
    end
  end
  z.last = now
  syncZone(zone)
  -- Places the game can't tell us about: visited when the zone or subzone
  -- you stand in bears the name of one of their areas.
  local here1, here2 = GetRealZoneText(), GetSubZoneText()
  for _, place in ipairs(A.zones[zone].places) do
    local key = placeKey(place)
    if place.visit and not z.places[key] then
      for i = FIRST_AREA, #place do
        local name = C_Map.GetAreaInfo(place[i]) or (i == FIRST_AREA and place[1])
        if name and not secret(name) and (name == here1 or name == here2) then
          z.places[key] = stamp()
          break
        end
      end
    end
  end
  ns.checkMilestones()
  ns.onAtlas()
end

function ns.zoneName(uiMap)
  local info = C_Map.GetMapInfo(uiMap)
  return (info and info.name) or (A.zones[uiMap] and A.zones[uiMap].name) or "?"
end

-- An area a journal recorded by its name, in the client's language of the
-- day: the client's own name for it (the data's areas by their English names,
-- so an English journal reads French on a French client); a name it doesn't
-- know stays as recorded.
local areaByEnglish
function ns.areaName(name)
  if not name or name == "" then return name end
  if not areaByEnglish then
    areaByEnglish = {}
    for id, n in pairs(A.areaNames or {}) do
      if not areaByEnglish[n] or id < areaByEnglish[n] then areaByEnglish[n] = id end
    end
  end
  local id = areaByEnglish[name]
  local own = id and C_Map.GetAreaInfo and C_Map.GetAreaInfo(id)
  if own and own ~= "" then return own end
  -- (a place inside a building: a translation's own list)
  return ns.subzoneNames and ns.subzoneNames[name] or name
end
-- An area's English name from its name in the client's language, by its id:
-- the game's C_Map.GetAreaInfo for each of the data's areas, the reverse made
-- once (a place inside a building: a translation's list, reversed). The journal
-- keeps places in English, by what the game says they are, so a journal kept
-- in one language reads in another (ns.areaName); a name the data doesn't know
-- is kept as the game gave it.
local areaHere, builtWith
function ns.areaEnglish(name)
  if not name or name == "" or secret(name) then return name end
  -- (made again only if the game's function is another: the tests' clients)
  if not areaHere or builtWith ~= C_Map.GetAreaInfo then
    areaHere, builtWith = {}, C_Map.GetAreaInfo
    for id, english in pairs(A.areaNames or {}) do
      local own = C_Map.GetAreaInfo and C_Map.GetAreaInfo(id)
      if type(own) == "string" and own ~= "" and (not areaHere[own] or id < areaHere[own][1]) then
        areaHere[own] = { id, english }
      end
    end
    for english, own in pairs(ns.subzoneNames or {}) do
      if not areaHere[own] then areaHere[own] = { 0, english } end
    end
  end
  local hit = areaHere[name]
  return hit and hit[2] or name
end
-- A place recorded as "Zone: Subzone": each part in the client's language,
-- joined as the language joins them.
function ns.placeText(p)
  if not p then return p end
  local zone, sub = p:match("^(.-): (.+)$")
  if not zone then return ns.areaName(p) end
  return L["%s: %s"]:format(ns.areaName(zone), ns.areaName(sub))
end

-- How many of a zone's places this character has explored, of how many.
function ns.zoneProgress(uiMap)
  local zone, z = A.zones[uiMap], ns.atlas() and ns.atlas().zones[uiMap]
  if not zone then return 0, 0 end
  local n = 0
  for _, place in ipairs(zone.places) do
    if z and z.places[placeKey(place)] then n = n + 1 end
  end
  return n, #zone.places
end

-- ── deaths and close calls ───────────────────────────────────────────────────
-- What hurt the player last: the combat log's damage on Classic; on Forever,
-- which closes the combat log, the last foe targeted in a fight.
local lastHit, lastFoe, lastFoeId
-- (its name, and its creature's id where the game gave it: its name in any
-- language, ns.creatureName)
local function foe()
  if lastHit and time() - lastHit.at <= 10 then return lastHit.name, lastHit.id end
  return lastFoe, lastFoeId
end
local function npcOf(guid)
  local id = type(guid) == "string" and not secret(guid) and guid:match("^%a+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
  return id and tonumber(id) or nil
end

if not ns.forever then
  ns.on("COMBAT_LOG_EVENT_UNFILTERED", function()
    local _, sub, _, source, sourceName, _, _, dest = CombatLogGetCurrentEventInfo()
    if dest == UnitGUID("player") and sourceName and (sub == "SWING_DAMAGE" or sub:find("_DAMAGE$")) then
      lastHit = { name = sourceName, id = npcOf(source), at = time() }
    end
  end)
end
ns.on("PLAYER_TARGET_CHANGED", function()
  if not UnitExists("target") or UnitIsPlayer("target") then return end
  local canAttack, name = UnitCanAttack("player", "target"), UnitName("target")
  if not secret(canAttack) and canAttack and name and not secret(name) then
    lastFoe, lastFoeId = name, npcOf(UnitGUID("target"))
  end
end)

local function mark(list, most)
  local zone, x, y = here()
  local s = stamp()
  local by, byId = foe()
  keep(list, { at = s.at, level = s.level, zone = zone, x = x, y = y, by = by, byId = byId }, most)
end

ns.on("PLAYER_DEAD", function()
  mark(ns.atlas().deaths, 500)
  ns.onAtlas()
end)

-- A close call: under a tenth of your health, and still alive five seconds
-- later. One a minute at most.
local pending, lastClose = false, 0
ns.onUnit("UNIT_HEALTH", "player", function()
  if pending or time() - lastClose < 60 then return end
  local h, max = UnitHealth("player"), UnitHealthMax("player")
  if secret(h) or secret(max) or not max or max == 0 or h <= 0 or h / max >= 0.1 then return end
  pending = true
  local function check()
    pending = false
    if UnitIsDeadOrGhost("player") then return end
    lastClose = time()
    mark(ns.atlas().closeCalls, 500)
    ns.checkMilestones()
    ns.onAtlas()
  end
  C_Timer.After(5, check)
end)

-- ── travel ───────────────────────────────────────────────────────────────────
-- A flight point's id from its name in the client's language (this language's
-- names, the data's English where the game keeps it); its English name, which
-- a flight and a route keep (one route in any language); its name in today's.
local taxiHere, taxiBuilt
function ns.taxiId(name)
  if not name or secret(name) then return nil end
  if not taxiHere or taxiBuilt ~= ns.taxiNames then
    taxiHere, taxiBuilt = {}, ns.taxiNames
    for id, n in pairs(A.taxi or {}) do
      if not taxiHere[n] or id < taxiHere[n] then taxiHere[n] = id end
    end
    for id, n in pairs(ns.taxiNames or {}) do
      taxiHere[n] = id
    end
  end
  return taxiHere[name]
end
function ns.taxiEnglish(name)
  local id = ns.taxiId(name)
  return id and A.taxi and A.taxi[id] or name
end
function ns.taxiName(english)
  local id = ns.taxiId(english)
  return id and ((ns.taxiNames or {})[id] or (A.taxi or {})[id]) or english
end
-- A route kept as "From > To" (English): in today's language.
function ns.routeText(route)
  local from, to = route:match("^(.-) > (.+)$")
  if not from then return route end
  return ns.taxiName(from) .. " > " .. ns.taxiName(to)
end

-- A flight: the taxi map names where you are (the current node) and where you
-- asked to go; kept by its points' ids, in English.
hooksecurefunc("TakeTaxiNode", function(index)
  local to = TaxiNodeName(index)
  local from
  for i = 1, NumTaxiNodes() do
    if TaxiNodeGetType(i) == "CURRENT" then from = TaxiNodeName(i) end
  end
  if not (to and from) then return end
  local fromId, toId = ns.taxiId(from), ns.taxiId(to)
  from, to = ns.taxiEnglish(from), ns.taxiEnglish(to)
  local a, s = ns.atlas(), stamp()
  keep(a.flights, { from = from, to = to, fromId = fromId, toId = toId, at = s.at, level = s.level }, 300)
  local route = from .. " > " .. to
  a.routes[route] = (a.routes[route] or 0) + 1
  ns.checkMilestones()
  ns.onAtlas()
end)

ns.on("HEARTHSTONE_BOUND", function()
  local place = ns.areaEnglish(GetBindLocation())
  if not place then return end
  local s = stamp()
  keep(ns.atlas().binds, { place = place, at = s.at, level = s.level }, 100)
  ns.checkMilestones()
end)

-- ── /yonder atlas: what the game reports here (for testing) ─────────────────
function ns.atlasReport()
  local zone, x, y = here()
  if not zone then
    print(PREFIX .. L["no zone of the atlas here (or the game hides where you are)."])
    return
  end
  local w, h = artSize(zone)
  print(
    PREFIX
      .. (L["%s (map %d), at %s, %s, map art %dx%d."]):format(ns.zoneName(zone), zone, tostring(x), tostring(y), w, h)
  )
  local z = ns.atlas().zones[zone]
  for _, place in ipairs(A.zones[zone].places) do
    local now = discovered(zone, place, w, h)
    local rec = z and z.places[placeKey(place)]
    print(
      L["  %s: %s%s"]:format(
        place[1],
        now and L["discovered"] or L["not discovered"],
        rec and (rec.retro and L[", recorded before the journal"] or L[", recorded"]) or ""
      )
    )
  end
  local a = ns.atlas()
  local placed = 0
  for _, e in ipairs(a.deaths) do
    if e.x then placed = placed + 1 end
  end
  print(
    L["  deaths recorded: %d (%d with a position), close calls: %d, world map pins: %s."]:format(
      #a.deaths,
      placed,
      #a.closeCalls,
      (ns.option("worldMapPins") and "on" or "off")
        .. (ns.worldMapPinsAttached and L[", attached to the map"] or L[", not attached"])
    )
  )
end

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
  if zone and syncZone(zone) > 0 then
    ns.checkMilestones()
    ns.onAtlas()
  end
end)
