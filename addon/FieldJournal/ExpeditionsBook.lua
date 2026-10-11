-- The Expeditions' tab in the book: on the left, by continent, the zones
-- entered that hold riddles or a quarry for this character (and their
-- faction's own capitals and starting zones), each with how much of it is
-- done, its riddles and its quarry under it once opened (a solved riddle by
-- its answer's name, the others by their verse's first line); on the right, a
-- riddle's page: its verse, how dangerous its place is, whether it asks
-- something there, the two hints, each asked for, and once solved its seal,
-- the naturalist's note and the margin, which only the gold seal opens; or a
-- quarry's poster: its portrait, its verse, its danger, the tracking (its
-- haunts on the world map, at the cost of the gold seal), and once brought
-- down its seal, note and margin. Records: Expeditions.lua.
local _, ns = ...
local D = ns.data
local X = D.expeditions or {}
local A = D.atlas or { zones = {}, continents = {} }
local ui = ns.ui
local T, SOFT = ui.T, ui.SOFT

local book, list, page
local current -- a riddle's id, "quarry:<id>", a zone's uiMap, or nil for the overview
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
-- a quarry's: never tracked, tracked, or brought down before the journal kept the hunts
local HUNT_SEALS = {
  gold = { SEALS.gold[1], "Gold", "never tracked", SEALS.gold[4] },
  plain = { SEALS.plain[1], "Plain", "tracked", SEALS.plain[4] },
  before = { nil, "None", "brought down before the journal kept the hunts", T.soft },
}
local TIERS = { near = "Near the road", off = "Off the road", hidden = "Hidden", town = "In town" }
local RANKS = { elite = "an elite", rare = "a rare", rareelite = "a rare elite" }

local function faction()
  local f = UnitFactionGroup("player")
  return f and not ns.secret(f) and f:lower() or nil
end

local function entered(uiMap)
  local z = ns.atlas().zones[uiMap]
  return z ~= nil and (z.first ~= nil or z.retro ~= nil or next(z.places or {}) ~= nil)
end

-- The zone's quarry, if this character may hunt it.
local function quarryOf(uiMap)
  local q = X[uiMap] and X[uiMap].quarry
  return q and ns.quarryOpen(q) and q or nil
end

