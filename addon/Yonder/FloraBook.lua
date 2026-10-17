-- Finds uses the same kit list, page and category select as the other tabs.
-- Only unlocked families and discovered item pages are shown. Fish and herbs
-- keep their original figures, notes and Atlas links.
local _, ns = ...
local L, F, M, ui = ns.kit.L, ns.data.flora, ns.data.materials, ns.ui
local T = ui.T
local book, list, page
local mode, current = "all", {}
local rows, pairsPool = {}, {}
ns.floraRows, ns.floraPairs = rows, pairsPool
local CATEGORIES = {
  {
    id = "fish",
    title = L["Fish"],
    families = { "fish" },
    overview = L["The catch so far"],
    icon = "Interface\\Icons\\Trade_Fishing",
  },
  {
    id = "plants",
    title = L["Plants"],
    families = { "plants" },
    overview = L["The herbs so far"],
    icon = "Interface\\Icons\\INV_Misc_Herb_07",
  },
  {
    id = "mining",
    title = L["Ores & Gems"],
    families = { "mining" },
    overview = L["Ores & Gems"],
    icon = "Interface\\Icons\\INV_Ore_Copper_01",
  },
  {
    id = "textiles",
    title = L["Cloth & Leather"],
    families = { "cloth", "leather" },
    overview = L["Cloth & Leather"],
    icon = "Interface\\Icons\\INV_Fabric_Linen_01",
  },
}
local categoryById = {}
for _, category in ipairs(CATEGORIES) do
  categoryById[category.id] = category
end
local function available(category)
  for _, family in ipairs(category.families) do
    if ns.findsUnlocked(family) then return true end
  end
  return false
end
local function families(which)
  local out = {}
  for _, family in
    ipairs(which == "all" and { "fish", "plants", "mining", "cloth", "leather" } or categoryById[which].families)
  do
    if ns.findsUnlocked(family) then table.insert(out, family) end
  end
  return out
end
local function records(which)
  local out = {}
  for _, family in ipairs(families(which or mode)) do
    for _, id in ipairs(ns.findOrder(family)) do
      local rec = ns.findRecord(id)
      if rec then out[id] = rec end
    end
  end
  return out
end
local function info(id) return ns.findInfo(id) end
local function name(id) return ns.findName(id) end
local function picture(id) return ui.icon(ns.findIcon(id)) end
local function totals(recs)
  local kinds, total = 0, 0
  for _, rec in pairs(recs) do
    kinds, total = kinds + 1, total + (rec.n or 0)
  end
  return kinds, total
end
local function counted(kinds, total, which)
  which = which or mode
  local plural = ns.kit.plural
  if which == "fish" then
    return plural(kinds, "%d kind of fish, %d caught", "%d kinds of fish, %d caught"):format(kinds, total)
  end
  if which == "plants" then return plural(kinds, "%d herb, %d taken", "%d herbs, %d taken"):format(kinds, total) end
  if which == "all" then return plural(kinds, "%d find, %d taken", "%d finds, %d taken"):format(kinds, total) end
  return plural(kinds, "%d material, %d taken", "%d materials, %d taken"):format(kinds, total)
end
local function when(stamp)
  if not stamp or not stamp.at then return end
  local where, sub = stamp.zone and ns.zoneName(stamp.zone), stamp.sub and ns.areaLabel(stamp.sub)
  if where and sub and sub ~= "" and sub ~= where then where = L["%s, %s"]:format(sub, where) end
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
  ore = L["Ore"],
  stone = L["Stone"],
  gem = L["Gem"],
  cloth = L["Cloth"],
  leather = L["Leather"],
  hide = L["Hide"],
}
local RANKS = { { 1, L["Apprentice"] }, { 75, L["Journeyman"] }, { 150, L["Expert"] }, { 225, L["Artisan"] } }
local function rankOf(skill)
  local result = RANKS[1][2]
  for _, rank in ipairs(RANKS) do
    if skill >= rank[1] then result = rank[2] end
  end
  return result
