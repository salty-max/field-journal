-- The Atlas on the game's own world map: where this character died (a skull)
-- and came close (a yellow mark), on the zone's map, with a tooltip; the
-- place of each riddle whose map was asked for, still unsolved (a shaded
-- circle, wider than the spot and never centred on it), and the haunts of the
-- quarry tracked (ns.hintCircles, the minimap's too). A data provider, as
-- the game's own map layers; the setting worldMapPins turns the marks off
-- (never a hint asked for). Forever's map runs its layers in a protected loop
-- that swallows an error without a word: the layer catches its own, says it
-- once in chat, and keeps what it drew last for /yonder where (ns.mapLayer).
local _, ns = ...

local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"
local SIZE = 22 -- in the map canvas's units (the map art is about 1000 wide)
local CIRCLE = "Interface\\AddOns\\Yonder\\Media\\Circle"

local provider
ns.mapLayer = { refreshes = 0 }

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
  local function draw(self)
    local layer = ns.mapLayer
    local atlas = ns.atlas and ns.atlas()
    local map = self:GetMap()
    local mapID = map:GetMapID()
    local canvas = map:GetCanvas()
    layer.refreshes, layer.map, layer.circles, layer.marks = layer.refreshes + 1, mapID, 0, 0
    if not (atlas and mapID and canvas) then return end
    local w, h = canvas:GetWidth(), canvas:GetHeight()
    -- the riddles' and the quarry's circles (x, y, r: percent of the map's width)
    for k, s in ipairs(ns.hintCircles(mapID)) do
      local c = circle(k)
      local size = 2 * s.r / 100 * w
      c:SetSize(size, size)
      c:SetFrameLevel(canvas:GetFrameLevel() + 1990)
      c:ClearAllPoints()
      c:SetPoint("CENTER", canvas, "TOPLEFT", s.x / 100 * w, -s.y / 100 * h)
      c.title, c.text = s.title, s.text
      c:Show()
      layer.circles = k
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
    layer.marks = n
  end
  function provider:RefreshAllData()
    self:RemoveAllData()
    local ok, err = pcall(draw, self)
    if not ok then
      local first = ns.mapLayer.err == nil
      ns.mapLayer.err = tostring(err)
      if first then print(ns.PREFIX .. "the world map's circles and marks failed to draw: " .. ns.mapLayer.err) end
    end
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
