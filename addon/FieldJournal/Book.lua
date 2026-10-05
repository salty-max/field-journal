-- The Bestiary as a book. On the left, a tree: the creature types, the
-- families met in each, the creatures met in each family (types and families
-- fold). On the right, a family's page (the League naturalist's note and who
-- was met in it) or a creature's (its portrait and this character's record of
-- it). A Trophies page lists the rares and bosses slain. /journal opens it.
-- Classic gets the parchment of the game's book reader; Forever, whose windows
-- are dark panels, a standard game window.
local _, ns = ...
local D = ns.data

local TROPHIES = "trophies"

-- Colours: dark ink on parchment (Classic), light text on a dark panel (Forever).
local T = ns.forever and {
  title = { 1, 0.82, 0 }, ink = { 0.9, 0.88, 0.82 }, faint = { 0.72, 0.70, 0.66 },
  mark = "|cffff9a40", soft = "|cffb0a890", link = "|cffffd100",
} or {
  title = { 0.22, 0.14, 0.05 }, ink = { 0.22, 0.14, 0.05 }, faint = { 0.30, 0.20, 0.09 },
  mark = "|cff8a3a1c", soft = "|cff6b4a26", link = "|cff6b2a0c",
}

local book, list, page
-- What the page shows: a family key (a number, or a "?type/family" string),
-- TROPHIES, or a creature (currentCreature set, current its family).
local current, currentCreature
local build

local function ink(fs, color)
  fs:SetTextColor(unpack(color))
  if not ns.forever then fs:SetShadowColor(0, 0, 0, 0) end
end

-- ── what a record says ───────────────────────────────────────────────────────
local function itemName(itemId)
  local name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemId)) or (GetItemInfo and GetItemInfo(itemId))
  return name or ("item " .. itemId)
end

