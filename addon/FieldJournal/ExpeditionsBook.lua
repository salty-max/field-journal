-- The Expeditions' tab in the book: on the left, by continent, the zones
-- entered that hold riddles for this character (and their faction's own
-- capitals), each with how many are solved, its riddles under it once opened
-- (a solved one by its answer's name, the others by their verse's first
-- line); on the right, a riddle's page: its verse, where it lies and how
-- dangerous it is, whether it asks something there, the two hints, each asked
-- for, and once solved its seal, the naturalist's note and the margin, which
-- only the gold seal opens. Records: Expeditions.lua.
local _, ns = ...
local D = ns.data
local X = D.expeditions or {}
local A = D.atlas or { zones = {}, continents = {} }
local ui = ns.ui
local T, SOFT = ui.T, ui.SOFT

local book, list, page
local current -- a riddle's id, a zone's uiMap, or nil for the overview
local last -- the page shown last (kept where it was scrolled, while the same)
local rows, pairsPool = {}, {}
ns.expeditionRows, ns.expeditionPairs = rows, pairsPool -- for the tests

local NOTE = "Interface\\Icons\\INV_Misc_Note_02"
local MAP = "Interface\\Icons\\INV_Misc_Map_01"
local BOOK = "Interface\\Icons\\INV_Misc_Book_09"
local SEALS = {
  gold = { "Interface\\Icons\\INV_Misc_Coin_01", "Gold", "from the verse alone", { 1, 0.82, 0 } },
  silver = { "Interface\\Icons\\INV_Misc_Coin_03", "Silver", "with the clue", { 0.78, 0.8, 0.84 } },
  plain = { "Interface\\Icons\\INV_Misc_Coin_05", "Plain", "with the map", { 0.8, 0.55, 0.35 } },
}
local TIERS = { near = "Near the road", off = "Off the road", hidden = "Hidden", town = "In town" }

local function faction()
  local f = UnitFactionGroup("player")
  return f and not ns.secret(f) and f:lower() or nil
end

local function entered(uiMap)
  local z = ns.atlas().zones[uiMap]
  return z ~= nil and (z.first ~= nil or z.retro ~= nil or next(z.places or {}) ~= nil)
end

-- A zone in the book: one with riddles for this character, entered (or its
-- faction's own ground: the capitals, the starting zones).
local function shown(uiMap)
  if #ns.riddlesOf(uiMap) == 0 then return false end
  return entered(uiMap) or (X[uiMap].home ~= nil and X[uiMap].home == faction())
end

local function progress(uiMap)
  local done, total = 0, 0
  for _, r in ipairs(ns.riddlesOf(uiMap)) do
    total = total + 1
    if ns.riddleSolved(r.id) then done = done + 1 end
  end
  return done, total
end

-- A riddle's title: its answer's name once solved, else its tier.
local function title(r)
  if ns.riddleSolved(r.id) then return ns.riddleName(r) end
  return TIERS[r.tier]
end

-- Folded or open zones, per character (open[uiMap] = true).
local function opened()
  local c = ns.journal()
  c.expeditionsOpen = c.expeditionsOpen or {}
  return c.expeditionsOpen
end

-- ── the list ─────────────────────────────────────────────────────────────────
local function style(r, kind)
  if kind == "zone" then
    r.fold:SetPoint("TOPLEFT", 4, -4)
    r.text:SetPoint("TOPLEFT", 20, -3)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.BODY_FONT, 12, "")
    r.text:SetTextColor(unpack(T.text))
    return 18
  elseif kind == "riddle" then
    r.text:SetPoint("LEFT", 30, 0)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.BODY_FONT, 11, "")
    r.text:SetTextColor(unpack(T.soft))
    return 16
  end
  -- a continent ("section"), or the overview
  local section = kind == "section"
  r.text:SetPoint("LEFT", 4, 0)
  r.text:SetPoint("RIGHT", -4, 0)
  r.text:SetFont(section and ui.TITLE_FONT or ui.BODY_FONT, section and 14 or 12, "")
  r.text:SetTextColor(unpack(T.gold))
  return section and 22 or 18
end

local function bar(r, done, total)
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
  return out
end

