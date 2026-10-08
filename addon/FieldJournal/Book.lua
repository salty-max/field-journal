-- The journal as a book: the standard game window (portrait, title bar), its
-- tabs (the Bestiary, Fish, Plants, the Atlas, the Milestones: each a file of
-- its own, *Book.lua, registered with ns.addTab), the links in chat that open
-- it, and the kit every tab is made of (ns.ui): its look, the list on the
-- left and the page on the right. Light text and gold titles on dark panels:
-- Forever's Professions cards; on Classic, the game's insets, the quest log's
-- dark book behind the list. /journal opens it.
local _, ns = ...

-- ── look ─────────────────────────────────────────────────────────────────────
local T = {
  gold = { 0.85, 0.70, 0.42 },
  text = { 0.93, 0.88, 0.76 },
  soft = { 0.62, 0.57, 0.49 },
  rule = { 0.85, 0.70, 0.42, 0.25 },
  mark = "|cffff9a40",
  rare = "|cffc7ccd6",
  link = "|cffd9b36b",
}
local LATIN = { enUS = true, enGB = true, frFR = true, deDE = true, esES = true, esMX = true, itIT = true, ptBR = true }
local BODY_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_FONT = LATIN[GetLocale()] and "Fonts\\MORPHEUS.TTF" or BODY_FONT
local function hex(c) return ("|cff%02x%02x%02x"):format(c[1] * 255, c[2] * 255, c[3] * 255) end
local SOFT = hex(T.soft)
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local HIGHLIGHT = "Interface\\QuestFrame\\UI-QuestTitleHighlight"

local function label(parent, font, size, color)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont(font, size, "")
  fs:SetTextColor(unpack(color))
  fs:SetShadowOffset(1, -1)
  fs:SetJustifyH("LEFT")
  return fs
end

local function rule(parent, color)
  local t = parent:CreateTexture(nil, "ARTWORK")
  t:SetColorTexture(unpack(color or T.rule))
  t:SetHeight(1)
  return t
end

-- Forever's Professions card (a dark rounded panel), cut in nine so it
-- stretches to any size without bending its corners.
local CARD_FILE, CARD_W, CARD_H = 8164414, 1024, 512
local CARD = { 1, 665, 1, 143 } -- the generic card, in the texture's pixels
local CORNER = 16
local function card(parent)
  local f = CreateFrame("Frame", nil, parent)
  local xs = { CARD[1], CARD[1] + CORNER, CARD[2] - CORNER, CARD[2] }
  local ys = { CARD[3], CARD[3] + CORNER, CARD[4] - CORNER, CARD[4] }
  for i = 1, 3 do
    for j = 1, 3 do
      local tex = f:CreateTexture(nil, "BACKGROUND")
      tex:SetTexture(CARD_FILE)
      tex:SetTexCoord(xs[j] / CARD_W, xs[j + 1] / CARD_W, ys[i] / CARD_H, ys[i + 1] / CARD_H)
      if j ~= 2 then tex:SetWidth(CORNER) end
      if i ~= 2 then tex:SetHeight(CORNER) end
      -- Corners pinned to the frame's edges; edges and centre between them.
      if j == 1 then tex:SetPoint("LEFT", f, "LEFT", 0, 0) end
      if j == 2 then
        tex:SetPoint("LEFT", f, "LEFT", CORNER, 0)
        tex:SetPoint("RIGHT", f, "RIGHT", -CORNER, 0)
      end
      if j == 3 then tex:SetPoint("RIGHT", f, "RIGHT", 0, 0) end
      if i == 1 then tex:SetPoint("TOP", f, "TOP", 0, 0) end
      if i == 2 then
        tex:SetPoint("TOP", f, "TOP", 0, -CORNER)
        tex:SetPoint("BOTTOM", f, "BOTTOM", 0, CORNER)
      end
      if i == 3 then tex:SetPoint("BOTTOM", f, "BOTTOM", 0, 0) end
    end
  end
  return f
end

-- Classic's panels: the game's inset, darkened a little for the text; behind
-- the list (book), the quest log's dark book (TBC's two-pane log, where the
-- game has it).
local function inset(parent, book)
  local ok, f = pcall(CreateFrame, "Frame", nil, parent, "InsetFrameTemplate")
  if not (ok and f) then f = CreateFrame("Frame", nil, parent) end
  local shade = f:CreateTexture(nil, "BACKGROUND", nil, 1)
  shade:SetPoint("TOPLEFT", 3, -3)
  shade:SetPoint("BOTTOMRIGHT", -3, 3)
  shade:SetColorTexture(0.03, 0.025, 0.02, 0.55)
  if not book then return f end
  local art = f:CreateTexture(nil, "BACKGROUND", nil, 2)
  art:SetPoint("TOPLEFT", 3, -3)
  art:SetPoint("BOTTOMRIGHT", -3, 3)
  if art:SetTexture("Interface\\QuestFrame\\UI-QuestLogDualPane-Left") == false then
    art:Hide()
  else
    art:SetTexCoord(20 / 512, 318 / 512, 74 / 512, 406 / 512)
  end
  return f
end

local function panel(parent, book)
  if ns.forever then return card(parent) end
  return inset(parent, book)
end

