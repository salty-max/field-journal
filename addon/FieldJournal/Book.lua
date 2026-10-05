-- The Bestiary as a book. On the left, a tree: the creature types, the
-- families met in each, the creatures met in each family (types and families
-- fold). On the right, a family's page (the League naturalist's note and who
-- was met in it) or a creature's (its portrait and this character's record of
-- it, in sections). A Trophies page lists the rares and bosses slain.
-- /journal opens it.
-- Both games: the standard game window (portrait, title bar), light text and
-- gold titles on dark panels. Forever: the cards of its Professions window.
-- Classic: the game's inset panels, the quest log's dark book behind the list.
local _, ns = ...
local D = ns.data

local TROPHIES = "trophies"

-- ── look ─────────────────────────────────────────────────────────────────────
local T = {
  gold = { 0.85, 0.70, 0.42 }, text = { 0.93, 0.88, 0.76 }, soft = { 0.62, 0.57, 0.49 },
  rule = { 0.85, 0.70, 0.42, 0.25 }, mark = "|cffff9a40", rare = "|cffc7ccd6", link = "|cffd9b36b",
}
local LIST = T

local LATIN = { enUS = true, enGB = true, frFR = true, deDE = true, esES = true, esMX = true, itIT = true, ptBR = true }
local BODY_FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local TITLE_FONT = (not GetLocale or LATIN[GetLocale()]) and "Fonts\\MORPHEUS.TTF" or BODY_FONT

local function hex(c) return ("|cff%02x%02x%02x"):format(c[1] * 255, c[2] * 255, c[3] * 255) end
local SOFT, LIST_SOFT = hex(T.soft), hex(LIST.soft)

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
-- the list, the quest log's dark book (TBC's two-pane log, where the game has it).
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

-- A scroll area moved by the mouse wheel, with a thin gold thumb.
local function scrollArea(parent, width)
  local s = CreateFrame("ScrollFrame", nil, parent)
  local c = CreateFrame("Frame", nil, s)
  c:SetSize(width, 1)
  s:SetScrollChild(c)
  s.child = c
  s.thumb = s:CreateTexture(nil, "OVERLAY")
  s.thumb:SetColorTexture(0.85, 0.70, 0.42, 0.45)
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

-- ── portraits ────────────────────────────────────────────────────────────────
-- The game's still portrait of a creature (as a unit frame's), round, in a
-- gold ring. Creatures the data doesn't know get their display id from a
-- hidden model, once (kept in their record).
local MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

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

local resolving, failed = nil, {}
local function resolveDisplay(id, rec)
  if resolving or failed[id] or not (C_Timer and C_Timer.NewTicker) then return end
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
  p.display = display
  if display and SetPortraitTextureFromCreatureDisplayID then
    p.tex:SetTexCoord(0, 1, 0, 1)
    SetPortraitTextureFromCreatureDisplayID(p.tex, display)
  else
    p.tex:SetTexture(QUESTION)
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
end

local function icon(path)
  return function(p)
    p.display = nil
    p.tex:SetTexture(path)
    p.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
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

local function day(stamp) return date("%d %b %Y", stamp and stamp.at or 0) end

-- A creature's levels in the world (the data's range, widened by any level
-- seen), not just the one it had when met.
local function levels(id, rec)
  local known = D.levels and D.levels[id]
  local low, high
  if type(known) == "number" then low, high = known, known
  elseif type(known) == "string" then
    local a, b = known:match("^(%d+)-(%d+)$")
    low, high = tonumber(a), tonumber(b)
  end
  if rec.low then low, high = math.min(low or rec.low, rec.low), math.max(high or rec.high, rec.high) end
  if not low then return nil end
  return low == high and ("level %d"):format(low) or ("levels %d-%d"):format(low, high)
end

local function joined(parts, sep)
  local out = {}
  for i = 1, table.maxn(parts) do
    local p = parts[i]
    if p and p ~= "" then table.insert(out, p) end
  end
  return table.concat(out, sep or "  -  ")
end

local function placeShort(p) return p and (p:match(": (.+)$") or p) end

-- ── the page ─────────────────────────────────────────────────────────────────
local book, list, page
-- What the page shows: a family key (a number, or a "?type/family" string),
-- TROPHIES, or a creature (currentCreature set, current its family).
local current, currentCreature
local build
local WIDTH = 440
local HEADER_H = 88

local function sortedIds(ids)
  local journal = ns.journal()
  table.sort(ids, function(a, b)
    local ra, rb = journal.creatures[a], journal.creatures[b]
    return (ra.name or "") < (rb.name or "")
  end)
  return ids
end

-- Pools of page parts, shown as needed.
local entries, headings, pairsPool, lootButtons = {}, {}, {}, {}
ns.pageEntries, ns.pagePairs, ns.pageLoot = entries, pairsPool, lootButtons -- for the tests

