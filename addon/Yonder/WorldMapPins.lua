-- The Atlas on the game's own world map: where this character died (a skull)
-- and came close (a yellow mark), on the zone's map, with a tooltip; the
-- place of each riddle whose map was asked for, still unsolved (a shaded
-- circle, wider than the spot and never centred on it), and the haunts of the
-- quarry tracked. A data provider, as
-- the game's own map layers; the setting worldMapPins turns the marks off
-- (never a hint asked for).
local _, ns = ...

local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"
local SIZE = 22 -- in the map canvas's units (the map art is about 1000 wide)
local CIRCLE = "Interface\\AddOns\\Yonder\\Media\\Circle"

local provider

local function pin(i)
  local p = provider.pins[i]
  if p then return p end
  p = CreateFrame("Button", nil, provider:GetMap():GetCanvas())
  p:SetSize(SIZE, SIZE)
  p.icon = p:CreateTexture(nil, "OVERLAY")
  p.icon:SetAllPoints()
  p:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(self.title, 1, 0.82, 0)
    GameTooltip:AddLine(self.text, 1, 1, 1, true)
    GameTooltip:AddLine("Yonder", 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  p:SetScript("OnLeave", function() GameTooltip:Hide() end)
  provider.pins[i] = p
  return p
end

-- A riddle's circle: under the marks, its verse's first line on hover.
local function circle(i)
  local c = provider.circles[i]
  if c then return c end
  c = CreateFrame("Frame", nil, provider:GetMap():GetCanvas())
  c.tex = c:CreateTexture(nil, "ARTWORK")
  c.tex:SetAllPoints()
  c.tex:SetTexture(CIRCLE)
  c.tex:SetVertexColor(0.95, 0.8, 0.35, 0.55)
  -- (hovered for its tooltip, never in the way of a click on the map)
  if c.SetMouseClickEnabled then
    c:SetMouseMotionEnabled(true)
    c:SetMouseClickEnabled(false)
  end
  c:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddLine(self.title, 1, 0.82, 0)
    GameTooltip:AddLine(self.text, 1, 1, 1, true)
    GameTooltip:AddLine("Yonder", 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  c:SetScript("OnLeave", function() GameTooltip:Hide() end)
  provider.circles[i] = c
  return c
end

local function line(e)
  return ("%s, level %d%s"):format(date("%d %b %Y", e.at or 0), e.level or 0, e.by and (" - " .. e.by) or "")
end

local function create()
  provider = CreateFromMixins(MapCanvasDataProviderMixin)
  provider.pins, provider.circles = {}, {}
  function provider:RemoveAllData()
    for _, p in ipairs(self.pins) do
      p:Hide()
    end
    for _, c in ipairs(self.circles) do
      c:Hide()
    end
  end
  function provider:RefreshAllData()
    self:RemoveAllData()
    local atlas = ns.atlas and ns.atlas()
    local map = self:GetMap()
    local mapID = map:GetMapID()
    local canvas = map:GetCanvas()
    if not (atlas and mapID and canvas) then return end
    local w, h = canvas:GetWidth(), canvas:GetHeight()
    -- the riddles' circles (x, y, r: percent of the map's width)
    local k = 0
    for _, r in ipairs(ns.riddlesOf(mapID)) do
      local rec = ns.riddleRecord(r.id)
      if rec and (rec.hints or 0) >= 2 and not rec.at then
        k = k + 1
        local c = circle(k)
        local size = 2 * r.circle[3] / 100 * w
        c:SetSize(size, size)
        c:SetFrameLevel(canvas:GetFrameLevel() + 1990)
        c:ClearAllPoints()
        c:SetPoint("CENTER", canvas, "TOPLEFT", r.circle[1] / 100 * w, -r.circle[2] / 100 * h)
        c.title, c.text = "A riddle's place", r.verse[1]
        c:Show()
      end
    end
    local q = ns.huntTarget()
    if q and q.zone == mapID then
      for _, haunt in ipairs(q.haunts) do
        k = k + 1
        local c = circle(k)
        local size = 2 * haunt[3] / 100 * w
        c:SetSize(size, size)
        c:SetFrameLevel(canvas:GetFrameLevel() + 1990)
        c:ClearAllPoints()
        c:SetPoint("CENTER", canvas, "TOPLEFT", haunt[1] / 100 * w, -haunt[2] / 100 * h)
        c.title, c.text = q.name, "Its haunts: the quarry you track."
        c:Show()
      end
    end
    if not ns.option("worldMapPins") then return end
    local n = 0
    local function place(list, icon, title)
      for _, e in ipairs(list or {}) do
        if e.zone == mapID and e.x and e.y then
          n = n + 1
          local p = pin(n)
          p:SetFrameLevel(canvas:GetFrameLevel() + 2000)
          p:ClearAllPoints()
          p:SetPoint("CENTER", canvas, "TOPLEFT", e.x / 100 * w, -e.y / 100 * h)
          p.icon:SetTexture(icon)
          p.title, p.text = title, line(e)
          p:Show()
        end
      end
    end
    place(atlas.closeCalls, CLOSE, "A close call")
    place(atlas.deaths, SKULL, "Died here")
  end
  WorldMapFrame:AddDataProvider(provider)
  ns.worldMapPinsAttached = true
end

-- Only an open map (a closed one refreshes its layers when it opens).
function ns.refreshWorldMapPins()
  local map = provider and provider:GetMap()
  if map and (not map.IsShown or map:IsShown()) then provider:RefreshAllData() end
end

ns.on("PLAYER_LOGIN", function()
  if WorldMapFrame and WorldMapFrame.AddDataProvider and MapCanvasDataProviderMixin and CreateFromMixins then
    create()
  end
end)

-- A death or close call recorded shows at once on an open map.
local onAtlas = ns.onAtlas
ns.onAtlas = function(...)
  if onAtlas then onAtlas(...) end
  ns.refreshWorldMapPins()
end
