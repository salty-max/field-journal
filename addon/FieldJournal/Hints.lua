-- A line on creature tooltips: "not yet in the journal" for a creature this
-- character hasn't met, else how many it has slain (and a trophy's mark).
-- Off in the settings (tooltipHints).
local _, ns = ...
local D = ns.data

local NEW = { 1, 0.82, 0 }
local KNOWN = { 0.65, 0.58, 0.45 }

local function addHint(tooltip)
  if tooltip ~= GameTooltip or not ns.option("tooltipHints") then return end
  local _, unit = tooltip:GetUnit()
  if not unit or ns.secret(unit) then return end
  local isPlayer = UnitIsPlayer(unit)
  if ns.secret(isPlayer) or isPlayer then return end
  local id = ns.creatureId(UnitGUID(unit))
  if not id then return end
  local journal = ns.journal()
  local rec = journal and journal.creatures[id]
  if not rec then
    -- Only creatures the journal would keep: those the data knows.
    if D.creatures[id] then tooltip:AddLine("Field Journal: not yet recorded", unpack(NEW)) end
    return
  end
  local slain = rec.slain or 0
  local mark = rec.trophy and " (trophy)" or ""
  tooltip:AddLine(("Field Journal: %s%s"):format(slain > 0 and ("%d slain"):format(slain) or "met", mark), unpack(KNOWN))
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, addHint)
else
  GameTooltip:HookScript("OnTooltipSetUnit", addHint)
end