-- A scroll area moved by the mouse wheel, with a thin gold thumb.
local function scrollArea(parent, width, name)
  local s = CreateFrame("ScrollFrame", name, parent)
  local c = CreateFrame("Frame", nil, s)
  c:SetSize(width, 1)
  s:SetScrollChild(c)
  s.child = c
  s.thumb = s:CreateTexture(nil, "OVERLAY")
  s.thumb:SetColorTexture(T.gold[1], T.gold[2], T.gold[3], 0.45)
  s.thumb:SetWidth(3)
  function s:UpdateThumb()
    local range, height = self:GetVerticalScrollRange() or 0, self:GetHeight() or 1
    if range <= 0 then
      self.thumb:Hide()
      return
    end
    local size = math.max(24, height * height / (height + range))
    self.thumb:SetHeight(size)
    self.thumb:ClearAllPoints()
    self.thumb:SetPoint("TOPRIGHT", self, "TOPRIGHT", 8, -(height - size) * self:GetVerticalScroll() / range)
    self.thumb:Show()
  end
  function s:ScrollTo(y)
    self:SetVerticalScroll(math.max(0, math.min(y, self:GetVerticalScrollRange() or 0)))
    self:UpdateThumb()
  end
  s:EnableMouseWheel(true)
  s:SetScript("OnMouseWheel", function(self, delta) self:ScrollTo(self:GetVerticalScroll() - delta * 40) end)
  s:SetScript("OnScrollRangeChanged", function(self) self:UpdateThumb() end)
  return s
end

-- A round portrait in a gold ring (p.tex: what it shows).
local function roundPortrait(parent, size)
  local p = CreateFrame("Frame", nil, parent)
  p:SetSize(size, size)
  p.ring = p:CreateTexture(nil, "BACKGROUND")
  p.ring:SetTexture(MASK)
  p.ring:SetVertexColor(0.72, 0.56, 0.24)
  p.ring:SetPoint("CENTER")
  p.ring:SetSize(size + 4, size + 4)
  p.back = p:CreateTexture(nil, "BORDER")
  p.back:SetTexture(MASK)
  p.back:SetVertexColor(0.06, 0.05, 0.04)
  p.back:SetAllPoints()
  p.tex = p:CreateTexture(nil, "ARTWORK")
  p.tex:SetAllPoints()
  local mask = p:CreateMaskTexture()
  mask:SetTexture(MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  mask:SetAllPoints(p.tex)
  p.tex:AddMaskTexture(mask)
  return p
end

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
  r:SetHighlightTexture(HIGHLIGHT, "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture(HIGHLIGHT)
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
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
local function progressBar(parent)
  local b = CreateFrame("StatusBar", nil, parent)
  b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  b:SetStatusBarColor(0.85, 0.65, 0.13)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  return b
end

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

local TITLE = "Explorer's Field Journal"
local function gameWindow()
  local ok, frame = pcall(CreateFrame, "Frame", "FieldJournalFrame", UIParent, "ButtonFrameTemplate")
  if not ok or not frame then return nil end
  if ButtonFrameTemplate_HideButtonBar then ButtonFrameTemplate_HideButtonBar(frame) end
  if type(frame.Inset) == "table" then frame.Inset:Hide() end
  local art = "Interface\\Icons\\INV_Misc_Book_11"
  if frame.SetPortraitToAsset then
    frame:SetPortraitToAsset(art)
  elseif type(frame.portrait) == "table" then
    frame.portrait:SetTexture(art)
  end
  if frame.SetTitle then
    frame:SetTitle(TITLE)
  elseif type(frame.TitleText) == "table" then
    frame.TitleText:SetText(TITLE)
  end
  return frame
end

-- No standard window on this client: a plain dialog frame.
local function dialog()
  local frame = CreateFrame("Frame", "FieldJournalFrame", UIParent, "BackdropTemplate")
  frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  local title = label(frame, TITLE_FONT, 16, T.gold)
  title:SetPoint("TOP", 0, -16)
  title:SetText(TITLE)
  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)
  return frame
end

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

-- The tabs, under the window's bottom edge, in the style of the character
-- sheet's (the shared panel tabs where that template doesn't exist: Forever).
local function hasTemplate(name)
  if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return name == "CharacterFrameTabButtonTemplate" end
  return C_XMLUtil.GetTemplateInfo(name) ~= nil
end

local function buildTabs()
  local template = hasTemplate("CharacterFrameTabButtonTemplate") and "CharacterFrameTabButtonTemplate"
    or "PanelTabButtonTemplate"
  for n, text in ipairs(TAB_TITLES) do
    local tab = CreateFrame("Button", "FieldJournalFrameTab" .. n, book, template)
    tab:SetID(n)
    tab:SetText(text)
    if n == 1 then
      tab:SetPoint("TOPLEFT", book, "BOTTOMLEFT", 14, 2)
    else
      tab:SetPoint("LEFT", "FieldJournalFrameTab" .. (n - 1), "RIGHT", -14, 0)
    end
    tab:SetScript("OnClick", function(self)
      local chosen = tabs[self:GetID()].chosen
      if chosen then chosen() end
      ns.showTab(self:GetID())
      if SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) end
    end)
    tab:SetScript("OnShow", function(self)
      if PanelTemplates_TabResize then PanelTemplates_TabResize(self, 0) end
    end)
    if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
  end
  if PanelTemplates_SetNumTabs then PanelTemplates_SetNumTabs(book, #TAB_TITLES) end
end

local function build()
  local window = gameWindow()
  book = window or dialog()
  book:SetSize(780, 560)
  book:SetPoint("CENTER")
  book:SetFrameStrata("HIGH")
  book:SetToplevel(true)
  book:SetMovable(true)
  book:EnableMouse(true)
  book:SetClampedToScreen(true)
  book:RegisterForDrag("LeftButton")
  book:SetScript("OnDragStart", book.StartMoving)
  book:SetScript("OnDragStop", book.StopMovingOrSizing)
  table.insert(UISpecialFrames, "FieldJournalFrame") -- Escape closes it

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
  buildTabs()
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
-- f<fish>, h<herb>, else a family (its index, or "?type/family").
local function followLink(link)
  local key = link:match("^fieldjournal:(.+)$")
  if not key then return end
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
