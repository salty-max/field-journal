-- The Fish and Plants tabs in the book (one list and one page for both): on
-- the left, the kinds this character has found, in groups (fish: of the
-- waters, reagents, rare catches, quest fish, weighed catches; herbs: by the
-- Herbalism rank they need), with how many; on the right, a kind's page: its
-- icon, the naturalist's note (where there is one), where it bites or grows
-- (the game's data, shown once found: no spoilers), and the character's
-- record. Records: Flora.lua.
local _, ns = ...
local F = ns.data.flora
local ui = ns.ui
local T, SOFT = ui.T, ui.SOFT

local book, list, page
local mode = "fish" -- the tab shown: "fish" or "plants"
local current = {} -- the open kind of each tab (an item id), nil for its overview
local rows, pairsPool = {}, {}
ns.floraRows, ns.floraPairs = rows, pairsPool -- for the tests

local function when(stamp)
  if not stamp or not stamp.at then return nil end
  local where = stamp.zone and ns.zoneName(stamp.zone)
  if where and stamp.sub and stamp.sub ~= where then where = ("%s, %s"):format(stamp.sub, where) end
  return ("%s%s, you were level %d"):format(ui.day(stamp), where and (" in " .. where) or "", stamp.level or 0)
end

local FISH_GROUPS = {
  { "food", "Fish of the waters" },
  { "reagent", "Reagents" },
  { "special", "Rare catches" },
  { "quest", "Quest catches" },
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

local function records()
  local c = ns.journal()
  return (mode == "fish" and c.fish or c.plants) or {}
end
local function info(id) return mode == "fish" and F.fish[id] or F.herbs[id] end
-- A kind's name: the game's (a weighed catch: the data's, as the game has none).
local function name(id)
  local d = info(id)
  if d.kind == "record" then return d.name end
  return ui.itemName(id, d.name)
end

-- ── the list ─────────────────────────────────────────────────────────────────
local function style(r, kind)
  if kind == "section" then
    r.text:SetPoint("LEFT", 4, 0)
    r.text:SetPoint("RIGHT", -4, 0)
    r.text:SetFont(ui.TITLE_FONT, 14, "")
    r.text:SetTextColor(unpack(T.gold))
    return 22
  end
  r.count:SetPoint("RIGHT", -4, 0)
  r.text:SetPoint("LEFT", kind == "overview" and 4 or 14, 0)
  r.text:SetPoint("RIGHT", r.count, "LEFT", -4, 0)
  r.text:SetFont(ui.BODY_FONT, 12, "")
  r.text:SetTextColor(unpack(kind == "overview" and T.gold or T.text))
  return 18
end

-- The kinds found, grouped: { { title, { ids } } }, the search applied.
local function groups(q)
  local recs = records()
  local function shown(id) return recs[id] and (q == "" or name(id):lower():find(q, 1, true)) end
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
  return out
end

local function refreshList()
  local q = ui.query(book)
  local found = groups(q)
  list:begin()
  if q == "" then
    local r = list:add("overview", mode == "fish" and "The catch so far" or "The herbs so far")
    r:SetScript("OnClick", function()
      current[mode] = nil
      ns.refresh()
    end)
    if current[mode] == nil then list:pick(r) end
  end
  local recs = records()
  for _, g in ipairs(found) do
    list:gap(6)
    list:add("section", g[1])
    for _, id in ipairs(g[2]) do
      local r = list:add("kind", name(id), recs[id].n or 0)
      r.key = id
      r:SetScript("OnClick", function()
        current[mode] = id
        ns.refresh()
      end)
      if current[mode] == id then list:pick(r) end
    end
  end
  if #found == 0 and q ~= "" then list:add("section", "Nothing found") end
  list:finish()
end

-- ── the pages ────────────────────────────────────────────────────────────────
local function zoneList(zones)
  local names = {}
  for _, z in ipairs(zones or {}) do
    table.insert(names, ns.zoneName(z))
  end
  table.sort(names)
  return #names > 0 and table.concat(names, ", ") or nil
end
local function listed(items) return items and #items > 0 and table.concat(items, ", ") or nil end

-- Where the character found it most: "Elwynn Forest (12), Westfall (3)".
local function mostFound(zones)
  local counts = {}
  for z, n in pairs(zones or {}) do
    table.insert(counts, { z, n })
  end
  table.sort(counts, function(a, b) return a[2] > b[2] end)
  local out = {}
  for i = 1, math.min(#counts, 5) do
    table.insert(out, ("%s (%d)"):format(ns.zoneName(counts[i][1]), counts[i][2]))
  end
  return listed(out)
end

local HOW = { gathered = "gathered", looted = "looted", other = "came to your bags" }

local function showKind(id)
  local d, rec = info(id), records()[id]
  if mode == "fish" then
    local season = d.season and ("only in %s"):format(d.season) or nil
    page:start(name(id), table.concat({ KIND[d.kind], season }, "  -  "), ui.icon(ui.itemIcon(id) or ui.QUESTION))
    page:text(d.note)
    page:section("Where it bites")
    page:row("Zones", zoneList(d.zones))
    page:row("Waters", listed(d.subzones))
    page:row("Dungeons", listed(d.dungeons))
    page:section("Your catches")
    page:row("First caught", when(rec.first))
    page:row("Caught", tostring(rec.n or 0))
    page:row("By day, by night", ("%d, %d"):format(rec.day or 0, rec.night or 0))
    if (rec.school or 0) > 0 then page:row("From schools", tostring(rec.school)) end
    if rec.heaviest then page:row("Heaviest", ("%d pounds"):format(rec.heaviest)) end
    page:row("Where", mostFound(rec.zones))
  else
    local inside = d.inside and "  -  found in other herbs" or ""
    page:start(name(id), ("Herbalism %d%s"):format(d.skill, inside), ui.icon(ui.itemIcon(id) or ui.QUESTION))
    page:text(d.note)
    page:section("Where it grows")
    page:row("Zones", zoneList(d.zones))
    page:row("Dungeons", listed(d.dungeons))
    page:section("Your herbs")
    local first = when(rec.first)
    page:row("First", first and ("%s (%s)"):format(first, HOW[rec.first.how] or "?") or nil)
    page:row("Gathered", tostring(rec.gathered or 0))
    page:row("Looted", tostring(rec.looted or 0))
    page:row("Where", mostFound(rec.zones))
  end
end

-- How many kinds, and how many taken in all.
local function totals(recs)
  local kinds, total = 0, 0
  for _, rec in pairs(recs) do
    kinds, total = kinds + 1, total + (rec.n or 0)
  end
  return kinds, total
end

local function showOverview()
  local recs = records()
  local kinds, total = totals(recs)
  if mode == "fish" then
    page:start(
      "The catch so far",
      ("%d kinds of fish, %d caught"):format(kinds, total),
      ui.icon("Interface\\Icons\\Trade_Fishing")
    )
    if kinds == 0 then
      page:row(
        "",
        SOFT .. "Nothing caught yet. Every fish you land is written down here, with where and when it bit.|r"
      )
      return
    end
    page:section("Your catches")
    local schools, night, heavy = 0, 0, nil
    for id, rec in pairs(recs) do
      schools, night = schools + (rec.school or 0), night + (rec.night or 0)
      if rec.heaviest and (not heavy or rec.heaviest > heavy[2]) then heavy = { id, rec.heaviest } end
    end
    page:row("Kinds", tostring(kinds))
    page:row("Caught", tostring(total))
    page:row("From schools", tostring(schools))
    page:row("By night", tostring(night))
    if heavy then page:row("Heaviest", ("%s, %d pounds"):format(F.fish[heavy[1]].name, heavy[2])) end
  else
    page:start(
      "The herbs so far",
      ("%d herbs, %d taken"):format(kinds, total),
      ui.icon("Interface\\Icons\\INV_Misc_Herb_07")
    )
    if kinds == 0 then
      local none =
        "No herb yet. Every herb that reaches your bags is written down here: gathered, looted, bought or given."
      page:row("", SOFT .. none .. "|r")
      return
    end
    page:section("Your herbs")
    local gathered, looted = 0, 0
    for _, rec in pairs(recs) do
      gathered, looted = gathered + (rec.gathered or 0), looted + (rec.looted or 0)
    end
    page:row("Kinds", tostring(kinds))
    page:row("Gathered", tostring(gathered))
    page:row("Looted", tostring(looted))
  end
end

local function refresh()
  local recs = records()
  local kinds, total = totals(recs)
  book.count:SetText(
    mode == "fish" and ("%d kinds of fish, %d caught"):format(kinds, total)
      or ("%d herbs, %d taken"):format(kinds, total)
  )
  refreshList()
  if current[mode] and recs[current[mode]] then
    showKind(current[mode])
  else
    current[mode] = nil
    showOverview()
  end
  page:finish()
end

-- ── building ─────────────────────────────────────────────────────────────────
local tab = {
  build = function(b)
    book = b
    list = ui.newList(book.left, style, rows)
    page = ui.newPage(book.sheet, "FieldJournalFloraPage", 110, pairsPool)
  end,
  show = function(n)
    local here = n == ns.TAB.fish or n == ns.TAB.plants
    if here then mode = n == ns.TAB.fish and "fish" or "plants" end
    list:SetShown(here)
    page:SetShown(here)
  end,
  refresh = refresh,
}
ns.addTab(ns.TAB.fish, tab)
ns.addTab(ns.TAB.plants, tab)

-- Open the book at a fish's or an herb's page (fieldjournal:f<id>, h<id>: a
-- link in chat).
local function open(which, id)
  if not ns.journal() then return end
  current[which] = id
  ns.openTab(which == "fish" and ns.TAB.fish or ns.TAB.plants)
end
function ns.openFish(id)
  if F.fish[id] then open("fish", id) end
end
function ns.openPlant(id)
  if F.herbs[id] then open("plants", id) end
end