end
local function style(row, kind)
  if kind == "section" then
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetPoint("RIGHT", -4, 0)
    row.text:SetFont(ui.TITLE_FONT, 14, "")
    row.text:SetTextColor(unpack(T.gold))
    return 22
  end
  row.count:SetPoint("RIGHT", -4, 0)
  row.text:SetPoint("LEFT", kind == "overview" and 4 or 14, 0)
  row.text:SetPoint("RIGHT", row.count, "LEFT", -4, 0)
  row.text:SetFont(ui.BODY_FONT, 12, "")
  row.text:SetTextColor(unpack(kind == "overview" and T.gold or T.text))
  return 18
end
local function groups(query)
  local recs, out = records(), {}
  local function add(title, order, wanted)
    local ids = {}
    for _, id in ipairs(order) do
      if recs[id] and (not wanted or wanted(info(id))) and (query == "" or name(id):lower():find(query, 1, true)) then
        table.insert(ids, id)
      end
    end
    if #ids > 0 then table.insert(out, { title, ids }) end
  end
  if mode == "fish" then
    for _, group in ipairs(FISH_GROUPS) do
      add(group[2], F.fishOrder, function(d) return d.kind == group[1] end)
    end
  elseif mode == "plants" then
    for _, rank in ipairs(RANKS) do
      add(rank[2], F.herbOrder, function(d) return rankOf(d.skill) == rank[2] end)
    end
  elseif mode == "mining" or mode == "textiles" then
    local labels = mode == "mining" and { { "ore", L["Ores"] }, { "stone", L["Stones"] }, { "gem", L["Gems"] } }
      or { { "cloth", L["Cloth"] }, { "leather", L["Leather"] }, { "hide", L["Hides"] } }
    for _, group in ipairs(labels) do
      add(group[2], M.order, function(d) return d.kind == group[1] end)
    end
  else
    for _, family in ipairs(families("all")) do
      add(ns.findFamilyInfo(family).title, ns.findOrder(family))
    end
  end
  return out
end
local function refreshList()
  local query, recs = ui.query(book), records()
  local found = groups(query)
  list:begin()
  if query == "" then
    local row = list:add("overview", mode == "all" and L["Your finds"] or categoryById[mode].overview)
    row:SetScript("OnClick", function()
      current[mode] = nil
      ns.refresh()
    end)
    if not current[mode] then list:pick(row) end
  end
  for _, group in ipairs(found) do
    list:gap(6)
    list:add("section", group[1])
    for _, id in ipairs(group[2]) do
      local row = list:add("kind", name(id), recs[id].n or 0)
      row.key = id
      row:SetScript("OnClick", function()
        current[mode] = id
        ns.refresh()
      end)
      if current[mode] == id then list:pick(row) end
    end
  end
  if #found == 0 and query ~= "" then list:add("section", L["Nothing found"]) end
  list:finish()
end
local function listed(items) return items and #items > 0 and table.concat(items, ", ") or nil end
local function areas(ids)
  local out = {}
  for _, id in ipairs(ids or {}) do
    table.insert(out, ns.areaLabel("a" .. id))
  end
  table.sort(out)
  return listed(out)
