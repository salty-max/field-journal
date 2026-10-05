-- The Atlas's tab in the book (built on first opening, in the Bestiary's
-- panels): on the left, the travels and the zones entered, by continent, with
-- how many of their places are explored; on the right, a zone's page (the
-- surveyor's note, the zone's own map with the fog this character has lifted
-- and its deaths and close calls marked, then its record) or the travels.
local _, ns = ...
local D = ns.data
local A = D.atlas or { zones = {}, continents = {} }

local ui
local book, list, page
local current -- a zone's uiMap, or nil for the travels
local rows, pairsPool, lines, pins = {}, {}, {}, {}
ns.atlasRows = rows -- for the tests

local ROW_WIDTH = 204
local MAP_W -- the page's width

local function day(stamp) return date("%d %b %Y", stamp and stamp.at or 0) end
local function when(stamp)
  if not stamp or stamp.retro or not stamp.at then return "before the journal" end
  return ("%s, you were level %d"):format(day(stamp), stamp.level or 0)
end

-- ── the list ─────────────────────────────────────────────────────────────────
-- Continents, the zones entered in each (a bar and a count of their places
-- explored), and under an open zone the places discovered, in the order they
-- were found: never the ones still to find. Zones fold; the one you stand in
-- opens on its own. The search box finds zones and places by name.
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = ui.label(r, ui.BODY_FONT, 12, ui.T.text)
  r.text:SetWordWrap(false)
  r.count = ui.label(r, ui.BODY_FONT, 10, ui.T.soft)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r.bar = CreateFrame("StatusBar", nil, r)
  r.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  r.bar:SetStatusBarColor(0.85, 0.65, 0.13)
  r.bar:SetHeight(4)
  local bg = r.bar:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
  rows[i] = r
  return r
end

local function entered(uiMap)
  local z = ns.atlas() and ns.atlas().zones[uiMap]
  return z and (z.first or z.retro or next(z.places or {})) and true or false
end

local selectedPlace -- a place's key, picked out on its zone's page
local showZone, showTravels

-- Folded or open zones, per character (open[uiMap] = true / false).
local function opened()
  local c = ns.journal()
  if not c then return {} end
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

local PLUS, MINUS = "Interface\\Buttons\\UI-PlusButton-Up", "Interface\\Buttons\\UI-MinusButton-Up"