local function zonesOf(continent)
  local out = {}
  for uiMap in pairs(X) do
    if A.zones[uiMap] and A.zones[uiMap].continent == continent and shown(uiMap) then table.insert(out, uiMap) end
  end
  table.sort(out, function(a, b) return ns.zoneName(a) < ns.zoneName(b) end)
  return out
end

local function refreshList()
  local q = ui.query(book)
  local searching = q ~= ""
  local only = ns.filterOf(ns.TAB.expeditions)
  -- a riddle is found by its answer once solved, by its verse before
  local function hit(r)
    if not searching then return true end
    local words = ns.riddleSolved(r.id) and ns.riddleName(r) or table.concat(r.verse, " ")
    return words:lower():find(q, 1, true) ~= nil
  end
  local function wanted(r) return (only ~= "open" or not ns.riddleSolved(r.id)) and hit(r) end
  list:begin()
  if not searching then
    local r = list:add("overview", "Expeditions")
    r:SetScript("OnClick", function()
      current = nil
      ns.refresh()
    end)
    if current == nil then list:pick(r) end
    list:gap(4)
  end
  for _, c in ipairs(continents()) do
    local zones = {}
    for _, uiMap in ipairs(zonesOf(c[1])) do
      local riddles = {}
      local zoneHit = searching and ns.zoneName(uiMap):lower():find(q, 1, true) ~= nil
      for _, r in ipairs(ns.riddlesOf(uiMap)) do
        if (zoneHit and (only ~= "open" or not ns.riddleSolved(r.id))) or wanted(r) then table.insert(riddles, r) end
      end
      if #riddles > 0 then table.insert(zones, { uiMap, riddles }) end
    end
    if #zones > 0 then
      list:add("section", c[2])
      for _, z in ipairs(zones) do
        local uiMap, riddles = z[1], z[2]
        local open = searching or opened()[uiMap]
        local r = list:add("zone", ns.zoneName(uiMap))
        r.zone = uiMap
        ui.fold(r, open)
        r.fold:Show()
        bar(r, progress(uiMap))
        r:SetScript("OnClick", function()
          opened()[uiMap] = not opened()[uiMap]
          current = uiMap
          ns.refresh()
        end)
        if current == uiMap then list:pick(r) end
        if open then
          for _, riddle in ipairs(riddles) do
            local solved = ns.riddleSolved(riddle.id)
            local row = list:add("riddle", solved and ns.riddleName(riddle) or riddle.verse[1])
            row.id = riddle.id
            if solved then
              local seal = SEALS[ns.riddleSeal(ns.riddleRecord(riddle.id))]
              row.text:SetTextColor(unpack(seal[4]))
            end
            row:SetScript("OnClick", function()
              current = riddle.id
              ns.refresh()
            end)
            if current == riddle.id then list:pick(row) end
          end
        end
      end
      list:gap(6)
    end
  end
  list:finish()
end

-- ── the pages ────────────────────────────────────────────────────────────────
local function when(rec) return ("%s, you were level %d"):format(ui.day(rec), rec.level or 0) end

-- A hint asked for, as the game asks before something can't be undone.
local ASK = {
  "Ask for a clue? This riddle will no longer earn its gold seal.",
  "Shade its place on your world map? This riddle will no longer earn its silver seal.",
}
StaticPopupDialogs.FIELDJOURNAL_HINT = {
  text = "%s",
  button1 = YES,
  button2 = NO,
  OnAccept = function(_, data) ns.takeHint(data.id, data.n) end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}
local function ask(id, n) StaticPopup_Show("FIELDJOURNAL_HINT", ASK[n], nil, { id = id, n = n }) end

local function button(i)
  local b = page.buttons[i]
  if b then return b end
  b = CreateFrame("Button", nil, page.child, "UIPanelButtonTemplate")
  b:SetSize(200, 24)
  page.buttons[i] = b
  return b
end

local function start(name, sub, picture)
  for _, b in ipairs(page.buttons) do
    b:Hide()
  end
  page:start(name, sub, ui.icon(picture))
end

