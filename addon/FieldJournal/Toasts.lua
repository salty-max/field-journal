-- The game's own toasts (its alert system), each kind queued on its own, so
-- a deed that earns two shows both, side by side, never one in place of the
-- other: a milestone earned, the achievement's toast with the journal's book;
-- a riddle solved or a quarry brought down, the toast of "New Recipe
-- Learned", with the riddle's seal or the quarry's portrait. A click opens
-- the book there, a right-click dismisses it. Nothing where the client lacks
-- them (the chat line and the sound stay); turned off by the alerts setting.
local _, ns = ...

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

local function setUpFind(frame, kind, id)
  frame.journalKind, frame.journalId = kind, id -- (a toast frame is used again: never left as it was)
  round(frame)
  if kind == "riddle" then
    local r = ns.riddleById[id]
    frame.Icon:SetTexture(ns.SEAL_ICON[ns.riddleSeal(ns.riddleRecord(id))])
    frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.Title:SetText("A riddle read aright")
    frame.Name:SetText(ns.riddleName(r))
  else
    local q = ns.quarryById[id]
    local display = ns.quarryDisplay(q)
    if display and SetPortraitTextureFromCreatureDisplayID then
      frame.Icon:SetTexCoord(0, 1, 0, 1)
      SetPortraitTextureFromCreatureDisplayID(frame.Icon, display)
    else
      frame.Icon:SetTexture(BOOK)
      frame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
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

-- A toast: ("milestone", its id), ("riddle", its id), ("quarry", its creature id).
function ns.toast(kind, id)
  if not ns.option("milestoneToast") then return end
  if kind == "milestone" then
    local s = system(MILESTONE, setUpMilestone)
    if s then s:AddAlert(id) end
  else
    local s = system(FIND, setUpFind)
    if s then s:AddAlert(kind, id) end
  end
end
