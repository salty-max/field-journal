-- The Milestones' tab in the book, over both panels: the figures on top (all
-- earned, and those of the creatures, the land and the expeditions), then one
-- row per milestone under its group's heading (and how many of it are
-- earned): its group's picture (a medal on it once earned), the title (gold
-- once earned), what it asks, and on the right when it was earned, or how
-- far along it is (a bar).
-- Milestones: Achievements.lua.
local _, ns = ...
local ui = ns.ui
local T = ui.T

-- (each group: its id, its heading, its picture, the figure it counts in)
local GROUPS = {
  { "tally", "Tallies", "Interface\\Icons\\INV_Misc_Book_09", "creatures" },
  { "type", "Every Family", "Interface\\Icons\\Ability_Hunter_BeastTaming", "creatures" },
  { "feat", "Feats", "Interface\\Icons\\INV_Misc_Head_Dragon_01", "creatures" },
  { "zone", "Rares by Zone", "Interface\\Icons\\INV_Misc_Map_01", "creatures" },
  { "fishing", "Fishing", "Interface\\Icons\\Trade_Fishing", "land" },
  { "herbs", "Herbs", "Interface\\Icons\\INV_Misc_Herb_07", "land" },
  { "travel", "Travels", "Interface\\Icons\\Ability_Mount_RidingHorse", "land" },
  { "explore", "Exploration", "Interface\\Icons\\INV_Misc_Map02", "land" },
  { "expeditions", "Expeditions", "Interface\\Icons\\INV_Misc_Note_02", "expeditions" },
}
local FIGURES = {
  { "all", "earned" },
  { "creatures", "of the creatures" },
  { "land", "of the land" },
  { "expeditions", "of the expeditions" },
}
local GOLD = { "Interface\\Icons\\INV_Misc_Coin_01", "Gold", "", { 1, 0.82, 0 } }
local TILES_H = 64
local ROW_H, WIDTH = 50, 700
local book, panel, scroll
local rows, headers = {}, {}
ns.milestoneRows = rows -- for the tests
local picked -- a milestone opened from chat or its alert: picked out, in view

local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Frame", nil, scroll.child)
  r:SetSize(WIDTH, ROW_H - 4)
  r.bg = r:CreateTexture(nil, "BACKGROUND")
  r.bg:SetAllPoints()
  r.picture = ui.roundPortrait(r, 34)
  r.picture:SetPoint("LEFT", 8, 0)
  r.medal = ui.badge(r.picture, 16)
  r.title = ui.label(r, ui.TITLE_FONT, 15, T.gold)
  r.title:SetPoint("TOPLEFT", 54, -7)
  r.text = ui.label(r, ui.BODY_FONT, 11, T.soft)
  r.text:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -5)
  r.text:SetWidth(500)
  r.status = ui.label(r, ui.BODY_FONT, 11, T.soft)
  r.status:SetPoint("TOPRIGHT", -12, -8)
  r.status:SetJustifyH("RIGHT")
  r.bar = ui.progressBar(r)
  r.bar:SetSize(150, 5)
  r.bar:SetPoint("TOPRIGHT", r.status, "BOTTOMRIGHT", 0, -7)
  rows[i] = r
  return r
end

local function header(i)
  local h = headers[i]
  if h then return h end
  h = CreateFrame("Frame", nil, scroll.child)
  h:SetSize(WIDTH, 26)
  h.text = ui.label(h, ui.TITLE_FONT, 17, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 2, 5)
  h.count = ui.label(h, ui.BODY_FONT, 12, T.soft)
  h.count:SetPoint("BOTTOMRIGHT", -4, 6)
  h.line = ui.rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  headers[i] = h
  return h
end

-- A milestone's row: earned (when, at what level) or how far along.
local function fill(r, m, picture)
  local earned = ns.earnedMilestone(m.id)
  r.id = m.id
  ui.icon(picture)(r.picture)
  r.picture.tex:SetDesaturated(not earned)
  r.picture.tex:SetVertexColor(earned and 1 or 0.6, earned and 1 or 0.6, earned and 1 or 0.6)
  ui.setBadge(r.medal, earned and GOLD or nil)
  r.title:SetText(m.title)
  r.text:SetText(m.text)
  if earned then
    r.title:SetTextColor(unpack(T.gold))
    r.text:SetTextColor(unpack(T.text))
    r.status:SetText(("Level %d, %s"):format(earned.level or 0, ui.day(earned)))
    r.bar:Hide()
  else
    local done, need = m.progress()
    r.title:SetTextColor(0.55, 0.53, 0.50)
    r.text:SetTextColor(unpack(T.soft))
    r.status:SetText(("%d/%d"):format(math.min(done, need), need))
    r.bar:SetMinMaxValues(0, math.max(need, 1))
    r.bar:SetValue(math.min(done, need))
    r.bar:SetShown(need > 1)
  end
  if m.id == picked then
    r.bg:SetColorTexture(ui.T.accent[1], ui.T.accent[2], ui.T.accent[3], 0.22)
  elseif earned then
    r.bg:SetColorTexture(ui.T.bar[1], ui.T.bar[2], ui.T.bar[3], 0.10)
  else
    r.bg:SetColorTexture(1, 1, 1, 0.03)
  end