-- A zone in the book: one with riddles or a quarry for this character,
-- entered (or its faction's own ground: the capitals, the starting zones).
local function shown(uiMap)
  if #ns.riddlesOf(uiMap) == 0 and not quarryOf(uiMap) then return false end
  return entered(uiMap) or (X[uiMap].home ~= nil and X[uiMap].home == faction())
end

-- Done and to do in a zone: its riddles, its quarry.
local function progress(uiMap)
  local done, total = 0, 0
  for _, r in ipairs(ns.riddlesOf(uiMap)) do
    total = total + 1
    if ns.riddleSolved(r.id) then done = done + 1 end
  end
  local q = quarryOf(uiMap)
  if q then
    total = total + 1
    if ns.quarryDown(q.id) then done = done + 1 end
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

-- A row under a zone: a riddle or its quarry, coloured by its seal once done.
local function item(text, id, seal)
  local row = list:add("riddle", text)
  row.id = id
  if seal then row.text:SetTextColor(unpack(seal[4])) end
  row:SetScript("OnClick", function()
    current = id
    ns.refresh()
  end)
  if current == id then list:pick(row) end
end

local function refreshList()
  local q = ui.query(book)
  local searching = q ~= ""
  local only = ns.filterOf(ns.TAB.expeditions)
  local function found(words) return not searching or words:lower():find(q, 1, true) ~= nil end
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
      local zoneHit = searching and found(ns.zoneName(uiMap))
      local riddles, quarry = {}, nil
      if only ~= "hunts" then
        for _, r in ipairs(ns.riddlesOf(uiMap)) do
          local solved = ns.riddleSolved(r.id)
          -- (a riddle is found by its answer once solved, by its verse before)
          local words = solved and ns.riddleName(r) or table.concat(r.verse, " ")
          if (only ~= "open" or not solved) and (zoneHit or found(words)) then table.insert(riddles, r) end
        end
      end
      local qq = only ~= "riddles" and quarryOf(uiMap)
      if qq and (only ~= "open" or not ns.quarryDown(qq.id)) and (zoneHit or found(qq.name)) then quarry = qq end
      if #riddles > 0 or quarry then table.insert(zones, { uiMap, riddles, quarry }) end
    end
    if #zones > 0 then
      list:add("section", c[2])
      for _, z in ipairs(zones) do
        local uiMap, riddles, quarry = z[1], z[2], z[3]
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
            item(
              solved and ns.riddleName(riddle) or riddle.verse[1],
              riddle.id,
              solved and SEALS[ns.riddleSeal(ns.riddleRecord(riddle.id))]
            )
          end
          if quarry then
            local down = ns.quarryDown(quarry.id)
            item(
              "Quarry: " .. quarry.name,
              "quarry:" .. quarry.id,
              down and HUNT_SEALS[ns.huntSeal(ns.huntRecord(quarry.id))]
            )
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

-- A hint asked for, or a quarry tracked, as the game asks before something
-- that can't be undone.
local ASK = {
  clue = "Ask for a clue? This riddle will no longer earn its gold seal.",
  map = "Shade its place on your world map? This riddle will no longer earn its silver seal.",
  track = "Track this quarry? Its haunts are shaded on your world map, and it will no longer earn its gold seal.",
}
StaticPopupDialogs.FIELDJOURNAL_HINT = {
  text = "%s",
  button1 = YES,
  button2 = NO,
  OnAccept = function(_, data)
    if data.quarry then
      ns.setHuntTarget(data.quarry)
    else
      ns.takeHint(data.id, data.n)
    end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}
local function ask(text, data) StaticPopup_Show("FIELDJOURNAL_HINT", text, nil, data) end

local function button(i)
  local b = page.buttons[i]
  if b then return b end
  b = CreateFrame("Button", nil, page.child, "UIPanelButtonTemplate")
  b:SetSize(200, 24)
  page.buttons[i] = b
  return b
end

-- (picture: an icon's path, or a portrait's setter)
local function start(name, sub, picture)
  for _, b in ipairs(page.buttons) do
    b:Hide()
  end
  page:start(name, sub, type(picture) == "function" and picture or ui.icon(picture))
end

-- A creature's still portrait, by its display id (a note without one).
local function portrait(model)
  return function(p)
    if model and model > 0 and SetPortraitTextureFromCreatureDisplayID then
      p.tex:SetTexCoord(0, 1, 0, 1)
      SetPortraitTextureFromCreatureDisplayID(p.tex, model)
    else
      ui.icon(NOTE)(p)
    end
  end
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
    b:SetScript("OnClick", function() ask(hints == 0 and ASK.clue or ASK.map, { id = r.id, n = hints + 1 }) end)
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

local function danger(q)
  local rank = RANKS[q.rank]
  return rank and ("%s, level %s"):format(rank:gsub("^%l", string.upper), q.level) or ("Level %s"):format(q.level)
end

local function showQuarry(q)
  local rec = ns.huntRecord(q.id) or {}
  local down = rec.at ~= nil
  local seal = down and HUNT_SEALS[ns.huntSeal(rec)]
  start(q.name, ("%s  -  the quarry"):format(ns.zoneName(q.zone)), portrait(q.model))
  page:text({ table.concat(q.verse, "\n") })
  page:section("The hunt")
  page:row("Danger", danger(q))
  local target = ns.huntTarget()
  if not down then
    local tracked = target and target.id == q.id
    page:row("Its haunts", tracked and "shaded on your world map" or "untracked")
    local b = button(1)
    if tracked then
      b:SetText("Stop tracking")
      b:SetScript("OnClick", function() ns.setHuntTarget(nil) end)
    else
      b:SetText("Track it")
      b:SetScript("OnClick", function()
        if rec.tracked then
          ns.setHuntTarget(q.id)
        else
          ask(ASK.track, { quarry = q.id })
        end
      end)
    end
    page:place(b, 34)
  else
    page:section("Brought down")
    page:row("Brought down", rec.retro and "before the journal kept the hunts" or when(rec))
    page:row("Seal", ("%s, %s"):format(seal[2], seal[3]))
    page:row("Note", ns.quarryNote(q))
    if ns.huntSeal(rec) == "gold" then
      page:row("Margin", ns.quarryMargin(q))
    else
      page:row("Margin", SOFT .. "only a gold seal opens it|r")
    end
  end
end

local function showZone(uiMap)
  local done, total = progress(uiMap)
  start(ns.zoneName(uiMap), ("%d of %d done"):format(done, total), MAP)
  local riddles = ns.riddlesOf(uiMap)
  if #riddles > 0 then
    page:section("Its riddles")
    for _, r in ipairs(riddles) do
      local rec = ns.riddleRecord(r.id)
      local value = rec and rec.at and ns.riddleName(r) or (SOFT .. r.verse[1] .. "|r")
      page:row(TIERS[r.tier], value)
    end
  end
  local q = quarryOf(uiMap)
  if q then
    page:section("Its quarry")
    page:row(q.name, ns.quarryDown(q.id) and "brought down" or (SOFT .. danger(q) .. "|r"))
  end
end

local function counts()
  local n = { riddles = 0, of = 0, gold = 0, silver = 0, plain = 0, quarries = 0, hunts = 0 }
  for uiMap in pairs(X) do
    for _, r in ipairs(ns.riddlesOf(uiMap)) do
      n.of = n.of + 1
      local rec = ns.riddleRecord(r.id)
      if rec and rec.at then
        n.riddles = n.riddles + 1
        local s = ns.riddleSeal(rec)
        n[s] = n[s] + 1
      end
    end
    local q = quarryOf(uiMap)
    if q then
      n.hunts = n.hunts + 1
      if ns.quarryDown(q.id) then n.quarries = n.quarries + 1 end
    end
  end
  return n
end

local function showOverview()
  local n = counts()
  start(
    "Expeditions",
    ("%d of %d riddles solved, %d of %d quarries"):format(n.riddles, n.of, n.quarries, n.hunts),
    BOOK
  )
  page:text({
    "Every land keeps a few things most travellers walk past: a grave beside a path, a statue nobody explains, "
      .. "a book left on a shelf. Each riddle here leads to one, in a land you have entered. It is solved where it "
      .. "leads, and some ask something of you there, as the story would.",
    "A riddle read from its verse alone earns the gold seal, and opens its margin; the clue costs the gold, the "
      .. "map the silver. Each land with rare creatures has its quarry too, a foe its people tell of (where none is, "
      .. "one of its rarest): found from its poster alone, it earns the gold; tracked, its haunts are shaded on "
      .. "your map.",
  })
  page:section("The record")
  page:row("Riddles", ("%d of %d solved"):format(n.riddles, n.of))
  page:row("Seals", ("%d gold, %d silver, %d plain"):format(n.gold, n.silver, n.plain))
  page:row("Quarries", ("%d of %d brought down"):format(n.quarries, n.hunts))
  local target = ns.huntTarget()
  if target then page:row("Tracking", ("%s, in %s"):format(target.name, ns.zoneName(target.zone))) end
end

local function refresh()
  local n = counts()
  book.count:SetText(("%d riddles solved, %d quarries"):format(n.riddles, n.quarries))
  refreshList()
  local r = type(current) == "string" and ns.riddleById[current]
  local qid = type(current) == "string" and tonumber(current:match("^quarry:(%d+)$"))
  local q = qid and ns.quarryById[qid]
  if r and ns.riddleOpen(r) then
    showRiddle(r)
  elseif q and ns.quarryOpen(q) then
    showQuarry(q)
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
    options = function()
      return {
        { value = "all", text = "Everything" },
        { value = "riddles", text = "Riddles" },
        { value = "hunts", text = "Hunts" },
        { value = "open", text = "Unfinished" },
      }
    end,
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

-- Open the book at a quarry's poster (fieldjournal:q<creature id>).
function ns.openQuarry(id)
  local q = ns.quarryById[id]
  if not (q and ns.journal()) then return end
  current = "quarry:" .. id
  opened()[q.zone] = true
  ns.openTab(ns.TAB.expeditions)
end