local function lootLine(rec, most)
  if not rec.loot then return nil end
  local items = {}
  for itemId, count in pairs(rec.loot) do table.insert(items, { itemId, count }) end
  table.sort(items, function(a, b) return a[2] > b[2] end)
  local parts = {}
  for i = 1, math.min(#items, most) do
    table.insert(parts, ("%s%s"):format(itemName(items[i][1]), items[i][2] > 1 and (" x" .. items[i][2]) or ""))
  end
  if #items > most then table.insert(parts, ("and %d more"):format(#items - most)) end
  return table.concat(parts, ", ")
end

local RANK = { r = "rare", R = "rare elite", b = "boss" }

local function markOf(id, rec)
  local rank = rec.trophy and rec.trophy.rank or ns.rank(id)
  if rec.trophy then return (" %s(%s, trophy)|r"):format(T.mark, RANK[rank] or "trophy") end
  if rank then return (" %s(%s)|r"):format(T.soft, RANK[rank]) end
  return ""
end

local function nameOf(id, rec) return (rec.name or ("Creature " .. id)) .. markOf(id, rec) end

local function day(stamp) return date("%d %b %Y", stamp and stamp.at or 0) end

local function levels(rec)
  if not rec.low then return nil end
  return rec.low == rec.high and ("Level %d"):format(rec.low) or ("Levels %d-%d"):format(rec.low, rec.high)
end

-- A line under a name: levels, kills.
local function summary(rec)
  local parts = {}
  table.insert(parts, levels(rec))
  table.insert(parts, (rec.slain or 0) > 0 and ("%d slain"):format(rec.slain) or "none slain")
  return table.concat(parts, " - ")
end

-- ── portraits ────────────────────────────────────────────────────────────────
-- A 3D model, held still on its first frame (as a unit frame's portrait).
local function freeze(model)
  if model.FreezeAnimation then model:FreezeAnimation(0, 0, 0) end
  if model.SetPaused then model:SetPaused(true) end
end

local function portraitFrame(parent, size)
  local p = CreateFrame("Frame", nil, parent)
  p:SetSize(size, size)
  p.well = p:CreateTexture(nil, "BACKGROUND")
  p.well:SetAllPoints()
  p.well:SetColorTexture(0.06, 0.05, 0.04, 0.9)
  p.model = CreateFrame("PlayerModel", nil, p)
  p.model:SetPoint("TOPLEFT", 1, -1)
  p.model:SetPoint("BOTTOMRIGHT", -1, 1)
  p.model:SetScript("OnModelLoaded", freeze)
  p.unknown = p:CreateTexture(nil, "ARTWORK")
  p.unknown:SetPoint("CENTER")
  p.unknown:SetSize(size * 0.55, size * 0.55)
  p.unknown:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
  p.border = CreateFrame("Frame", nil, p, "BackdropTemplate")
  p.border:SetPoint("TOPLEFT", -2, 2)
  p.border:SetPoint("BOTTOMRIGHT", 2, -2)
  p.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
  p.border:SetBackdropBorderColor(0.72, 0.56, 0.24)
  return p
end

-- The creature's face (zoom 1: the face, 0: the whole body): its display id
-- from the data; creatures the data doesn't know try the client's own lookup,
-- else a question mark.
local function portrait(p, id, zoom)
  local display = D.models and D.models[id]
  p.model:ClearModel()
  if display then
    p.model:SetDisplayInfo(display)
  elseif p.model.SetCreature then
    p.model:SetCreature(id)
  end
  p.model:SetPortraitZoom(zoom)
  p.model:SetCamDistanceScale(1)
  freeze(p.model)
  local shown = display ~= nil or p.model.SetCreature ~= nil
  p.model:SetShown(shown)
  p.unknown:SetShown(not shown)
end

-- ── the open page ────────────────────────────────────────────────────────────
local WIDTH = 420
local PORTRAIT, BIG = 56, 150
-- Rows on a family's or the trophies' page: portrait, name, a line; a click
-- opens the creature's page.
local entries = {}
ns.pageEntries = entries -- for the tests

local function entry(i)
  local e = entries[i]
  if e then return e end
  e = CreateFrame("Button", nil, page.child)
  e:SetSize(WIDTH, PORTRAIT + 8)
  e.portrait = portraitFrame(e, PORTRAIT)
  e.portrait:SetPoint("TOPLEFT", 2, -2)
  e.model, e.unknown = e.portrait.model, e.portrait.unknown
  e.name = e:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  e.name:SetPoint("TOPLEFT", e.portrait, "TOPRIGHT", 10, -4)
  e.name:SetWidth(WIDTH - PORTRAIT - 14)
  e.name:SetJustifyH("LEFT")
  ink(e.name, T.title)
  e.facts = e:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  e.facts:SetPoint("TOPLEFT", e.name, "BOTTOMLEFT", 0, -4)
  e.facts:SetWidth(WIDTH - PORTRAIT - 14)
  e.facts:SetJustifyH("LEFT")
  e.facts:SetSpacing(2)
  ink(e.facts, T.faint)
  e:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  e:SetScript("OnClick", function(self) ns.openCreature(self.id) end)
  entries[i] = e
  return e
end

local function sortedIds(ids)
  local journal = ns.journal()
  table.sort(ids, function(a, b)
    local ra, rb = journal.creatures[a], journal.creatures[b]
    return (ra.name or "") < (rb.name or "")
  end)
  return ids
end

local function hideAll()
  for _, e in ipairs(entries) do e:Hide() end
  page.portrait:Hide()
  page.record:Hide()
end

-- Lays out entries for ids under y; returns the new y.
local function layEntries(ids, y, line)
  local journal = ns.journal()
  for i, id in ipairs(ids) do
    local rec = journal.creatures[id]
    local e = entry(i)
    e:ClearAllPoints()
    e:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
    e.name:SetText(nameOf(id, rec))
    e.facts:SetText(line(id, rec))
    portrait(e.portrait, id, 0.9)
    e.id = id
    e:Show()
    y = y + math.max(PORTRAIT + 8, e.name:GetStringHeight() + 8 + e.facts:GetStringHeight()) + 10
  end
  return y
end

local function finish(y, keep)
  page.child:SetHeight(y + 20)
  if not keep then page:SetVerticalScroll(0) end
end

-- keep: re-render in place (the records changed), keeping the scroll.
local function showFamily(key, keep)
  current, currentCreature = key, nil
  local journal = ns.journal()
  if not journal or not key then return end
  hideAll()
  local intro, ids
  if key == TROPHIES then
    page.title:SetText("Trophies")
    intro = { "The rare beasts and the great foes this traveller has brought down, with the day and the level of the deed." }
    ids = {}
    for id, rec in pairs(journal.creatures) do
      if rec.trophy then table.insert(ids, id) end
    end
    table.sort(ids, function(a, b) return journal.creatures[a].trophy.at < journal.creatures[b].trophy.at end)
    if #ids == 0 then table.insert(intro, "None yet.") end
  else
    page.title:SetText(ns.familyTitle(key))
    local family = type(key) == "number" and D.families[key]
    intro = {}
    if family and #family.note > 0 then
      for _, p in ipairs(family.note) do table.insert(intro, p) end
    else
      table.insert(intro, T.soft .. "The naturalist has not yet written of these. What follows is your own record.|r")
    end
    ids = sortedIds(ns.metByFamily()[key] or {})
  end
  page.body:ClearAllPoints()
  page.body:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -12)
  page.body:SetWidth(WIDTH)
  page.body:SetText(table.concat(intro, "\n\n"))
  local y = page.title:GetStringHeight() + 12 + page.body:GetStringHeight() + 20
  if key == TROPHIES then
    y = layEntries(ids, y, function(id, rec)
      return ("%s, slain %s at level %d."):format(ns.familyTitle(ns.familyKey(id, rec)), day(rec.trophy), rec.trophy.level or 0)
    end)
  else
    y = layEntries(ids, y, function(_, rec) return summary(rec) end)
  end
  finish(y, keep)
end

-- A creature's page: its portrait (the whole creature), its family, and
-- everything this character has recorded of it.
local function showCreature(id, keep)
  local journal = ns.journal()
  local rec = journal and journal.creatures[id]
  if not rec then return end
  current, currentCreature = ns.familyKey(id, rec), id
  hideAll()
  page.title:SetText(nameOf(id, rec))
  page.portrait:ClearAllPoints()
  page.portrait:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 2, -14)
  portrait(page.portrait, id, 0)
  page.portrait:Show()
  -- Beside the portrait: what it is.
  local what = { ("%s%s|r"):format(T.link, ns.familyTitle(current)) }
  table.insert(what, levels(rec))
  page.record:SetText(table.concat(what, "\n"))
  page.record:Show()
  -- Under it: the record.
  local lines = {}
  local function add(label, text) if text then table.insert(lines, ("%s%s:|r %s"):format(T.soft, label, text)) end end
  local first, last = rec.first or {}, rec.last
  add("First met", ("%s, at level %d"):format(day(first), first.level or 0))
  if last and last.at ~= first.at then add("Last seen", ("%s, at level %d"):format(day(last), last.level or 0)) end
  add("Where", rec.places and table.concat(rec.places, "; "))
  if (rec.slain or 0) > 0 then
    add("Slain", ("%d (first %s, at level %d)"):format(rec.slain, day(rec.firstSlain), rec.firstSlain and rec.firstSlain.level or 0))
  else
    add("Slain", "none yet")
  end
  if rec.trophy then add("Trophy", ("%s, at level %d"):format(day(rec.trophy), rec.trophy.level or 0)) end
  add("Loot", lootLine(rec, 12))
  page.body:ClearAllPoints()
  page.body:SetPoint("TOPLEFT", page.portrait, "BOTTOMLEFT", -2, -16)
  page.body:SetWidth(WIDTH)
  page.body:SetText(table.concat(lines, "\n"))
  local y = page.title:GetStringHeight() + 14 + BIG + 16 + page.body:GetStringHeight()
  finish(y, keep)
