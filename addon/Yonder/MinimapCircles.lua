-- The hints on the minimap, as on the world map (WorldMapPins.lua): the place
-- of each riddle whose map was asked for, still unsolved, and the haunts of
-- the quarry tracked (ns.hintCircles), shaded circles under the minimap's own
-- buttons, clipped to its face (round, or square when a minimap addon says so
-- through GetMinimapShape), following the reader and turning with a rotating
-- minimap. The zone's size in yards is the data's (ns.zoneYards); the
-- minimap's span the game's (C_Minimap.GetViewRadius on Forever), else its
-- zoom's, indoors or out. Nothing while the game hides where the reader is.
local _, ns = ...

local CIRCLE = "Interface\\AddOns\\Yonder\\Media\\Circle"
local ROUND = "Interface\\CharacterFrame\\TempPortraitAlphaMask"
local SQUARE = "Interface\\Buttons\\WHITE8X8"
-- The minimap's width in yards at each zoom, 0 (widest) to 5, indoors and out
-- (at zoom + 1).
local SPAN = {
  indoor = { 300, 240, 180, 120, 80, 50 },
  outdoor = { 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 3, 200, 133 + 1 / 3 },
}
local LOOK = 1 -- seconds between two looks at the zone's circles (placed every frame while it has some)

local secret = ns.secret
local getCVar = (C_CVar and C_CVar.GetCVar) or GetCVar

local layer, mask, shape
local textures = {}
local spots, zone = {}, nil -- the circles of the zone the reader is in
local since, look, now = 0, 0, false -- seconds since the last placing, till the next look; at once
ns.minimapLayer = { circles = 0, seen = 0 } -- (for /yonder where and the tests)

-- Half the minimap's width, in yards.
local function radius()
  if C_Minimap and C_Minimap.GetViewRadius then
    local r = C_Minimap.GetViewRadius()
    if r and not secret(r) and r > 0 then return r end
  end
  local span = SPAN[IsIndoors() and "indoor" or "outdoor"]
  return (span[(Minimap:GetZoom() or 0) + 1] or span[1]) / 2
end

local function texture(i)
  local t = textures[i]
  if t then return t end
  t = layer:CreateTexture(nil, "ARTWORK")
  t:SetTexture(CIRCLE)
  t:SetVertexColor(0.95, 0.8, 0.35, 0.45)
  t:AddMaskTexture(mask)
  -- (never snapped to whole pixels: the minimap's ground glides under the
  -- reader, a snapped circle would jiggle on it)
  if t.SetSnapToPixelGrid then
    t:SetSnapToPixelGrid(false)
    t:SetTexelSnappingBias(0)
  end
  textures[i] = t
  return t
end

local function hideFrom(i)
  for j = i, #textures do
    textures[j]:Hide()
  end
end

-- The minimap's face: round, or square for a minimap addon that says so.
local function face()
  local s = (GetMinimapShape and GetMinimapShape() == "SQUARE") and SQUARE or ROUND
  if s ~= shape then
    shape = s
    mask:SetTexture(s, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
  end
end

local function place(elapsed)
  local uiMap, px, py = ns.where()
  look = look - elapsed
  if uiMap ~= zone or look <= 0 then
    zone, look = uiMap, LOOK
    spots = uiMap and ns.hintCircles(uiMap) or {}
  end
  local w, h = ns.zoneYards(zone or 0)
  local cos, sin = 1, 0
  if getCVar("rotateMinimap") == "1" then
    local f = GetPlayerFacing()
    if f and not secret(f) then
      cos, sin = math.cos(f), math.sin(f)
    else
      px = nil -- (a turning minimap and no facing: nowhere to draw)
    end
  end
  local seen = 0
  if #spots > 0 and px and w then
    face()
    local yards = radius()
    local scale = layer:GetWidth() / 2 / yards -- pixels a yard
    for i, s in ipairs(spots) do
      -- yards east and north of the reader, then turned as the minimap is
      -- (the facing: 0 north, counterclockwise)
      local e, n = (s.x / 100 - px) * w, (py - s.y / 100) * h
      local x, y = e * cos + n * sin, n * cos - e * sin
      local r = s.r / 100 * w
      local t = texture(i)
      if math.sqrt(x * x + y * y) - r > yards * 1.5 then -- (past the face, a square's corners too)
        t:Hide()
      else
        t:SetSize(2 * r * scale, 2 * r * scale)
        t:ClearAllPoints()
        t:SetPoint("CENTER", layer, "CENTER", x * scale, y * scale)
        t:Show()
        seen = seen + 1
      end
    end
    hideFrom(#spots + 1)
  else
    hideFrom(1)
  end
  ns.minimapLayer.circles, ns.minimapLayer.seen = #spots, seen
end

local function create()
  layer = CreateFrame("Frame", nil, Minimap)
  layer:SetAllPoints(Minimap)
  layer:SetFrameLevel(Minimap:GetFrameLevel() + 1)
  mask = layer:CreateMaskTexture()
  mask:SetAllPoints(layer)
  face()
  layer:SetScript("OnUpdate", function(_, elapsed)
    since = since + elapsed
    if not now and #spots == 0 and since < LOOK then return end
    place(since)
    since, now = 0, false
  end)
  ns.minimapLayer.attached, ns.minimapLayer.frame = true, layer
end

-- A hint taken, a quarry tracked or brought down, a riddle solved: both maps
-- again, the minimap at its next frame.
function ns.refreshHints()
  ns.refreshWorldMapPins()
  look, now = 0, true
end

ns.on("PLAYER_LOGIN", function()
  if Minimap and Minimap.CreateMaskTexture then create() end
end)
