-- The Bestiary's tab in the book. On the left, a tree: the creature types,
-- the families met in each, the creatures met in each family (types and
-- families fold), the trophies first. On the right, a family's page (the
-- League naturalist's note and who was met in it), a creature's (its portrait
-- and this character's record of it, in sections), or the trophies' (the
-- rares and bosses slain).
local _, ns = ...
local D = ns.data
local ui = ns.ui
local T, SOFT, QUESTION = ui.T, ui.SOFT, ui.QUESTION

local TROPHIES = "trophies"
local book, list, page
-- What the page shows: a family key (a number, or a "?type/family" string),
-- TROPHIES, or a creature (currentCreature, current its family). fresh: a
-- new page (scrolled to the top), not the same one rewritten.
local current, currentCreature, fresh

-- ── portraits ────────────────────────────────────────────────────────────────
-- The game's still portrait of a creature (as a unit frame's). Creatures the
-- data doesn't know get their display id from a hidden model, once (kept in
-- their record).
local resolving, failed = nil, {}
local function resolveDisplay(id, rec)
  if resolving or failed[id] or not C_Timer.NewTicker then return end
  local model = CreateFrame("PlayerModel", nil, UIParent)
  if not (model.SetCreature and model.GetDisplayInfo) then return end
  -- Off screen but shown: a hidden model doesn't load.
  model:SetSize(64, 64)
  model:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -200, -200)
  resolving = id
  model:SetCreature(id)
  local tries = 0
  C_Timer.NewTicker(0.5, function(ticker)
    tries = tries + 1
    local display = model:GetDisplayInfo()
    if type(display) == "number" and not ns.secret(display) and display > 0 then
      rec.display = display
    elseif tries < 10 then
      model:SetCreature(id) -- again: the first time only asks the server
      return
    else
      failed[id] = true
    end
    if ticker then ticker:Cancel() end
    model:ClearModel()
    model:Hide()
    resolving = nil
    ns.refresh()
  end)
end

local function setPortrait(p, id, rec)
  local display = (D.models and D.models[id]) or (rec and rec.display)
  if not display and rec then resolveDisplay(id, rec) end
  if display and SetPortraitTextureFromCreatureDisplayID then
    p.tex:SetTexCoord(0, 1, 0, 1)
    SetPortraitTextureFromCreatureDisplayID(p.tex, display)
  else
    ui.icon(QUESTION)(p)
  end
  p.display = display
end

-- ── what a record says ───────────────────────────────────────────────────────
local RANK = { r = "rare", R = "rare elite", b = "boss" }

local function rankOf(id, rec) return rec.trophy and rec.trophy.rank or ns.rank(id) end

local function rankTag(id, rec)
  local rank = rankOf(id, rec)
  if rec.trophy then return ("  %s%s, trophy|r"):format(T.mark, RANK[rank] or "trophy") end
  if rank then return ("  %s%s|r"):format(T.rare, RANK[rank]) end
  return ""
end

-- A creature's levels in the world (the data's range, widened by any level
-- seen), not just the one it had when met.
local function levels(id, rec)
  local known = D.levels and D.levels[id]
  local low, high
  if type(known) == "number" then
    low, high = known, known
  elseif type(known) == "string" then
    local a, b = known:match("^(%d+)-(%d+)$")
    low, high = tonumber(a), tonumber(b)
  end
  if rec.low then
    low, high = math.min(low or rec.low, rec.low), math.max(high or rec.high, rec.high)
  end
  if not low then return nil end
  return low == high and ("level %d"):format(low) or ("levels %d-%d"):format(low, high)
end

-- The parts given, the empty ones left out ("a  -  b").
local function joined(parts, sep)
  local out = {}
  for i = 1, table.maxn(parts) do
    local p = parts[i]
    if p and p ~= "" then table.insert(out, p) end
  end
  return table.concat(out, sep or "  -  ")
end

local function placeShort(p) return p and (p:match(": (.+)$") or p) end
local function day(stamp) return ui.day(stamp) end