end

-- The figures on top: earned of shown, in all and by the groups' figure.
local tiles = {}
local function figures(counts)
  local w = math.floor((WIDTH - 3 * 12) / 4)
  for k, f in ipairs(FIGURES) do
    local t = tiles[k]
    if not t then
      t = CreateFrame("Frame", nil, scroll.child)
      t:SetSize(w, TILES_H - 14)
      t.art = ui.panel(t)
      t.art:SetAllPoints()
      t.value = ui.label(t.art, ui.TITLE_FONT, 20, T.gold)
      t.value:SetPoint("TOP", 0, -7)
      t.label = ui.label(t.art, ui.BODY_FONT, 11, T.soft)
      t.label:SetPoint("BOTTOM", 0, 8)
      t:SetPoint("TOPLEFT", (k - 1) * (w + 12), 0)
      tiles[k] = t
    end
    local c = counts[f[1]] or { 0, 0 }
    t.value:SetText(("%d/%d"):format(c[1], c[2]))
    t.label:SetText(f[2])
    t:Show()
  end
end

local function refresh()
  book.count:SetText(("%d of %d milestones"):format(ns.milestoneCount()))
  local counts = { all = { 0, 0 } }
  for _, group in ipairs(GROUPS) do
    counts[group[4]] = counts[group[4]] or { 0, 0 }
    for _, m in ipairs(ns.milestones) do
      if m.group == group[1] and ns.milestoneVisible(m) then
        local earned = ns.earnedMilestone(m.id) and 1 or 0
        for _, key in ipairs({ "all", group[4] }) do
          counts[key][1], counts[key][2] = counts[key][1] + earned, counts[key][2] + 1
        end
      end
    end
  end
  figures(counts)
  local i, y, pickedY = 0, TILES_H, nil
  for g, group in ipairs(GROUPS) do
    local shown, earned = {}, 0
    for _, m in ipairs(ns.milestones) do
      if m.group == group[1] and ns.milestoneVisible(m) then
        table.insert(shown, m)
        if ns.earnedMilestone(m.id) then earned = earned + 1 end
      end
    end
    local h = header(g)
    h:SetShown(#shown > 0)
    if #shown > 0 then
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h.text:SetText(group[2])
      h.count:SetText(("%d of %d"):format(earned, #shown))
      y = y + 34
    end
    for _, m in ipairs(shown) do
      i = i + 1
      local r = row(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", 0, -y)
      if m.id == picked then pickedY = y end
      fill(r, m, group[3])
      r:Show()
      y = y + ROW_H
    end
    if #shown > 0 then y = y + 12 end
  end
  for k = i + 1, #rows do
    rows[k]:Hide()
  end
  scroll.child:SetHeight(y)
  scroll:UpdateThumb()
  if pickedY then
    local height = scroll:GetHeight()
    scroll:SetVerticalScroll(math.min(math.max(0, y - height), math.max(0, pickedY - (height - ROW_H) / 2)))
    scroll:UpdateThumb()
  end
end

ns.addTab(ns.TAB.milestones, {
  whole = true,
  build = function(b)
    book = b
    panel = ui.panel(book)
    panel:SetPoint("TOPLEFT", book.left, "TOPLEFT")
    panel:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT")
    scroll = ui.scrollArea(panel, WIDTH, "FieldJournalMilestones")
    scroll:SetPoint("TOPLEFT", 22, -18)
    scroll:SetPoint("BOTTOMRIGHT", -22, 14)
  end,
  show = function(n) panel:SetShown(n == ns.TAB.milestones) end,
  chosen = function() picked = nil end,
  refresh = refresh,
})

-- Open the book at the milestones, one of them picked out.
function ns.openMilestones(id)
  picked = id
  ns.openTab(ns.TAB.milestones)
end
