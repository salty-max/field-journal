-- The Bestiary as a book: on the left, the creature types and the families met
-- in them (a click on a type folds it); on the right, on parchment, the
-- family's note by the League's naturalist and this character's record of
-- every creature met in it. A Trophies page lists the rares and bosses slain.
-- /journal opens it.
local _, ns = ...
local D = ns.data

local INK = { 0.22, 0.14, 0.05 }
local TROPHIES = "trophies"

local book, list, page
local current -- family key (number or "?…" string) or TROPHIES
local build

-- ── the open page ────────────────────────────────────────────────────────────
local function place(rec)
  local p = rec.places and rec.places[1]
  if not p then return nil end
  if #rec.places > 1 then return ("%s, and %d other place%s"):format(p, #rec.places - 1, #rec.places > 2 and "s" or "") end
  return p
end

local function itemName(itemId)
  local name = (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(itemId)) or (GetItemInfo and GetItemInfo(itemId))
  return name or ("item " .. itemId)
end

local function lootLine(rec)
  if not rec.loot then return nil end
  local items = {}
  for itemId, count in pairs(rec.loot) do table.insert(items, { itemId, count }) end
  table.sort(items, function(a, b) return a[2] > b[2] end)
  local parts = {}
  for i = 1, math.min(#items, 5) do
    table.insert(parts, ("%s%s"):format(itemName(items[i][1]), items[i][2] > 1 and (" x" .. items[i][2]) or ""))
  end
  if #items > 5 then table.insert(parts, ("and %d more"):format(#items - 5)) end
  return "Loot: " .. table.concat(parts, ", ")
end

local RANK = { r = "rare", R = "rare elite", b = "boss" }

-- One creature's record, as a few lines of the page.
local function creatureText(id, rec)
  local journal = ns.journal()
  local lines = {}
  local mark = rec.trophy and (" |cff8a3a1c(%s, trophy)|r"):format(RANK[rec.trophy.rank] or "trophy")
    or (ns.rank(id) and (" |cff6b4a26(%s)|r"):format(RANK[ns.rank(id)]) or "")
  table.insert(lines, ("|cff38240d%s|r%s"):format(rec.name or ("creature " .. id), mark))
  local facts = {}
  if rec.low then table.insert(facts, rec.low == rec.high and ("level %d"):format(rec.low) or ("levels %d-%d"):format(rec.low, rec.high)) end
  local where = place(rec)
  if where then table.insert(facts, where) end
  table.insert(facts, (rec.slain or 0) > 0 and ("%d slain"):format(rec.slain) or "none slain")
  table.insert(lines, table.concat(facts, " - "))
  if rec.first then
    table.insert(lines, ("First met %s, at level %d."):format(date("%d %b %Y", rec.first.at or 0), rec.first.level or 0))
  end
  local loot = lootLine(rec)
  if loot then table.insert(lines, loot) end
  return table.concat(lines, "\n")
end

local function sortedIds(ids)
  local journal = ns.journal()
  table.sort(ids, function(a, b)
    local ra, rb = journal.creatures[a], journal.creatures[b]
    return (ra.name or "") < (rb.name or "")
  end)
  return ids
end

-- keep: re-render in place (the page's records changed), keeping the scroll.
local function showPage(key, keep)
  current = key
  local journal = ns.journal()
  if not journal or not key then return end
  local paras = {}
  local title
  if key == TROPHIES then
    title = "Trophies"
    table.insert(paras, "|cff6b4a26The rare beasts and the great foes this traveller has brought down, with the day and the level of the deed.|r")
    local ids = {}
    for id, rec in pairs(journal.creatures) do
      if rec.trophy then table.insert(ids, id) end
    end
    table.sort(ids, function(a, b) return journal.creatures[a].trophy.at < journal.creatures[b].trophy.at end)
    if #ids == 0 then table.insert(paras, "None yet.") end
    for _, id in ipairs(ids) do
      local rec = journal.creatures[id]
      table.insert(paras, ("|cff38240d%s|r - %s, slain %s at level %d"):format(rec.name or ("creature " .. id),
        ns.familyTitle(ns.familyKey(id, rec)), date("%d %b %Y", rec.trophy.at), rec.trophy.level or 0))
    end
  else
    title = ns.familyTitle(key)
    local family = type(key) == "number" and D.families[key]
    if family and #family.note > 0 then
      for _, p in ipairs(family.note) do table.insert(paras, p) end
    else
      table.insert(paras, "|cff6b4a26The naturalist has not yet written of these. What follows is your own record.|r")
    end
    local ids = sortedIds(ns.metByFamily()[key] or {})
    table.insert(paras, ("|cff6b4a26Met: %d|r"):format(#ids))
    for _, id in ipairs(ids) do table.insert(paras, creatureText(id, journal.creatures[id])) end
  end
  page.title:SetText(title)
  page.body:SetText(table.concat(paras, "\n\n"))
  if not keep then page.scroll:SetVerticalScroll(0) end
  page.child:SetHeight(page.title:GetStringHeight() + page.body:GetStringHeight() + 60)
end

-- ── the list ─────────────────────────────────────────────────────────────────
local rows = {}
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(196, 18)
  r.text = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  r.text:SetPoint("LEFT", 8, 0)
  r.text:SetPoint("RIGHT", -34, 0)
  r.text:SetJustifyH("LEFT")
  r.count = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  r.count:SetPoint("RIGHT", -6, 0)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(16, 16)
  r.fold:SetPoint("LEFT", 2, 0)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  rows[i] = r
  return r
end

local function folded()
  local j = ns.journal()
  if not j then return {} end
  j.collapsed = j.collapsed or {}
  return j.collapsed
end

-- Does a family (or one of its creatures) match the search?
local function matches(key, ids, query)
  if ns.familyTitle(key):lower():find(query, 1, true) then return true end
  local journal = ns.journal()
  for _, id in ipairs(ids) do
    local name = journal.creatures[id].name
    if name and name:lower():find(query, 1, true) then return true end
  end
  return false
end

function ns.refresh()
  if not book then return end
  local creatures, families, slain = ns.counts()
  book.count:SetText(("%d creatures, %d families, %d slain"):format(creatures, families, slain))
  for _, r in ipairs(rows) do r:Hide() end
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local searching = query ~= ""
  local by = ns.metByFamily()
  local i, y = 0, 0
  local function add(kind, text, key, count)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.key = key
    r.fold:SetShown(kind == "section")
    r.text:SetPoint("LEFT", kind == "section" and 20 or 8, 0)
    r.count:SetText(count and tostring(count) or "")
    if kind == "section" then
      r.text:SetFontObject("GameFontNormal")
      r.text:SetText(text)
      r.fold:SetTexture(folded()[key] and "Interface\\Buttons\\UI-PlusButton-Up" or "Interface\\Buttons\\UI-MinusButton-Up")
      r:SetScript("OnClick", function()
        folded()[key] = not folded()[key] or nil
        ns.refresh()
      end)
      y = y + 22
    else
      r.text:SetFontObject(key == current and "GameFontNormalSmall" or "GameFontHighlightSmall")
      r.text:SetText(text)
      r:SetScript("OnClick", function()
        showPage(key)
        ns.refresh()
      end)
      y = y + 18
    end
    r:Show()
  end
  local journal = ns.journal()
  local trophies = 0
  for _, rec in pairs(journal and journal.creatures or {}) do
    if rec.trophy then trophies = trophies + 1 end
  end
  if trophies > 0 and not searching then add("family", "Trophies", TROPHIES, trophies) end
  -- Families met, under their section; the unrecorded ones (creatures the data
  -- doesn't know) at the end of their creature type's section.
  for _, section in ipairs(D.sections) do
    local keys = {}
    for index, family in ipairs(D.families) do
      if family.section == section.id and by[index] then table.insert(keys, index) end
    end
    for key in pairs(by) do
      if type(key) == "string" then
        local rec = journal.creatures[by[key][1]]
        if rec and rec.type and section.type ~= "" and key:find("?" .. section.type, 1, true) == 1 then table.insert(keys, key) end
      end
    end
    local shown = {}
    for _, key in ipairs(keys) do
      if not searching or matches(key, by[key], query) then table.insert(shown, key) end
    end
    if #shown > 0 then
      y = y + 4
      add("section", section.title, section.id)
      if searching or not folded()[section.id] then
        for _, key in ipairs(shown) do add("family", ns.familyTitle(key), key, #by[key]) end
      end
    end
  end
  -- Creatures of a type no section holds (localized names of other clients).
  local other = {}
  for key in pairs(by) do
    if type(key) == "string" then
      local placed = false
      for _, section in ipairs(D.sections) do
        if key:find("?" .. section.type, 1, true) == 1 then placed = true end
      end
      if not placed and (not searching or matches(key, by[key], query)) then table.insert(other, key) end
    end
  end
  if #other > 0 then
    y = y + 4
    add("section", "Unrecorded", "unrecorded")
    if searching or not folded().unrecorded then
      for _, key in ipairs(other) do add("family", ns.familyTitle(key), key, #by[key]) end
    end
  end
  list.child:SetHeight(y + 8)
  if current and page:IsShown() then showPage(current, true) end
end

-- ── the book ─────────────────────────────────────────────────────────────────
function build()
  book = CreateFrame("Frame", "FieldJournalFrame", UIParent, "BackdropTemplate")
  book:SetSize(760, 520)
  book:SetPoint("CENTER")
  book:SetFrameStrata("HIGH")
  book:SetToplevel(true)
  book:SetMovable(true)
  book:EnableMouse(true)
  book:SetClampedToScreen(true)
  book:RegisterForDrag("LeftButton")
  book:SetScript("OnDragStart", book.StartMoving)
  book:SetScript("OnDragStop", book.StopMovingOrSizing)
  book:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  tinsert(UISpecialFrames, "FieldJournalFrame") -- Escape closes it

  local title = book:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -18)
  title:SetText("Explorer's Field Journal: the Bestiary")

  local close = CreateFrame("Button", nil, book, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)

  book.count = book:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  book.count:SetPoint("TOPLEFT", 24, -22)

  book.search = CreateFrame("EditBox", "FieldJournalSearch", book, "SearchBoxTemplate")
  book.search:SetSize(196, 20)
  book.search:SetPoint("TOPLEFT", 28, -44)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  list = CreateFrame("ScrollFrame", "FieldJournalList", book, "UIPanelScrollFrameTemplate")
  list:SetPoint("TOPLEFT", 20, -70)
  list:SetPoint("BOTTOMLEFT", 20, 20)
  list:SetWidth(204)
  list.child = CreateFrame("Frame", nil, list)
  list.child:SetSize(204, 10)
  list:SetScrollChild(list.child)

  local sheet = CreateFrame("Frame", nil, book)
  sheet:SetPoint("TOPLEFT", 256, -40)
  sheet:SetPoint("BOTTOMRIGHT", -20, 18)
  local paper = sheet:CreateTexture(nil, "BACKGROUND")
  paper:SetAllPoints()
  -- The parchment of the game's own book reader, as in Lorekeeper's Codex.
  paper:SetTexture("Interface\\MailFrame\\UI-MailFrameBG")
  paper:SetTexCoord(0, 0.625, 0, 0.70)

  page = CreateFrame("ScrollFrame", "FieldJournalPage", sheet, "UIPanelScrollFrameTemplate")
  page:SetPoint("TOPLEFT", 18, -16)
  page:SetPoint("BOTTOMRIGHT", -32, 14)
  page.scroll = page
  page.child = CreateFrame("Frame", nil, page)
  page.child:SetSize(420, 10)
  page:SetScrollChild(page.child)

  page.title = page.child:CreateFontString(nil, "OVERLAY", "QuestTitleFont")
  page.title:SetPoint("TOPLEFT", 0, 0)
  page.title:SetWidth(420)
  page.title:SetJustifyH("LEFT")
  page.title:SetTextColor(unpack(INK))
  page.title:SetShadowColor(0, 0, 0, 0)

  page.body = page.child:CreateFontString(nil, "OVERLAY", "QuestFont")
  page.body:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -12)
  page.body:SetWidth(420)
  page.body:SetJustifyH("LEFT")
  page.body:SetSpacing(2)
  page.body:SetTextColor(unpack(INK))
  page.body:SetShadowColor(0, 0, 0, 0)

  book:SetScript("OnShow", function()
    if not current then
      -- First opening: the most recently met family.
      local journal, latest, at = ns.journal(), nil, -1
      for key, f in pairs(journal and journal.families or {}) do
        if (f.at or 0) > at then latest, at = key, f.at or 0 end
      end
      current = latest
    end
    if current then showPage(current) else
      page.title:SetText("The Bestiary")
      page.body:SetText("|cff6b4a26Nothing recorded yet. Target or mouse over a creature of the wild, and it will be written here.|r")
    end
    ns.refresh()
  end)
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

-- Open the book at a family (a link in chat: fieldjournal:<family index>,
-- fieldjournal:?<type>/<family> or fieldjournal:c<creature id>).
function ns.openFamily(key)
  if not book then build() end
  current = key
  if book:IsShown() then
    showPage(key)
    ns.refresh()
  else
    book:Show()
  end
end

local function followLink(link)
  local key = link:match("^fieldjournal:(.+)$")
  if not key then return end
  local creature = key:match("^c(%d+)$")
  if creature then
    local journal = ns.journal()
    key = ns.familyKey(tonumber(creature), journal and journal.creatures[tonumber(creature)])
  else
    key = tonumber(key) or key
  end
  if key then ns.openFamily(key) end
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
