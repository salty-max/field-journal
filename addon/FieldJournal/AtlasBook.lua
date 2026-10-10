-- The Atlas's tab in the book: on the left, the travels and the zones
-- entered, by continent, with how many of their places are explored; on the
-- right, a zone's page (the surveyor's note, the zone's own map with the fog
-- this character has lifted and its deaths and close calls marked, then its
-- record) or the travels. Records: Atlas.lua.
local _, ns = ...
local D = ns.data
local A = D.atlas or { zones = {}, continents = {} }
local F = D.flora or { fish = {}, herbs = {}, fishOrder = {}, herbOrder = {} }
local ui = ns.ui
local T, SOFT = ui.T, ui.SOFT

local book, list, page
local current -- a zone's uiMap, or nil for the travels
local selectedPlace -- a place's key, picked out on its zone's page
local pins, rows, pairsPool = {}, {}, {}
ns.atlasRows, ns.atlasPairs = rows, pairsPool -- for the tests
local MAP_W = ui.WIDTH
local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"

local function day(stamp) return ui.day(stamp) end
local function when(stamp)
  if not stamp or stamp.retro or not stamp.at then return "before the journal" end
  return ("%s, you were level %d"):format(day(stamp), stamp.level or 0)
end

local function entered(uiMap)
  local z = ns.atlas().zones[uiMap]
  return z and (z.first or z.retro or next(z.places or {})) and true or false
end

-- Folded or open zones, per character (open[uiMap] = true / false).
local function opened()
  local c = ns.journal()
  c.atlasOpen = c.atlasOpen or {}
  return c.atlasOpen
end

-- The places of a zone this character has discovered, in the order found
-- (those from before the journal first, by name).
local function discoveredPlaces(uiMap)
  local z = ns.atlas().zones[uiMap]
  local out = {}
  for _, place in ipairs(A.zones[uiMap].places) do
    local rec = z and z.places[ns.placeKey(place)]
    if rec then table.insert(out, { place = place, rec = rec }) end
  end
  table.sort(out, function(a, b)
    local ta, tb = a.rec.at or 0, b.rec.at or 0
    if ta ~= tb then return ta < tb end
    return a.place[1] < b.place[1]
  end)
  return out
end

-- ── the list ─────────────────────────────────────────────────────────────────
-- Continents, the zones entered in each (a bar and a count of their places
-- explored), and under an open zone the places discovered, in the order they
-- were found: never the ones still to find. Zones fold; the one you stand in
-- opens on its own. The search box finds zones and places by name.
local function style(r, kind)
  if kind == "zone" then
    r.fold:SetPoint("TOPLEFT", 4, -4)
    r.text:SetPoint("TOPLEFT", 20, -3)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.BODY_FONT, 12, "")
    r.text:SetTextColor(unpack(T.text))
    return 18
  elseif kind == "place" then
    r.text:SetPoint("LEFT", 30, 0)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.BODY_FONT, 11, "")
    r.text:SetTextColor(unpack(T.soft))
    return 16
  end
  -- a continent ("section"), or the travels
  local section = kind == "section"
  r.text:SetPoint("LEFT", 4, 0)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetFont(section and ui.TITLE_FONT or ui.BODY_FONT, section and 14 or 12, "")
  r.text:SetTextColor(unpack(T.gold))
  return section and 22 or 18
end

-- A zone's progress: a bar under its name, the count beside it.
local function progress(r, done, total)
  if not r.bar then
    r.bar = ui.progressBar(r)
    r.bar:SetHeight(4)
  end
  list:grow(r, 14)
  r.bar:ClearAllPoints()
  r.bar:SetPoint("BOTTOMLEFT", 20, 5)
  r.bar:SetPoint("BOTTOMRIGHT", -44, 5)
  r.bar:SetMinMaxValues(0, total)
  r.bar:SetValue(done)
  r.bar:Show()
  r.count:SetPoint("LEFT", r.bar, "RIGHT", 6, 0)
  r.count:SetText(("%d/%d"):format(done, total))
end

