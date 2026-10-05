-- The Fish and Plants records: every fish this character catches and every
-- herb that reaches its bags (FieldJournalChar):
--   fish[itemId] = {
--     first = { at, level, zone, sub }   the first catch (zone: the Atlas's uiMap)
--     n                                   catches
--     zones = { [uiMap] = n }
--     day, night                          catches by the hour (the game's clock)
--     school                              catches from a school (not open water)
--     heaviest                            a weighed kind's heaviest, in pounds
--   }
--   plants[itemId] = {
--     first = { at, level, zone, sub, how }   how: gathered, looted, other
--     n, gathered, looted                  herbs taken (counted as received)
--     zones = { [uiMap] = n }               where gathered or looted
--   }
-- Fishing loot is known by the game (IsFishingLoot); a school by its loot's
-- source (GetLootSourceInfo: a fishing hole of the data). An herb is gathered
-- when its loot comes from an herb node of the data, else looted; one that
-- reaches the bags another way (bought, a quest's reward, the mail) is noted
-- once, when the bags are next looked at.
local _, ns = ...
local F = ns.data.flora
local secret = ns.secret

local function char() return ns.journal() end

local function objectId(guid)
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind == "GameObject" then return tonumber(id) end
end

local function itemOf(link)
  return link and not secret(link) and tonumber(link:match("item:(%d+)"))
end

local function now()
  local zone = ns.atlasHere and ns.atlasHere()
  local sub = GetSubZoneText and GetSubZoneText()
  if secret(sub) or sub == "" then sub = nil end
  return { at = time(), level = UnitLevel("player"), zone = zone, sub = sub }
end

local function night()
  local h = GetGameTime and GetGameTime()
  return h ~= nil and not secret(h) and (h < 6 or h >= 20)
end

local function announce(kind, id, name)
  if not ns.option("chat") then return end
  print(ns.PREFIX .. ("a new %s: |cffffd100|Hfieldjournal:%s%d|h[%s]|h|r"):format(kind == "f" and "catch" or "herb", kind, id, name))
end

local function changed()
  if ns.checkMilestones then ns.checkMilestones() end
  if ns.onFlora then ns.onFlora() end
end

-- ── fish ─────────────────────────────────────────────────────────────────────
-- A catch (item id; a weighed one counts for its kind), n of it.
local function caught(itemId, n, school)
  local entry, pounds = itemId, nil
  local w = F.weights[itemId]
  if w then entry, pounds = w[1], w[2] end
  if not F.fish[entry] then return end
  local c = char()
  c.fish = c.fish or {}
  local where = now()
  local rec = c.fish[entry]
  local new = rec == nil
  if new then
    rec = { first = where, n = 0, zones = {}, day = 0, night = 0, school = 0 }
    c.fish[entry] = rec
  end
  rec.n = rec.n + n
  if where.zone then rec.zones[where.zone] = (rec.zones[where.zone] or 0) + n end
  if night() then rec.night = rec.night + n else rec.day = rec.day + n end
  if school then rec.school = rec.school + n end
  if pounds and pounds > (rec.heaviest or 0) then rec.heaviest = pounds end
  if new then announce("f", entry, F.fish[entry].name) end
  return true
end

-- ── herbs ────────────────────────────────────────────────────────────────────
local function herb(itemId, n, how, quiet)
  if not F.herbs[itemId] then return end
  local c = char()
  c.plants = c.plants or {}
  local rec = c.plants[itemId]
  local new = rec == nil
  if new then
    local first = now()
    first.how = how
    rec = { first = first, n = 0, gathered = 0, looted = 0, zones = {} }
    c.plants[itemId] = rec
  end
  rec.n = rec.n + n
  if how == "gathered" or how == "looted" then
    rec[how] = rec[how] + n
    local zone = ns.atlasHere and ns.atlasHere()
    if zone then rec.zones[zone] = (rec.zones[zone] or 0) + n end
  end
  if new and not quiet then announce("h", itemId, F.herbs[itemId].name) end
  return true
end

-- ── the loot window ──────────────────────────────────────────────────────────
-- Each slot once per window (the game can report a window twice).
local seen = {}
ns.on("LOOT_CLOSED", function() seen = {} end)

ns.on("LOOT_OPENED", function()
  if not (GetNumLootItems and GetLootSlotLink) then return end
  local fishing = IsFishingLoot and IsFishingLoot()
  if secret(fishing) then fishing = false end
  local any = false
  for slot = 1, GetNumLootItems() do
    local itemId = itemOf(GetLootSlotLink(slot))
    if itemId and (F.herbs[itemId] or F.fish[itemId] or F.weights[itemId]) then
      local guid = GetLootSourceInfo and GetLootSourceInfo(slot)
      local _, _, quantity = GetLootSlotInfo(slot)
      local count = (quantity and not secret(quantity) and quantity > 0) and quantity or 1
      local object = objectId(guid)
      local key = slot .. ":" .. itemId
      if not seen[key] then
        seen[key] = true
        if fishing then
          any = caught(itemId, count, object ~= nil and F.schools[object] == true) or any
        elseif F.herbs[itemId] then
          any = herb(itemId, count, (object and F.herbNodes[object]) and "gathered" or "looted") or any
        end
      end
    end
  end
  if any then changed() end
end)

-- Herbs that reach the bags another way: bought, a quest's reward, the mail,
-- a trade. Looked at when the bags settle; only a herb not yet in the record
-- is noted (how many came is unknown).
local function bagItem(bag, slot)
  if C_Container and C_Container.GetContainerItemID then return C_Container.GetContainerItemID(bag, slot) end
  return GetContainerItemID and GetContainerItemID(bag, slot)
end
local function bagSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) end
  return GetContainerNumSlots and GetContainerNumSlots(bag) or 0
end
local pending = false
-- quiet: at login (the herbs already carried, before the journal knew of them)
local function lookInBags(quiet)
  pending = false
  local c = char()
  if not c then return end
  local any = false
  for bag = 0, 4 do
    for slot = 1, bagSlots(bag) or 0 do
      local id = bagItem(bag, slot)
      if id and not secret(id) and F.herbs[id] and not (c.plants and c.plants[id]) then
        any = herb(id, 0, "other", quiet) or any
      end
    end
  end
  if any then changed() end
end
ns.on("BAG_UPDATE_DELAYED", function()
  if pending then return end
  pending = true
  -- after the loot window's own records, so a looted herb isn't "other"
  if C_Timer then C_Timer.After(1, lookInBags) else lookInBags() end
end)
local function atLogin() lookInBags(true) end
ns.on("PLAYER_ENTERING_WORLD", function() if C_Timer then C_Timer.After(3, atLogin) else atLogin() end end)

-- For the book and the milestones.
function ns.fishRecord(id) local c = char() return c and c.fish and c.fish[id] end
function ns.plantRecord(id) local c = char() return c and c.plants and c.plants[id] end