local function refreshList()
  for _, r in ipairs(rows) do r:Hide() end
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local searching = query ~= ""
  local function hit(name) return not searching or name:lower():find(query, 1, true) ~= nil end
  local i, y, selectedY = 0, 0, nil
  local function add(kind, text)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.kind, r.zone, r.place = kind, nil, nil
    r.text:SetText(text)
    r.text:ClearAllPoints()
    r.count:ClearAllPoints()
    r.count:SetText("")
    r.fold:Hide()
    r.bar:Hide()
    r.selected:Hide()
    r:Enable()
    local height
    if kind == "section" then
      r.text:SetPoint("LEFT", 4, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.TITLE_FONT, 14, "")
      r.text:SetTextColor(unpack(ui.T.gold))
      height = 22
    elseif kind == "zone" then
      r.fold:ClearAllPoints()
      r.fold:SetPoint("TOPLEFT", 4, -4)
      r.text:SetPoint("TOPLEFT", 20, -3)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(ui.T.text))
      height = 18
    elseif kind == "place" then
      r.text:SetPoint("LEFT", 30, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.BODY_FONT, 11, "")
      r.text:SetTextColor(unpack(ui.T.soft))
      height = 16
    else -- the travels
      r.text:SetPoint("LEFT", 4, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(ui.T.gold))
      height = 18
    end
    r:SetHeight(height)
    y = y + height
    r:Show()
    return r
  end
  local function select(r)
    r.selected:Show()
    r.text:SetTextColor(1, 1, 1)
    selectedY = y
  end

  if not searching then
    local r = add("travels", "Travels")
    r:SetScript("OnClick", function() showTravels(); refreshList() end)
    if current == nil then select(r) end
  end
  local continents = {}
  for id, name in pairs(A.continents) do table.insert(continents, { id, name }) end
  table.sort(continents, function(a, b) return a[2] < b[2] end)
  table.insert(continents, { 0, "Elsewhere" })
  local standing = ns.atlasHere and ns.atlasHere()
  for _, c in ipairs(continents) do
    local zones = {}
    for uiMap, zone in pairs(A.zones) do
      if zone.continent == c[1] and entered(uiMap) then
        local places = discoveredPlaces(uiMap)
        local shown = {}
        local zoneHit = hit(ns.zoneName(uiMap))
        for _, p in ipairs(places) do
          if zoneHit or hit(p.place[1]) then table.insert(shown, p) end
        end
        if zoneHit or #shown > 0 then table.insert(zones, { uiMap, shown }) end
      end
    end
    if #zones > 0 then
      table.sort(zones, function(a, b) return ns.zoneName(a[1]) < ns.zoneName(b[1]) end)
      y = y + 6
      add("section", c[2])
      for _, z in ipairs(zones) do
        local uiMap, shown = z[1], z[2]
        local done, total = ns.zoneProgress(uiMap)
        local open = opened()[uiMap]
        if open == nil then open = uiMap == standing end
        open = open or searching
        local r = add("zone", ns.zoneName(uiMap))
        r.zone = uiMap
        if total > 0 then
          -- the progress: a bar under the name, the count beside it
          r:SetHeight(32)
          y = y + 14
          r.fold:SetTexture(open and MINUS or PLUS)
          r.fold:SetShown(#shown > 0)
          r.bar:ClearAllPoints()
          r.bar:SetPoint("BOTTOMLEFT", 20, 5)
          r.bar:SetPoint("BOTTOMRIGHT", -44, 5)
          r.bar:SetMinMaxValues(0, total)
          r.bar:SetValue(done)
          r.bar:Show()
          r.count:SetPoint("LEFT", r.bar, "RIGHT", 6, 0)
          r.count:SetText(("%d/%d"):format(done, total))
        end
        r:SetScript("OnClick", function()
          -- the open zone's row folds it; any other opens its page, unfolded
          if current == uiMap and not selectedPlace and (opened()[uiMap] or (opened()[uiMap] == nil and uiMap == standing)) then
            opened()[uiMap] = false
          else
            opened()[uiMap] = true
            showZone(uiMap)
          end
          refreshList()
        end)
        if current == uiMap and not selectedPlace then select(r) end
        if open then
          for _, p in ipairs(shown) do
            local pr = add("place", p.place[1])
            local key = ns.placeKey(p.place)
            pr.zone, pr.place = uiMap, key
            pr:SetScript("OnClick", function()
              showZone(uiMap, key)
              refreshList()
            end)
            if current == uiMap and selectedPlace == key then select(pr) end
          end
        end
      end
    end
  end
  list.child:SetHeight(y + 8)
  list:UpdateThumb()
  -- Keep the selection in view.
  if selectedY then
    local top, height = list:GetVerticalScroll(), list:GetHeight()
    if selectedY - 18 < top or selectedY > top + height then list:ScrollTo(selectedY - height / 2) end
  end
end

-- ── the page ─────────────────────────────────────────────────────────────────
local function pair(i)
  local p = pairsPool[i]
  if p then return p end
  p = CreateFrame("Frame", nil, page.child)
  p:SetSize(MAP_W, 16)
  p.label = ui.label(p, ui.BODY_FONT, 12, ui.T.soft)
  p.label:SetPoint("TOPLEFT", 0, 0)
  p.label:SetWidth(100)
  p.value = ui.label(p, ui.BODY_FONT, 12, ui.T.text)
  p.value:SetPoint("TOPLEFT", 108, 0)
  p.value:SetWidth(MAP_W - 108)
  p.value:SetSpacing(4)
  pairsPool[i] = p
  return p
end
ns.atlasPairs = pairsPool -- for the tests

local function heading(i)
  local h = lines[i]
  if h then return h end
  h = CreateFrame("Frame", nil, page.child)
  h:SetSize(MAP_W, 24)
  h.text = ui.label(h, ui.TITLE_FONT, 16, ui.T.gold)
  h.text:SetPoint("BOTTOMLEFT", 0, 5)
  h.line = ui.rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  lines[i] = h
  return h
end

-- Lays out a page: header, then blocks (a heading, label/value rows), from y.
local y, hi, pi
local function start()
  for _, x in ipairs(pairsPool) do x:Hide() end
  for _, x in ipairs(lines) do x:Hide() end
  for _, x in ipairs(pins) do x:Hide() end
  page.map:Hide()
  page.note:Hide()
  y, hi, pi = ui.HEADER_H + 2, 0, 0
end
local function section(title)
  hi = hi + 1
  local h = heading(hi)
  h.text:SetText(title)
  h:ClearAllPoints()
  h:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  h:Show()
  y = y + 34
end
local function row2(name, value)
  if not value then return end
  pi = pi + 1
  local p = pair(pi)
  p.label:SetText(name)
  p.value:SetText(value)
  p:ClearAllPoints()
  p:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  local height = math.max(16, p.value:GetStringHeight())
  p:SetHeight(height)
  p:Show()
  y = y + height + 8
end
local function finish()
  page.child:SetHeight(y + 24)
  page:ScrollTo(0)
end

-- The zone's map: the world map's own art, the overlays of the places this
-- character has explored on top (as the world map draws them), scaled to the
-- page; deaths and close calls marked.
local function drawMap(uiMap, marks)
  local map = page.map
  local layers = C_Map.GetMapArtLayers and C_Map.GetMapArtLayers(uiMap)
  local layer = layers and layers[1]
  if not layer or ns.secret(layer) then return false end
  local w, h = layer.layerWidth, layer.layerHeight
  local scale = MAP_W / w
  map:SetSize(MAP_W, h * scale)
  map.canvas:SetSize(w, h)
  map.canvas:SetScale(scale)
  for _, t in ipairs(map.tiles) do t:Hide() end
  local n = 0
  local function tile(file, x, y, tw, th, coords)
    n = n + 1
    local t = map.tiles[n]
    if not t then
      t = map.canvas:CreateTexture(nil, "ARTWORK")
      map.tiles[n] = t
    end
    t:SetDrawLayer(coords and "ARTWORK" or "BACKGROUND")
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", map.canvas, "TOPLEFT", x, -y)
    t:SetSize(tw, th)
    t:SetTexture(file)
    if coords then t:SetTexCoord(unpack(coords)) else t:SetTexCoord(0, 1, 0, 1) end
    t:Show()
  end
  -- the art
  local files = C_Map.GetMapArtLayerTextures(uiMap, 1) or {}
  local cols, tilesRows = math.ceil(w / layer.tileWidth), math.ceil(h / layer.tileHeight)
  for r = 1, tilesRows do
    for c = 1, cols do
      local file = files[(r - 1) * cols + c]
      if file then tile(file, layer.tileWidth * (c - 1), layer.tileHeight * (r - 1), layer.tileWidth, layer.tileHeight) end
    end
  end
  -- the places explored
  local TW, TH = layer.tileWidth, layer.tileHeight
  local function fileSize(px) local s = 16; while s < px do s = s * 2 end; return s end
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
            tile(file, info.offsetX + TW * (k - 1), info.offsetY + TH * (j - 1), pw, ph, { 0, pw / fw, 0, ph / fh })
          end
        end
      end
    end
  end
  -- the marks: x and y are percents of the zone's map
  for i, m in ipairs(marks) do
    local pin = pins[i]
    if not pin then
      pin = CreateFrame("Button", nil, map)
      pin:SetSize(14, 14)
      pin.icon = pin:CreateTexture(nil, "OVERLAY")
      pin.icon:SetAllPoints()
      pin:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(self.title, 1, 0.82, 0)
        GameTooltip:AddLine(self.text, 1, 1, 1, true)
        GameTooltip:Show()
      end)
      pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
      pins[i] = pin
    end
    pin:SetFrameLevel(map:GetFrameLevel() + 5)
    pin:ClearAllPoints()
    pin:SetPoint("CENTER", map, "TOPLEFT", m.x / 100 * MAP_W, -m.y / 100 * h * scale)
    pin.icon:SetTexture(m.icon)
    pin.title, pin.text = m.title, m.text
    pin:Show()
  end
  map:ClearAllPoints()
  map:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  map:Show()
  y = y + h * scale + 16
  return true
