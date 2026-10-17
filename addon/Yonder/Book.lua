-- The journal as a book: the standard game window (portrait, title bar), its
-- tabs (the Expeditions, the Bestiary, Finds, the Atlas, the
-- Milestones: each a file of its own, *Book.lua, registered with ns.addTab),
-- the links in chat that open it, and what every tab is made of (ns.ui): the
-- kit's look in the journal's theme, its list on the left and page on the
-- right. Light text and gold titles on dark panels:
-- Forever's Professions cards; on Classic, the game's insets, the quest log's
-- dark book behind the list. /yonder opens it.
local _, ns = ...
local L = ns.kit.L

-- ── look ─────────────────────────────────────────────────────────────────────
-- The kit's (Kit.lua), in the Yonder's theme: a sage accent, the panels
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
local BODY_FONT, TITLE_FONT = K.BODY_FONT, K.TITLE_FONT
local SOFT = K.hex(T.soft)
local label, rule, panel, scrollArea = K.label, K.rule, K.panel, K.scrollArea
-- A round portrait in the theme's ring, a dark disc behind it (p.tex: what it shows).
local function roundPortrait(parent, size) return K.roundIcon(parent, size, true) end

local function day(stamp) return K.day(stamp and stamp.at) end

-- The search box's words, trimmed and lower case ("": no search).
local function query(book) return strtrim((book.search:GetText() or ""):lower()) end

-- The list on the left and the page on the right: the kit's (Kit.lua), as
-- every book of the family.
local WIDTH, HEADER_H = K.PAGE_WIDTH, K.PAGE_HEADER_H
local function newPage(parent, name, labelWidth, pairs)
  return K.page(parent, name, { labelWidth = labelWidth, pairs = pairs })
end

-- ── the window ───────────────────────────────────────────────────────────────
local book
-- (the Expeditions first: what the book is opened for; the Bestiary fills itself)
local TAB = { expeditions = 1, bestiary = 2, finds = 3, atlas = 4, milestones = 5 }
ns.TAB = TAB
-- tabs[n] = { build(book), show(selected tab), refresh(), chosen() (its tab
-- clicked), whole (over both panels), filter = { default, options() } (a
-- select under the search box: its choice, ns.filterOf(n)) }
local tabs, TAB_TITLES = {}, { L["Expeditions"], L["Bestiary"], L["Finds"], L["Atlas"], L["Achievements"] }
function ns.addTab(n, tab) tabs[n] = tab end

-- A tab's choice in its select (the kit's, under the search box), else its
-- default; kept for the session.
function ns.filterOf(n)
  local tab = tabs[n]
  if not (tab and tab.filter) then return nil end
  if tab.filterValue == nil then return tab.filter.default end
  return tab.filterValue
end

function ns.setFilter(n, value)
  if tabs[n] and tabs[n].filter then tabs[n].filterValue = value end
end

-- The standard game window (portrait: the journal's book; title bar), else a
-- plain dialog where the client has no such template (Kit.lua).
local TITLE = "Yonder"

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
  if tab.filter and not tab.whole then
    book.filter:SetOptions(tab.filter.options())
    book.filter:SetValue(ns.filterOf(n))
    book.filter:Show()
  else
    book.filter:Hide()
  end
  local told = {}
  for _, t in ipairs(tabs) do
    if t.built and not told[t] then
      told[t] = true
      t.show(n)
    end
  end
  ns.refresh()
end

local function build()
  local window = K.gameWindow("YonderFrame", TITLE, "Interface\\AddOns\\Yonder\\Media\\Logo")
  book = window or K.dialog("YonderFrame", TITLE)
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
  book.search = CreateFrame("EditBox", "YonderSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:SetPoint("TOPLEFT", book.left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", book.left, "TOPRIGHT", -12, -10)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)
  -- Under it, the open tab's own select (a sort, a continent), if it has one.
  book.filter = K.select(book.left, 220, "")
  book.filter:SetPoint("TOPLEFT", book.left, "TOPLEFT", 12, -38)
  book.filter.onChange = function(value)
    tabs[book.selectedTab].filterValue = value
    ns.refresh()
  end
  book.filter:Hide()

  book.selectedTab = TAB.expeditions
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
-- |Hyonder:<what>|h: c<creature id>, m<milestone id>, z<uiMap>,
-- f<fish>, h<herb>, x<riddle id>, q<quarry's creature id>, else a family (its id, "murlocs", first: an id may begin
-- with one of those letters; an older link's index; or "?type/family").
local function followLink(link)
  local key = link:match("^yonder:(.+)$")
  if not key then return end
  if ns.familyById[key] then return ns.openFamily(key) end
  local category = key:match("^finds/(%a+)$")
  if category then return ns.openFindCategory(category) end
  local kind, rest = key:sub(1, 1), key:sub(2)
  local id = tonumber(rest)
  if kind == "m" then
    ns.openMilestones(rest)
  elseif kind == "z" and id then
    ns.openZone(id)
  elseif kind == "x" and ns.riddleById[rest] then
    ns.openRiddle(rest)
  elseif kind == "q" and id then
    ns.openQuarry(id)
  elseif kind == "f" and id then
    ns.openFish(id)
  elseif kind == "h" and id then
    ns.openPlant(id)
  elseif kind == "i" and id then
    ns.openFind(id)
  elseif kind == "c" and id then
    ns.openCreature(id)
  else
    ns.openFamily(tonumber(key) or key)
  end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("yonder", function(link)
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
  QUESTION = K.QUESTION,
  label = label,
  rule = rule,
  panel = panel,
  scrollArea = scrollArea,
  roundPortrait = roundPortrait,
  icon = K.icon,
  progressBar = K.bar,
  fold = K.fold,
  day = day,
  query = query,
  itemName = K.itemName,
  itemIcon = K.itemIcon,
  newList = K.list,
  newPage = newPage,
  window = window,
}
