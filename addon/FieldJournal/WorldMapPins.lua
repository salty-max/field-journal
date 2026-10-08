-- The Atlas on the game's own world map: where this character died (a skull)
-- and came close (a yellow mark), on the zone's map, with a tooltip. A data
-- provider, as the game's own map layers; the setting worldMapPins turns it off.
local _, ns = ...

local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"
local CLOSE = "Interface\\GossipFrame\\AvailableQuestIcon"
local SIZE = 22 -- in the map canvas's units (the map art is about 1000 wide)

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
    GameTooltip:AddLine("Explorer's Field Journal", 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  p:SetScript("OnLeave", function() GameTooltip:Hide() end)
  provider.pins[i] = p
  return p
end

local function line(e)
  return ("%s, level %d%s"):format(date("%d %b %Y", e.at or 0), e.level or 0, e.by and (" - " .. e.by) or "")
end

local function create()
  provider = CreateFromMixins(MapCanvasDataProviderMixin)
  provider.pins = {}
  function provider:RemoveAllData()
    for _, p in ipairs(self.pins) do
      p:Hide()
    end
  end
  function provider:RefreshAllData()
    self:RemoveAllData()
    local atlas = ns.atlas and ns.atlas()
    if not (atlas and ns.option("worldMapPins")) then return end
    local map = self:GetMap()
    local mapID = map:GetMapID()
    local canvas = map:GetCanvas()
    if not (mapID and canvas) then return end
    local w, h = canvas:GetWidth(), canvas:GetHeight()
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
