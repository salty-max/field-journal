-- The Expeditions' tab in the book: on the left, by continent, the zones
-- entered that hold riddles or a quarry for this character (and their
-- faction's own capitals and starting zones), each with how much of it is
-- done, its riddles and its quarry under it once opened (a solved riddle by
-- its answer's name, the others by their verse's first line). On the right:
-- the overview (the record, what is under way: the quarry tracked and the
-- riddle pinned, and what was done lately, as cards); a zone's page (its
-- riddles in words, a card for each and for its quarry, its map: where each
-- was read, the places asked for, the haunts tracked); a riddle's page (its
-- verse set apart, how dangerous its place is, what it asks there, the two
-- hints, each asked for, pinning it to the screen, and once solved its seal,
-- the note and the margin, which only the gold seal opens); or a quarry's
-- poster (the creature turning in its frame, its verse, its danger, the
-- tracking at the cost of the gold seal, and once brought down its seal, note
-- and margin). Records: Expeditions.lua; the card pinned: ExpeditionsPin.lua.
local _, ns = ...
local L = ns.kit.L
local D = ns.data
local X = D.expeditions or {}
local A = D.atlas or { zones = {}, continents = {} }
local ui = ns.ui
local T = ui.T

local book, list, page
local current -- a riddle's id, "quarry:<id>", a zone's uiMap, or nil for the overview
local last -- the page shown last (kept where it was scrolled, while the same)
local rows, pairsPool = {}, {}
ns.expeditionRows, ns.expeditionPairs = rows, pairsPool -- for the tests