-- The creatures of a family in the order the select asks: by name, the most
-- slain, the last slain, or in the order they were first met.
local SORTS = {
  { value = "name", text = "Sorted by name" },
  { value = "slain", text = "The most slain first" },
  { value = "recent", text = "The last slain first" },
  { value = "met", text = "In the order met" },
}
local function sortedIds(ids)
  local creatures = ns.journal().creatures
  local by = ns.filterOf(ns.TAB.bestiary) or "name"
  local function name(id) return creatures[id].name or "" end
  local function key(id)
    local rec = creatures[id]
    if by == "slain" then return -(rec.slain or 0) end
    if by == "recent" then return -((rec.lastSlain and rec.lastSlain.at) or 0) end
    if by == "met" then return (rec.firstSlain and rec.firstSlain.at) or (rec.first and rec.first.at) or 0 end
    return 0
  end
  table.sort(ids, function(a, b)
    local ka, kb = key(a), key(b)
    if ka ~= kb then return ka < kb end
    return name(a) < name(b)
  end)
  return ids
end

-- ── the page's parts ─────────────────────────────────────────────────────────
-- A creature on a family's or the trophies' page: portrait, name, a line.
local ENTRY_H = 52
local entries, lootButtons, rows, pairsPool = {}, {}, {}, {}
ns.pageEntries, ns.pageLoot, ns.listRows, ns.pagePairs = entries, lootButtons, rows, pairsPool -- for the tests

local function entry(i)
  local e = entries[i]
  if e then return e end
  e = CreateFrame("Button", nil, page.child)
  e:SetSize(ui.WIDTH, ENTRY_H)
  e.portrait = ui.roundPortrait(e, 40)
  e.portrait:SetPoint("LEFT", 4, 0)
  e.name = ui.label(e, ui.TITLE_FONT, 15, T.text)
  e.name:SetPoint("TOPLEFT", e.portrait, "TOPRIGHT", 12, -2)
  e.name:SetPoint("RIGHT", -4, 0)
  e.name:SetWordWrap(false)
  e.facts = ui.label(e, ui.BODY_FONT, 11, T.soft)
  e.facts:SetPoint("TOPLEFT", e.name, "BOTTOMLEFT", 0, -5)
  e.facts:SetPoint("RIGHT", -4, 0)
  e.facts:SetWordWrap(false)
  e.line = ui.rule(e)
  e.line:SetPoint("BOTTOMLEFT", 0, 0)
  e.line:SetPoint("BOTTOMRIGHT", 0, 0)
  e:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  e:SetScript("OnClick", function(self) ns.openCreature(self.id) end)
  entries[i] = e
  return e
end

-- An item taken from the creature: its icon, quality border, count, tooltip.
local function lootButton(i)
  local b = lootButtons[i]
  if b then return b end
  b = CreateFrame("Button", nil, page.child)
  b:SetSize(34, 34)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetAllPoints()
  b.border = b:CreateTexture(nil, "OVERLAY")
  b.border:SetTexture("Interface\\Common\\WhiteIconFrame")
  b.border:SetAllPoints()
  b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
  b.count:SetPoint("BOTTOMRIGHT", -2, 2)
  b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    if GameTooltip.SetItemByID then GameTooltip:SetItemByID(self.itemId) end
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function() GameTooltip:Hide() end)
  lootButtons[i] = b
  return b
end

local function itemQuality(itemId)
  if C_Item and C_Item.GetItemQualityByID then return C_Item.GetItemQualityByID(itemId) end
  if GetItemInfo then return select(3, GetItemInfo(itemId)) end
end

-- The page, laid out again: the Bestiary's own parts hidden too.
local function start(title, sub, setPicture)
  for _, pool in ipairs({ entries, lootButtons }) do
    for _, x in ipairs(pool) do
      x:Hide()
    end
  end
  page.familyLink.key = false
  page:start(title, sub, setPicture)
end

local function layEntries(ids, line)
  local creatures = ns.journal().creatures
  for i, id in ipairs(ids) do
    local rec = creatures[id]
    local e = entry(i)
    e.name:SetText((rec.name or ("Creature " .. id)) .. rankTag(id, rec))
    e.facts:SetText(line(id, rec))
    setPortrait(e.portrait, id, rec)
    e.id = id
    page:place(e, ENTRY_H + 4)
  end
end

