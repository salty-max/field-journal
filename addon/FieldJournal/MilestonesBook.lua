-- The Milestones' tab in the book, over both panels: one row per milestone,
-- under its group's heading: the title (gold once earned), what it asks, and
-- on the right when it was earned, or how far along it is (a bar).
-- Milestones: Achievements.lua.
local _, ns = ...
local ui = ns.ui
local T = ui.T

local GROUPS = {
  { "tally", "Tallies" },
  { "type", "Every Family" },
  { "feat", "Feats" },
  { "zone", "Rares by Zone" },
  { "fishing", "Fishing" },
  { "herbs", "Herbs" },
  { "travel", "Travels" },
  { "explore", "Exploration" },
}
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
  r.title = ui.label(r, ui.TITLE_FONT, 15, T.gold)
  r.title:SetPoint("TOPLEFT", 12, -7)
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
  h.line = ui.rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  headers[i] = h
  return h
end

-- A milestone's row: earned (when, at what level) or how far along.
local function fill(r, m)
  local earned = ns.earnedMilestone(m.id)
  r.id = m.id
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
    r.bg:SetColorTexture(0.85, 0.70, 0.42, 0.22)
  elseif earned then
    r.bg:SetColorTexture(0.85, 0.65, 0.13, 0.10)
  else
    r.bg:SetColorTexture(1, 1, 1, 0.03)
  end
end

local function refresh()
  book.count:SetText(("%d of %d milestones"):format(ns.milestoneCount()))
  local i, y, pickedY = 0, 0, nil
  for g, group in ipairs(GROUPS) do
    local shown = {}
    for _, m in ipairs(ns.milestones) do
      if m.group == group[1] and ns.milestoneVisible(m) then table.insert(shown, m) end
    end
    local h = header(g)
    h:SetShown(#shown > 0)
    if #shown > 0 then
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h.text:SetText(group[2])
      y = y + 34
    end
    for _, m in ipairs(shown) do
      i = i + 1
      local r = row(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", 0, -y)
      if m.id == picked then pickedY = y end
      fill(r, m)
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
