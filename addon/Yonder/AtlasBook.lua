-- The Atlas's tab in the book: on the left, the travels and the zones
-- entered, by continent, with how many of their places are explored; on the
-- right, a zone's page (the surveyor's note, the zone's own map with the fog
-- this character has lifted and its deaths and close calls marked, then its
-- record) or the travels. Records: Atlas.lua.
local _, ns = ...
local L = ns.kit.L
local D = ns.data
local A = D.atlas or { zones = {}, continents = {} }
local F = D.flora or { fish = {}, herbs = {}, fishOrder = {}, herbOrder = {} }
local ui = ns.ui
local T = ui.T

local book, list, page
local current -- a zone's uiMap, or nil for the travels
local selectedPlace -- a place's key, picked out on its zone's page
local rows, pairsPool = {}, {}
ns.atlasRows, ns.atlasPairs = rows, pairsPool -- for the tests
local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"

local function day(stamp) return ui.day(stamp) end
local function when(stamp)
  if not stamp or stamp.retro or not stamp.at then return L["before the journal"] end
  return (L["%s, you were level %d"]):format(day(stamp), stamp.level or 0)
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
  table.insert(out, { 0, L["Elsewhere"] })
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
    local r = list:add("travels", L["Travels"])
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

-- ── the zone's page ──────────────────────────────────────────────────────────
-- What grows and bites in a zone (the data's herbs and fish): the ones this
-- character has found, as their items, the rest only counted (no spoilers).
local function foundHere(order, data, recs, uiMap, wanted)
  local found, rest = {}, 0
  for _, id in ipairs(order) do
    local d = data[id]
    if not wanted or wanted(d) then
      for _, z in ipairs(d.zones) do
        if z == uiMap then
          if recs[id] then
            table.insert(found, { id, d.kind == "record" and d.name or ui.itemName(id, d.name) })
          else
            rest = rest + 1
          end
          break
        end
      end
    end
  end
  table.sort(found, function(a, b) return a[2] < b[2] end)
  return found, rest
end

local function inZone(events, uiMap)
  local out = {}
  for _, e in ipairs(events or {}) do
    if e.zone == uiMap then table.insert(out, e) end
  end
  return out
end

local function eventLine(e) return (L["%s, level %d%s"]):format(day(e), e.level or 0, e.by and (" - " .. e.by) or "") end

-- The page, laid out again: the map hidden too.
local MAP_ICON, MAP2_ICON = "Interface\\Icons\\INV_Misc_Map_01", "Interface\\Icons\\INV_Misc_Map02"
local function start(title, sub, picture)
  page.map:Hide()
  page:start(title, sub, ui.icon(picture))
end

-- A section of found items: their icons, and what is still to find.
-- (none, more: what is left to find, worded by the count: "1 herb", "3 herbs")
local function grows(title, found, rest, none, more)
  if #found == 0 and rest == 0 then return end
  page:section(title)
  if #found > 0 then page:items(found) end
  if rest > 0 then page:paragraph((#found == 0 and none or more):format(rest), T.soft) end
end

-- A death or a close call, as a card.
local function eventCard(e, died)
  page:card(
    died and (L["Died, at level %d"]):format(e.level or 0) or (L["A close call, at level %d"]):format(e.level or 0),
    day(e) .. (e.by and ("  -  " .. e.by) or ""),
    function(p)
      p.tex:SetTexture(died and SKULL or CLOSE)
      p.tex:SetTexCoord(0, 1, 0, 1)
    end
  )
end

-- Flights from or to a zone (a taxi node is named "Place, Zone").
local function routesOf(uiMap)
  local name, routes, n = ns.zoneName(uiMap), {}, 0
  for route, times in pairs(ns.atlas().routes or {}) do
    if route:find(name, 1, true) then
      table.insert(routes, { route, times })
      n = n + times
    end
  end
  table.sort(routes, function(a, b) return a[2] > b[2] end)
  return routes, n
end

local function showZone(uiMap, placeKey)
  local zone, z = A.zones[uiMap], ns.atlas().zones[uiMap] or { places = {} }
  local done, total = ns.zoneProgress(uiMap)
  local explored = total > 0 and (L["%d of %d places explored"]):format(done, total) or nil
  start(
    ns.zoneName(uiMap),
    table.concat({ A.continents[zone.continent] or L["Elsewhere"], explored }, "  -  "),
    MAP_ICON
  )
  page:text(zone.note) -- the surveyor's note
  local deaths, calls = inZone(ns.atlas().deaths, uiMap), inZone(ns.atlas().closeCalls, uiMap)
  local routes, flights = routesOf(uiMap)
  -- the figures
  local figures = {}
  if total > 0 then table.insert(figures, { ("%d/%d"):format(done, total), L["places found"] }) end
  table.insert(figures, { tostring(z.visits or ((z.first or z.retro) and 1 or 0)), L["visits"] })
  if flights > 0 then table.insert(figures, { tostring(flights), ns.kit.plural(flights, "flight", "flights") }) end
  if #deaths + #calls > 0 then table.insert(figures, { L["%d / %d"]:format(#deaths, #calls), L["deaths / calls"] }) end
  page:stats(figures)
  -- the map, with this character's deaths and close calls, and the place picked out
  local marks = {}
  for _, e in ipairs(deaths) do
    if e.x then table.insert(marks, { x = e.x, y = e.y, icon = SKULL, title = L["Died here"], text = eventLine(e) }) end
  end
  for _, e in ipairs(calls) do
    if e.x then
      table.insert(marks, { x = e.x, y = e.y, icon = CLOSE, title = L["A close call"], text = eventLine(e) })
    end
  end
  local picked
  for _, place in ipairs(zone.places) do
    if ns.placeKey(place) == placeKey then picked = place end
  end
  page.map.pick:Hide()
  local height = page.map:draw(uiMap, marks)
  if height then page:place(page.map, height + 16) end
  if height and picked then
    -- the picked place: its area outlined on the map
    page.map.pick:ClearAllPoints()
    page.map.pick:SetPoint("TOPLEFT", page.map.canvas, "TOPLEFT", picked[2], -picked[3])
    page.map.pick:SetSize(picked[4] - picked[2], picked[5] - picked[3])
    page.map.pick:Show()
  end
  if picked then
    page:section(picked[1])
    page:row(L["Discovered"], when(z.places[placeKey]))
  end
  -- the places explored, in the order found: a click outlines one on the map
  if total > 0 then
    page:section(L["Places explored"])
    local chips = {}
    for _, d in ipairs(discoveredPlaces(uiMap)) do
      local key = ns.placeKey(d.place)
      table.insert(chips, {
        d.place[1],
        function()
          current, selectedPlace = uiMap, selectedPlace ~= key and key or nil
          ns.refresh()
        end,
        key == placeKey,
        L["Discovered %s. Click to outline it on the map."]:format(when(d.rec)),
      })
    end
    if #chips > 0 then page:chips(chips) end
    if done < total then
      page:paragraph(
        done == 0 and (L["Nothing explored yet: %d places to find."]):format(total)
          or (L["%d still to find."]):format(total - done),
        T.soft
      )
    end
  end
  -- the record
  page:section(L["Travels here"])
  page:row(L["First visit"], when(z.first or (z.retro and { retro = true }) or nil))
  if z.last and z.last.at ~= (z.first and z.first.at) then page:row(L["Last seen"], when(z.last)) end
  -- its expedition
  local edone, etotal
  if ns.expeditionOf then
    edone, etotal = ns.expeditionOf(uiMap)
  end
  if edone then
    page:section(L["Its expedition"])
    page:card(
      -- ("The Barrens Expedition", "The Durotar Expedition")
      (ns.zoneName(uiMap):find("^The ") and L["%s Expedition"] or L["The %s Expedition"]):format(ns.zoneName(uiMap)),
      edone == etotal and L["complete"] or (L["%d of %d done: its riddles and its quarry"]):format(edone, etotal),
      ui.icon("Interface\\Icons\\INV_Misc_Book_09"),
      function() ns.openExpeditionZone(uiMap) end
    )
  end
  -- what grows and bites here
  local c = ns.journal()
  local herbs, herbsLeft = foundHere(F.herbOrder, F.herbs, c.plants or {}, uiMap)
  local fish, fishLeft = foundHere(F.fishOrder, F.fish, c.fish or {}, uiMap, function(d) return d.kind ~= "quest" end)
  local plural = ns.kit.plural
  grows(
    L["What grows here"],
    herbs,
    herbsLeft,
    plural(herbsLeft, "None found here yet: %d herb to find.", "None found here yet: %d herbs to find."),
    plural(herbsLeft, "%d more herb to find here.", "%d more herbs to find here.")
  )
  grows(
    L["What bites here"],
    fish,
    fishLeft,
    plural(fishLeft, "None found here yet: %d fish to find.", "None found here yet: %d fish to find."),
    plural(fishLeft, "%d more fish to find here.", "%d more fish to find here.")
  )
  -- close to the end
  if #deaths + #calls > 0 then
    page:section(L["Close to the end"])
    for _, e in ipairs(deaths) do
      eventCard(e, true)
    end
    for _, e in ipairs(calls) do
      eventCard(e, false)
    end
  end
  if #routes > 0 then
    page:section(L["Flights"])
    for _, r in ipairs(routes) do
      page:row(r[2] == 1 and L["Once"] or (L["%d times"]):format(r[2]), r[1])
    end
  end
end

-- ── the travels' page ────────────────────────────────────────────────────────
-- The places this character discovered last, the latest first: { uiMap, place, rec }.
local function lately(max)
  local out = {}
  for uiMap, zone in pairs(A.zones) do
    local z = ns.atlas().zones[uiMap]
    for _, place in ipairs(zone.places) do
      local rec = z and z.places[ns.placeKey(place)]
      if rec and rec.at and not rec.retro then table.insert(out, { uiMap, place, rec }) end
    end
  end
  table.sort(out, function(a, b) return a[3].at > b[3].at end)
  for i = #out, max + 1, -1 do
    out[i] = nil
  end
  return out
end

local function showTravels()
  local a = ns.atlas()
  local zones, places, explored = 0, 0, 0
  local byContinent = {}
  for uiMap, zone in pairs(A.zones) do
    if entered(uiMap) then
      zones = zones + 1
      local done, total = ns.zoneProgress(uiMap)
      explored, places = explored + done, places + total
      local c = byContinent[zone.continent or 0] or { zones = 0, done = 0, total = 0 }
      c.zones, c.done, c.total = c.zones + 1, c.done + done, c.total + total
      byContinent[zone.continent or 0] = c
    end
  end
  start(L["Travels"], L["%d zones entered, %d places explored"]:format(zones, explored), MAP2_ICON)
  page:stats({
    { tostring(zones), ns.kit.plural(zones, "zone entered", "zones entered") },
    { tostring(explored), L["places found"] },
    { tostring(#(a.flights or {})), "flights" },
    { tostring(#(a.deaths or {})), "deaths" },
  })
  local shownContinents = {}
  for _, c in ipairs(continents()) do
    if byContinent[c[1]] then table.insert(shownContinents, c) end
  end
  if #shownContinents > 0 then
    page:section(L["The lands"])
    for _, c in ipairs(shownContinents) do
      local n = byContinent[c[1]]
      page:card(
        c[2],
        ns.kit
          .plural(n.zones, "%d zone entered, %d of %d places explored", "%d zones entered, %d of %d places explored")
          :format(n.zones, n.done, n.total),
        ui.icon(MAP2_ICON)
      )
    end
  end
  local recent = lately(6)
  if #recent > 0 then
    page:section(L["Lately discovered"])
    for _, x in ipairs(recent) do
      local uiMap, key = x[1], ns.placeKey(x[2])
      page:card(x[2][1], L["%s  -  %s"]:format(ns.zoneName(uiMap), when(x[3])), ui.icon(MAP_ICON), function()
        current, selectedPlace = uiMap, key
        opened()[uiMap] = true
        ns.refresh()
      end)
    end
  end
  page:section(L["The road so far"])
  local top, topN = nil, 0
  for route, n in pairs(a.routes or {}) do
    if n > topN then
      top, topN = route, n
    end
  end
  if top then page:row(L["Flown most"], L["%s, %d times"]:format(top, topN)) end
  if #(a.crossings or {}) > 0 then page:row(L["Crossings"], L["%d between continents"]:format(#a.crossings)) end
  local bind = a.binds and a.binds[#a.binds]
  if bind then page:row(L["Hearth"], L["%s, since %s"]:format(bind.place, day(bind))) end
  page:row(L["Close calls"], tostring(#(a.closeCalls or {})))
  if #(a.deaths or {}) > 0 then
    page:section(L["The last deaths"])
    for i = #a.deaths, math.max(1, #a.deaths - 4), -1 do
      local e = a.deaths[i]
      page:card(e.zone and ns.zoneName(e.zone) or L["Somewhere"], eventLine(e), function(p)
        p.tex:SetTexture(SKULL)
        p.tex:SetTexCoord(0, 1, 0, 1)
      end)
    end
  end
end

local function refresh()
  local n = 0
  for uiMap in pairs(A.zones) do
    if entered(uiMap) then n = n + 1 end
  end
  book.count:SetText(L["%d zones in the atlas"]:format(n))
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
  page = ui.newPage(book.sheet, "YonderAtlasPage", 100, pairsPool)
  local map = ui.newMap(page.child)
  -- (a place picked out: its area outlined)
  map.pick = CreateFrame("Frame", nil, map.canvas, "BackdropTemplate")
  map.pick:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 24 })
  map.pick:SetBackdropBorderColor(1, 0.82, 0)
  map.pick:Hide()
  page.map = map
end

-- The select's lands: every one, or a continent entered (none not yet seen).
local function lands()
  local out = { { value = "all", text = L["Every land"] } }
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

-- Open the book at a zone's page (yonder:z<uiMap>: a link in chat).
function ns.openZone(uiMap)
  if not (A.zones[uiMap] and ns.journal()) then return end
  current, selectedPlace = uiMap, nil
  opened()[uiMap] = true
  ns.openTab(ns.TAB.atlas)
end