-- A creature on a family's or the trophies' page: portrait, name, a line.
local ENTRY_H = 52
local function entry(i)
  local e = entries[i]
  if e then return e end
  e = CreateFrame("Button", nil, page.child)
  e:SetSize(WIDTH, ENTRY_H)
  e.portrait = roundPortrait(e, 40)
  e.portrait:SetPoint("LEFT", 4, 0)
  e.name = label(e, TITLE_FONT, 15, T.text)
  e.name:SetPoint("TOPLEFT", e.portrait, "TOPRIGHT", 12, -2)
  e.name:SetPoint("RIGHT", -4, 0)
  e.name:SetWordWrap(false)
  e.facts = label(e, BODY_FONT, 11, T.soft)
  e.facts:SetPoint("TOPLEFT", e.name, "BOTTOMLEFT", 0, -5)
  e.facts:SetPoint("RIGHT", -4, 0)
  e.facts:SetWordWrap(false)
  e.line = rule(e)
  e.line:SetPoint("BOTTOMLEFT", 0, 0)
  e.line:SetPoint("BOTTOMRIGHT", 0, 0)
  e:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  e:SetScript("OnClick", function(self) ns.openCreature(self.id) end)
  entries[i] = e
  return e
end

-- A section heading with a rule under it.
local function heading(i)
  local h = headings[i]
  if h then return h end
  h = CreateFrame("Frame", nil, page.child)
  h:SetSize(WIDTH, 24)
  h.text = label(h, TITLE_FONT, 16, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 0, 5)
  h.line = rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  headings[i] = h
  return h
end

-- A label and its value, side by side.
local LABEL_W = 92
local function pair(i)
  local p = pairsPool[i]
  if p then return p end
  p = CreateFrame("Frame", nil, page.child)
  p:SetSize(WIDTH, 16)
  p.label = label(p, BODY_FONT, 12, T.soft)
  p.label:SetPoint("TOPLEFT", 0, 0)
  p.label:SetWidth(LABEL_W)
  p.value = label(p, BODY_FONT, 12, T.text)
  p.value:SetPoint("TOPLEFT", LABEL_W + 8, 0)
  p.value:SetWidth(WIDTH - LABEL_W - 8)
  p.value:SetSpacing(4)
  pairsPool[i] = p
  return p
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
local function itemIcon(itemId)
  if C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(itemId) end
  if GetItemIcon then return GetItemIcon(itemId) end
end

local function clear()
  for _, pool in ipairs({ entries, headings, pairsPool, lootButtons }) do
    for _, x in ipairs(pool) do x:Hide() end
  end
  page.body:Hide()
  page.empty:Hide()
  page.familyLink.key = nil
end

-- The header: portrait (or an icon), title, a line under it.
local function header(title, sub, setPicture)
  page.title:SetText(title)
  page.sub:SetText(sub or "")
  setPicture(page.portrait)
end

local function finish(y, keep)
  page.child:SetHeight(y + 24)
  if keep then page:UpdateThumb() else page:ScrollTo(0) end
end

local function layEntries(ids, y, line)
  local journal = ns.journal()
  for i, id in ipairs(ids) do
    local rec = journal.creatures[id]
    local e = entry(i)
    e:ClearAllPoints()
    e:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
    e.name:SetText((rec.name or ("Creature " .. id)) .. rankTag(id, rec))
    e.facts:SetText(line(id, rec))
    setPortrait(e.portrait, id, rec)
    e.id = id
    e:Show()
    y = y + ENTRY_H + 4
  end
  return y
end

