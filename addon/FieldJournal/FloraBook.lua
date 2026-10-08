-- The Fish and Plants tabs in the book (built on first opening, in the
-- Bestiary's panels, one list and one page for both): on the left, the kinds
-- this character has found, in groups (fish: of the waters, reagents, rare
-- catches, quest fish, weighed catches; herbs: by the Herbalism rank they
-- need), with how many; on the right, a kind's page: its icon, the naturalist's
-- note (where there is one), where it bites or grows (the game's data, shown
-- once found: no spoilers), and the character's record. Records: Flora.lua.
local _, ns = ...
local F = ns.data.flora

local ui
local book, list, page
local mode = "fish" -- the tab shown: "fish" or "plants"
local current = {} -- the open kind of each tab (an item id), nil for its overview
local rows, pairsPool, lines = {}, {}, {}
ns.floraRows = rows -- for the tests

local ROW_WIDTH = 204
local W -- the page's width

local function day(stamp) return date("%d %b %Y", stamp and stamp.at or 0) end
local function when(stamp)
  if not stamp or not stamp.at then return nil end
  local where = stamp.zone and ns.zoneName(stamp.zone)
  if where and stamp.sub and stamp.sub ~= where then where = ("%s, %s"):format(stamp.sub, where) end
  return ("%s%s, you were level %d"):format(day(stamp), where and (" in " .. where) or "", stamp.level or 0)
end

-- The game's name and icon of an item (localized; the data's English name
-- while the game hasn't the item in its cache yet).
local function itemName(id, fallback)
  local name = GetItemInfo and GetItemInfo(id)
  if name and not ns.secret(name) then return name end
  return fallback
end
local function itemIcon(id)
  if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
  return GetItemIcon and GetItemIcon(id)
end

local FISH_GROUPS = {
  { "food", "Fish of the waters" },
  { "reagent", "Reagents" },
  { "special", "Rare catches" },
  { "quest", "Quest fish" },
  { "record", "Weighed catches" },
}
local KIND = {
  food = "A fish of the waters",
  reagent = "A reagent",
  special = "A rare catch",
  quest = "A quest fish",
  record = "Weighed catches",
}
-- The Herbalism ranks, by the skill an herb needs.
local RANKS = { { 1, "Apprentice" }, { 75, "Journeyman" }, { 150, "Expert" }, { 225, "Artisan" } }
local function rankOf(skill)
  local name = RANKS[1][2]
  for _, r in ipairs(RANKS) do
    if skill >= r[1] then name = r[2] end
  end
  return name
end

local function records() return mode == "fish" and (ns.journal().fish or {}) or (ns.journal().plants or {}) end
local function info(id) return mode == "fish" and F.fish[id] or F.herbs[id] end
local function name(id)
  return mode == "fish" and (info(id).kind == "record" and info(id).name or itemName(id, info(id).name))
    or itemName(id, info(id).name)
end

-- ── the list ─────────────────────────────────────────────────────────────────
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = ui.label(r, ui.BODY_FONT, 12, ui.T.text)
  r.text:SetWordWrap(false)
  r.count = ui.label(r, ui.BODY_FONT, 10, ui.T.soft)
  r.count:SetJustifyH("RIGHT")
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
  rows[i] = r
  return r
end

-- The kinds found, grouped: { { title, { ids } } }, the search applied.
local function groups()
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local recs = records()
  local function shown(id) return recs[id] and (query == "" or name(id):lower():find(query, 1, true)) end
  local out = {}
  if mode == "fish" then
    for _, g in ipairs(FISH_GROUPS) do
      local ids = {}
      for _, id in ipairs(F.fishOrder) do
        if F.fish[id].kind == g[1] and shown(id) then table.insert(ids, id) end
      end
      if #ids > 0 then table.insert(out, { g[2], ids }) end
    end
  else
    for _, r in ipairs(RANKS) do
      local ids = {}
      for _, id in ipairs(F.herbOrder) do
        if rankOf(F.herbs[id].skill) == r[2] and shown(id) then table.insert(ids, id) end
      end
      if #ids > 0 then table.insert(out, { r[2], ids }) end
    end
  end
  return out, query ~= ""
end

local showKind, showOverview

local function refreshList()
  for _, r in ipairs(rows) do
    r:Hide()
  end
  local i, y, selectedY = 0, 0, nil
  local function add(kind, text, count)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.key = nil
    r.text:SetText(text)
    r.text:ClearAllPoints()
    r.count:ClearAllPoints()
    r.count:SetText(count or "")
    r.selected:Hide()
    r:Enable()
    r:SetScript("OnClick", nil)
    local height
    if kind == "section" then
      r.text:SetPoint("LEFT", 4, 0)
      r.text:SetPoint("RIGHT", -4, 0)
      r.text:SetFont(ui.TITLE_FONT, 14, "")
      r.text:SetTextColor(unpack(ui.T.gold))
      height = 22
    else
      r.count:SetPoint("RIGHT", -4, 0)
      r.text:SetPoint("LEFT", kind == "overview" and 4 or 14, 0)
      r.text:SetPoint("RIGHT", r.count, "LEFT", -4, 0)
      r.text:SetFont(ui.BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(kind == "overview" and ui.T.gold or ui.T.text))
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
  local found, searching = groups()
  if not searching then
    local r = add("overview", mode == "fish" and "The catch so far" or "The herbs so far")
    r:SetScript("OnClick", function()
      showOverview()
      refreshList()
    end)
    if current[mode] == nil then select(r) end
  end
  local recs = records()
  for _, g in ipairs(found) do
    y = y + 6
    add("section", g[1])
    for _, id in ipairs(g[2]) do
      local r = add("kind", name(id), tostring(recs[id].n or 0))
      r.key = id
      r:SetScript("OnClick", function()
        showKind(id)
        refreshList()
      end)
      if current[mode] == id then select(r) end
    end
  end
  if #found == 0 and searching then add("section", "Nothing found") end
  list.child:SetHeight(y + 8)
  list:UpdateThumb()
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
  p:SetSize(W, 16)
  p.label = ui.label(p, ui.BODY_FONT, 12, ui.T.soft)
  p.label:SetPoint("TOPLEFT", 0, 0)
  p.label:SetWidth(110)
  p.value = ui.label(p, ui.BODY_FONT, 12, ui.T.text)
  p.value:SetPoint("TOPLEFT", 118, 0)
  p.value:SetWidth(W - 118)
  p.value:SetSpacing(4)
  pairsPool[i] = p
  return p
end
ns.floraPairs = pairsPool -- for the tests

local function heading(i)
  local h = lines[i]
  if h then return h end
  h = CreateFrame("Frame", nil, page.child)
  h:SetSize(W, 24)
  h.text = ui.label(h, ui.TITLE_FONT, 16, ui.T.gold)
  h.text:SetPoint("BOTTOMLEFT", 0, 5)
  h.line = ui.rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  lines[i] = h
  return h
end

local y, hi, pi
local function start()
  for _, x in ipairs(pairsPool) do
    x:Hide()
  end
  for _, x in ipairs(lines) do
    x:Hide()
  end
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
local function row2(label, value)
  if not value or value == "" then return end
  pi = pi + 1
  local p = pair(pi)
  p.label:SetText(label)
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

local function zoneList(zones)
  local names = {}
  for _, z in ipairs(zones or {}) do
    table.insert(names, ns.zoneName(z))
  end
  table.sort(names)
  return #names > 0 and table.concat(names, ", ") or nil
end
local function joined(list) return list and #list > 0 and table.concat(list, ", ") or nil end

-- Where the character found it most: "Elwynn Forest (12), Westfall (3)".
local function mostFound(zones)
  local list = {}
  for z, n in pairs(zones or {}) do
    table.insert(list, { z, n })
  end
  table.sort(list, function(a, b) return a[2] > b[2] end)
  local out = {}
  for i = 1, math.min(#list, 5) do
    table.insert(out, ("%s (%d)"):format(ns.zoneName(list[i][1]), list[i][2]))
  end
  return joined(out)
end

local function note(text)
  if not text or #text == 0 then return end
  page.note:SetText(table.concat(text, "\n\n"))
  page.note:ClearAllPoints()
  page.note:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  page.note:Show()
  y = y + page.note:GetStringHeight() + 20
end

function showKind(id)
  current[mode] = id
  local d, rec = info(id), records()[id]
  if not (d and rec) then return showOverview() end
  start()
  page.title:SetText(name(id))
  ui.icon(itemIcon(id) or "Interface\\Icons\\INV_Misc_QuestionMark")(page.portrait)
  if mode == "fish" then
    page.sub:SetText(table.concat({ KIND[d.kind], d.season and ("only in %s"):format(d.season) or nil }, "  -  "))
    note(d.note)
    section("Where it bites")
    row2("Zones", zoneList(d.zones))
    row2("Waters", joined(d.subzones))
    row2("Dungeons", joined(d.dungeons))
    section("Your catches")
    row2("First caught", when(rec.first))
    row2("Caught", tostring(rec.n or 0))
    row2("By day, by night", ("%d, %d"):format(rec.day or 0, rec.night or 0))
    if (rec.school or 0) > 0 then row2("From schools", tostring(rec.school)) end
    if rec.heaviest then row2("Heaviest", ("%d pounds"):format(rec.heaviest)) end
    row2("Where", mostFound(rec.zones))
  else
    page.sub:SetText(("Herbalism %d%s"):format(d.skill, d.inside and "  -  found in other herbs" or ""))
    note(d.note)
    section("Where it grows")
    row2("Zones", zoneList(d.zones))
    row2("Dungeons", joined(d.dungeons))
    section("Your herbs")
    local how = { gathered = "gathered", looted = "looted", other = "came to your bags" }
    local first = when(rec.first)
    row2("First", first and ("%s (%s)"):format(first, how[rec.first.how] or "?") or nil)
    row2("Gathered", tostring(rec.gathered or 0))
    row2("Looted", tostring(rec.looted or 0))
    row2("Where", mostFound(rec.zones))
  end
  finish()
end

function showOverview()
  current[mode] = nil
  start()
  local recs, kinds, total = records(), 0, 0
  for _, rec in pairs(recs) do
    kinds = kinds + 1
    total = total + (rec.n or 0)
  end
  if mode == "fish" then
    page.title:SetText("The catch so far")
    page.sub:SetText(("%d kinds of fish, %d caught"):format(kinds, total))
    ui.icon("Interface\\Icons\\Trade_Fishing")(page.portrait)
    if kinds == 0 then
      row2("", ui.SOFT .. "Nothing caught yet. Every fish you land is written down here, with where and when it bit.|r")
    else
      section("Your catches")
      local schools, night, heavy = 0, 0, nil
      for id, rec in pairs(recs) do
        schools, night = schools + (rec.school or 0), night + (rec.night or 0)
        if rec.heaviest and (not heavy or rec.heaviest > heavy[2]) then heavy = { id, rec.heaviest } end
      end
      row2("Kinds", tostring(kinds))
      row2("Caught", tostring(total))
      row2("From schools", tostring(schools))
      row2("By night", tostring(night))
      if heavy then row2("Heaviest", ("%s, %d pounds"):format(F.fish[heavy[1]].name, heavy[2])) end
    end
  else
    page.title:SetText("The herbs so far")
    page.sub:SetText(("%d herbs, %d taken"):format(kinds, total))
    ui.icon("Interface\\Icons\\INV_Misc_Herb_07")(page.portrait)
    if kinds == 0 then
      row2(
        "",
        ui.SOFT
          .. "No herb yet. Every herb that reaches your bags is written down here: gathered, looted, bought or given.|r"
      )
    else
      section("Your herbs")
      local gathered, looted = 0, 0
      for _, rec in pairs(recs) do
        gathered, looted = gathered + (rec.gathered or 0), looted + (rec.looted or 0)
      end
      row2("Kinds", tostring(kinds))
      row2("Gathered", tostring(gathered))
      row2("Looted", tostring(looted))
    end
  end
  finish()
end

function ns.refreshFlora(which)
  if not list then return end
  mode = which or mode
  local recs, kinds, total = records(), 0, 0
  for _, rec in pairs(recs) do
    kinds = kinds + 1
    total = total + (rec.n or 0)
  end
  book.count:SetText(
    mode == "fish" and ("%d kinds of fish, %d caught"):format(kinds, total)
      or ("%d herbs, %d taken"):format(kinds, total)
  )
  refreshList()
  if current[mode] and recs[current[mode]] then
    showKind(current[mode])
  else
    showOverview()
  end
end

-- ── building ─────────────────────────────────────────────────────────────────
function ns.buildFloraBook(b)
  ui = ns.ui
  book = b
  W = ui.WIDTH
  list = ui.scrollArea(book.left, ROW_WIDTH)
  list:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -40)
  list:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -18, 12)
  page = ui.scrollArea(book.sheet, W)
  _G.FieldJournalFloraPage = page
  page:SetPoint("TOPLEFT", book.sheet, "TOPLEFT", 26, -22)
  page:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT", -22, 14)
  book.floraList, book.floraPage = list, page

  page.portrait = ui.roundPortrait(page.child, 64)
  page.portrait:SetPoint("TOPLEFT", 2, -2)
  page.title = ui.label(page.child, ui.TITLE_FONT, 24, ui.T.gold)
  page.title:SetPoint("TOPLEFT", page.portrait, "TOPRIGHT", 16, -8)
  page.title:SetWidth(W - 86)
  page.title:SetWordWrap(false)
  page.sub = ui.label(page.child, ui.BODY_FONT, 12, ui.T.soft)
  page.sub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -7)
  page.sub:SetWidth(W - 86)
  local headerRule = ui.rule(page.child)
  headerRule:SetPoint("TOPLEFT", 0, -76)
  headerRule:SetPoint("TOPRIGHT", 0, -76)
  page.note = ui.label(page.child, ui.BODY_FONT, 13, ui.T.text)
  page.note:SetWidth(W)
  page.note:SetSpacing(4)
end

-- Open the book at a fish's or an herb's page (fieldjournal:f<id>, h<id>: a
-- link in chat).
local function open(which, id)
  if not ns.journal() then return end
  local b = ns.ui.build()
  mode = which
  current[which] = id
  if not b:IsShown() then b:Show() end
  ns.showTab(which == "fish" and ns.TAB.fish or ns.TAB.plants)
end
function ns.openFish(id)
  if F.fish[id] then open("fish", id) end
end
function ns.openPlant(id)
  if F.herbs[id] then open("plants", id) end
end

-- A new catch or herb while the book shows its tab: the list follows.
ns.onFlora = function()
  local b = book
  if b and b:IsShown() and (b.selectedTab == ns.TAB.fish or b.selectedTab == ns.TAB.plants) then ns.refresh() end
end