end
local function mostFound(zones)
  local counts, out = {}, {}
  for zone, count in pairs(zones or {}) do
    table.insert(counts, { zone, count })
  end
  table.sort(counts, function(a, b) return a[2] > b[2] end)
  for i = 1, math.min(#counts, 5) do
    table.insert(out, L["%s (%d)"]:format(ns.zoneName(counts[i][1]), counts[i][2]))
  end
  return listed(out)
end
local HOW = { gathered = L["gathered"], looted = L["looted"], skinned = L["skinned"], other = L["came to your bags"] }
local function zoneChips(zones)
  local out = {}
  for _, zone in ipairs(zones or {}) do
    table.insert(out, { ns.zoneName(zone), function() ns.openZone(zone) end, false, L["Open its page in the Atlas."] })
  end
  table.sort(out, function(a, b) return a[1] < b[1] end)
  if #out > 0 then page:chips(out) end
end
local function showKind(id)
  local d, rec, family = info(id), ns.findRecord(id), ns.findFamily(id)
  if family == "fish" then
    local season = d.season and (d.season == "winter" and L["only in winter"] or L["only in summer"])
    page:start(name(id), table.concat({ KIND[d.kind], season }, "  -  "), picture(id))
    page:text(d.note)
    local figures = { { tostring(rec.n or 0), L["caught"] } }
    if rec.heaviest then table.insert(figures, { L["%d lb"]:format(rec.heaviest), L["the heaviest"] }) end
    table.insert(figures, { L["%d / %d"]:format(rec.day or 0, rec.night or 0), L["day / night"] })
    if (rec.school or 0) > 0 then table.insert(figures, { tostring(rec.school), L["from schools"] }) end
    page:stats(figures)
    page:section(L["Where it bites"])
    zoneChips(d.zones)
    page:row(L["Waters"], areas(d.subzones))
    page:row(L["Dungeons"], areas(d.dungeons))
    page:section(L["Your catches"])
    page:row(L["First caught"], when(rec.first))
  else
    local subtitle = family == "plants"
        and L["Herbalism %d%s"]:format(d.skill, d.inside and L["  -  found in other herbs"] or "")
      or KIND[d.kind]
    page:start(name(id), subtitle, picture(id))
    page:text(d.note)
    local figures = { { tostring(rec.n or 0), L["taken"] } }
    if family == "plants" or family == "mining" then
      table.insert(figures, { tostring(rec.gathered or 0), L["gathered"] })
    end
    if family == "leather" then table.insert(figures, { tostring(rec.skinned or 0), L["skinned"] }) end
    table.insert(figures, { tostring(rec.looted or 0), L["looted"] })
    local carried = ns.findBagCount(id)
    table.insert(figures, { carried and tostring(carried) or "?", L["in bags"] })
    page:stats(figures)
    page:section(family == "plants" and L["Where it grows"] or L["Where it is found"])
    zoneChips(d.zones)
    page:row(L["Dungeons"], areas(d.dungeons))
    page:section(family == "plants" and L["Your herbs"] or L["Your finds"])
    local first = when(rec.first)
    page:row(L["First"], first and L["%s (%s)"]:format(first, HOW[rec.first.how] or "?"))
  end
  page:row(L["Where"], mostFound(rec.zones))
end
local function lately(recs)
  local ids = {}
  for id, rec in pairs(recs) do
    if rec.first and rec.first.at and info(id) then table.insert(ids, id) end
  end
  table.sort(ids, function(a, b)
    if recs[a].first.at == recs[b].first.at then return a < b end
    return recs[a].first.at > recs[b].first.at
  end)
  if #ids == 0 then return end
  page:section(
    mode == "fish" and L["The last new catches"]
      or mode == "plants" and L["The last new herbs"]
      or L["The last new finds"]
  )
  for i = 1, math.min(#ids, 5) do
    local id = ids[i]
    page:card(name(id), when(recs[id].first), picture(id), function()
      current[mode] = id
      ns.refresh()
    end)
  end
end
local function options()
  local out = { { value = "all", text = L["All finds"] } }
  for _, category in ipairs(CATEGORIES) do
    if available(category) then table.insert(out, { value = category.id, text = category.title }) end
  end
  return out
end
local function choose(which, id)
  current[which] = id
  ns.setFilter(ns.TAB.finds, which)
  ns.openTab(ns.TAB.finds)
end
local function showOverview()
  local recs = records()
  local kinds, total = totals(recs)
  local category = categoryById[mode]
  page:start(
    category and category.overview or L["Your finds"],
    counted(kinds, total),
    ui.icon(category and category.icon or "Interface\\Icons\\INV_Misc_Book_09")
  )
  if mode == "all" then
    page:paragraph(
      L["Your collections share these pages. Learning a gathering profession opens its collection, and the journal keeps it even if you change trades."],
      T.soft
    )
    for _, group in ipairs(CATEGORIES) do
      if available(group) then
        local n, amount = totals(records(group.id))
        page:card(group.title, counted(n, amount, group.id), ui.icon(group.icon), function() choose(group.id) end)
      end
    end
  elseif kinds == 0 then
    page:paragraph(
      mode == "fish" and L["Nothing caught yet. Every fish you land is written down here, with where and when it bit."]
        or mode == "plants" and L["No herb yet. Every herb that reaches your bags is written down here: gathered, looted, bought or given."]
        or L["Nothing recorded here yet. Materials you gather, loot or receive will open their pages."],
      T.soft
    )
  elseif mode == "fish" then
    local schools, nights, heavy = 0, 0, nil
    for id, rec in pairs(recs) do
      schools, nights = schools + (rec.school or 0), nights + (rec.night or 0)
      if rec.heaviest and (not heavy or rec.heaviest > heavy[2]) then heavy = { id, rec.heaviest } end
    end
    page:stats({
      { tostring(kinds), ns.kit.plural(kinds, "kind", "kinds") },
      { tostring(total), L["caught"] },
      { tostring(schools), L["from schools"] },
      { tostring(nights), L["by night"] },
    })
    if heavy then
      page:section(L["The heaviest"])
      page:card(name(heavy[1]), L["%d pounds"]:format(heavy[2]), picture(heavy[1]), function()
        current[mode] = heavy[1]
        ns.refresh()
      end)
    end
  else
    local gathered, looted, skinned = 0, 0, 0
    for _, rec in pairs(recs) do
      gathered, looted, skinned =
        gathered + (rec.gathered or 0), looted + (rec.looted or 0), skinned + (rec.skinned or 0)
    end
    local figures = {
      { tostring(kinds), ns.kit.plural(kinds, "kind", "kinds") },
      { tostring(total), L["taken"] },
      { tostring(looted), L["looted"] },
    }
    if mode == "plants" or mode == "mining" then table.insert(figures, { tostring(gathered), L["gathered"] }) end
    if mode == "textiles" and ns.findsUnlocked("leather") then
      table.insert(figures, { tostring(skinned), L["skinned"] })
    end
    page:stats(figures)
  end
  if mode == "textiles" and not ns.findsUnlocked("leather") then
    page:paragraph(L["Cloth is open to everyone. Learn Skinning to add leather and hides."], T.soft)
  end
  lately(recs)
end
local function refresh()
  mode = ns.filterOf(ns.TAB.finds) or "all"
  if mode ~= "all" and (not categoryById[mode] or not available(categoryById[mode])) then
    mode = "all"
    ns.setFilter(ns.TAB.finds, mode)
  end
  book.filter:SetOptions(options())
  book.filter:SetValue(mode)
  book.count:SetText(counted(totals(records())))
  refreshList()
  if current[mode] and records()[current[mode]] then
    showKind(current[mode])
  else
    current[mode] = nil
    showOverview()
  end
  page:finish()
end
ns.addTab(ns.TAB.finds, {
  build = function(b)
    book = b
    list = ui.newList(book.left, style, rows, true)
    page = ui.newPage(book.sheet, "YonderFloraPage", 110, pairsPool)
  end,
  show = function(n)
    local here = n == ns.TAB.finds
    list:SetShown(here)
    page:SetShown(here)
  end,
  refresh = refresh,
  filter = { default = "all", options = options },
})
function ns.openFindCategory(family)
  local which = (family == "cloth" or family == "leather") and "textiles" or family
  if which == "all" or (categoryById[which] and available(categoryById[which])) then choose(which) end
end
function ns.openFind(id)
  local family = ns.findFamily(id)
  if not family or not ns.findsUnlocked(family) then return end
  choose((family == "cloth" or family == "leather") and "textiles" or family, ns.findRecord(id) and id or nil)
end
function ns.openFish(id)
  if F.fish[id] then ns.openFind(id) end
end
function ns.openPlant(id)
  if F.herbs[id] then ns.openFind(id) end
end