local NOTE = "Interface\\Icons\\INV_Misc_Note_02"
local MAP = "Interface\\Icons\\INV_Misc_Map_01"
local BOOK = "Interface\\Icons\\INV_Misc_Book_09"
-- (each: icon, name, how it was earned, colour, its ring, its name in a
-- sentence and at a sentence's head, a language wording them its own way)
local SEALS = {
  gold = {
    ns.SEAL_ICON.gold,
    L["Gold"],
    L["from the verse alone"],
    { 1, 0.82, 0 },
    "gold",
    L["the gold seal"],
    L["The gold seal"],
  },
  silver = {
    ns.SEAL_ICON.silver,
    L["Silver"],
    L["with the clue"],
    { 0.78, 0.8, 0.84 },
    "silver",
    L["the silver seal"],
    L["The silver seal"],
  },
  plain = {
    ns.SEAL_ICON.plain,
    L["Plain"],
    L["with the map"],
    { 0.8, 0.55, 0.35 },
    "copper",
    L["the plain seal"],
    L["The plain seal"],
  },
}
-- a quarry's: never tracked, tracked, or brought down before the journal kept the hunts
-- A riddle's or a quarry's ring, by its seal, in place of a medal (the kit's
-- tier rings): gold, silver, copper for the plain seal; iron while not done;
-- the plain bronze for a quarry brought down before the journal kept hunts.
-- (the pinned card's too: ExpeditionsPin.lua)
function ns.sealRing(seal, done)
  local R = ns.kit.RINGS
  if not done then return R.iron end
  return seal and seal[5] and R[seal[5]] or nil
end
local ringOf = ns.sealRing
local HUNT_SEALS = {
  gold = {
    SEALS.gold[1],
    L["Gold"],
    L["never tracked"],
    SEALS.gold[4],
    "gold",
    SEALS.gold[6],
    SEALS.gold[7],
  },
  plain = {
    SEALS.plain[1],
    L["Plain"],
    L["tracked"],
    SEALS.plain[4],
    "copper",
    SEALS.plain[6],
    SEALS.plain[7],
  },
  before = { nil, L["None"], L["brought down before the journal kept the hunts"], T.soft },
}
local TIERS = { near = L["Near the road"], off = L["Off the road"], hidden = L["Hidden"], town = L["In town"] }
local RANKS = { elite = L["An elite"], rare = L["A rare"], rareelite = L["A rare elite"] }

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
  -- a zone of no continent (Forever's Zephras Isle), as the Atlas files it
  table.insert(out, { 0, L["Elsewhere"] })
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
    local r = list:add("overview", L["Expeditions"])
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
              L["Quarry: %s"]:format(quarry.name),
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

-- ── the page's parts ─────────────────────────────────────────────────────────
local WIDTH = ui.WIDTH
local TROPHY = "Interface\\Icons\\INV_Misc_Head_Dragon_01"

-- (of riddles: a language with genders words them for a riddle)
local NUMBERS = {
  L["one"],
  L["two"],
  L["three"],
  L["four"],
  L["five"],
  L["six"],
  L["seven"],
  L["eight"],
  L["nine"],
  L["ten"],
  L["eleven"],
  L["twelve"],
}
local function capital(s) return (s:gsub("^%l", string.upper)) end
local function words(n) return NUMBERS[n] or tostring(n) end

-- A list in words: "a, b and c".
local function join(items)
  if #items <= 1 then return items[1] or "" end
  return table.concat(items, ", ", 1, #items - 1) .. L[" and "] .. items[#items]
end

-- A hint asked for, or a quarry tracked, as the game asks before something
-- that can't be undone.
local ASK = {
  clue = L["Ask for a clue? This riddle will no longer earn its gold seal."],
  map = L["Shade its place on your world map? This riddle will no longer earn its silver seal."],
  track = L["Track this quarry? Its haunts are shaded on your world map, and it will no longer earn its gold seal."],
}
StaticPopupDialogs.YONDER_HINT = {
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
local function ask(text, data) StaticPopup_Show("YONDER_HINT", text, nil, data) end

-- The buttons under a riddle or a poster, side by side ({ text, click }).
local BUTTON_W = 190
local function actions(buttons)
  local row = page.actions
  for i, a in ipairs(buttons) do
    local b = page.buttons[i]
    if not b then
      b = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
      b:SetSize(BUTTON_W, 24)
      page.buttons[i] = b
    end
    b:SetText(a[1])
    b:SetScript("OnClick", a[2])
    b:ClearAllPoints()
    b:SetPoint("LEFT", row, "LEFT", (i - 1) * (BUTTON_W + 12), 0)
    b:Show()
  end
  page:place(row, 40)
end

-- A text set apart in a panel of its own, its lines from the left: the
-- verse, the margin.
local function framed(key, size)
  local f = page.parts[key]
  if not f then
    f = CreateFrame("Frame", nil, page.child)
    f:SetWidth(WIDTH)
    f.art = ui.panel(f)
    f.art:SetAllPoints()
    -- (a width of its own, never the panel's anchors: measured at once,
    -- before the panel is laid out, a verse's wrapped lines are all counted)
    f.text = ui.label(f.art, ui.BODY_FONT, size, T.text)
    f.text:SetPoint("TOP", 0, -16)
    f.text:SetWidth(WIDTH - 40)
    f.text:SetSpacing(5)
    page.parts[key] = f
  end
  return f
end
local function setApart(key, text, size)
  local f = framed(key, size)
  f.text:SetText(text)
  local th = f.text:GetStringHeight()
  f.text:SetHeight(th + 2) -- (as tall as its lines: never cut short with "...")
  local h = th + 34
  f:SetHeight(h)
  page:place(f, h + 14)
end

-- The seal earned: its coin, its name in its colour, how and when.
local function sealBlock(seal, how, rec)
  local s = page.parts.seal
  if not s then
    s = CreateFrame("Frame", nil, page.child)
    s:SetSize(WIDTH, 54)
    s.coin = ui.roundPortrait(s, 44)
    s.coin:SetPoint("LEFT", 2, 0)
    s.name = ui.label(s, ui.TITLE_FONT, 18, T.gold)
    s.name:SetPoint("TOPLEFT", s.coin, "TOPRIGHT", 14, -3)
    s.detail = ui.label(s, ui.BODY_FONT, 12, T.soft)
    s.detail:SetPoint("TOPLEFT", s.name, "BOTTOMLEFT", 0, -6)
    s.detail:SetWidth(WIDTH - 64)
    page.parts.seal = s
  end
  if seal[1] then
    ui.icon(seal[1])(s.coin)
    s.coin:Show()
  else
    s.coin:Hide()
  end
  s.name:SetText(seal[1] and seal[7] or L["No seal"])
  s.name:SetTextColor(unpack(seal[4]))
  s.detail:SetText(rec.retro and how or (L["%s, on %s, at level %d."]):format(how, ui.day(rec), rec.level or 0))
  page:place(s, 66)
end

-- A riddle or the quarry as a card (a zone's page, the overview's): a click
-- opens it; its ring its seal's (done), iron till then.
local function placeCard(target, name, facts, picture, seal, done)
  page:card(name, facts, picture, function()
    current = target
    ns.refresh()
  end, nil, ringOf(seal, done))
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

-- The quarry still at large: its portrait in shadow (brought down, its face).
local function shadowed(model)
  return function(p)
    portrait(model)(p)
    p.tex:SetDesaturated(true)
    p.tex:SetVertexColor(0.3, 0.3, 0.3)
  end
end
local function quarryPicture(q)
  local display = ns.quarryDisplay(q)
  return ns.quarryDown(q.id) and portrait(display) or shadowed(display)
end

-- A riddle's picture: unsolved, its note; solved, what it led to: its
-- keeper's face, the book read, a keeper the data has no face for, a place
-- found or a stone (the seal is the ring round it, never the picture).
local SPYGLASS, TABLET = "Interface\\Icons\\INV_Misc_Spyglass_02", "Interface\\Icons\\INV_Misc_StoneTablet_05"
local function riddlePicture(r)
  if not ns.riddleSolved(r.id) then return ui.icon(NOTE) end
  local face = ns.riddleFace(r)
  if face then return portrait(face) end
  if r.asks == "reading" then return ui.icon(BOOK) end
  return ui.icon((r.area or r.npc) and SPYGLASS or TABLET)
end

-- The zone's map on a page, with what this character knows of it (marks:
-- where riddles were read and the quarry fell; circles: the places asked for,
-- the haunts tracked; each mark and circle says what it is on hover).
local function mapBlock(uiMap, marks, circles)
  local height = page.map:draw(uiMap, marks, circles)
  if not height then return end
  page:section(L["The map"])
  page:place(page.map, height + 16)
end

local function sealOf(r)
  local rec = ns.riddleRecord(r.id)
  return rec and rec.at and SEALS[ns.riddleSeal(rec)]
end

-- What a riddle's map shows: its place once asked for (unsolved), where it
-- was read once solved.
local function riddleMarks(r, marks, circles)
  local rec = ns.riddleRecord(r.id) or {}
  if rec.at then
    if rec.x then
      local seal = SEALS[ns.riddleSeal(rec)]
      table.insert(marks, {
        x = rec.x,
        y = rec.y,
        icon = seal[1],
        title = ns.riddleName(r),
        text = L["Read here, %s"]:format(ui.day(rec)),
      })
    end
  elseif (rec.hints or 0) >= 2 then
    table.insert(
      circles,
      { x = r.circle[1], y = r.circle[2], r = r.circle[3], title = L["A riddle's place"], text = r.verse[1] }
    )
  end
end

local function quarryMarks(q, marks, circles)
  local rec = ns.huntRecord(q.id) or {}
  if rec.at then
    if rec.x then
      table.insert(
        marks,
        { x = rec.x, y = rec.y, icon = TROPHY, title = q.name, text = L["Brought down here, %s"]:format(ui.day(rec)) }
      )
    end
  else
    local target = ns.huntTarget()
    if target and target.id == q.id then
      for _, h in ipairs(q.haunts) do
        table.insert(
          circles,
          { x = h[1], y = h[2], r = h[3], title = q.name, text = L["Its haunts: the quarry you track."] }
        )
      end
    end
  end
end

-- (picture: an icon's path, or a portrait's setter; ring: its ring, ringOf's)
local function start(name, sub, picture, ring)
  for _, b in ipairs(page.buttons) do
    b:Hide()
  end
  for _, part in pairs(page.parts) do
    part:Hide()
  end
  page.map:Hide()
  page:start(name, sub, type(picture) == "function" and picture or ui.icon(picture), nil, ring)
end

local function pinButton(key)
  local pinned = ns.pinned() == key
  return {
    pinned and L["Unpin from the screen"] or L["Pin to the screen"],
    function() ns.pin(not pinned and key or nil) end,
  }
end

-- (for the card pinned to the screen and the toasts)
ns.riddlePicture, ns.quarryPicture = riddlePicture, quarryPicture
ns.SEALS, ns.HUNT_SEALS = SEALS, HUNT_SEALS

-- ── the pages ────────────────────────────────────────────────────────────────
local RIDDLE_HOW =
  { gold = L["Read from the verse alone"], silver = L["Read with the clue"], plain = L["Read with the map"] }

local function showRiddle(r)
  local rec = ns.riddleRecord(r.id) or {}
  local solved = rec.at ~= nil
  local seal = solved and SEALS[ns.riddleSeal(rec)]
  -- (unsolved, its title is its tier already)
  local sub = solved and table.concat({ ns.zoneName(r.zone), TIERS[r.tier] }, "  -  ") or ns.zoneName(r.zone)
  start(title(r), sub, riddlePicture(r), ringOf(seal, solved))
  setApart("verse", table.concat(r.verse, "\n"), 14)
  page:section(L["The riddle"])
  page:row(L["Danger"], r.danger)
  if r.asks == "gesture" then
    page:row(L["It asks"], L["something of you there"])
  elseif r.asks == "reading" then
    page:row(L["It asks"], L["a reading there"])
  elseif r.npc then
    page:row(L["It asks"], L["a word with someone there"])
  else
    page:row(L["It asks"], L["only that you find it"])
  end
  if r.night then page:row(L["When"], L["by night"]) end
  local hints = rec.hints or 0
  if hints >= 1 then page:row(L["The clue"], r.hint) end
  if hints >= 2 then
    page:row(
      L["The map"],
      solved and L["its place was shaded on your world map"] or L["its place is shaded on your world map"]
    )
  end
  if not solved then
    local buttons = {}
    if hints < 2 then
      table.insert(buttons, {
        hints == 0 and L["Ask for a clue"] or L["Ask for the map"],
        function() ask(hints == 0 and ASK.clue or ASK.map, { id = r.id, n = hints + 1 }) end,
      })
    end
    table.insert(buttons, pinButton(r.id))
    actions(buttons)
  end
  if solved then
    page:section(L["Solved"])
    sealBlock(seal, RIDDLE_HOW[ns.riddleSeal(rec)], rec)
    page:section(L["The note"])
    page:paragraph(ns.riddleNote(r))
    page:section(L["In the margin"])
    if hints == 0 then
      setApart("margin", ns.riddleMargin(r), 13)
    else
      page:paragraph(L["Only a gold seal opens the margin, and this riddle was read with a hint."], T.soft)
    end
  end
  local marks, circles = {}, {}
  riddleMarks(r, marks, circles)
  if #marks + #circles > 0 then mapBlock(r.zone, marks, circles) end
end

local function danger(q)
  local rank = RANKS[q.rank]
  return rank and L["%s, level %s"]:format(rank, q.level) or L["Level %s"]:format(q.level)
end

local HUNT_HOW = {
  gold = L["Brought down without tracking it"],
  plain = L["Brought down after tracking it"],
  before = L["Brought down before the journal kept the hunts."],
}

local function showQuarry(q)
  local rec = ns.huntRecord(q.id) or {}
  local down = rec.at ~= nil
  local display = ns.quarryDisplay(q)
  local hseal = down and HUNT_SEALS[ns.huntSeal(rec)]
  start(q.name, L["%s  -  the quarry"]:format(ns.zoneName(q.zone)), quarryPicture(q), ringOf(hseal, down))
  page:model(display, not down)
  setApart("verse", table.concat(q.verse, "\n"), 14)
  page:section(L["The hunt"])
  page:row(L["Danger"], danger(q))
  if not down then
    local target = ns.huntTarget()
    local tracked = target and target.id == q.id
    page:row(L["Its haunts"], tracked and L["shaded on your world map"] or L["untracked"])
    local track
    if tracked then
      track = { L["Stop tracking"], function() ns.setHuntTarget(nil) end }
    else
      track = {
        L["Track it"],
        function()
          if rec.tracked then
            ns.setHuntTarget(q.id)
          else
            ask(ASK.track, { quarry = q.id })
          end
        end,
      }
    end
    actions({ track, pinButton("quarry:" .. q.id) })
  else
    page:section(L["Brought down"])
    local seal = ns.huntSeal(rec)
    sealBlock(HUNT_SEALS[seal], HUNT_HOW[seal], rec)
    page:section(L["The note"])
    page:paragraph(ns.quarryNote(q))
    page:section(L["In the margin"])
    if seal == "gold" then
      setApart("margin", ns.quarryMargin(q), 13)
    else
      page:paragraph(L["Only a gold seal opens the margin: a quarry never tracked."], T.soft)
    end
  end
  local marks, circles = {}, {}
  quarryMarks(q, marks, circles)
  if #marks + #circles > 0 then mapBlock(q.zone, marks, circles) end
end

-- A zone's riddles in words: "two near the road, one off it and one hidden".
local TIER_WORDS =
  { near = L["%s near the road"], off = L["%s off the road"], hidden = L["%s hidden"], town = L["%s in its town"] }
local TIER_ORDER = { "near", "off", "hidden", "town" }
local function tierWords(riddles)
  local n = {}
  for _, r in ipairs(riddles) do
    n[r.tier] = (n[r.tier] or 0) + 1
  end
  local parts = {}
  for _, t in ipairs(TIER_ORDER) do
    if n[t] then table.insert(parts, TIER_WORDS[t]:format(words(n[t]))) end
  end
  return join(parts)
end

-- The seals of riddles read, in words: "two with the gold seal, one with the silver".
local SEAL_WORDS = {
  gold = L["%s with the gold seal"],
  silver = L["%s with the silver seal"],
  plain = L["%s with the plain seal"],
}
local function sealWords(riddles)
  local n = {}
  for _, r in ipairs(riddles) do
    local rec = ns.riddleRecord(r.id)
    if rec and rec.at then
      local s = ns.riddleSeal(rec)
      n[s] = (n[s] or 0) + 1
    end
  end
  local parts = {}
  for _, s in ipairs({ "gold", "silver", "plain" }) do
    if n[s] then table.insert(parts, SEAL_WORDS[s]:format(words(n[s]))) end
  end
  return join(parts)
end

local function zoneWords(uiMap)
  local riddles, q = ns.riddlesOf(uiMap), quarryOf(uiMap)
  local name = ns.zoneName(uiMap)
  local first
  if #riddles > 0 then
    first = (q and L["%s keeps %s for you, %s, and a quarry its people tell of."] or L["%s keeps %s for you, %s."]):format(
      name,
      #riddles == 1 and L["one riddle"] or L["%s riddles"]:format(words(#riddles)),
      tierWords(riddles)
    )
  else
    first = L["%s keeps no riddle for you, only a quarry its people tell of."]:format(name)
  end
  local read = 0
  for _, r in ipairs(riddles) do
    if ns.riddleSolved(r.id) then read = read + 1 end
  end
  local second
  local done, total = progress(uiMap)
  local m = ns.earnedMilestone("expedition-" .. uiMap)
  if done == total and total > 0 then
    second = m and m.at and (L["Every one of them done: the expedition was complete on %s."]):format(ui.day(m))
      or L["Every one of them done: the expedition is complete."]
  elseif read > 0 then
    second = L["%s read so far, %s."]:format(read == 1 and L["One"] or capital(words(read)), sealWords(riddles))
  elseif #riddles > 0 then
    second = L["None read yet."]
  end
  return { second and (first .. " " .. second) or first }
end

local function showZone(uiMap)
  local done, total = progress(uiMap)
  local continent = A.zones[uiMap] and A.continents[A.zones[uiMap].continent] or L["Elsewhere"]
  start(ns.zoneName(uiMap), L["%s  -  %d of %d done"]:format(continent, done, total), MAP)
  page:text(zoneWords(uiMap))
  local marks, circles = {}, {}
  local riddles = ns.riddlesOf(uiMap)
  if #riddles > 0 then
    page:section(L["Its riddles"])
    for _, r in ipairs(riddles) do
      local rec = ns.riddleRecord(r.id) or {}
      local seal = sealOf(r)
      if seal then
        placeCard(
          r.id,
          ns.riddleName(r),
          L["%s  -  %s, %s"]:format(TIERS[r.tier], seal[6], ui.day(rec)),
          riddlePicture(r),
          seal,
          true
        )
      else
        local hints = rec.hints or 0
        local tail = hints >= 2 and L["  -  its place shaded"] or hints == 1 and L["  -  the clue taken"] or ""
        placeCard(r.id, TIERS[r.tier] .. tail, r.verse[1], ui.icon(NOTE))
      end
      riddleMarks(r, marks, circles)
    end
  end
  local q = quarryOf(uiMap)
  if q then
    page:section(L["Its quarry"])
    local rec = ns.huntRecord(q.id) or {}
    local state
    if rec.at then
      local seal = HUNT_SEALS[ns.huntSeal(rec)]
      state = rec.retro and L["brought down before the journal kept the hunts"]
        or L["brought down %s, %s"]:format(ui.day(rec), seal[6])
    else
      local target = ns.huntTarget()
      state = (target and target.id == q.id) and L["tracked"] or L["still at large"]
    end
    local hseal = rec.at and HUNT_SEALS[ns.huntSeal(rec)]
    placeCard(
      "quarry:" .. q.id,
      q.name,
      L["%s  -  %s"]:format(danger(q), state),
      quarryPicture(q),
      hseal,
      rec.at ~= nil
    )
    quarryMarks(q, marks, circles)
  end
  mapBlock(uiMap, marks, circles)
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

-- The last riddles read and quarries brought down, the latest first.
local function lately(max)
  local out = {}
  for uiMap in pairs(X) do
    for _, r in ipairs(ns.riddlesOf(uiMap)) do
      local rec = ns.riddleRecord(r.id)
      if rec and rec.at then table.insert(out, { at = rec.at, riddle = r, rec = rec }) end
    end
    local q = quarryOf(uiMap)
    local rec = q and ns.huntRecord(q.id)
    if rec and rec.at and not rec.retro then table.insert(out, { at = rec.at, quarry = q, rec = rec }) end
  end
  table.sort(out, function(a, b) return a.at > b.at end)
  for i = #out, max + 1, -1 do
    out[i] = nil
  end
  return out
end

local function showOverview()
  local n = counts()
  start(
    L["Expeditions"],
    L["%d of %d riddles solved, %d of %d quarries"]:format(n.riddles, n.of, n.quarries, n.hunts),
    BOOK
  )
  page:text({
    L["Every land keeps a few things most travellers walk past: a grave beside a path, a statue nobody explains, a book left on a shelf. Each riddle here leads to one, in a land you have entered. It is solved where it leads, and some ask something of you there, as the story would."],
    L["A riddle read from its verse alone earns the gold seal, and opens its margin; the clue costs the gold, the map the silver. Each land with rare creatures has its quarry too, a foe its people tell of: found from its poster alone, it earns the gold; tracked, its haunts are shaded on your map."],
  })
  page:section(L["The record"])
  page:row(L["Riddles"], L["%d of %d solved"]:format(n.riddles, n.of))
  page:row(L["Seals"], L["%d gold, %d silver, %d plain"]:format(n.gold, n.silver, n.plain))
  page:row(L["Quarries"], L["%d of %d brought down"]:format(n.quarries, n.hunts))
  local target = ns.huntTarget()
  local pinned = ns.pinned()
  if target or pinned then page:section(L["Under way"]) end
  if target then
    placeCard(
      "quarry:" .. target.id,
      target.name,
      L["tracked, in %s  -  %s"]:format(ns.zoneName(target.zone), danger(target)),
      quarryPicture(target)
    )
  end
  local pr = pinned and ns.riddleById[pinned]
  if pr and not ns.riddleSolved(pr.id) then
    placeCard(pr.id, TIERS[pr.tier], L["pinned, in %s  -  %s"]:format(ns.zoneName(pr.zone), pr.verse[1]), ui.icon(NOTE))
  end
  local recent = lately(5)
  if #recent > 0 then
    page:section(L["Lately"])
    for _, x in ipairs(recent) do
      if x.riddle then
        local seal = SEALS[ns.riddleSeal(x.rec)]
        placeCard(
          x.riddle.id,
          ns.riddleName(x.riddle),
          L["%s  -  %s, %s"]:format(ns.zoneName(x.riddle.zone), seal[6], ui.day(x.rec)),
          riddlePicture(x.riddle),
          seal,
          true
        )
      else
        local seal = HUNT_SEALS[ns.huntSeal(x.rec)]
        placeCard(
          "quarry:" .. x.quarry.id,
          x.quarry.name,
          L["%s  -  brought down, %s, %s"]:format(ns.zoneName(x.quarry.zone), seal[6], ui.day(x.rec)),
          portrait(ns.quarryDisplay(x.quarry)),
          seal,
          true
        )
      end
    end
  end
end

local function refresh()
  local n = counts()
  book.count:SetText(
    L["%s, %s"]:format(
      ns.kit.plural(n.riddles, "%d riddle solved", "%d riddles solved"):format(n.riddles),
      ns.kit.plural(n.quarries, "%d quarry", "%d quarries"):format(n.quarries)
    )
  )
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
  page = ui.newPage(book.sheet, "YonderExpeditionsPage", 90, pairsPool)
  page.buttons, page.parts = {}, {}
  page.actions = CreateFrame("Frame", nil, page.child)
  page.actions:SetSize(WIDTH, 26)
  page.map = ui.newMap(page.child)
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
        { value = "all", text = L["Everything"] },
        { value = "riddles", text = L["Riddles"] },
        { value = "hunts", text = L["Hunts"] },
        { value = "open", text = L["Unfinished"] },
      }
    end,
  },
})

-- Open the book at a riddle (yonder:x<id>: a link in chat).
function ns.openRiddle(id)
  local r = ns.riddleById[id]
  if not (r and ns.journal()) then return end
  current = id
  opened()[r.zone] = true
  ns.openTab(ns.TAB.expeditions)
end

-- A zone's expedition, for the Atlas: shown in the book, how much is done.
function ns.expeditionOf(uiMap)
  if not (X[uiMap] and ns.journal() and shown(uiMap)) then return nil end
  return progress(uiMap)
end

-- Open the book at a zone's expedition page.
function ns.openExpeditionZone(uiMap)
  if not ns.expeditionOf(uiMap) then return end
  current = uiMap
  opened()[uiMap] = true
  ns.openTab(ns.TAB.expeditions)
end

-- Open the book at a quarry's poster (yonder:q<creature id>).
function ns.openQuarry(id)
  local q = ns.quarryById[id]
  if not (q and ns.journal()) then return end
  current = "quarry:" .. id
  opened()[q.zone] = true
  ns.openTab(ns.TAB.expeditions)
end