-- ── the pages ────────────────────────────────────────────────────────────────
local function showFamily(key)
  local creatures = ns.journal().creatures
  local ids, intro
  if key == TROPHIES then
    ids = {}
    for id, rec in pairs(creatures) do
      if rec.trophy then table.insert(ids, id) end
    end
    table.sort(ids, function(a, b) return creatures[a].trophy.at < creatures[b].trophy.at end)
    start("Trophies", ("%d brought down"):format(#ids), ui.icon("Interface\\Icons\\INV_Misc_Head_Dragon_01"))
    intro =
      "The rare beasts and the great foes this traveller has brought down, with the day and the level of the deed."
  else
    ids = sortedIds(ns.metByFamily()[key] or {})
    local family = ns.familyById[key]
    local section
    for _, s in ipairs(D.sections) do
      if family and s.id == family.section then section = s.title end
    end
    start(ns.familyTitle(key), joined({ section, ("%d slain"):format(#ids) }), function(p)
      if ids[1] then
        setPortrait(p, ids[1], creatures[ids[1]])
      else
        ui.icon(QUESTION)(p)
      end
    end)
    intro = family and #family.note > 0 and table.concat(family.note, "\n\n")
      or (SOFT .. "The naturalist has not yet written of these. What follows is your own record.|r")
  end
  page:text({ intro })
  page:section(key == TROPHIES and "The trophy shelf" or "Slain in the wild")
  if key == TROPHIES then
    layEntries(ids, function(id, rec)
      local slain = ("slain %s at level %d"):format(day(rec.trophy), rec.trophy.level or 0)
      return joined({ ns.familyTitle(ns.familyKey(id, rec)), slain })
    end)
    if #ids == 0 then page:row("", SOFT .. "None yet.|r") end
  else
    layEntries(ids, function(id, rec)
      local slain = (rec.slain or 0) > 0 and ("%d slain"):format(rec.slain) or "none slain"
      return joined({ levels(id, rec), slain, placeShort(rec.places and rec.places[1]) })
    end)
  end
end

-- A creature's page: header (portrait, name, family, levels, rank), then the
-- record in sections: encounters, the hunt, spoils.
local function showCreature(id)
  local rec = ns.journal().creatures[id]
  local rank = rankOf(id, rec)
  start(
    rec.name or ("Creature " .. id),
    joined({ T.link .. ns.familyTitle(current) .. "|r", levels(id, rec), RANK[rank] }),
    function(p) setPortrait(p, id, rec) end
  )
  page.familyLink.key = current

  local first, last = rec.first or {}, rec.last
  page:section("Encounters")
  page:row("First met", joined({ day(first), first.level and ("you were level %d"):format(first.level) }, ", "))
  if last and last.at ~= first.at then
    page:row("Last seen", joined({ day(last), last.level and ("you were level %d"):format(last.level) }, ", "))
  end
  page:row("Where", rec.places and table.concat(rec.places, "\n"))
  page.y = page.y + 10

  page:section("The hunt")
  if (rec.slain or 0) > 0 then
    page:row("Slain", tostring(rec.slain))
    local firstLevel = rec.firstSlain and ("you were level %d"):format(rec.firstSlain.level or 0)
    page:row("First kill", joined({ day(rec.firstSlain), firstLevel }, ", "))
    if rec.lastSlain and rec.firstSlain and rec.lastSlain.at ~= rec.firstSlain.at then
      page:row("Last kill", day(rec.lastSlain))
    end
  else
    page:row("Slain", SOFT .. "none yet|r")
  end
  if rec.trophy then page:row("Trophy", ("%s, at level %d"):format(day(rec.trophy), rec.trophy.level or 0)) end
  page.y = page.y + 10

  page:section("Spoils")
  local items = {}
  for itemId, count in pairs(rec.loot or {}) do
    table.insert(items, { itemId, count })
  end
  table.sort(items, function(a, b) return a[2] > b[2] end)
  if #items == 0 then
    page:row("", SOFT .. "Nothing taken from it yet.|r")
    return
  end
  local perRow = math.floor((ui.WIDTH + 6) / 40)
  for i, item in ipairs(items) do
    local b = lootButton(i)
    b.itemId = item[1]
    b.icon:SetTexture(ui.itemIcon(item[1]) or QUESTION)
    local quality = itemQuality(item[1])
    local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if color then
      b.border:SetVertexColor(color.r, color.g, color.b)
    else
      b.border:SetVertexColor(0.6, 0.6, 0.6)
    end
    b.count:SetText(item[2] > 1 and item[2] or "")
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", page.child, "TOPLEFT", ((i - 1) % perRow) * 40, -(page.y + math.floor((i - 1) / perRow) * 40))
    b:Show()
  end
  page.y = page.y + math.ceil(#items / perRow) * 40
end

-- Before anything is recorded.
local function showEmpty()
  start("The Bestiary", nil, ui.icon("Interface\\Icons\\INV_Misc_Book_11"))
  page:text({
    SOFT .. "Nothing recorded yet. Target or mouse over a creature of the wild, and it will be written here.|r",
  })
end

local function showPage()
  local creatures = ns.journal().creatures
  if currentCreature and creatures[currentCreature] then
    showCreature(currentCreature)
  elseif current then
    currentCreature = nil
    showFamily(current)
  else
    showEmpty()
  end
  page:finish(not fresh)
  fresh = false
end

-- ── the list ─────────────────────────────────────────────────────────────────
-- Types fold (folded: collapsed[section id]); families unfold (open[family]),
-- kept in the journal.
local function journalState(name)
  local j = ns.journal()
  j[name] = j[name] or {}
  return j[name]
end
local function folded() return journalState("collapsed") end
local function opened() return journalState("open") end

local function style(r, kind)
  if kind == "section" then
    r.fold:SetPoint("LEFT", 2, 0)
    r.fold:Show()
    r.text:SetPoint("LEFT", 18, 0)
    r.text:SetFont(ui.TITLE_FONT, 14, "")
    r.text:SetTextColor(unpack(T.gold))
    r.count:SetPoint("RIGHT", -4, 0)
    return 22
  elseif kind == "family" or kind == "trophies" then
    r.fold:SetPoint("LEFT", 10, 0)
    r.fold:SetShown(kind == "family")
    r.text:SetPoint("LEFT", kind == "family" and 26 or 8, 0)
    r.text:SetPoint("RIGHT", -28, 0)
    r.text:SetFont(ui.BODY_FONT, 12, "")
    r.text:SetTextColor(unpack(kind == "family" and T.text or T.gold))
    r.count:SetPoint("RIGHT", -4, 0)
    return 18
  end
  r.text:SetPoint("LEFT", 34, 0)
  r.text:SetPoint("RIGHT", -28, 0)
  r.text:SetFont(ui.BODY_FONT, 11, "")
  r.text:SetTextColor(unpack(T.soft))
  return 16
end

-- A page chosen (a click, a link): shown fresh.
local function choose(key, creature)
  current, currentCreature, fresh = key, creature, true
end

local function refreshList()
  local q = ui.query(book)
  local searching = q ~= ""
  local creatures = ns.journal().creatures
  local by = ns.metByFamily()
  local function nameHit(id)
    local name = creatures[id].name
    return name ~= nil and name:lower():find(q, 1, true) ~= nil
  end
  list:begin()

  -- Trophies first.
  local trophies = 0
  for _, rec in pairs(creatures) do
    if rec.trophy then trophies = trophies + 1 end
  end
  if trophies > 0 and not searching then
    local r = list:add("trophies", "Trophies", trophies)
    r:SetScript("OnClick", function()
      choose(TROPHIES)
      ns.refresh()
    end)
    if current == TROPHIES then list:pick(r) end
  end

  -- A family and, unfolded, its creatures.
  local function addFamily(key)
    local ids = by[key]
    local titleHit = searching and ns.familyTitle(key):lower():find(q, 1, true)
    local shownIds = {}
    for _, id in ipairs(sortedIds(ids)) do
      if not searching or titleHit or nameHit(id) then table.insert(shownIds, id) end
    end
    if #shownIds == 0 then return end
    local open = searching or opened()[key]
    local r = list:add("family", ns.familyTitle(key), #ids)
    ui.fold(r, open)
    r.key = key
    r:SetScript("OnClick", function()
      -- The open family's row folds it; any other opens its page, unfolded.
      if current == key and not currentCreature and opened()[key] then
        opened()[key] = nil
      else
        opened()[key] = true
        choose(key)
      end
      ns.refresh()
    end)
    if current == key and not currentCreature then list:pick(r) end
    if not open then return end
    for _, id in ipairs(shownIds) do
      local rec = creatures[id]
      local mark = rankOf(id, rec) and (" " .. SOFT .. "*|r") or ""
      local c = list:add("creature", (rec.name or ("Creature " .. id)) .. mark)
      c.id = id
      c:SetScript("OnClick", function()
        choose(key, id)
        ns.refresh()
      end)
      if currentCreature == id then list:pick(c) end
    end
  end

  local function addSection(id, title, keys)
    local shown = {}
    for _, key in ipairs(keys) do
      local hit = not searching or ns.familyTitle(key):lower():find(q, 1, true)
      for _, cid in ipairs(hit and {} or by[key]) do
        if nameHit(cid) then hit = true end
      end
      if hit then table.insert(shown, key) end
    end
    if #shown == 0 then return end
    list:gap(4)
    local r = list:add("section", title)
    ui.fold(r, searching or not folded()[id])
    r:SetScript("OnClick", function()
      folded()[id] = not folded()[id] or nil
      ns.refresh()
    end)
    if searching or not folded()[id] then
      for _, key in ipairs(shown) do
        addFamily(key)
      end
    end
  end

  -- Families met, under their type; keys the data couldn't place (a type of
  -- another client's language) at the end.
  local placed = {}
  for _, section in ipairs(D.sections) do
    local keys = {}
    for _, family in ipairs(D.families) do
      if family.section == section.id and by[family.id] then
        table.insert(keys, family.id)
        placed[family.id] = true
      end
    end
    addSection(section.id, section.title, keys)
  end
  local other = {}
  for key in pairs(by) do
    if not placed[key] then table.insert(other, key) end
  end
  table.sort(other, function(a, b) return tostring(a) < tostring(b) end)
  addSection("unrecorded", "Unrecorded", other)
  list:finish()
end

local function refresh()
  local creatures, families, slain = ns.counts()
  book.count:SetText(("%d creatures, %d families, %d slain"):format(creatures, families, slain))
  -- The first opening: the family most recently met.
  if current == nil then
    local latest, at = nil, -1
    for key, f in pairs(ns.journal().families) do
      if (f.at or 0) > at then
        latest, at = key, f.at or 0
      end
    end
    if latest then
      choose(latest)
      opened()[latest] = true
    end
  end
  refreshList()
  showPage()
end

ns.addTab(ns.TAB.bestiary, {
  build = function(b)
    book = b
    list = ui.newList(book.left, style, rows, true)
    page = ui.newPage(book.sheet, "FieldJournalPage", 92, pairsPool)
    -- On a creature's page, its family (the line under the title): a click
    -- opens the family's page.
    page.familyLink = CreateFrame("Button", nil, page.child)
    page.familyLink:SetAllPoints(page.sub)
    page.familyLink:SetScript("OnClick", function(self)
      if self.key then ns.openFamily(self.key) end
    end)
  end,
  show = function(n)
    list:SetShown(n == ns.TAB.bestiary)
    page:SetShown(n == ns.TAB.bestiary)
  end,
  refresh = refresh,
  filter = { default = "name", options = function() return SORTS end },
})

-- Open the book at a family (its id, or ?<type>/<family>; an older link's
-- index in Data.lua's list), unfolded in the list.
function ns.openFamily(key)
  if not ns.journal() then return end
  if type(key) == "number" then key = D.families[key] and D.families[key].id end
  if not key then return end
  choose(key)
  opened()[key] = true
  ns.openTab(ns.TAB.bestiary)
end

-- Open the book at a creature's page (fieldjournal:c<creature id>).
function ns.openCreature(id)
  local rec = ns.journal() and ns.journal().creatures[id]
  if not rec then return end
  local key = ns.familyKey(id, rec)
  choose(key, id)
  opened()[key] = true
  ns.openTab(ns.TAB.bestiary)
end
