-- The Fish and Plants tabs in the book (one list and one page for both): on
-- the left, the kinds this character has found, in groups (fish: of the
-- waters, reagents, rare catches, quest fish, weighed catches; herbs: by the
-- Herbalism rank they need), with how many; on the right, a kind's page: its
-- icon, the naturalist's note (where there is one), where it bites or grows
-- (the game's data, shown once found: no spoilers), and the character's
-- record. Records: Flora.lua.
local _, ns = ...
local L = ns.kit.L
local F = ns.data.flora
local ui = ns.ui
local T = ui.T

local book, list, page
local mode = "fish" -- the tab shown: "fish" or "plants"
local current = {} -- the open kind of each tab (an item id), nil for its overview
local rows, pairsPool = {}, {}
ns.floraRows, ns.floraPairs = rows, pairsPool -- for the tests

local function when(stamp)
  if not stamp or not stamp.at then return nil end
  local where = stamp.zone and ns.zoneName(stamp.zone)
  if where and stamp.sub and stamp.sub ~= where then where = L["%s, %s"]:format(stamp.sub, where) end
  if where then return L["%s in %s, you were level %d"]:format(ui.day(stamp), where, stamp.level or 0) end
  return L["%s, you were level %d"]:format(ui.day(stamp), stamp.level or 0)
end

local FISH_GROUPS = {
  { "food", L["Fish of the waters"] },
  { "reagent", L["Reagents"] },
  { "special", L["Rare catches"] },
  { "quest", L["Quest catches"] },
  { "record", L["Weighed catches"] },
}
local KIND = {
  food = L["A fish of the waters"],
  reagent = L["A reagent"],
  special = L["A rare catch"],
  quest = L["A quest fish"],
  record = L["Weighed catches"],
}
-- The Herbalism ranks, by the skill an herb needs.
local RANKS = { { 1, L["Apprentice"] }, { 75, L["Journeyman"] }, { 150, L["Expert"] }, { 225, L["Artisan"] } }
local function rankOf(skill)
  local name = RANKS[1][2]
  for _, r in ipairs(RANKS) do
    if skill >= r[1] then name = r[2] end
  end
  return name
end

-- (each tab its own records and data, never the other's: a character who
-- never fished has no fish table, and "fish and c.fish or c.plants" would
-- show its herbs as catches)
local function records()
  local c = ns.journal()
  if mode == "fish" then return c.fish or {} end
  return c.plants or {}
end
local function info(id)
  if mode == "fish" then return F.fish[id] end
  return F.herbs[id]
end
-- "1 kind of fish, 1 caught", "3 herbs, 5 taken"
local function counted(kinds, total)
  local plural = ns.kit.plural
  if mode == "fish" then
    return plural(kinds, "%d kind of fish, %d caught", "%d kinds of fish, %d caught"):format(kinds, total)
  end
  return plural(kinds, "%d herb, %d taken", "%d herbs, %d taken"):format(kinds, total)
end
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
    local r = list:add("overview", mode == "fish" and L["The catch so far"] or L["The herbs so far"])
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
  if #found == 0 and q ~= "" then list:add("section", L["Nothing found"]) end
  list:finish()
end

-- ── the pages ────────────────────────────────────────────────────────────────
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
    table.insert(out, L["%s (%d)"]:format(ns.zoneName(counts[i][1]), counts[i][2]))
  end
  return listed(out)
end

local HOW = { gathered = L["gathered"], looted = L["looted"], other = L["came to your bags"] }

-- The zones it bites or grows in, as names to pick: each opens its Atlas page.
local function zoneChips(zones)
  local out = {}
  for _, z in ipairs(zones or {}) do
    table.insert(out, { ns.zoneName(z), function() ns.openZone(z) end, false, L["Open its page in the Atlas."] })
  end
  table.sort(out, function(a, b) return a[1] < b[1] end)
  if #out > 0 then page:chips(out) end
end

local function itemPicture(id) return ui.icon(ui.itemIcon(id) or ui.QUESTION) end

local function showKind(id)
  local d, rec = info(id), records()[id]
  if mode == "fish" then
    local season = d.season and (d.season == "winter" and L["only in winter"] or L["only in summer"]) or nil
    page:start(name(id), table.concat({ KIND[d.kind], season }, "  -  "), itemPicture(id))
    page:text(d.note)
    local figures = { { tostring(rec.n or 0), L["caught"] } }
    if rec.heaviest then table.insert(figures, { L["%d lb"]:format(rec.heaviest), L["the heaviest"] }) end
    table.insert(figures, { L["%d / %d"]:format(rec.day or 0, rec.night or 0), L["day / night"] })
    if (rec.school or 0) > 0 then table.insert(figures, { tostring(rec.school), L["from schools"] }) end
    page:stats(figures)
    page:section(L["Where it bites"])
    zoneChips(d.zones)
    page:row(L["Waters"], listed(d.subzones))
    page:row(L["Dungeons"], listed(d.dungeons))
    page:section(L["Your catches"])
    page:row(L["First caught"], when(rec.first))
    page:row(L["Where"], mostFound(rec.zones))
  else
    local inside = d.inside and L["  -  found in other herbs"] or ""
    page:start(name(id), L["Herbalism %d%s"]:format(d.skill, inside), itemPicture(id))
    page:text(d.note)
    page:stats({
      { tostring(rec.n or 0), L["taken"] },
      { tostring(rec.gathered or 0), L["gathered"] },
      { tostring(rec.looted or 0), L["looted"] },
    })
    page:section(L["Where it grows"])
    zoneChips(d.zones)
    page:row(L["Dungeons"], listed(d.dungeons))
    page:section(L["Your herbs"])
    local first = when(rec.first)
    page:row(L["First"], first and (L["%s (%s)"]):format(first, HOW[rec.first.how] or "?") or nil)
    page:row(L["Where"], mostFound(rec.zones))
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

-- The kinds found last, the latest first, as cards: a click opens one.
local function lately(recs, max)
  local ids = {}
  for id, rec in pairs(recs) do
    if rec.first and rec.first.at and info(id) then table.insert(ids, id) end
  end
  table.sort(ids, function(a, b) return recs[a].first.at > recs[b].first.at end)
  if #ids == 0 then return end
  page:section(mode == "fish" and L["The last new catches"] or L["The last new herbs"])
  for i = 1, math.min(#ids, max) do
    local id = ids[i]
    page:card(name(id), when(recs[id].first), itemPicture(id), function()
      current[mode] = id
      ns.refresh()
    end)
  end
end

local function showOverview()
  local recs = records()
  local kinds, total = totals(recs)
  if mode == "fish" then
    page:start(L["The catch so far"], counted(kinds, total), ui.icon("Interface\\Icons\\Trade_Fishing"))
    if kinds == 0 then
      page:paragraph(
        L["Nothing caught yet. Every fish you land is written down here, with where and when it bit."],
        T.soft
      )
      return
    end
    local schools, night, heavy = 0, 0, nil
    for id, rec in pairs(recs) do
      schools, night = schools + (rec.school or 0), night + (rec.night or 0)
      if rec.heaviest and (not heavy or rec.heaviest > heavy[2]) then heavy = { id, rec.heaviest } end
    end
    page:stats({
      { tostring(kinds), ns.kit.plural(kinds, "kind", "kinds") },
      { tostring(total), L["caught"] },
      { tostring(schools), L["from schools"] },
      { tostring(night), L["by night"] },
    })
    if heavy then
      page:section(L["The heaviest"])
      page:card(name(heavy[1]), L["%d pounds"]:format(heavy[2]), itemPicture(heavy[1]), function()
        current[mode] = heavy[1]
        ns.refresh()
      end)
    end
  else
    page:start(L["The herbs so far"], counted(kinds, total), ui.icon("Interface\\Icons\\INV_Misc_Herb_07"))
    if kinds == 0 then
      page:paragraph(
        L["No herb yet. Every herb that reaches your bags is written down here: gathered, looted, bought or given."],
        T.soft
      )
      return
    end
    local gathered, looted = 0, 0
    for _, rec in pairs(recs) do
      gathered, looted = gathered + (rec.gathered or 0), looted + (rec.looted or 0)
    end
    page:stats({
      { tostring(kinds), ns.kit.plural(kinds, "herb", "herbs") },
      { tostring(total), L["taken"] },
      { tostring(gathered), L["gathered"] },
      { tostring(looted), L["looted"] },
    })
  end
  lately(recs, 5)
end

local function refresh()
  local recs = records()
  local kinds, total = totals(recs)
  book.count:SetText(counted(kinds, total))
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
    page = ui.newPage(book.sheet, "YonderFloraPage", 110, pairsPool)
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

-- Open the book at a fish's or an herb's page (yonder:f<id>, h<id>: a
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
