-- A riddle or a quarry pinned to the screen: a small card of its own, in the
-- book's look, that stays while the reader goes looking. It shows the verse
-- (and the clue or the map, once asked for), and once solved or brought down
-- its seal; dragged anywhere (kept where it was left, per character), closed
-- by its cross; a click opens the book there. One at a time: pinning another
-- replaces it. The book's pages pin and unpin (ns.pin); the record keeps it
-- (Expeditions.lua: pinned, pinAt).
local _, ns = ...
local ui = ns.ui
local T = ui.T
local WIDTH, PAD = 280, 14
local NOTE = "Interface\\Icons\\INV_Misc_Note_02"
local TIERS = { near = "Near the road", off = "Off the road", hidden = "Hidden", town = "In town" }
local card

function ns.pinned()
  local e = ns.journal() and ns.expeditions()
  return e and e.pinned
end

-- What a key names: the riddle, or the quarry ("quarry:<id>"), if this
-- character may have it.
local function subject(key)
  if type(key) ~= "string" then return end
  local qid = tonumber(key:match("^quarry:(%d+)$"))
  if qid then
    local q = ns.quarryById[qid]
    return nil, q and ns.quarryOpen(q) and q or nil
  end
  local r = ns.riddleById[key]
  return r and ns.riddleOpen(r) and r or nil
end

local function save()
  local e = ns.expeditions()
  local point, _, relative, x, y = card:GetPoint(1)
  if e and point then e.pinAt = { point, relative, x, y } end
end

local function place()
  local e = ns.expeditions()
  local at = e and e.pinAt
  card:ClearAllPoints()
  if at then
    card:SetPoint(at[1], UIParent, at[2], at[3], at[4])
  else
    card:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -240, -220)
  end
end

local function build()
  card = CreateFrame("Button", "FieldJournalPinnedCard", UIParent, "BackdropTemplate")
  card:SetWidth(WIDTH)
  card:SetFrameStrata("MEDIUM")
  card:SetClampedToScreen(true)
  card:SetMovable(true)
  card:EnableMouse(true)
  card:RegisterForDrag("LeftButton")
  if ns.forever then
    card.art = ui.panel(card)
    card.art:SetAllPoints()
  else
    card:SetBackdrop({
      bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    card:SetBackdropColor(0.04, 0.05, 0.035, 0.92)
    card:SetBackdropBorderColor(unpack(T.ring))
  end
  -- (what it shows, above its art)
  local body = CreateFrame("Frame", nil, card)
  body:SetAllPoints()
  body:SetFrameLevel(card:GetFrameLevel() + 4)
  card.body = body
  card.picture = ui.roundPortrait(body, 32)
  card.picture:SetPoint("TOPLEFT", PAD, -PAD)
  card.title = ui.label(body, ui.TITLE_FONT, 15, T.gold)
  card.title:SetPoint("TOPLEFT", card.picture, "TOPRIGHT", 10, -1)
  card.title:SetPoint("RIGHT", -28, 0)
  card.title:SetWordWrap(false)
  card.sub = ui.label(body, ui.BODY_FONT, 11, T.soft)
  card.sub:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -4)
  card.sub:SetPoint("RIGHT", -28, 0)
  card.sub:SetWordWrap(false)
  card.verse = ui.label(body, ui.BODY_FONT, 12, T.text)
  card.verse:SetPoint("TOPLEFT", PAD, -(PAD + 42))
  card.verse:SetWidth(WIDTH - 2 * PAD)
  card.verse:SetSpacing(3)
  card.extra = ui.label(body, ui.BODY_FONT, 11, T.soft)
  card.extra:SetPoint("TOPLEFT", card.verse, "BOTTOMLEFT", 0, -8)
  card.extra:SetWidth(WIDTH - 2 * PAD)
  card.extra:SetSpacing(2)
  card.close = CreateFrame("Button", nil, body, "UIPanelCloseButton")
  card.close:SetSize(24, 24)
  card.close:SetPoint("TOPRIGHT", -3, -3)
  card.close:SetScript("OnClick", function() ns.pin(nil) end)

  card:SetScript("OnDragStart", function(self) self:StartMoving() end)
  card:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if self.SetUserPlaced then self:SetUserPlaced(false) end
    save()
  end)
  card:SetScript("OnClick", function(self)
    if self.riddle then
      ns.openRiddle(self.riddle)
    elseif self.quarry then
      ns.openQuarry(self.quarry)
    end
  end)
  card:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine("Explorer's Field Journal", T.accent[1], T.accent[2], T.accent[3])
    GameTooltip:AddLine("Click to open it in the journal; drag to move it.", 1, 1, 1, true)
    GameTooltip:Show()
  end)
  card:SetScript("OnLeave", function() GameTooltip:Hide() end)
  card:Hide()
  place()
