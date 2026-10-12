-- The game's own toasts (its alert system), each kind queued on its own, so
-- a deed that earns two shows both, side by side, never one in place of the
-- other: a milestone earned, the achievement's toast with the journal's book;
-- a riddle solved or a quarry brought down, the toast of "New Recipe
-- Learned", with what the riddle led to (its keeper's face, a book, a place)
-- or the quarry's face, and the seal earned as a medal on it. A click opens
-- the book there, a right-click dismisses it. Where the client lacks one,
-- or the game's toast fails to set up (the error said once in chat), a card
-- of the journal's own takes its place, in the book's look, at the top of the
-- screen. Turned off by the alerts setting; /journal toast shows one.
local _, ns = ...
local PREFIX = ns.PREFIX

local BOOK = "Interface\\AddOns\\FieldJournal\\Media\\Logo"
local MILESTONE, FIND = "AchievementAlertFrameTemplate", "NewRecipeLearnedAlertFrameTemplate"
local systems = {}

-- The achievement toast's points shield runs AchievementShield_OnLoad, from
-- the game's achievement window, loaded on demand. Classic Era has no such
-- window, and Forever's (its own game type) doesn't define it: any achievement
-- toast then warns, ours and the game's own alike, the first one before ours
-- had a chance to help. So at load, where the game hasn't defined it, a
-- stand-in does what it does (the shield's two methods); the game's own
-- replaces it whenever its window loads.
if not AchievementShield_OnLoad then
  -- selene: allow(unused_variable)
  function AchievementShield_OnLoad(self)
    self.Desaturate = AchievementShield_Desaturate or function() end
    self.Saturate = AchievementShield_Saturate or function() end
  end
end

local function onClick(self, button, down)
  if AlertFrame_OnClick and AlertFrame_OnClick(self, button, down) then return end -- right-click: dismissed
  local kind, id = self.journalKind, self.journalId
  if kind == "milestone" then
    ns.openMilestones(id)
  elseif kind == "riddle" then
    ns.openRiddle(id)
  elseif kind == "quarry" then
    ns.openQuarry(id)
  end
end

local function setUpMilestone(frame, id)
  frame.journalKind, frame.journalId = "milestone", id
  frame.Icon.Texture:SetTexture(BOOK)
  frame.Unlocked:SetText("Field Journal milestone")
  frame.Name:SetText(ns.milestoneById[id].title)
  frame.Shield:Hide() -- no points
  frame:SetScript("OnClick", onClick)
end

-- Round, as the book's pictures: a mask texture (Texture:SetMask, the recipe
-- toast's own way, forbids changing the crop afterwards on Forever).
local function round(frame)
  if frame.journalMask or not frame.CreateMaskTexture then return end
  frame.journalMask = frame:CreateMaskTexture()
  frame.journalMask:SetTexture(
    "Interface\\CharacterFrame\\TempPortraitAlphaMask",
    "CLAMPTOBLACKADDITIVE",
    "CLAMPTOBLACKADDITIVE"
  )
  frame.journalMask:SetAllPoints(frame.Icon)
  frame.Icon:AddMaskTexture(frame.journalMask)
end

-- The seal's medal on the toast's picture: its coin, round, in a ring of its
-- colour, at the picture's lower right.
local function medal(frame, seal)
  if not rawget(frame, "journalMedal") then
    local ring = frame:CreateTexture(nil, "OVERLAY", nil, 6)
    ring:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    ring:SetSize(22, 22)
    ring:SetPoint("CENTER", frame.Icon, "BOTTOMRIGHT", -5, 5)
    local coin = frame:CreateTexture(nil, "OVERLAY", nil, 7)
    coin:SetSize(18, 18)
    coin:SetPoint("CENTER", ring)
    if frame.CreateMaskTexture then
      local mask = frame:CreateMaskTexture()
      mask:SetTexture(
        "Interface\\CharacterFrame\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
      )
      mask:SetAllPoints(coin)
      coin:AddMaskTexture(mask)
    end
    frame.journalMedal = { ring = ring, coin = coin }
  end
  local m = frame.journalMedal
  m.ring:SetShown(seal ~= nil)
  m.coin:SetShown(seal ~= nil)
  if seal then
    m.ring:SetVertexColor(unpack(seal[4]))
    m.coin:SetTexture(seal[1])
    m.coin:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  end
end

-- What a page's picture setter draws, drawn on the toast's icon instead.
local function picture(frame, setter)
  frame.Icon:SetVertexColor(1, 1, 1)
  if frame.Icon.SetDesaturated then frame.Icon:SetDesaturated(false) end
  setter({ tex = frame.Icon })
end

local function setUpFind(frame, kind, id)
  frame.journalKind, frame.journalId = kind, id -- (a toast frame is used again: never left as it was)
  round(frame)
  if kind == "riddle" then
    local r = ns.riddleById[id]
    picture(frame, ns.riddlePicture(r))
    medal(frame, ns.SEALS[ns.riddleSeal(ns.riddleRecord(id))])
    frame.Title:SetText("A riddle read aright")
    frame.Name:SetText(ns.riddleName(r))
  else
    local q = ns.quarryById[id]
    picture(frame, ns.quarryPicture(q))
    local seal = ns.HUNT_SEALS[ns.huntSeal(ns.huntRecord(id))]
    medal(frame, seal[1] and seal or nil)
    frame.Title:SetText("A quarry brought down")
    frame.Name:SetText(q.name)
  end
  frame:SetScript("OnClick", onClick)
end

-- The toast system of a template, made on first use where the client has it.
local function system(template, setUp)
  if systems[template] == nil then
    systems[template] = false
    if
      AlertFrame
      and AlertFrame.AddQueuedAlertFrameSubSystem
      and C_XMLUtil
      and C_XMLUtil.GetTemplateInfo
      and C_XMLUtil.GetTemplateInfo(template)
    then
      systems[template] = AlertFrame:AddQueuedAlertFrameSubSystem(template, setUp, 2, 6)
    end
  end
  return systems[template]
end

-- ── the journal's own card, where the game's toast can't be ─────────────────
-- A card at the top of the screen: the picture (its medal), a short line, the
-- name; a click opens the book there, its cross or a right-click dismisses it.
-- One at a time: the others wait their turn. Gone after a few seconds, never
-- while the mouse is on it.
local WIDTH, HEIGHT, SECONDS = 380, 66, 8
local card, waiting, timer = nil, {}, nil
local showNext

local function dismiss()
  if timer then timer:Cancel() end
  timer = nil
  if card then card:Hide() end
  if #waiting > 0 then showNext() end
end

local function startTimer(seconds)
  if timer then timer:Cancel() end
  if not C_Timer then return end
  timer = C_Timer.NewTimer(seconds, function()
    timer = nil
    if card:IsMouseOver() then
      startTimer(1)
    else
      dismiss()
    end
  end)
end

local function build()
  local ui = ns.ui
  card = CreateFrame("Button", "FieldJournalBanner", UIParent, "BackdropTemplate")
  card:SetSize(WIDTH, HEIGHT)
  card:SetPoint("TOP", 0, -120)
  card:SetFrameStrata("HIGH")
  card:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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
    card:SetBackdropColor(0.04, 0.05, 0.035, 0.95)
    card:SetBackdropBorderColor(unpack(ui.T.ring))
  end
  local body = CreateFrame("Frame", nil, card)
  body:SetAllPoints()
  body:SetFrameLevel(card:GetFrameLevel() + 4)
  card.picture = ui.roundPortrait(body, 42)
  card.picture:SetPoint("LEFT", 14, 0)
  card.medal = ui.badge(card.picture, 18)
  card.kicker = ui.label(body, ui.BODY_FONT, 11, ui.T.soft)
  card.kicker:SetPoint("TOPLEFT", card.picture, "TOPRIGHT", 14, -2)
  card.name = ui.label(body, ui.TITLE_FONT, 18, ui.T.gold)
  card.name:SetPoint("TOPLEFT", card.kicker, "BOTTOMLEFT", 0, -4)
  card.name:SetPoint("RIGHT", -30, 0)
  card.name:SetWordWrap(false)
  card.close = CreateFrame("Button", nil, body, "UIPanelCloseButton")
  card.close:SetSize(24, 24)
  card.close:SetPoint("TOPRIGHT", -3, -3)
  card.close:SetScript("OnClick", dismiss)
  card:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
  card:SetScript("OnClick", function(self, button)
    local kind, id = self.journalKind, self.journalId
    dismiss()
    if button == "RightButton" then return end
    if kind == "milestone" then
      ns.openMilestones(id)
    elseif kind == "riddle" then
      ns.openRiddle(id)
    elseif kind == "quarry" then
      ns.openQuarry(id)
    end
  end)
  card:Hide()
end

-- What a toast of this kind shows: { picture setter, its seal, a line, a name }.
local function content(kind, id)
  local ui = ns.ui
  if kind == "milestone" then
    return ui.icon(BOOK), nil, "Field Journal milestone", ns.milestoneById[id].title
  elseif kind == "riddle" then
    local r = ns.riddleById[id]
    return ns.riddlePicture(r), ns.SEALS[ns.riddleSeal(ns.riddleRecord(id))], "A riddle read aright", ns.riddleName(r)
  end
  local q = ns.quarryById[id]
  local seal = ns.HUNT_SEALS[ns.huntSeal(ns.huntRecord(id))]
  return ns.quarryPicture(q), seal[1] and seal or nil, "A quarry brought down", q.name
end

showNext = function()
  local next = table.remove(waiting, 1)
  if not next then return end
  if not card then build() end
  local ok, pic, seal, kicker, name = pcall(content, next[1], next[2])
  if not ok then
    pic, seal, kicker, name = ns.ui.icon(BOOK), nil, "Explorer's Field Journal", ""
  end
  card.journalKind, card.journalId = next[1], next[2]
  card.picture.tex:SetVertexColor(1, 1, 1)
  card.picture.tex:SetDesaturated(false)
  if not pcall(pic, card.picture) then ns.ui.icon(BOOK)(card.picture) end
  ns.ui.setBadge(card.medal, seal)
  card.kicker:SetText(kicker)
  card.name:SetText(name)
  card:Show()
  startTimer(SECONDS)
end

local function ownCard(kind, id)
  table.insert(waiting, { kind, id })
  if not (card and card:IsShown()) then showNext() end
end

-- The game's toast set up safely: an error (said once) gives way to the
-- journal's own card.
local failed
local function safely(setUp, kindOf)
  return function(frame, ...)
    local ok, err = pcall(setUp, frame, ...)
    if ok then return end
    if not failed then
      failed = true
      print(
        PREFIX
          .. ("the game's alert could not be set up (%s): the journal shows its own card instead."):format(
            tostring(err)
          )
      )
    end
    local kind, id = kindOf(...)
    ownCard(kind, id)
    return false
  end
end
local function milestoneOf(id) return "milestone", id end
local function findOf(kind, id) return kind, id end

-- A toast: ("milestone", its id), ("riddle", its id), ("quarry", its creature id).
function ns.toast(kind, id)
  if not ns.option("milestoneToast") then return end
  local s
  if kind == "milestone" then
    s = system(MILESTONE, safely(setUpMilestone, milestoneOf))
    if s then return s:AddAlert(id) end
  else
    s = system(FIND, safely(setUpFind, findOf))
    if s then return s:AddAlert(kind, id) end
  end
  ownCard(kind, id)
end

-- /journal toast: the last riddle solved (else any of this character's), as
-- its toast would show it, and which toast the client gave.
function ns.toastTest()
  local best, at
  for id, r in pairs(ns.riddleById) do
    local rec = ns.riddleRecord(id)
    if ns.riddleOpen(r) and (not best or (rec and rec.at or 0) > at) then
      best, at = id, rec and rec.at or 0
    end
  end
  if not best then
    print(PREFIX .. "no riddle in this game to show.")
    return
  end
  local game = system(FIND, safely(setUpFind, findOf))
  print(
    PREFIX
      .. (
        game and "a riddle's alert, the game's toast (%s)."
        or "a riddle's alert: the journal's own card (the game has no %s)."
      ):format(FIND)
  )
  if game then
    game:AddAlert("riddle", best)
  else
    ownCard("riddle", best)
  end
end