end
ns.showCreature = showCreature

local function rerender()
  if not (current and page:IsShown()) then return end
  if currentCreature then showCreature(currentCreature, true) else showFamily(current, true) end
end

-- ── the list ─────────────────────────────────────────────────────────────────
local ROW_WIDTH = 196
local rows = {}
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.text:SetPoint("RIGHT", -34, 0)
  r.text:SetJustifyH("LEFT")
  r.text:SetWordWrap(false)
  r.count = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  r.count:SetPoint("RIGHT", -6, 0)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(14, 14)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.6)
  rows[i] = r
  return r
end

local function journalState(name)
  local j = ns.journal()
  if not j then return {} end
  j[name] = j[name] or {}
  return j[name]
end
-- Types fold (folded: collapsed[section id]); families unfold (open[family]).
local function folded() return journalState("collapsed") end
local function opened() return journalState("open") end
local function familyId(key) return type(key) == "number" and D.families[key].id or key end

local function nameMatches(id, query)
  local name = ns.journal().creatures[id].name
  return name ~= nil and name:lower():find(query, 1, true) ~= nil
end

local function plus(r, open)
  r.fold:SetTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
end

function ns.refresh()
  if not book then return end
  local creatures, families, slain = ns.counts()
  book.count:SetText(("%d creatures, %d families, %d slain"):format(creatures, families, slain))
  for _, r in ipairs(rows) do r:Hide() end
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local searching = query ~= ""
  local by = ns.metByFamily()
  local journal = ns.journal()
  local i, y, selectedY = 0, 0, nil
  local function add(kind, text, count)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.kind = kind
    r.count:SetText(count and tostring(count) or "")
    r.text:SetText(text)
    r.fold:ClearAllPoints()
    r.selected:Hide()
    if kind == "section" then
      r.fold:SetPoint("LEFT", 2, 0)
      r.fold:Show()
      r.text:SetPoint("LEFT", 20, 0)
      r.text:SetFontObject("GameFontNormal")
      y = y + 22
    elseif kind == "family" then
      r.fold:SetPoint("LEFT", 10, 0)
      r.fold:Show()
      r.text:SetPoint("LEFT", 26, 0)
      r.text:SetFontObject("GameFontHighlightSmall")
      y = y + 18
    else
      r.fold:Hide()
      r.text:SetPoint("LEFT", 34, 0)
      r.text:SetFontObject("GameFontHighlightSmall")
      y = y + 16
    end
    r:Show()
    return r
  end
  local function select(r)
    r.selected:Show()
    selectedY = y
  end

  -- Trophies first.
  local trophies = 0
  for _, rec in pairs(journal and journal.creatures or {}) do
    if rec.trophy then trophies = trophies + 1 end
  end
  if trophies > 0 and not searching then
    local r = add("trophies", "Trophies", trophies)
    r.fold:Hide()
    r.text:SetPoint("LEFT", 8, 0)
    r:SetScript("OnClick", function()
      showFamily(TROPHIES)
      ns.refresh()
    end)
    if current == TROPHIES then select(r) end
  end

  -- A family and, unfolded, its creatures.
  local function addFamily(key)
    local ids = by[key]
    local titleHit = searching and ns.familyTitle(key):lower():find(query, 1, true)
    local shownIds = {}
    for _, id in ipairs(sortedIds(ids)) do
      if not searching or titleHit or nameMatches(id, query) then table.insert(shownIds, id) end
    end
    if #shownIds == 0 then return end
    local open = searching or opened()[familyId(key)]
    local r = add("family", ns.familyTitle(key), #ids)
    plus(r, open)
    r.key = key
    r:SetScript("OnClick", function()
      -- The open family's row folds it; any other opens its page, unfolded.
      if current == key and not currentCreature and opened()[familyId(key)] then
        opened()[familyId(key)] = nil
      else
        opened()[familyId(key)] = true
        showFamily(key)
      end
      ns.refresh()
    end)
    if current == key and not currentCreature then select(r) end
    if not open then return end
    for _, id in ipairs(shownIds) do
      local c = add("creature", nameOf(id, journal.creatures[id]))
      c.id = id
      c:SetScript("OnClick", function()
        showCreature(id)
        ns.refresh()
      end)
      if currentCreature == id then select(c) end
    end
  end

  local function addSection(id, title, keys)
    local shown = {}
    for _, key in ipairs(keys) do
      local hit = not searching or ns.familyTitle(key):lower():find(query, 1, true)
      if not hit then
        for _, cid in ipairs(by[key]) do
          if nameMatches(cid, query) then hit = true end
        end
      end
      if hit then table.insert(shown, key) end
    end
    if #shown == 0 then return end
    y = y + 4
    local r = add("section", title)
    plus(r, searching or not folded()[id])
    r:SetScript("OnClick", function()
      folded()[id] = not folded()[id] or nil
      ns.refresh()
    end)
    if searching or not folded()[id] then
      for _, key in ipairs(shown) do addFamily(key) end
    end
  end

  -- Families met, under their type; keys the data couldn't place (a type of
  -- another client's language) at the end.
  local placed = {}
  for _, section in ipairs(D.sections) do
    local keys = {}
    for index, family in ipairs(D.families) do
      if family.section == section.id and by[index] then
        table.insert(keys, index)
        placed[index] = true
      end
    end
    addSection(section.id, section.title, keys)
  end
  local other = {}
  for key in pairs(by) do
    if not placed[key] then table.insert(other, key) end
  end
  table.sort(other, function(a, b) return tostring(a) < tostring(b) end)
  addSection("unrecorded", "Unrecorded", other)

  list.child:SetHeight(y + 8)
  -- Keep the selection in view (a link in chat may open a page far down).
  if selectedY then
    local top, height = list:GetVerticalScroll(), list:GetHeight()
    if selectedY - 18 < top or selectedY > top + height then
      list:SetVerticalScroll(math.max(0, selectedY - height / 2))
    end
  end
  rerender()
end

-- ── the book ─────────────────────────────────────────────────────────────────
-- Forever: a standard game window (portrait, title bar, dark insets).
local function gameWindow()
  local ok, frame = pcall(CreateFrame, "Frame", "FieldJournalFrame", UIParent, "ButtonFrameTemplate")
  if not ok or not frame then return nil end
  if ButtonFrameTemplate_HideButtonBar then ButtonFrameTemplate_HideButtonBar(frame) end
  if type(frame.Inset) == "table" then frame.Inset:Hide() end
  local icon = "Interface\\Icons\\INV_Misc_Book_11"
  if frame.SetPortraitToAsset then frame:SetPortraitToAsset(icon)
  elseif type(frame.portrait) == "table" then frame.portrait:SetTexture(icon) end
  local text = "Explorer's Field Journal: the Bestiary"
  if frame.SetTitle then frame:SetTitle(text)
  elseif type(frame.TitleText) == "table" then frame.TitleText:SetText(text) end
  return frame
end

local function inset(parent)
  local ok, f = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate")
  if ok and f then return f end
  return CreateFrame("Frame", nil, parent)
end

function build()
  local modern = ns.forever and gameWindow()
  book = modern or CreateFrame("Frame", "FieldJournalFrame", UIParent, "BackdropTemplate")
  book:SetSize(760, 540)
  book:SetPoint("CENTER")
  book:SetFrameStrata("HIGH")
  book:SetToplevel(true)
  book:SetMovable(true)
  book:EnableMouse(true)
  book:SetClampedToScreen(true)
  book:RegisterForDrag("LeftButton")
  book:SetScript("OnDragStart", book.StartMoving)
  book:SetScript("OnDragStop", book.StopMovingOrSizing)
  tinsert(UISpecialFrames, "FieldJournalFrame") -- Escape closes it

  local top = modern and -28 or -40 -- below the title bar
  if not modern then
    book:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    local title = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("Explorer's Field Journal: the Bestiary")
    local close = CreateFrame("Button", nil, book, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
  end

  book.count = book:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  book.search = CreateFrame("EditBox", "FieldJournalSearch", book, "SearchBoxTemplate")
  book.search:SetSize(196, 20)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  local left, sheet
  if modern then
    -- Count and search under the title bar, beside the portrait; the list
    -- and the page in insets.
    book.count:SetPoint("TOPLEFT", 66, -34)
    book.search:SetPoint("TOPLEFT", 70, -50)
    left = inset(book)
    left:SetPoint("TOPLEFT", 8, -76)
    left:SetPoint("BOTTOMLEFT", 8, 8)
    left:SetWidth(232)
    sheet = inset(book)
    sheet:SetPoint("TOPLEFT", 246, top)
    sheet:SetPoint("BOTTOMRIGHT", -8, 8)
  else
    book.count:SetPoint("TOPLEFT", 24, -22)
    book.search:SetPoint("TOPLEFT", 28, -44)
    left = book
    sheet = CreateFrame("Frame", nil, book)
    sheet:SetPoint("TOPLEFT", 256, top)
    sheet:SetPoint("BOTTOMRIGHT", -20, 18)
    local paper = sheet:CreateTexture(nil, "BACKGROUND")
    paper:SetAllPoints()
    -- The parchment of the game's own book reader, as in Lorekeeper's Codex.
    paper:SetTexture("Interface\\MailFrame\\UI-MailFrameBG")
    paper:SetTexCoord(0, 0.625, 0, 0.70)
  end

  list = CreateFrame("ScrollFrame", "FieldJournalList", left, "UIPanelScrollFrameTemplate")
  if modern then
    list:SetPoint("TOPLEFT", 4, -6)
    list:SetPoint("BOTTOMRIGHT", -26, 6)
  else
    list:SetPoint("TOPLEFT", 20, -70)
    list:SetPoint("BOTTOMLEFT", 20, 20)
    list:SetWidth(204)
  end
  list.child = CreateFrame("Frame", nil, list)
  list.child:SetSize(204, 10)
  list:SetScrollChild(list.child)

  page = CreateFrame("ScrollFrame", "FieldJournalPage", sheet, "UIPanelScrollFrameTemplate")
  page:SetPoint("TOPLEFT", 18, -16)
  page:SetPoint("BOTTOMRIGHT", -32, 14)
  page.child = CreateFrame("Frame", nil, page)
  page.child:SetSize(WIDTH, 10)
  page:SetScrollChild(page.child)

  page.title = page.child:CreateFontString(nil, "OVERLAY", "QuestTitleFont")
  page.title:SetPoint("TOPLEFT", 0, 0)
  page.title:SetWidth(WIDTH)
  page.title:SetJustifyH("LEFT")
  ink(page.title, T.title)

  page.body = page.child:CreateFontString(nil, "OVERLAY", "QuestFont")
  page.body:SetWidth(WIDTH)
  page.body:SetJustifyH("LEFT")
  page.body:SetSpacing(3)
  ink(page.body, T.ink)

  -- A creature's page: the big portrait, and what it is beside it.
  page.portrait = portraitFrame(page.child, BIG)
  page.portrait:Hide()
  page.record = page.child:CreateFontString(nil, "OVERLAY", "QuestFont")
  page.record:SetPoint("TOPLEFT", page.portrait, "TOPRIGHT", 14, -4)
  page.record:SetWidth(WIDTH - BIG - 20)
  page.record:SetJustifyH("LEFT")
  page.record:SetSpacing(4)
  ink(page.record, T.ink)
  page.record:Hide()

  book:SetScript("OnShow", function()
    if not current then
      -- First opening: the most recently met family.
      local journal, latest, at = ns.journal(), nil, -1
      for key, f in pairs(journal and journal.families or {}) do
        if (f.at or 0) > at then latest, at = key, f.at or 0 end
      end
      current = latest
      if current then opened()[familyId(current)] = true end
    end
    if currentCreature then showCreature(currentCreature)
    elseif current then showFamily(current)
    else
      hideAll()
      page.title:SetText("The Bestiary")
      page.body:ClearAllPoints()
      page.body:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -12)
      page.body:SetText(T.soft .. "Nothing recorded yet. Target or mouse over a creature of the wild, and it will be written here.|r")
    end
    ns.refresh()
  end)
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

local function open(show)
  if not book then build() end
  if book:IsShown() then
    show()
    ns.refresh()
  else
    book:Show()
  end
end

-- Open the book at a family (fieldjournal:<family index> or
-- fieldjournal:?<type>/<family>), unfolded in the list.
function ns.openFamily(key)
  if not book then build() end
  current, currentCreature = key, nil
  opened()[familyId(key)] = true
  open(function() showFamily(key) end)
end

-- Open the book at a creature's page (fieldjournal:c<creature id>).
function ns.openCreature(id)
  local journal = ns.journal()
  local rec = journal and journal.creatures[id]
  if not rec then return end
  if not book then build() end
  current, currentCreature = ns.familyKey(id, rec), id
  opened()[familyId(current)] = true
  open(function() showCreature(id) end)
end

local function followLink(link)
  local key = link:match("^fieldjournal:(.+)$")
  if not key then return end
  local creature = tonumber(key:match("^c(%d+)$"))
  if creature then
    ns.openCreature(creature)
  else
    ns.openFamily(tonumber(key) or key)
  end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("fieldjournal", function(link)
    followLink(link)
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
elseif hooksecurefunc and SetItemRef then
  hooksecurefunc("SetItemRef", function(link) followLink(link) end)
end

-- What's recorded while the book is open shows up at once (throttled: meeting
-- creatures happens constantly).
local pending = false
ns.onRecord = function()
  if not (book and book:IsShown()) or pending then return end
  pending = true
  local function run()
    pending = false
    ns.refresh()
  end
  if C_Timer then C_Timer.After(0.5, run) else run() end
end