end

local function seal(name, color)
  return ("|cff%02x%02x%02x%s|r"):format(color[1] * 255, color[2] * 255, color[3] * 255, name)
end
local SEAL_COLORS = { gold = { 1, 0.82, 0 }, silver = { 0.78, 0.8, 0.84 }, plain = { 0.8, 0.55, 0.35 } }

local function fill(r, q)
  card.riddle, card.quarry = r and r.id, q and q.id
  local extra = {}
  if r then
    local rec = ns.riddleRecord(r.id) or {}
    if rec.at then
      local s = ns.riddleSeal(rec)
      ui.icon(ns.SEAL_ICON[s])(card.picture)
      card.title:SetText(ns.riddleName(r))
      table.insert(extra, ("Read, with the %s."):format(seal(s .. " seal", SEAL_COLORS[s])))
    else
      ui.icon(NOTE)(card.picture)
      card.title:SetText(TIERS[r.tier])
      if (rec.hints or 0) >= 1 then table.insert(extra, "The clue: " .. r.hint) end
      if (rec.hints or 0) >= 2 then table.insert(extra, "Its place is shaded on your world map.") end
    end
    card.sub:SetText(ns.zoneName(r.zone) .. (r.night and "  -  by night" or ""))
    card.verse:SetText(table.concat(r.verse, "\n"))
  else
    local rec = ns.huntRecord(q.id) or {}
    local display = ns.quarryDisplay(q)
    if display and SetPortraitTextureFromCreatureDisplayID then
      card.picture.tex:SetTexCoord(0, 1, 0, 1)
      SetPortraitTextureFromCreatureDisplayID(card.picture.tex, display)
    else
      ui.icon(NOTE)(card.picture)
    end
    card.title:SetText(q.name)
    card.sub:SetText(ns.zoneName(q.zone) .. "  -  the quarry")
    card.verse:SetText(table.concat(q.verse, "\n"))
    if rec.at then
      local s = ns.huntSeal(rec)
      table.insert(
        extra,
        s == "before" and "Brought down before the journal kept the hunts."
          or ("Brought down, with the %s."):format(seal(s .. " seal", SEAL_COLORS[s]))
      )
    else
      local target = ns.huntTarget()
      if target and target.id == q.id then table.insert(extra, "Its haunts are shaded on your world map.") end
    end
  end
  card.extra:SetText(table.concat(extra, "\n"))
  local h = PAD + 42 + card.verse:GetStringHeight() + PAD
  if #extra > 0 then h = h + 8 + card.extra:GetStringHeight() end
  card:SetHeight(h)
end

-- The card as the record has it: shown with what is pinned, else hidden.
function ns.refreshPin()
  local r, q = subject(ns.pinned())
  if not (r or q) then
    if card then card:Hide() end
    return
  end
  if not card then build() end
  fill(r, q)
  card:Show()
end

-- Pinned (a riddle's id, "quarry:<id>"), or nothing (nil).
function ns.pin(key)
  local e = ns.expeditions()
  if not e then return end
  e.pinned = key
  ns.refreshPin()
  ns.onRecord()
end

-- What changes the record changes the card.
local onRecord = ns.onRecord
ns.onRecord = function(...)
  if onRecord then onRecord(...) end
  ns.refreshPin()
end
