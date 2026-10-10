-- The journal as a book: the standard game window (portrait, title bar), its
-- tabs (the Bestiary, Fish, Plants, the Atlas, the Milestones: each a file of
-- its own, *Book.lua, registered with ns.addTab), the links in chat that open
-- it, and the kit every tab is made of (ns.ui): its look, the list on the
-- left and the page on the right. Light text and gold titles on dark panels:
-- Forever's Professions cards; on Classic, the game's insets, the quest log's
-- dark book behind the list. /journal opens it.
local _, ns = ...

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), in the Field Journal's theme: a sage accent, the panels
-- a faint moss, like a naturalist's notes.
local K = ns.kit
K.theme({
  accent = { 0.70, 0.80, 0.55 },
  ring = { 0.52, 0.62, 0.36 },
  bar = { 0.55, 0.72, 0.30 },
  tint = { 0.90, 1.00, 0.88 },
  shade = { 0.02, 0.03, 0.02, 0.55 },
  highlight = { 0.80, 1.00, 0.75 },
})
local T = K.T
T.mark, T.rare, T.link = "|cffff9a40", "|cffc7ccd6", K.hex(T.accent)
local BODY_FONT, TITLE_FONT, hex = K.BODY_FONT, K.TITLE_FONT, K.hex
local SOFT = hex(T.soft)
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local label, rule, panel, scrollArea = K.label, K.rule, K.panel, K.scrollArea
-- A round portrait in the theme's ring, a dark disc behind it (p.tex: what it shows).
local function roundPortrait(parent, size) return K.roundIcon(parent, size, true) end

-- An icon for a portrait: icon(path)(portrait).
local function icon(path)
  return function(p)
    p.display = nil
    p.tex:SetTexture(path)
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
end

-- An item's name (the data's English one while the game hasn't the item in
-- its cache yet) and icon.
local function itemName(id, fallback)
  local get = (C_Item and C_Item.GetItemInfo) or GetItemInfo
  local name = get and get(id)
  if name and not ns.secret(name) then return name end
  return fallback
end
local function itemIcon(id)
  if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
  return GetItemIcon and GetItemIcon(id)
end

local function day(stamp) return date("%d %b %Y", stamp and stamp.at or 0) end

-- The search box's words, trimmed and lower case ("": no search).
local function query(book) return strtrim((book.search:GetText() or ""):lower()) end