local function continents()
  local out = {}
  for id, name in pairs(A.continents) do
    table.insert(out, { id, name })
  end
  table.sort(out, function(a, b) return a[2] < b[2] end)
  table.insert(out, { 0, "Elsewhere" })
  return out
end

-- The zones of a continent entered (and found by the search), each with the
-- places shown under it.
local function zonesOf(continent, hit)
  local zones = {}
  for uiMap, zone in pairs(A.zones) do
    if zone.continent == continent and entered(uiMap) then
      local zoneHit = hit(ns.zoneName(uiMap))
      local shown = {}
      for _, p in ipairs(discoveredPlaces(uiMap)) do
        if zoneHit or hit(p.place[1]) then table.insert(shown, p) end
      end
      if zoneHit or #shown > 0 then table.insert(zones, { uiMap, shown }) end
    end
  end
  table.sort(zones, function(a, b) return ns.zoneName(a[1]) < ns.zoneName(b[1]) end)
  return zones
end

local function refreshList()
  local q = ui.query(book)
  local searching = q ~= ""
  local function hit(name) return not searching or name:lower():find(q, 1, true) ~= nil end
  local standing = ns.atlasHere()
  list:begin()
  if not searching then
    local r = list:add("travels", "Travels")
    r:SetScript("OnClick", function()
      current, selectedPlace = nil, nil
      ns.refresh()
    end)
    if current == nil then list:pick(r) end
  end
  local only = ns.filterOf(ns.TAB.atlas)
  for _, c in ipairs(continents()) do
    local zones = (only == "all" or only == c[1]) and zonesOf(c[1], hit) or {}
    if #zones > 0 then
      list:gap(6)
      list:add("section", c[2])
    end
    for _, z in ipairs(zones) do
      local uiMap, shown = z[1], z[2]
      local done, total = ns.zoneProgress(uiMap)
      local open = opened()[uiMap]
      if open == nil then open = uiMap == standing end
      open = open or searching
      local r = list:add("zone", ns.zoneName(uiMap))
      r.zone = uiMap
      if total > 0 then
        ui.fold(r, open)
        r.fold:SetShown(#shown > 0)
        progress(r, done, total)
      end
      r:SetScript("OnClick", function()
        -- the open zone's row folds it; any other opens its page, unfolded
        local isOpen = opened()[uiMap] or (opened()[uiMap] == nil and uiMap == standing)
        if current == uiMap and not selectedPlace and isOpen then
          opened()[uiMap] = false
        else
          opened()[uiMap] = true
          current, selectedPlace = uiMap, nil
        end
        ns.refresh()
      end)
      if current == uiMap and not selectedPlace then list:pick(r) end
      for _, p in ipairs(open and shown or {}) do
        local pr = list:add("place", p.place[1])
        local key = ns.placeKey(p.place)
        pr.zone, pr.place = uiMap, key
        pr:SetScript("OnClick", function()
          current, selectedPlace = uiMap, key
          ns.refresh()
        end)
        if current == uiMap and selectedPlace == key then list:pick(pr) end
      end
    end
  end
  list:finish()
end

-- ── the zone's map ───────────────────────────────────────────────────────────
-- The world map's own art, the overlays of the places this character has
-- explored on top (as the world map draws them), scaled to the page; deaths
-- and close calls marked (marks: x and y are percents of the zone's map).
local function tile(map, n, file, x, y, w, h, coords)
  local t = map.tiles[n]
  if not t then
    t = map.canvas:CreateTexture(nil, "ARTWORK")
    map.tiles[n] = t
  end
  t:SetDrawLayer(coords and "ARTWORK" or "BACKGROUND")
  t:ClearAllPoints()
  t:SetPoint("TOPLEFT", map.canvas, "TOPLEFT", x, -y)
  t:SetSize(w, h)
  t:SetTexture(file)
  t:SetTexCoord(unpack(coords or { 0, 1, 0, 1 }))
  t:Show()
end

-- The side of the texture file holding a part of an overlay: the power of
-- two that fits it.
local function fileSize(px)
  local s = 16
  while s < px do
    s = s * 2
  end
  return s
end

local function pin(i, map)
  local p = pins[i]
  if p then return p end
  p = CreateFrame("Button", nil, map)
  p:SetSize(14, 14)
  p.icon = p:CreateTexture(nil, "OVERLAY")
  p.icon:SetAllPoints()
  p:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(self.title, 1, 0.82, 0)
    GameTooltip:AddLine(self.text, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  p:SetScript("OnLeave", function() GameTooltip:Hide() end)
  pins[i] = p
  return p
end

local function drawMap(uiMap, marks)
  local map = page.map
  local layers = C_Map.GetMapArtLayers(uiMap)
  local layer = layers and layers[1]
  if not layer or ns.secret(layer) then return false end
  local w, h = layer.layerWidth, layer.layerHeight
  local TW, TH = layer.tileWidth, layer.tileHeight
  local scale = MAP_W / w
  map:SetSize(MAP_W, h * scale)
  map.canvas:SetSize(w, h)
  map.canvas:SetScale(scale)
  for _, t in ipairs(map.tiles) do
    t:Hide()
  end
  local n = 0
  -- the art
  local files = C_Map.GetMapArtLayerTextures(uiMap, 1) or {}
  local cols = math.ceil(w / TW)
  for r = 1, math.ceil(h / TH) do
    for c = 1, cols do
      local file = files[(r - 1) * cols + c]
      if file then
        n = n + 1
        tile(map, n, file, TW * (c - 1), TH * (r - 1), TW, TH)
      end
    end
  end
  -- the places explored
  for _, info in ipairs(C_MapExplorationInfo.GetExploredMapTextures(uiMap) or {}) do
    if not info.isShownByMouseOver then
      local wide, tall = math.ceil(info.textureWidth / TW), math.ceil(info.textureHeight / TH)
      for j = 1, tall do
        local ph = j < tall and TH or (info.textureHeight % TH == 0 and TH or info.textureHeight % TH)
        local fh = j < tall and TH or fileSize(ph)
        for k = 1, wide do
          local pw = k < wide and TW or (info.textureWidth % TW == 0 and TW or info.textureWidth % TW)
          local fw = k < wide and TW or fileSize(pw)
          local file = info.fileDataIDs[(j - 1) * wide + k]
          if file then
            n = n + 1
            local x, y = info.offsetX + TW * (k - 1), info.offsetY + TH * (j - 1)
            tile(map, n, file, x, y, pw, ph, { 0, pw / fw, 0, ph / fh })
          end
        end
      end
    end
  end
  -- the marks
  for i, m in ipairs(marks) do
    local p = pin(i, map)
    p:SetFrameLevel(map:GetFrameLevel() + 5)
    p:ClearAllPoints()
    p:SetPoint("CENTER", map, "TOPLEFT", m.x / 100 * MAP_W, -m.y / 100 * h * scale)
    p.icon:SetTexture(m.icon)
    p.title, p.text = m.title, m.text
    p:Show()
  end
  page:place(map, h * scale + 16)
  return true
end

-- ── the zone's page ──────────────────────────────────────────────────────────
-- What grows and bites in a zone (the data's herbs and fish): the ones this
-- character has found named, the rest only counted (no spoilers).
local function inThisZone(order, data, recs, uiMap, wanted)
  local found, rest = {}, 0
  for _, id in ipairs(order) do
    local d = data[id]
    if not wanted or wanted(d) then
      for _, z in ipairs(d.zones) do
        if z == uiMap then
          if not recs[id] then
            rest = rest + 1
          else
            table.insert(found, d.kind == "record" and d.name or ui.itemName(id, d.name))
          end
          break
        end
      end
    end
  end
  table.sort(found)
  if #found == 0 and rest == 0 then return nil end
  if #found == 0 then return SOFT .. ("none found yet; %d to find|r"):format(rest) end
  local text = table.concat(found, ", ")
  if rest > 0 then text = text .. SOFT .. ("; %d more to find|r"):format(rest) end
  return text
end

local function inZone(events, uiMap)
  local out = {}
  for _, e in ipairs(events or {}) do
    if e.zone == uiMap then table.insert(out, e) end
  end
  return out
end

local function eventLine(e) return ("%s, level %d%s"):format(day(e), e.level or 0, e.by and (" - " .. e.by) or "") end

-- The page, laid out again: the map and its marks hidden too.
local function start(title, sub, picture)
  for _, p in ipairs(pins) do
    p:Hide()
  end
  page.map:Hide()
  page:start(title, sub, ui.icon(picture))
end

local function showZone(uiMap, placeKey)
  local zone, z = A.zones[uiMap], ns.atlas().zones[uiMap] or { places = {} }
  local done, total = ns.zoneProgress(uiMap)
  local explored = total > 0 and ("%d of %d places explored"):format(done, total) or nil
  start(
    ns.zoneName(uiMap),
    table.concat({ A.continents[zone.continent] or "Elsewhere", explored }, "  -  "),
    "Interface\\Icons\\INV_Misc_Map_01"
  )
  page:text(zone.note) -- the surveyor's note
  -- The map, with this character's deaths and close calls.
  local marks = {}
  local deaths, calls = inZone(ns.atlas().deaths, uiMap), inZone(ns.atlas().closeCalls, uiMap)
  for _, e in ipairs(deaths) do
    if e.x then table.insert(marks, { x = e.x, y = e.y, icon = SKULL, title = "Died here", text = eventLine(e) }) end
  end
  for _, e in ipairs(calls) do
    if e.x then table.insert(marks, { x = e.x, y = e.y, icon = CLOSE, title = "A close call", text = eventLine(e) }) end
  end
  local picked
  for _, place in ipairs(zone.places) do
    if ns.placeKey(place) == placeKey then picked = place end
  end
  page.map.pick:Hide()
  if drawMap(uiMap, marks) and picked then
    -- the picked place: its area outlined on the map
    page.map.pick:ClearAllPoints()
    page.map.pick:SetPoint("TOPLEFT", page.map.canvas, "TOPLEFT", picked[2], -picked[3])
    page.map.pick:SetSize(picked[4] - picked[2], picked[5] - picked[3])
    page.map.pick:Show()
  end
  if picked then
    page:section(picked[1])
    page:row("Discovered", when(z.places[placeKey]))
  end
  -- The record.
  page:section("Travels here")
  page:row("First visit", when(z.first or (z.retro and { retro = true }) or nil))
  if z.last and z.last.at ~= (z.first and z.first.at) then page:row("Last seen", when(z.last)) end
  if z.visits then page:row("Visits", tostring(z.visits)) end
  if total > 0 then
    local names = {}
    for _, place in ipairs(zone.places) do
      if z.places[ns.placeKey(place)] then table.insert(names, place[1]) end
    end
    page:row("Explored", #names > 0 and table.concat(names, ", ") or (SOFT .. "nothing yet|r"))
    if done < total then page:row("", SOFT .. ("%d still to find."):format(total - done) .. "|r") end
  end
  local c = ns.journal()
  local herbs = inThisZone(F.herbOrder, F.herbs, c.plants or {}, uiMap)
  local fish = inThisZone(F.fishOrder, F.fish, c.fish or {}, uiMap, function(d) return d.kind ~= "quest" end)
  if herbs or fish then
    page:section("What grows and bites here")
    page:row("Herbs", herbs)
    page:row("Fish", fish)
  end
  if #deaths > 0 or #calls > 0 then
    page:section("Close to the end")
    for _, e in ipairs(deaths) do
      page:row("Died", eventLine(e))
    end
    for _, e in ipairs(calls) do
      page:row("Close call", eventLine(e))
    end
  end
  -- Flights from or to this zone (a taxi node is named "Place, Zone").
  local name, routes = ns.zoneName(uiMap), {}
  for route, n in pairs(ns.atlas().routes or {}) do
    if route:find(name, 1, true) then table.insert(routes, { route, n }) end
  end
  if #routes > 0 then
    table.sort(routes, function(a, b) return a[2] > b[2] end)
    page:section("Flights")
    for _, r in ipairs(routes) do
      page:row(r[2] == 1 and "Once" or ("%d times"):format(r[2]), r[1])
    end
  end
end

-- ── the travels' page ────────────────────────────────────────────────────────
local function showTravels()
  local a = ns.atlas()
  local zones, places, explored = 0, 0, 0
  for uiMap in pairs(A.zones) do
    if entered(uiMap) then
      zones = zones + 1
      local done, total = ns.zoneProgress(uiMap)
      explored, places = explored + done, places + total
    end
  end
  start("Travels", ("%d zones entered, %d places explored"):format(zones, explored), "Interface\\Icons\\INV_Misc_Map02")
  page:section("The road so far")
  page:row("Zones", tostring(zones))
  page:row("Places", ("%d explored of %d in the zones entered"):format(explored, places))
  local top, topN = nil, 0
  for route, n in pairs(a.routes or {}) do
    if n > topN then
      top, topN = route, n
    end
  end
  local often = top and (" (most often: %s, %d times)"):format(top, topN) or ""
  page:row("Flights", ("%d%s"):format(#(a.flights or {}), often))
  if #(a.crossings or {}) > 0 then page:row("Crossings", ("%d between continents"):format(#a.crossings)) end
  local bind = a.binds and a.binds[#a.binds]
  if bind then page:row("Hearth", ("%s, since %s"):format(bind.place, day(bind))) end
  page:row("Deaths", tostring(#(a.deaths or {})))
  page:row("Close calls", tostring(#(a.closeCalls or {})))
  if #(a.deaths or {}) > 0 then
    page:section("The last deaths")
    for i = #a.deaths, math.max(1, #a.deaths - 9), -1 do
      local e = a.deaths[i]
      page:row(e.zone and ns.zoneName(e.zone) or "?", eventLine(e))
    end
  end
end

local function refresh()
  local n = 0
  for uiMap in pairs(A.zones) do
    if entered(uiMap) then n = n + 1 end
  end
  book.count:SetText(("%d zones in the atlas"):format(n))
  refreshList()
  if current then
    showZone(current, selectedPlace)
  else
    showTravels()
  end
  page:finish()
end

-- ── building ─────────────────────────────────────────────────────────────────
local function build(b)
  book = b
  list = ui.newList(book.left, style, rows, true)
  page = ui.newPage(book.sheet, "FieldJournalAtlasPage", 100, pairsPool)
  local map = CreateFrame("Frame", nil, page.child)
  map:SetClipsChildren(true)
  map.canvas = CreateFrame("Frame", nil, map)
  map.canvas:SetPoint("TOPLEFT")
  map.tiles = {}
  map.pick = CreateFrame("Frame", nil, map.canvas, "BackdropTemplate")
  map.pick:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 24 })
  map.pick:SetBackdropBorderColor(1, 0.82, 0)
  map.pick:Hide()
  map.border = CreateFrame("Frame", nil, map, "BackdropTemplate")
  map.border:SetAllPoints()
  map.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  map.border:SetBackdropBorderColor(unpack(ui.T.ring))
  map.border:SetFrameLevel(map:GetFrameLevel() + 8)
  page.map = map
end

-- The select's lands: every one, or a continent entered (none not yet seen).
local function lands()
  local out = { { value = "all", text = "Every land" } }
  for _, c in ipairs(continents()) do
    if #zonesOf(c[1], function() return true end) > 0 then table.insert(out, { value = c[1], text = c[2] }) end
  end
  return out
end

ns.addTab(ns.TAB.atlas, {
  build = build,
  show = function(n)
    list:SetShown(n == ns.TAB.atlas)
    page:SetShown(n == ns.TAB.atlas)
  end,
  refresh = refresh,
  filter = { default = "all", options = lands },
})

-- Open the book at a zone's page (fieldjournal:z<uiMap>: a link in chat).
function ns.openZone(uiMap)
  if not (A.zones[uiMap] and ns.journal()) then return end
  current, selectedPlace = uiMap, nil
  opened()[uiMap] = true
  ns.openTab(ns.TAB.atlas)
end
