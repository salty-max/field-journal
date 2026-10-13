-- The Milestones' tab in the book, over both panels: the kit's board (the
-- figures on top: all earned, and those of the creatures, the land and the
-- expeditions; then one row per milestone under its group's heading and how
-- many of it are earned: its group's picture, a medal on it once earned, the
-- title, what it asks, when it was earned or how far along it is).
-- Milestones: Achievements.lua.
local _, ns = ...
local L = ns.kit.L
local ui = ns.ui

-- (each group: its id, its heading, its picture, the figure it counts in)
local GROUPS = {
  { "tally", L["Tallies"], "Interface\\Icons\\INV_Misc_Book_09", "creatures" },
  { "type", L["Every Family"], "Interface\\Icons\\Ability_Hunter_BeastTaming", "creatures" },
  { "feat", L["Feats"], "Interface\\Icons\\INV_Misc_Head_Dragon_01", "creatures" },
  { "zone", L["Rares by Zone"], "Interface\\Icons\\INV_Misc_Map_01", "creatures" },
  { "fishing", L["Fishing"], "Interface\\Icons\\Trade_Fishing", "land" },
  { "herbs", L["Herbs"], "Interface\\Icons\\INV_Misc_Herb_07", "land" },
  { "travel", L["Travels"], "Interface\\Icons\\Ability_Mount_RidingHorse", "land" },
  { "explore", L["Exploration"], "Interface\\Icons\\INV_Misc_Map02", "land" },
  { "expeditions", L["Expeditions"], "Interface\\Icons\\INV_Misc_Note_02", "expeditions" },
}
local FIGURES = {
  { "all", "earned" },
  { "creatures", L["of the creatures"] },
  { "land", L["of the land"] },
  { "expeditions", L["of the expeditions"] },
}
local book, panel, board
ns.milestoneRows = {} -- for the tests
local picked -- a milestone opened from chat or its banner: picked out, in view

-- The milestones shown (none of a type or zone not met yet: no spoilers).
local function items()
  local out = {}
  for _, m in ipairs(ns.milestones) do
    if ns.milestoneVisible(m) then
      table.insert(out, {
        id = m.id,
        group = m.group,
        title = m.title,
        text = m.text,
        earned = ns.earnedMilestone(m.id),
        progress = m.progress,
      })
    end
  end
  return out
end

local function refresh()
  book.count:SetText(L["%d of %d milestones"]:format(ns.milestoneCount()))
  board:refresh(picked)
end

ns.addTab(ns.TAB.milestones, {
  whole = true,
  build = function(b)
    book = b
    panel = ui.panel(book)
    panel:SetPoint("TOPLEFT", book.left, "TOPLEFT")
    panel:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT")
    board = ns.kit.board({
      parent = panel,
      name = "YonderMilestones",
      groups = GROUPS,
      figures = FIGURES,
      items = items,
      rows = ns.milestoneRows,
    })
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