local function showRiddle(r)
  local rec = ns.riddleRecord(r.id) or {}
  local solved = rec.at ~= nil
  local seal = solved and SEALS[ns.riddleSeal(rec)]
  -- (unsolved, its title is its tier already)
  local sub = solved and table.concat({ ns.zoneName(r.zone), TIERS[r.tier] }, "  -  ") or ns.zoneName(r.zone)
  start(title(r), sub, seal and seal[1] or NOTE)
  page:text({ table.concat(r.verse, "\n") })
  page:section("The riddle")
  page:row("Danger", r.danger)
  if r.asks == "gesture" then
    page:row("It asks", "something of you there")
  elseif r.asks == "reading" then
    page:row("It asks", "a reading there")
  end
  if r.night then page:row("When", "by night") end
  local hints = rec.hints or 0
  if hints >= 1 then page:row("The clue", r.hint) end
  if hints >= 2 then
    page:row("The map", solved and "its place was shaded on your world map" or "its place is shaded on your world map")
  end
  if not solved and hints < 2 then
    local b = button(1)
    b:SetText(hints == 0 and "Ask for a clue" or "Ask for the map")
    b:SetScript("OnClick", function() ask(r.id, hints + 1) end)
    page:place(b, 34)
  end
  if solved then
    page:section("Solved")
    page:row("Solved", when(rec))
    page:row("Seal", ("%s, %s"):format(seal[2], seal[3]))
    page:row("Note", ns.riddleNote(r))
    if hints == 0 then
      page:row("Margin", ns.riddleMargin(r))
    else
      page:row("Margin", SOFT .. "only a gold seal opens it|r")
    end
  end
end

local function showZone(uiMap)
  local done, total = progress(uiMap)
  start(ns.zoneName(uiMap), ("%d of %d riddles solved"):format(done, total), MAP)
  page:section("Its riddles")
  for _, r in ipairs(ns.riddlesOf(uiMap)) do
    local rec = ns.riddleRecord(r.id)
    local value = rec and rec.at and ns.riddleName(r) or (SOFT .. r.verse[1] .. "|r")
    page:row(TIERS[r.tier], value)
  end
end

local function seals()
  local n = { gold = 0, silver = 0, plain = 0 }
  for _, rec in pairs(ns.expeditions().riddles) do
    if rec.at then
      local s = ns.riddleSeal(rec)
      n[s] = n[s] + 1
    end
  end
  return n
end

local function totals()
  local done, total = 0, 0
  for uiMap in pairs(X) do
    local d, t = progress(uiMap)
    done, total = done + d, total + t
  end
  return done, total
end

local function showOverview()
  local done, total = totals()
  start("Expeditions", ("%d of %d riddles solved"):format(done, total), BOOK)
  page:text({
    "Every land keeps a few things most travellers walk past: a grave beside a path, a statue nobody explains, "
      .. "a book left on a shelf. Each riddle here leads to one, in a land you have entered. It is solved where it "
      .. "leads, and some ask something of you there, as the story would.",
    "A riddle read from its verse alone earns the gold seal, and opens its margin; the clue costs the gold, the "
      .. "map the silver.",
  })
  page:section("The record")
  page:row("Solved", ("%d of %d"):format(done, total))
  local n = seals()
  page:row("Seals", ("%d gold, %d silver, %d plain"):format(n.gold, n.silver, n.plain))
end

local function refresh()
  local done = totals()
  book.count:SetText(("%d riddles solved"):format(done))
  refreshList()
  local r = type(current) == "string" and ns.riddleById[current]
  if r and ns.riddleOpen(r) then
    showRiddle(r)
  elseif type(current) == "number" and X[current] then
    showZone(current)
  else
    current = nil
    showOverview()
  end
  page:finish(last == current)
  last = current
end

-- ── building ─────────────────────────────────────────────────────────────────
local function build(b)
  book = b
  list = ui.newList(book.left, style, rows, true)
  page = ui.newPage(book.sheet, "FieldJournalExpeditionsPage", 90, pairsPool)
  page.buttons = {}
end

ns.addTab(ns.TAB.expeditions, {
  build = build,
  show = function(n)
    list:SetShown(n == ns.TAB.expeditions)
    page:SetShown(n == ns.TAB.expeditions)
  end,
  refresh = refresh,
  filter = {
    default = "all",
    options = function() return { { value = "all", text = "Every riddle" }, { value = "open", text = "Unsolved" } } end,
  },
})

-- Open the book at a riddle (fieldjournal:x<id>: a link in chat).
function ns.openRiddle(id)
  local r = ns.riddleById[id]
  if not (r and ns.journal()) then return end
  current = id
  opened()[r.zone] = true
  ns.openTab(ns.TAB.expeditions)
end