-- Methods set on a frame (a frame's own metatable must stay as the game made it).
local function extend(frame, methods)
  for k, v in pairs(methods) do
    frame[k] = v
  end
  return frame
end

-- ── the list ─────────────────────────────────────────────────────────────────
-- The column on the left: rows laid out from the top, one picked out (and
-- kept in view). style(row, kind) places a row's parts for its kind and
-- returns its height; each tab has its own kinds. rows: the pool of rows
-- (made at the tab's load, for the tests).
local ROW_WIDTH = 204
local List = {}

local function newList(parent, style, rows)
  local l = extend(scrollArea(parent, ROW_WIDTH), List)
  l.rows, l.style = rows or {}, style
  l:SetPoint("TOPLEFT", parent, "TOPLEFT", 12, -40)
  l:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -18, 12)
  return l
end

function List:row(i)
  local r = self.rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, self.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = label(r, BODY_FONT, 12, T.text)
  r.text:SetWordWrap(false)
  r.count = label(r, BODY_FONT, 10, T.soft)
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r.bar = false -- (a progress bar, made by the tab that wants one)
  r.selected = K.highlight(r)
  self.rows[i] = r
  return r
end

-- The list, laid out again.
function List:begin()
  for _, r in ipairs(self.rows) do
    r:Hide()
  end
  self.n, self.y, self.selectedY = 0, 0, false
end

-- A row of a kind, its text and count, under the last.
function List:add(kind, text, count)
  self.n = self.n + 1
  local r = self:row(self.n)
  r:ClearAllPoints()
  r:SetPoint("TOPLEFT", 0, -self.y)
  r.kind, r.key, r.id, r.zone, r.place = kind, false, false, false, false
  r.text:ClearAllPoints()
  r.text:SetText(text)
  r.count:ClearAllPoints()
  r.count:SetText(count and tostring(count) or "")
  r.fold:ClearAllPoints()
  r.fold:Hide()
  if r.bar then r.bar:Hide() end
  r.selected:Hide()
  r:SetScript("OnClick", nil)
  local height = self.style(r, kind)
  r:SetHeight(height)
  self.y = self.y + height
  r:Show()
  return r
end

-- A row taller than its kind (a progress bar under it).
function List:grow(r, by)
  r:SetHeight(r:GetHeight() + by)
  self.y = self.y + by
end

function List:gap(by) self.y = self.y + by end

-- The row picked out: what the page shows.
function List:pick(r)
  r.selected:Show()
  r.text:SetTextColor(1, 1, 1)
  self.selectedY = self.y
end

function List:finish()
  self.child:SetHeight(self.y + 8)
  self:UpdateThumb()
  local y = self.selectedY
  if y then
    local top, height = self:GetVerticalScroll(), self:GetHeight()
    if y - 18 < top or y > top + height then self:ScrollTo(y - height / 2) end
  end
end

-- A row's fold mark: open (minus) or folded (plus).
local PLUS, MINUS = "Interface\\Buttons\\UI-PlusButton-Up", "Interface\\Buttons\\UI-MinusButton-Up"
local function fold(r, open) r.fold:SetTexture(open and MINUS or PLUS) end

-- A small progress bar (a row's, a milestone's).
local progressBar = K.bar

-- ── the page ─────────────────────────────────────────────────────────────────
-- The sheet on the right: a header (a round portrait, the title, a line under
-- it, a rule), then blocks laid out from the top: a note, sections with their
-- label and value rows. labelWidth: the rows' labels; pairs: their pool
-- (made at the tab's load, for the tests).
local WIDTH = 440
local HEADER_H = 88
local Page = {}

local function newPage(parent, name, labelWidth, pairs)
  local p = extend(scrollArea(parent, WIDTH, name), Page)
  p.labelWidth, p.pairs, p.headings = labelWidth, pairs or {}, {}
  p:SetPoint("TOPLEFT", parent, "TOPLEFT", 26, -22)
  p:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 14)
  p.portrait = roundPortrait(p.child, 64)
  p.portrait:SetPoint("TOPLEFT", 2, -2)
  p.title = label(p.child, TITLE_FONT, 24, T.gold)
  p.title:SetPoint("TOPLEFT", p.portrait, "TOPRIGHT", 16, -8)
  p.title:SetWidth(WIDTH - 86)
  p.title:SetWordWrap(false)
  p.sub = label(p.child, BODY_FONT, 12, T.soft)
  p.sub:SetPoint("TOPLEFT", p.title, "BOTTOMLEFT", 0, -7)
  p.sub:SetWidth(WIDTH - 86)
  local line = rule(p.child)
  line:SetPoint("TOPLEFT", 0, -76)
  line:SetPoint("TOPRIGHT", 0, -76)
  p.note = label(p.child, BODY_FONT, 13, T.text)
  p.note:SetWidth(WIDTH)
  p.note:SetSpacing(4)
  return p
end

-- The page, laid out again: the header's title, the line under it, the
-- portrait (setPicture(portrait): icon(path), say), the blocks after it.
function Page:start(title, sub, setPicture)
  for _, x in ipairs(self.pairs) do
    x:Hide()
  end
  for _, x in ipairs(self.headings) do
    x:Hide()
  end
  self.note:Hide()
  self.title:SetText(title)
  self.sub:SetText(sub or "")
  setPicture(self.portrait)
  self.y, self.hi, self.pi = HEADER_H + 2, 0, 0
end

-- A block at the page's next place (a frame or a font string), so tall.
function Page:place(block, height)
  block:ClearAllPoints()
  block:SetPoint("TOPLEFT", self.child, "TOPLEFT", 0, -self.y)
  block:Show()
  self.y = self.y + height
end

-- The note at the head of a page (its paragraphs).
function Page:text(paragraphs)
  if not paragraphs or #paragraphs == 0 then return end
  self.note:SetText(table.concat(paragraphs, "\n\n"))
  self:place(self.note, self.note:GetStringHeight() + 20)
end

function Page:heading(i)
  local h = self.headings[i]
  if h then return h end
  h = CreateFrame("Frame", nil, self.child)
  h:SetSize(WIDTH, 24)
  h.text = label(h, TITLE_FONT, 16, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 0, 5)
  h.line = rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  self.headings[i] = h
  return h
end

function Page:section(title)
  self.hi = self.hi + 1
  local h = self:heading(self.hi)
  h.text:SetText(title)
  self:place(h, 34)
end

function Page:pair(i)
  local p = self.pairs[i]
  if p then return p end
  local w = self.labelWidth
  p = CreateFrame("Frame", nil, self.child)
  p:SetSize(WIDTH, 16)
  p.label = label(p, BODY_FONT, 12, T.soft)
  p.label:SetPoint("TOPLEFT", 0, 0)
  p.label:SetWidth(w)
  p.value = label(p, BODY_FONT, 12, T.text)
  p.value:SetPoint("TOPLEFT", w + 8, 0)
  p.value:SetWidth(WIDTH - w - 8)
  p.value:SetSpacing(4)
  self.pairs[i] = p
  return p
end

-- A label and its value, side by side (nothing without a value).
function Page:row(name, value)
  if not value or value == "" then return end
  self.pi = self.pi + 1
  local p = self:pair(self.pi)
  p.label:SetText(name)
  p.value:SetText(value)
  local height = math.max(16, p.value:GetStringHeight())
  p:SetHeight(height)
  self:place(p, height + 8)
end

-- The page's height, scrolled to the top (keep: where it was).
function Page:finish(keep)
  self.child:SetHeight(self.y + 24)
  if keep then
    self:UpdateThumb()
  else
    self:ScrollTo(0)
  end
end

-- ── the window ───────────────────────────────────────────────────────────────
local book
local TAB = { bestiary = 1, fish = 2, plants = 3, atlas = 4, milestones = 5 }
ns.TAB = TAB
-- tabs[n] = { build(book), show(selected tab), refresh(), chosen() (its tab
-- clicked), whole (over both panels) }
local tabs, TAB_TITLES = {}, { "Bestiary", "Fish", "Plants", "Atlas", "Milestones" }
function ns.addTab(n, tab) tabs[n] = tab end

-- The standard game window (portrait: the journal's book; title bar), else a
-- plain dialog where the client has no such template (Kit.lua).
local TITLE = "Explorer's Field Journal"

-- Rewrite what the open tab shows.
function ns.refresh()
  local tab = book and tabs[book.selectedTab]
  if tab and tab.built then tab.refresh() end
end

-- The tab n shown (built on first showing).
function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  local tab = tabs[n]
  if not tab.built then
    tab.build(book)
    tab.built = true
  end
  book.left:SetShown(not tab.whole)
  book.sheet:SetShown(not tab.whole)
  book.search:SetShown(not tab.whole)
  local told = {}
  for _, t in ipairs(tabs) do
    if t.built and not told[t] then
      told[t] = true -- (Fish and Plants: one tab, shown for both)
      t.show(n)
    end
  end
  ns.refresh()
end

local function build()
  local window = K.gameWindow("FieldJournalFrame", TITLE, "Interface\\Icons\\INV_Misc_Book_11")
  book = window or K.dialog("FieldJournalFrame", TITLE)
  K.movable(book, 780, 560)

  -- The count beside the portrait; the list's column below it, the page to
  -- the right, under the title bar; the search box at the top of the list's
  -- column (its left edge holds the glass).
  local edge = window and 8 or 14
  book.count = label(book, BODY_FONT, 11, T.gold)
  book.count:SetPoint("TOPLEFT", 64, -36)
  book.left = panel(book, true)
  book.left:SetPoint("TOPLEFT", edge, -58)
  book.left:SetPoint("BOTTOMLEFT", edge, edge)
  book.left:SetWidth(244)
  book.sheet = panel(book)
  book.sheet:SetPoint("TOPLEFT", book.left, "TOPRIGHT", 4, 32)
  book.sheet:SetPoint("BOTTOMRIGHT", -edge, edge)
  book.search = CreateFrame("EditBox", "FieldJournalSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:SetPoint("TOPLEFT", book.left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", book.left, "TOPRIGHT", -12, -10)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  book.selectedTab = TAB.bestiary
  book:SetScript("OnShow", function() ns.showTab(book.selectedTab) end)
  K.tabs(book, TAB_TITLES, function(n)
    local chosen = tabs[n].chosen
    if chosen then chosen() end
    ns.showTab(n)
  end)
end

local function window()
  if not book then build() end
  return book
end

function ns.toggle() window():SetShown(not book:IsShown()) end

-- The book open at a tab (the page it shows chosen by the caller).
function ns.openTab(n)
  window()
  book.selectedTab = n
  if book:IsShown() then
    ns.showTab(n)
  else
    book:Show() -- (its OnShow shows the tab)
  end
end

-- ── links in chat ────────────────────────────────────────────────────────────
-- |Hfieldjournal:<what>|h: c<creature id>, m<milestone id>, z<uiMap>,
-- f<fish>, h<herb>, else a family (its id, "murlocs", first: an id may begin
-- with one of those letters; an older link's index; or "?type/family").
local function followLink(link)
  local key = link:match("^fieldjournal:(.+)$")
  if not key then return end
  if ns.familyById[key] then return ns.openFamily(key) end
  local kind, rest = key:sub(1, 1), key:sub(2)
  local id = tonumber(rest)
  if kind == "m" then
    ns.openMilestones(rest)
  elseif kind == "z" and id then
    ns.openZone(id)
  elseif kind == "f" and id then
    ns.openFish(id)
  elseif kind == "h" and id then
    ns.openPlant(id)
  elseif kind == "c" and id then
    ns.openCreature(id)
  else
    ns.openFamily(tonumber(key) or key)
  end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("fieldjournal", function(link)
    followLink(link)
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
else
  -- Clients without the link registry still pass every click to SetItemRef.
  hooksecurefunc("SetItemRef", function(link) followLink(link) end)
end

-- What's recorded while the book is open shows up at once (throttled: meeting
-- creatures happens constantly).
local pending = false
ns.onRecord = function()
  if not (book and book:IsShown()) or pending then return end
  pending = true
  C_Timer.After(0.5, function()
    pending = false
    ns.refresh()
  end)
end
ns.onMilestone = ns.onRecord
ns.onAtlas = ns.onRecord
ns.onFlora = ns.onRecord

-- The kit, for the tabs.
ns.ui = {
  T = T,
  TITLE_FONT = TITLE_FONT,
  BODY_FONT = BODY_FONT,
  WIDTH = WIDTH,
  HEADER_H = HEADER_H,
  SOFT = SOFT,
  QUESTION = QUESTION,
  label = label,
  rule = rule,
  panel = panel,
  scrollArea = scrollArea,
  roundPortrait = roundPortrait,
  icon = icon,
  progressBar = progressBar,
  fold = fold,
  day = day,
  query = query,
  itemName = itemName,
  itemIcon = itemIcon,
  newList = newList,
  newPage = newPage,
  window = window,
}