-- keep: re-render in place (the records changed), keeping the scroll.
local function showFamily(key, keep)
  current, currentCreature = key, nil
  local journal = ns.journal()
  if not journal or not key then return end
  clear()
  local ids, intro
  if key == TROPHIES then
    ids = {}
    for id, rec in pairs(journal.creatures) do
      if rec.trophy then table.insert(ids, id) end
    end
    table.sort(ids, function(a, b) return journal.creatures[a].trophy.at < journal.creatures[b].trophy.at end)
    header("Trophies", ("%d brought down"):format(#ids), icon("Interface\\Icons\\INV_Misc_Head_Dragon_01"))
    intro = "The rare beasts and the great foes this traveller has brought down, with the day and the level of the deed."
  else
    ids = sortedIds(ns.metByFamily()[key] or {})
    local family = type(key) == "number" and D.families[key]
    local section
    for _, s in ipairs(D.sections) do
      if family and s.id == family.section then section = s.title end
    end
    header(ns.familyTitle(key), joined({ section, ("%d met"):format(#ids) }), function(p)
      if ids[1] then setPortrait(p, ids[1], journal.creatures[ids[1]]) else icon(QUESTION)(p) end
    end)
    intro = family and #family.note > 0 and table.concat(family.note, "\n\n")
      or (SOFT .. "The naturalist has not yet written of these. What follows is your own record.|r")
  end
  page.body:SetText(intro)
  page.body:Show()
  local y = HEADER_H + page.body:GetStringHeight() + 22
  local h = heading(1)
  h.text:SetText(key == TROPHIES and "The trophy shelf" or "Met in the wild")
  h:ClearAllPoints()
  h:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
  h:Show()
  y = y + 30
  if key == TROPHIES then
    y = layEntries(ids, y, function(id, rec)
      return joined({ ns.familyTitle(ns.familyKey(id, rec)), ("slain %s at level %d"):format(day(rec.trophy), rec.trophy.level or 0) })
    end)
    if #ids == 0 then
      page.empty:SetText(SOFT .. "None yet.|r")
      page.empty:ClearAllPoints()
      page.empty:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
      page.empty:Show()
      y = y + 20
    end
  else
    y = layEntries(ids, y, function(id, rec)
      local slain = (rec.slain or 0) > 0 and ("%d slain"):format(rec.slain) or "none slain"
      return joined({ levels(id, rec), slain, placeShort(rec.places and rec.places[1]) })
    end)
  end
  finish(y, keep)
end

-- A creature's page: header (portrait, name, family, levels, rank), then the
-- record in sections: encounters, the hunt, spoils.
local function showCreature(id, keep)
  local journal = ns.journal()
  local rec = journal and journal.creatures[id]
  if not rec then return end
  current, currentCreature = ns.familyKey(id, rec), id
  clear()
  local rank = rankOf(id, rec)
  header(rec.name or ("Creature " .. id), joined({ T.link .. ns.familyTitle(current) .. "|r", levels(id, rec), RANK[rank] }),
    function(p) setPortrait(p, id, rec) end)
  page.familyLink.key = current
  local y = HEADER_H + 2
  local hi, pi = 0, 0
  local function section(title)
    hi = hi + 1
    local h = heading(hi)
    h.text:SetText(title)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
    h:Show()
    y = y + 34
  end
  local function row(name, value)
    if not value then return end
    pi = pi + 1
    local p = pair(pi)
    p.label:SetText(name)
    p.value:SetText(value)
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", page.child, "TOPLEFT", 0, -y)
    local height = math.max(16, p.value:GetStringHeight())
    p:SetHeight(height)
    p:Show()
    y = y + height + 8
  end

  local first, last = rec.first or {}, rec.last
  section("Encounters")
  row("First met", joined({ day(first), first.level and ("you were level %d"):format(first.level) }, ", "))
  if last and last.at ~= first.at then
    row("Last seen", joined({ day(last), last.level and ("you were level %d"):format(last.level) }, ", "))
  end
  row("Where", rec.places and table.concat(rec.places, "\n"))
  y = y + 10

  section("The hunt")
  if (rec.slain or 0) > 0 then
    row("Slain", tostring(rec.slain))
    row("First kill", joined({ day(rec.firstSlain), rec.firstSlain and ("you were level %d"):format(rec.firstSlain.level or 0) }, ", "))
    if rec.lastSlain and rec.firstSlain and rec.lastSlain.at ~= rec.firstSlain.at then row("Last kill", day(rec.lastSlain)) end
  else
    row("Slain", SOFT .. "none yet|r")
  end
  if rec.trophy then row("Trophy", ("%s, at level %d"):format(day(rec.trophy), rec.trophy.level or 0)) end
  y = y + 10

  section("Spoils")
  local items = {}
  for itemId, count in pairs(rec.loot or {}) do table.insert(items, { itemId, count }) end
  table.sort(items, function(a, b) return a[2] > b[2] end)
  if #items == 0 then
    row("", SOFT .. "Nothing taken from it yet.|r")
  else
    local perRow = math.floor((WIDTH + 6) / 40)
    for i, item in ipairs(items) do
      local b = lootButton(i)
      b.itemId = item[1]
      b.icon:SetTexture(itemIcon(item[1]) or QUESTION)
      local quality = itemQuality(item[1])
      local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
      if color then b.border:SetVertexColor(color.r, color.g, color.b) else b.border:SetVertexColor(0.6, 0.6, 0.6) end
      b.count:SetText(item[2] > 1 and item[2] or "")
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", page.child, "TOPLEFT", ((i - 1) % perRow) * 40, -(y + math.floor((i - 1) / perRow) * 40))
      b:Show()
    end
    y = y + math.ceil(#items / perRow) * 40
  end
  finish(y, keep)
end
ns.showCreature = showCreature

local function rerender()
  if not (current and book:IsShown()) then return end
  if currentCreature then showCreature(currentCreature, true) else showFamily(current, true) end
end

-- ── the list ─────────────────────────────────────────────────────────────────
local ROW_WIDTH = 204
local rows = {}
ns.listRows = rows -- for the tests
local function row(i)
  local r = rows[i]
  if r then return r end
  r = CreateFrame("Button", nil, list.child)
  r:SetSize(ROW_WIDTH, 18)
  r.text = label(r, BODY_FONT, 12, LIST.text)
  r.text:SetPoint("RIGHT", -28, 0)
  r.text:SetWordWrap(false)
  r.count = label(r, BODY_FONT, 10, LIST.soft)
  r.count:SetPoint("RIGHT", -4, 0)
  r.count:SetJustifyH("RIGHT")
  r.fold = r:CreateTexture(nil, "ARTWORK")
  r.fold:SetSize(12, 12)
  r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  r.selected = r:CreateTexture(nil, "BACKGROUND")
  r.selected:SetAllPoints()
  r.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
  r.selected:SetBlendMode("ADD")
  r.selected:SetAlpha(0.7)
  rows[i] = r
  return r
end

local function journalState(name)
  local j = ns.journal()
  if not j then return {} end
  j[name] = j[name] or {}
  return j[name]
end
-- Types fold (folded: collapsed[section id]); families unfold (open[family]).
local function folded() return journalState("collapsed") end
local function opened() return journalState("open") end
local function familyId(key) return type(key) == "number" and D.families[key].id or key end

local function nameMatches(id, query)
  local name = ns.journal().creatures[id].name
  return name ~= nil and name:lower():find(query, 1, true) ~= nil
end

local function plus(r, open)
  r.fold:SetTexture(open and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
end

function ns.refresh()
  if not book then return end
  if book.selectedTab == 3 then return ns.refreshMilestones() end
  if book.selectedTab == 2 then return ns.refreshAtlas and ns.refreshAtlas() end
  local creatures, families, slain = ns.counts()
  book.count:SetText(("%d creatures, %d families, %d slain"):format(creatures, families, slain))
  for _, r in ipairs(rows) do r:Hide() end
  local query = (book.search:GetText() or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  local searching = query ~= ""
  local by = ns.metByFamily()
  local journal = ns.journal()
  local i, y, selectedY = 0, 0, nil
  local function add(kind, text, count)
    i = i + 1
    local r = row(i)
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", 0, -y)
    r.kind = kind
    r.count:SetText(count and tostring(count) or "")
    r.text:SetText(text)
    r.fold:ClearAllPoints()
    r.selected:Hide()
    local height
    if kind == "section" then
      r.fold:SetPoint("LEFT", 2, 0)
      r.fold:Show()
      r.text:SetPoint("LEFT", 18, 0)
      r.text:SetFont(TITLE_FONT, 14, "")
      r.text:SetTextColor(unpack(LIST.gold))
      height = 22
    elseif kind == "family" then
      r.fold:SetPoint("LEFT", 10, 0)
      r.fold:Show()
      r.text:SetPoint("LEFT", 26, 0)
      r.text:SetFont(BODY_FONT, 12, "")
      r.text:SetTextColor(unpack(LIST.text))
      height = 18
    else
      r.fold:Hide()
      r.text:SetPoint("LEFT", 34, 0)
      r.text:SetFont(BODY_FONT, 11, "")
      r.text:SetTextColor(unpack(LIST.soft))
      height = 16
    end
    r:SetHeight(height)
    y = y + height
    r:Show()
    return r
  end
  local function select(r)
    r.selected:Show()
    r.text:SetTextColor(1, 1, 1)
    selectedY = y
  end

  -- Trophies first.
  local trophies = 0
  for _, rec in pairs(journal and journal.creatures or {}) do
    if rec.trophy then trophies = trophies + 1 end
  end
  if trophies > 0 and not searching then
    local r = add("family", "Trophies", trophies)
    r.fold:Hide()
    r.text:SetPoint("LEFT", 8, 0)
    r.text:SetTextColor(unpack(LIST.gold))
    r:SetScript("OnClick", function()
      showFamily(TROPHIES)
      ns.refresh()
    end)
    if current == TROPHIES then select(r) end
  end

  -- A family and, unfolded, its creatures.
  local function addFamily(key)
    local ids = by[key]
    local titleHit = searching and ns.familyTitle(key):lower():find(query, 1, true)
    local shownIds = {}
    for _, id in ipairs(sortedIds(ids)) do
      if not searching or titleHit or nameMatches(id, query) then table.insert(shownIds, id) end
    end
    if #shownIds == 0 then return end
    local open = searching or opened()[familyId(key)]
    local r = add("family", ns.familyTitle(key), #ids)
    plus(r, open)
    r.key = key
    r:SetScript("OnClick", function()
      -- The open family's row folds it; any other opens its page, unfolded.
      if current == key and not currentCreature and opened()[familyId(key)] then
        opened()[familyId(key)] = nil
      else
        opened()[familyId(key)] = true
        showFamily(key)
      end
      ns.refresh()
    end)
    if current == key and not currentCreature then select(r) end
    if not open then return end
    for _, id in ipairs(shownIds) do
      local rec = journal.creatures[id]
      local c = add("creature", (rec.name or ("Creature " .. id)) .. (rankOf(id, rec) and (" " .. LIST_SOFT .. "*|r") or ""))
      c.id = id
      c:SetScript("OnClick", function()
        showCreature(id)
        ns.refresh()
      end)
      if currentCreature == id then select(c) end
    end
  end

  local function addSection(id, title, keys)
    local shown = {}
    for _, key in ipairs(keys) do
      local hit = not searching or ns.familyTitle(key):lower():find(query, 1, true)
      if not hit then
        for _, cid in ipairs(by[key]) do
          if nameMatches(cid, query) then hit = true end
        end
      end
      if hit then table.insert(shown, key) end
    end
    if #shown == 0 then return end
    y = y + 4
    local r = add("section", title)
    plus(r, searching or not folded()[id])
    r:SetScript("OnClick", function()
      folded()[id] = not folded()[id] or nil
      ns.refresh()
    end)
    if searching or not folded()[id] then
      for _, key in ipairs(shown) do addFamily(key) end
    end
  end

  -- Families met, under their type; keys the data couldn't place (a type of
  -- another client's language) at the end.
  local placed = {}
  for _, section in ipairs(D.sections) do
    local keys = {}
    for index, family in ipairs(D.families) do
      if family.section == section.id and by[index] then
        table.insert(keys, index)
        placed[index] = true
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

  list.child:SetHeight(y + 8)
  list:UpdateThumb()
  -- Keep the selection in view (a link in chat may open a page far down).
  if selectedY then
    local top, height = list:GetVerticalScroll(), list:GetHeight()
    if selectedY - 18 < top or selectedY > top + height then list:ScrollTo(selectedY - height / 2) end
  end
  rerender()
end

-- ── the milestones ───────────────────────────────────────────────────────────
-- A second tab: one row per milestone, under its group's heading: the title
-- (gold once earned), what it asks, and on the right when it was earned, or
-- how far along it is (a bar).
local GROUPS = {
  { "tally", "Tallies" }, { "type", "Every Family" }, { "feat", "Feats" }, { "zone", "Rares by Zone" },
  { "travel", "Travels" }, { "explore", "Exploration" },
}
local M_ROW, M_WIDTH = 50, 700
local milestones
local mRows, mHeaders = {}, {}
local selectedMilestone

local function progressBar(parent)
  local b = CreateFrame("StatusBar", nil, parent)
  b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  b:SetStatusBarColor(0.85, 0.65, 0.13)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  return b
end

local function mRow(i)
  local r = mRows[i]
  if r then return r end
  r = CreateFrame("Frame", nil, milestones.child)
  r:SetSize(M_WIDTH, M_ROW - 4)
  r.bg = r:CreateTexture(nil, "BACKGROUND")
  r.bg:SetAllPoints()
  r.title = label(r, TITLE_FONT, 15, T.gold)
  r.title:SetPoint("TOPLEFT", 12, -7)
  r.text = label(r, BODY_FONT, 11, T.soft)
  r.text:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -5)
  r.text:SetWidth(500)
  r.status = label(r, BODY_FONT, 11, T.soft)
  r.status:SetPoint("TOPRIGHT", -12, -8)
  r.status:SetJustifyH("RIGHT")
  r.bar = progressBar(r)
  r.bar:SetSize(150, 5)
  r.bar:SetPoint("TOPRIGHT", r.status, "BOTTOMRIGHT", 0, -7)
  mRows[i] = r
  return r
end

local function mHeader(i)
  local h = mHeaders[i]
  if h then return h end
  h = CreateFrame("Frame", nil, milestones.child)
  h:SetSize(M_WIDTH, 26)
  h.text = label(h, TITLE_FONT, 17, T.gold)
  h.text:SetPoint("BOTTOMLEFT", 2, 5)
  h.line = rule(h)
  h.line:SetPoint("BOTTOMLEFT")
  h.line:SetPoint("BOTTOMRIGHT")
  mHeaders[i] = h
  return h
end
ns.milestoneRows = mRows -- for the tests

function ns.refreshMilestones()
  if not milestones then return end
  book.count:SetText(("%d of %d milestones"):format(ns.milestoneCount()))
  local i, y, selectedY = 0, 0, nil
  for g, group in ipairs(GROUPS) do
    local shown = {}
    for _, m in ipairs(ns.milestones) do
      if m.group == group[1] and ns.milestoneVisible(m) then table.insert(shown, m) end
    end
    local h = mHeader(g)
    h:SetShown(#shown > 0)
    if #shown > 0 then
      h:ClearAllPoints()
      h:SetPoint("TOPLEFT", 0, -y)
      h.text:SetText(group[2])
      y = y + 34
    end
    for _, m in ipairs(shown) do
      i = i + 1
      local r = mRow(i)
      r:ClearAllPoints()
      r:SetPoint("TOPLEFT", 0, -y)
      r.id = m.id
      if m.id == selectedMilestone then selectedY = y end
      local earned = ns.earnedMilestone(m.id)
      local done, need = m.progress()
      r.title:SetText(m.title)
      r.text:SetText(m.text)
      if earned then
        r.title:SetTextColor(unpack(T.gold))
        r.text:SetTextColor(unpack(T.text))
        r.status:SetText(("Level %d, %s"):format(earned.level or 0, date("%d %b %Y", earned.at or 0)))
        r.bar:Hide()
      else
        r.title:SetTextColor(0.55, 0.53, 0.50)
        r.text:SetTextColor(unpack(T.soft))
        r.status:SetText(("%d/%d"):format(math.min(done, need), need))
        r.bar:SetMinMaxValues(0, math.max(need, 1))
        r.bar:SetValue(math.min(done, need))
        r.bar:SetShown(need > 1)
      end
      if m.id == selectedMilestone then r.bg:SetColorTexture(0.85, 0.70, 0.42, 0.22)
      elseif earned then r.bg:SetColorTexture(0.85, 0.65, 0.13, 0.10)
      else r.bg:SetColorTexture(1, 1, 1, 0.03) end
      r:Show()
      y = y + M_ROW
    end
    if #shown > 0 then y = y + 12 end
  end
  for k = i + 1, #mRows do mRows[k]:Hide() end
  milestones.child:SetHeight(y)
  milestones:UpdateThumb()
  -- A milestone opened from chat or its alert: bring it into view.
  if selectedY then
    local height = milestones:GetHeight()
    milestones:SetVerticalScroll(math.min(math.max(0, y - height), math.max(0, selectedY - (height - M_ROW) / 2)))
    milestones:UpdateThumb()
  end
end

local function buildMilestones()
  book.milestonePanel = ns.forever and card(book) or inset(book)
  book.milestonePanel:SetPoint("TOPLEFT", book.left, "TOPLEFT")
  book.milestonePanel:SetPoint("BOTTOMRIGHT", book.sheet, "BOTTOMRIGHT")
  milestones = scrollArea(book.milestonePanel, M_WIDTH)
  _G.FieldJournalMilestones = milestones
  milestones:SetPoint("TOPLEFT", 22, -18)
  milestones:SetPoint("BOTTOMRIGHT", -22, 14)
  book.milestonePanel:Hide()
end

-- The book's two tabs, under its bottom edge, in the style of the character
-- sheet's (the shared panel tabs where that template doesn't exist: Forever).
-- The tabs: 1 the Bestiary, 2 the Atlas (AtlasBook.lua: its own list and
-- page in the same panels), 3 the Milestones.
function ns.showTab(n)
  if not book then return end
  book.selectedTab = n
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, n) end
  if n == 2 and not rawget(book, "atlasList") and ns.buildAtlasBook then ns.buildAtlasBook(book) end
  book.left:SetShown(n ~= 3)
  book.sheet:SetShown(n ~= 3)
  book.search:SetShown(n ~= 3) -- the Bestiary's and the Atlas's
  list:SetShown(n == 1)
  page:SetShown(n == 1)
  if rawget(book, "atlasList") then
    book.atlasList:SetShown(n == 2)
    book.atlasPage:SetShown(n == 2)
  end
  book.milestonePanel:SetShown(n == 3)
  ns.refresh()
end

local function hasTemplate(name)
  if not (C_XMLUtil and C_XMLUtil.GetTemplateInfo) then return name == "CharacterFrameTabButtonTemplate" end
  return C_XMLUtil.GetTemplateInfo(name) ~= nil
end

local function buildTabs()
  local template = hasTemplate("CharacterFrameTabButtonTemplate") and "CharacterFrameTabButtonTemplate" or "PanelTabButtonTemplate"
  for n, text in ipairs({ "Bestiary", "Atlas", "Milestones" }) do
    local tab = CreateFrame("Button", "FieldJournalFrameTab" .. n, book, template)
    tab:SetID(n)
    tab:SetText(text)
    if n == 1 then tab:SetPoint("TOPLEFT", book, "BOTTOMLEFT", 14, 2)
    else tab:SetPoint("LEFT", "FieldJournalFrameTab" .. (n - 1), "RIGHT", -14, 0) end
    tab:SetScript("OnClick", function(self)
      selectedMilestone = nil
      ns.showTab(self:GetID())
      if PlaySound and SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB) end
    end)
    tab:SetScript("OnShow", function(self)
      if PanelTemplates_TabResize then PanelTemplates_TabResize(self, 0) end
    end)
    if PanelTemplates_TabResize then PanelTemplates_TabResize(tab, 0) end
  end
  if PanelTemplates_SetNumTabs then PanelTemplates_SetNumTabs(book, 3) end
  book.selectedTab = 1
  if PanelTemplates_SetTab then PanelTemplates_SetTab(book, 1) end
end

-- Open the book at the milestones, one of them picked out.
function ns.openMilestones(id)
  if not book then build() end
  selectedMilestone = id
  if not book:IsShown() then book:Show() end
  ns.showTab(3)
end

-- ── the book ─────────────────────────────────────────────────────────────────
-- Forever: a standard game window (portrait, title bar), its inset removed.
local TITLE = "Explorer's Field Journal: the Bestiary"
local function gameWindow()
  local ok, frame = pcall(CreateFrame, "Frame", "FieldJournalFrame", UIParent, "ButtonFrameTemplate")
  if not ok or not frame then return nil end
  if ButtonFrameTemplate_HideButtonBar then ButtonFrameTemplate_HideButtonBar(frame) end
  if type(frame.Inset) == "table" then frame.Inset:Hide() end
  local art = "Interface\\Icons\\INV_Misc_Book_11"
  if frame.SetPortraitToAsset then frame:SetPortraitToAsset(art)
  elseif type(frame.portrait) == "table" then frame.portrait:SetTexture(art) end
  if frame.SetTitle then frame:SetTitle(TITLE)
  elseif type(frame.TitleText) == "table" then frame.TitleText:SetText(TITLE) end
  return frame
end

function build()
  local window = gameWindow()
  book = window or CreateFrame("Frame", "FieldJournalFrame", UIParent, "BackdropTemplate")
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
  tinsert(UISpecialFrames, "FieldJournalFrame") -- Escape closes it

  book.count = label(book, BODY_FONT, 11, LIST.gold)
  book.search = CreateFrame("EditBox", "FieldJournalSearch", book, "SearchBoxTemplate")
  book.search:SetHeight(20)
  book.search:HookScript("OnTextChanged", function() ns.refresh() end)

  if not window then
    -- No standard window on this client: a plain dialog frame.
    book:SetBackdrop({
      bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
      tile = true, tileSize = 32, edgeSize = 32,
      insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    local title = label(book, TITLE_FONT, 16, LIST.gold)
    title:SetPoint("TOP", 0, -16)
    title:SetText(TITLE)
    local close = CreateFrame("Button", nil, book, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -6, -6)
  end
  -- The count beside the portrait; the list's column below it, the page to
  -- the right, under the title bar.
  local edge = window and 8 or 14
  book.count:SetPoint("TOPLEFT", 64, -36)
  local left = ns.forever and card(book) or inset(book, true)
  book.left = left
  left:SetPoint("TOPLEFT", edge, -58)
  left:SetPoint("BOTTOMLEFT", edge, edge)
  left:SetWidth(244)
  local sheet = ns.forever and card(book) or inset(book)
  book.sheet = sheet
  sheet:SetPoint("TOPLEFT", left, "TOPRIGHT", 4, 32)
  sheet:SetPoint("BOTTOMRIGHT", -edge, edge)
  -- The search box inside the list's column (its left edge holds the glass).
  book.search:SetPoint("TOPLEFT", left, "TOPLEFT", 18, -10)
  book.search:SetPoint("TOPRIGHT", left, "TOPRIGHT", -12, -10)

  list = scrollArea(left, ROW_WIDTH)
  list:SetPoint("TOPLEFT", left, "TOPLEFT", 12, -40)
  list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -18, 12)

  page = scrollArea(sheet, WIDTH)
  _G.FieldJournalPage = page
  page:SetPoint("TOPLEFT", sheet, "TOPLEFT", 26, -22)
  page:SetPoint("BOTTOMRIGHT", sheet, "BOTTOMRIGHT", -22, 14)

  -- The header: portrait, title, a line (on a creature's page, its family:
  -- a click opens the family's page).
  page.portrait = roundPortrait(page.child, 64)
  page.portrait:SetPoint("TOPLEFT", 2, -2)
  page.title = label(page.child, TITLE_FONT, 24, T.gold)
  page.title:SetPoint("TOPLEFT", page.portrait, "TOPRIGHT", 16, -8)
  page.title:SetWidth(WIDTH - 86)
  page.title:SetWordWrap(false)
  page.sub = label(page.child, BODY_FONT, 12, T.soft)
  page.sub:SetPoint("TOPLEFT", page.title, "BOTTOMLEFT", 0, -7)
  page.sub:SetWidth(WIDTH - 86)
  page.familyLink = CreateFrame("Button", nil, page.child)
  page.familyLink:SetAllPoints(page.sub)
  page.familyLink:SetScript("OnClick", function(self)
    if self.key then ns.openFamily(self.key) end
  end)
  local headerRule = rule(page.child)
  headerRule:SetPoint("TOPLEFT", 0, -76)
  headerRule:SetPoint("TOPRIGHT", 0, -76)

  page.body = label(page.child, BODY_FONT, 13, T.text)
  page.body:SetPoint("TOPLEFT", 0, -HEADER_H)
  page.body:SetWidth(WIDTH)
  page.body:SetSpacing(4)
  page.empty = label(page.child, BODY_FONT, 12, T.soft)

  book:SetScript("OnShow", function()
    if not current then
      -- First opening: the most recently met family.
      local journal, latest, at = ns.journal(), nil, -1
      for key, f in pairs(journal and journal.families or {}) do
        if (f.at or 0) > at then latest, at = key, f.at or 0 end
      end
      current = latest
      if current then opened()[familyId(current)] = true end
    end
    if currentCreature then showCreature(currentCreature)
    elseif current then showFamily(current)
    else
      clear()
      header("The Bestiary", nil, icon("Interface\\Icons\\INV_Misc_Book_11"))
      page.body:SetText(SOFT .. "Nothing recorded yet. Target or mouse over a creature of the wild, and it will be written here.|r")
      page.body:Show()
    end
    ns.refresh()
  end)

  buildMilestones()
  buildTabs()
end

function ns.toggle()
  if not book then build() end
  book:SetShown(not book:IsShown())
end

local function open(show)
  if not book then build() end
  if book.selectedTab ~= 1 then ns.showTab(1) end
  if book:IsShown() then
    show()
    ns.refresh()
  else
    book:Show()
  end
end

-- Open the book at a family (fieldjournal:<family index> or
-- fieldjournal:?<type>/<family>), unfolded in the list.
function ns.openFamily(key)
  if not book then build() end
  current, currentCreature = key, nil
  opened()[familyId(key)] = true
  open(function() showFamily(key) end)
end

-- Open the book at a creature's page (fieldjournal:c<creature id>).
function ns.openCreature(id)
  local journal = ns.journal()
  local rec = journal and journal.creatures[id]
  if not rec then return end
  if not book then build() end
  current, currentCreature = ns.familyKey(id, rec), id
  opened()[familyId(current)] = true
  open(function() showCreature(id) end)
end

local function followLink(link)
  local key = link:match("^fieldjournal:(.+)$")
  if not key then return end
  local milestone = key:match("^m(.+)$")
  if milestone then return ns.openMilestones(milestone) end
  local zone = tonumber(key:match("^z(%d+)$"))
  if zone then return ns.openZone and ns.openZone(zone) end
  local creature = tonumber(key:match("^c(%d+)$"))
  if creature then
    ns.openCreature(creature)
  else
    ns.openFamily(tonumber(key) or key)
  end
end
if LinkUtil and LinkUtil.RegisterLinkHandler then
  LinkUtil.RegisterLinkHandler("fieldjournal", function(link)
    followLink(link)
    return LinkProcessorResponse and LinkProcessorResponse.Handled
  end)
elseif hooksecurefunc and SetItemRef then
  hooksecurefunc("SetItemRef", function(link) followLink(link) end)
end

-- What's recorded while the book is open shows up at once (throttled: meeting
-- creatures happens constantly).
local pending = false
ns.onRecord = function()
  if not (book and book:IsShown()) or pending then return end
  pending = true
  local function run()
    pending = false
    ns.refresh()
  end
  if C_Timer then C_Timer.After(0.5, run) else run() end
end
ns.onMilestone = ns.onRecord
ns.onAtlas = ns.onRecord

-- The book's look, for the Atlas's pages (AtlasBook.lua).
ns.ui = {
  T = T, TITLE_FONT = TITLE_FONT, BODY_FONT = BODY_FONT, WIDTH = WIDTH, HEADER_H = HEADER_H, SOFT = SOFT,
  label = label, rule = rule, roundPortrait = roundPortrait, scrollArea = scrollArea, icon = icon,
  book = function() return book end, build = function() if not book then build() end return book end,
}
