-- A zone's map in a page (the Atlas's, the Expeditions'): the world map's own
-- art, the overlays of the places this character has explored on top (as the
-- world map draws them), scaled to the page's width, in a thin ring; marks (an
-- icon, a tooltip) and shaded circles (a riddle's place, a quarry's haunts)
-- over it. x and y are percents of the zone's map, a circle's r of its width.
--   local map = ui.newMap(page.child)
--   map:draw(uiMap, marks, circles)  -> its height, or nil where the game has no art
--     marks = { { x, y, icon, title, text } }, circles = { { x, y, r, title, text } }
local _, ns = ...
local ui = ns.ui
local CIRCLE = "Interface\\AddOns\\FieldJournal\\Media\\Circle"
local Map = {}

local function tooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:AddLine(self.title, 1, 0.82, 0)
  if self.text then GameTooltip:AddLine(self.text, 1, 1, 1, true) end
  GameTooltip:Show()
end
local function untooltip() GameTooltip:Hide() end

local function tile(map, n, file, x, y, w, h, coords)
  local t = map.tiles[n]
  if not t then
    t = map.canvas:CreateTexture(nil, "ARTWORK")
    map.tiles[n] = t
  end
  t:SetDrawLayer(coords and "ARTWORK" or "BACKGROUND")
  t:ClearAllPoints()
  t:SetPoint("TOPLEFT", map.canvas, "TOPLEFT", x, -y)
  t:SetSize(w, h)
  t:SetTexture(file)
  t:SetTexCoord(unpack(coords or { 0, 1, 0, 1 }))
  t:Show()
end

-- The side of the texture file holding a part of an overlay: the power of
-- two that fits it.
local function fileSize(px)
  local s = 16
  while s < px do
    s = s * 2
  end
  return s
end

local function pin(map, i)
  local p = map.pins[i]
  if p then return p end
  p = CreateFrame("Button", nil, map)
  p:SetSize(14, 14)
  p.icon = p:CreateTexture(nil, "OVERLAY")
  p.icon:SetAllPoints()
  p:SetScript("OnEnter", tooltip)
  p:SetScript("OnLeave", untooltip)
  map.pins[i] = p
  return p
end

local function circle(map, i)
  local c = map.circles[i]
  if c then return c end
  c = CreateFrame("Frame", nil, map)
  c.tex = c:CreateTexture(nil, "ARTWORK")
  c.tex:SetAllPoints()
  c.tex:SetTexture(CIRCLE)
  c.tex:SetVertexColor(0.95, 0.8, 0.35, 0.55)
  c:EnableMouse(true)
  c:SetScript("OnEnter", tooltip)
  c:SetScript("OnLeave", untooltip)
  map.circles[i] = c
  return c
end

function Map:draw(uiMap, marks, circles)
  for _, x in ipairs(self.pins) do
    x:Hide()
  end
  for _, x in ipairs(self.circles) do
    x:Hide()
  end
  local layers = C_Map.GetMapArtLayers(uiMap)
  local layer = layers and layers[1]
  if not layer or ns.secret(layer) then
    self:Hide()
    return nil
  end
  local W = ui.WIDTH
  local w, h = layer.layerWidth, layer.layerHeight
  local TW, TH = layer.tileWidth, layer.tileHeight
  local scale = W / w
  self:SetSize(W, h * scale)
  self.canvas:SetSize(w, h)
  self.canvas:SetScale(scale)
  for _, t in ipairs(self.tiles) do
    t:Hide()
  end
  local n = 0
  -- the art
  local files = C_Map.GetMapArtLayerTextures(uiMap, 1) or {}
  local cols = math.ceil(w / TW)
  for r = 1, math.ceil(h / TH) do
    for c = 1, cols do
      local file = files[(r - 1) * cols + c]
      if file then
        n = n + 1
        tile(self, n, file, TW * (c - 1), TH * (r - 1), TW, TH)
      end
    end
  end
  -- the places explored
  for _, info in ipairs(C_MapExplorationInfo.GetExploredMapTextures(uiMap) or {}) do
    if not info.isShownByMouseOver then
      local wide, tall = math.ceil(info.textureWidth / TW), math.ceil(info.textureHeight / TH)
      for j = 1, tall do
        local ph = j < tall and TH or (info.textureHeight % TH == 0 and TH or info.textureHeight % TH)
        local fh = j < tall and TH or fileSize(ph)
        for k = 1, wide do
          local pw = k < wide and TW or (info.textureWidth % TW == 0 and TW or info.textureWidth % TW)
          local fw = k < wide and TW or fileSize(pw)
          local file = info.fileDataIDs[(j - 1) * wide + k]
          if file then
            n = n + 1
            local x, y = info.offsetX + TW * (k - 1), info.offsetY + TH * (j - 1)
            tile(self, n, file, x, y, pw, ph, { 0, pw / fw, 0, ph / fh })
          end
        end
      end
    end
  end
  -- the circles, under the marks
  for i, m in ipairs(circles or {}) do
    local c = circle(self, i)
    local size = 2 * m.r / 100 * W
    c:SetSize(size, size)
    c:SetFrameLevel(self:GetFrameLevel() + 3)
    c:ClearAllPoints()
    c:SetPoint("CENTER", self, "TOPLEFT", m.x / 100 * W, -m.y / 100 * h * scale)
    c.title, c.text = m.title, m.text
    c:Show()
  end
  -- the marks
  for i, m in ipairs(marks or {}) do
    local p = pin(self, i)
    p:SetFrameLevel(self:GetFrameLevel() + 5)
    p:ClearAllPoints()
    p:SetPoint("CENTER", self, "TOPLEFT", m.x / 100 * W, -m.y / 100 * h * scale)
    p.icon:SetTexture(m.icon)
    p.title, p.text = m.title, m.text
    p:Show()
  end
  self:Show()
  return h * scale
end

function ui.newMap(parent)
  local map = CreateFrame("Frame", nil, parent)
  map:SetClipsChildren(true)
  map.canvas = CreateFrame("Frame", nil, map)
  map.canvas:SetPoint("TOPLEFT")
  map.tiles, map.pins, map.circles = {}, {}, {}
  map.border = CreateFrame("Frame", nil, map, "BackdropTemplate")
  map.border:SetAllPoints()
  map.border:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
  map.border:SetBackdropBorderColor(unpack(ui.T.ring))
  map.border:SetFrameLevel(map:GetFrameLevel() + 8)
  for k, v in pairs(Map) do
    map[k] = v
  end
  map:Hide()
  return map
end