end

local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"

local function inZone(list, uiMap)
  local out = {}
  for _, e in ipairs(list or {}) do
    if e.zone == uiMap then table.insert(out, e) end
  end
  return out
end

local function eventLine(e)
  return ("%s, level %d%s"):format(day(e), e.level or 0, e.by and (" - " .. e.by) or "")
end

function showZone(uiMap, placeKey)
  current, selectedPlace = uiMap, placeKey
  local zone, z = A.zones[uiMap], ns.atlas().zones[uiMap] or { places = {} }
  start()
  local done, total = ns.zoneProgress(uiMap)
  page.title:SetText(ns.zoneName(uiMap))
  page.sub:SetText(table.concat({ A.continents[zone.continent] or "Elsewhere",
    total > 0 and ("%d of %d places explored"):format(done, total) or nil }, "  -  "))
  ui.icon("Interface\\Icons\\INV_Misc_Map_01")(page.portrait)
  -- The surveyor's note.
  if zone.note and #zone.note > 0 then
    page.note:SetText(table.concat(zone.note, "\n\n"))
    page.note:ClearAllPoints()
    page.note:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
    page.note:Show()
    y = y + page.note:GetStringHeight() + 20
  end
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
    local rec = z.places[placeKey]
    section(picked[1])
    row2("Discovered", when(rec))
  end
  -- The record.
  section("Travels here")
  row2("First visit", when(z.first or (z.retro and { retro = true }) or nil))
  if z.last and z.last.at ~= (z.first and z.first.at) then row2("Last seen", when(z.last)) end
  if z.visits then row2("Visits", tostring(z.visits)) end
  if total > 0 then
    local names = {}
    for _, place in ipairs(zone.places) do
      if z.places[ns.placeKey(place)] then table.insert(names, place[1]) end
    end
    row2("Explored", #names > 0 and table.concat(names, ", ") or (ui.SOFT .. "nothing yet|r"))
    if done < total then row2("", ui.SOFT .. ("%d still to find."):format(total - done) .. "|r") end
  end
  if #deaths > 0 or #calls > 0 then
    section("Close to the end")
    for _, e in ipairs(deaths) do row2("Died", eventLine(e)) end
    for _, e in ipairs(calls) do row2("Close call", eventLine(e)) end
  end
  -- Flights from or to this zone (a taxi node is named "Place, Zone").
  local name, routes = ns.zoneName(uiMap), {}
  for route, n in pairs(ns.atlas().routes or {}) do
    if route:find(name, 1, true) then table.insert(routes, { route, n }) end
  end
  if #routes > 0 then
    table.sort(routes, function(a, b) return a[2] > b[2] end)
    section("Flights")
    for _, r in ipairs(routes) do row2(r[2] == 1 and "Once" or ("%d times"):format(r[2]), r[1]) end
  end
  finish()
end

function showTravels()
  current, selectedPlace = nil, nil
  local a = ns.atlas()
  start()
  local zones, places, explored = 0, 0, 0
  for uiMap in pairs(A.zones) do
    if entered(uiMap) then
      zones = zones + 1
      local done, total = ns.zoneProgress(uiMap)
      explored, places = explored + done, places + total
    end
  end
  page.title:SetText("Travels")
  page.sub:SetText(("%d zones entered, %d places explored"):format(zones, explored))
  ui.icon("Interface\\Icons\\INV_Misc_Map02")(page.portrait)
  section("The road so far")
  row2("Zones", tostring(zones))
  row2("Places", ("%d explored of %d in the zones entered"):format(explored, places))
  local top, topN = nil, 0
  for route, n in pairs(a.routes or {}) do
    if n > topN then top, topN = route, n end
  end
  row2("Flights", ("%d%s"):format(#(a.flights or {}), top and (" (most often: %s, %d times)"):format(top, topN) or ""))
  if #(a.crossings or {}) > 0 then row2("Crossings", ("%d between continents"):format(#a.crossings)) end
  local bind = a.binds and a.binds[#a.binds]
  if bind then row2("Hearth", ("%s, since %s"):format(bind.place, day(bind))) end
  row2("Deaths", tostring(#(a.deaths or {})))
  row2("Close calls", tostring(#(a.closeCalls or {})))
  if #(a.deaths or {}) > 0 then
    section("The last deaths")
    for i = #a.deaths, math.max(1, #a.deaths - 9), -1 do
      local e = a.deaths[i]
      row2(e.zone and ns.zoneName(e.zone) or "?", eventLine(e))
    end
  end
  finish()
end

function ns.refreshAtlas()
  if not list then return end
  book.count:SetText(("%d zones in the atlas"):format((function()
    local n = 0
    for uiMap in pairs(A.zones) do if entered(uiMap) then n = n + 1 end end
    return n
  end)()))
  refreshList()
  if current then showZone(current, selectedPlace) else showTravels() end
end

-- ── building ─────────────────────────────────────────────────────────────────
function ns.buildAtlasBook(b)
  ui = ns.ui
  book = b
  MAP_W = ui.WIDTH
  list = ui.scrollArea(book.left, ROW_WIDTH)
  list:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -40)
  list:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -18, 12)
  page = ui.scrollArea(book.sheet, MAP_W)
  _G.FieldJournalAtlasPage = page
  page:SetPoint("TOPLEFT", book.sheet, "TOPLEFT", 26, -22)
  page:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT", -22, 14)
  book.atlasList, book.atlasPage = list, page

  page.portrait = ui.roundPortrait(page.child, 64)
  page.portrait:SetPoint("TOPLEFT", 2, -2)
  page.title = ui.label(page.child, ui.TITLE_FONT, 24, ui.T.gold)
  page.title:SetPoint("TOPLEFT", page.portrait, "TOPRIGHT", 16, -8)
  page.title:SetWidth(MAP_W - 86)
  page.title:SetWordWrap(false)
  page.sub = ui.label(page.child, ui.BODY_FONT, 12, ui.T.soft)
  page.sub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -7)
  page.sub:SetWidth(MAP_W - 86)
  local headerRule = ui.rule(page.child)
  headerRule:SetPoint("TOPLEFT", 0, -76)
  headerRule:SetPoint("TOPRIGHT", 0, -76)
  page.note = ui.label(page.child, ui.BODY_FONT, 13, ui.T.text)
  page.note:SetWidth(MAP_W)
  page.note:SetSpacing(4)

  page.map = CreateFrame("Frame", nil, page.child)
  page.map:SetClipsChildren(true)
  page.map.canvas = CreateFrame("Frame", nil, page.map)
  page.map.canvas:SetPoint("TOPLEFT")
  page.map.tiles = {}
  page.map.pick = CreateFrame("Frame", nil, page.map.canvas, "BackdropTemplate")
  page.map.pick:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 24 })
  page.map.pick:SetBackdropBorderColor(1, 0.82, 0)
  page.map.pick:Hide()
  page.map.border = CreateFrame("Frame", nil, page.map, "BackdropTemplate")
  page.map.border:SetAllPoints()
  page.map.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  page.map.border:SetBackdropBorderColor(0.72, 0.56, 0.24)
  page.map.border:SetFrameLevel(page.map:GetFrameLevel() + 8)
end

-- Open the book at a zone's page (fieldjournal:z<uiMap>: a link in chat).
function ns.openZone(uiMap)
  if not A.zones[uiMap] then return end
  local b = ns.ui.build()
  current, selectedPlace = uiMap, nil
  opened()[uiMap] = true
  if not b:IsShown() then b:Show() end
  ns.showTab(ns.TAB.atlas)
end
