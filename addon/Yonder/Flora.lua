-- Finds are item pages, never gathering nodes. Fish and plants keep their
-- original saved tables. New materials live in materials[itemId], with the
-- same first/n/zones record and gathered/skinned/looted provenance.
-- finds.unlocked and finds.announced are permanent, per-character family
-- flags. Unlearning a profession never withdraws pages or stops recording.
local _, ns = ...
local L, F, M = ns.kit.L, ns.data.flora, ns.data.materials
local secret = ns.secret
local function char() return ns.journal() end

local FAMILIES = {
  { id = "fish", title = L["Fish"], icon = "Interface\\Icons\\Trade_Fishing" },
  { id = "plants", title = L["Plants"], icon = "Interface\\Icons\\INV_Misc_Herb_07" },
  { id = "mining", title = L["Ores & Gems"], icon = "Interface\\Icons\\INV_Ore_Copper_01" },
  { id = "cloth", title = L["Cloth"], icon = "Interface\\Icons\\INV_Fabric_Linen_01" },
  { id = "leather", title = L["Leather & Hides"], icon = "Interface\\Icons\\INV_Misc_LeatherScrap_03" },
}
ns.findFamilies = FAMILIES
local byFamily = {}
for _, family in ipairs(FAMILIES) do
  byFamily[family.id] = family
end
function ns.findFamilyInfo(family) return byFamily[family] end
function ns.findInfo(id) return F.fish[id] or F.herbs[id] or M.items[id] end
function ns.findFamily(id)
  if F.fish[id] then return "fish" end
  if F.herbs[id] then return "plants" end
  return M.items[id] and M.items[id].family
end
function ns.findOrder(family)
  if family == "fish" then return F.fishOrder end
  if family == "plants" then return F.herbOrder end
  local out = {}
  for _, id in ipairs(M.order) do
    if M.items[id].family == family then table.insert(out, id) end
  end
  return out
end
function ns.findRecord(id)
  local c, family = char(), ns.findFamily(id)
  if not c then return end
  local recs
  if family == "fish" then
    recs = c.fish
  elseif family == "plants" then
    recs = c.plants
  else
    recs = c.materials
  end
  return recs and recs[id]
end
function ns.findName(id)
  local d = ns.findInfo(id)
  if not d then return end
  if d.kind == "record" then return ns.catchNames and ns.catchNames[id] or d.name end
  local names = M.itemNames[GetLocale()] or {}
  return ns.kit.itemName(id, names[id] or d.name)
end
function ns.findIcon(id) return ns.kit.itemIcon(id) or (M.items[id] and M.items[id].icon) or ns.kit.QUESTION end
-- Current carried stock is distinct from lifetime observed acquisitions.
-- Query it live so consuming, selling or moving a stack cannot rewrite history.
function ns.findBagCount(id)
  local count = (C_Item and C_Item.GetItemCount or GetItemCount)(id, false)
  if not secret(count) and type(count) == "number" and count >= 0 then return count end
end
function ns.findsUnlocked(family)
  local c = char()
  return c and c.finds and c.finds.unlocked[family] == true or false
end
local function changed(quiet)
  ns.checkMilestones(quiet)
  ns.onFlora()
end
local function unlock(family)
  local c = char()
  if not byFamily[family] or c.finds.unlocked[family] then return false end
  c.finds.unlocked[family] = true
  return true
end
local function announceUnlocks()
  local c = char()
  for _, family in ipairs(FAMILIES) do
    if ns.findsUnlocked(family.id) and not c.finds.announced[family.id] then
      c.finds.announced[family.id] = true
      local link = ("|cffffd100|Hyonder:finds/%s|h[%s]|h|r"):format(family.id, family.title)
      print(ns.PREFIX .. L["a new collection in Finds: %s"]:format(link))
      ns.toast("finds", family.id)
    end
  end
end

local lookInBags
local scanning = false
-- Prefer profession ids, including Forever's child skill lines. On clients
-- with only the skills pane, expand folded headers while reading and restore
-- them in reverse order. SKILL_LINES_CHANGED is synchronous, so the guard
-- also prevents our own header changes from re-entering this scan.
local function professions()
  local found = {}
  local names = M.professionNames[GetLocale()] or {}
  if GetProfessions and GetProfessionInfo then
    -- Sparse slots are normal: Fishing can be known without either primary.
    for _, index in pairs({ GetProfessions() }) do
      local name, _, _, _, _, _, id = GetProfessionInfo(index)
      local family = not secret(id) and M.skillAliases[id] or nil
      family = family or (name and not secret(name) and names[name])
      if family then found[family] = true end
    end
  elseif GetNumSkillLines and GetSkillLineInfo then
    local folded, i = {}, 1
    while i <= GetNumSkillLines() do
      local name, header, expanded = GetSkillLineInfo(i)
      if header and not expanded and ExpandSkillHeader and CollapseSkillHeader then
        table.insert(folded, i)
        ExpandSkillHeader(i)
      elseif not header and name and not secret(name) and names[name] then
        found[names[name]] = true
      end
      i = i + 1
    end
    for n = #folded, 1, -1 do
      CollapseSkillHeader(folded[n])
    end
  end
  return found
end
function ns.refreshFindsProfessions()
  local c = char()
  if not c or scanning then return end
  scanning = true
  c.finds = c.finds or { unlocked = {}, announced = {} }
  c.finds.unlocked, c.finds.announced = c.finds.unlocked or {}, c.finds.announced or {}
  unlock("cloth")
  -- Upgrade migration: old catches and herbs remain readable even when the
  -- character no longer has their profession. Their saved records stay put.
  if c.fish and next(c.fish) then unlock("fish") end
  if c.plants and next(c.plants) then unlock("plants") end
  for id in pairs(c.materials or {}) do
    if M.items[id] then unlock(M.items[id].family) end
  end
  for family in pairs(professions()) do
    unlock(family)
  end
  scanning = false
  announceUnlocks()
  if lookInBags then lookInBags(true) end
  ns.onFlora()
end
ns.on("PLAYER_LOGIN", ns.refreshFindsProfessions)
ns.on("SKILL_LINES_CHANGED", ns.refreshFindsProfessions)
ns.on("SPELLS_CHANGED", ns.refreshFindsProfessions)

local function entity(guid)
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  return kind, tonumber(id)
end
local function itemOf(link) return link and not secret(link) and tonumber(link:match("item:(%d+)")) end
local function now()
  local sub = GetSubZoneText()
  if secret(sub) or sub == "" then sub = nil end
  return { at = time(), level = UnitLevel("player"), zone = ns.atlasHere(), sub = sub and (ns.areaKey(sub) or sub) }
end
local function night()
  local h = GetGameTime()
  return h ~= nil and not secret(h) and (h < 6 or h >= 18)
end
local function announce(kind, id)
  local message = kind == "f" and L["a new catch: %s"] or kind == "h" and L["a new herb: %s"] or L["a new find: %s"]
  print(ns.PREFIX .. message:format(("|cffffd100|Hyonder:%s%d|h[%s]|h|r"):format(kind, id, ns.findName(id))))
end
local function caught(itemId, n, school)
  if not ns.findsUnlocked("fish") then return end
  local entry, pounds = itemId, nil
  local w = F.weights[itemId]
  if w then
    entry, pounds = w[1], w[2]
  end
  if not F.fish[entry] then return end
  local c, where = char(), now()
  c.fish = c.fish or {}
  local rec, new = c.fish[entry], c.fish[entry] == nil
  if new then
    rec = { first = where, n = 0, zones = {}, day = 0, night = 0, school = 0 }
    c.fish[entry] = rec
  end
  rec.n = rec.n + n
  if where.zone then rec.zones[where.zone] = (rec.zones[where.zone] or 0) + n end
  if night() then
    rec.night = rec.night + n
  else
    rec.day = rec.day + n
  end
  if school then rec.school = rec.school + n end
  if pounds and pounds > (rec.heaviest or 0) then rec.heaviest = pounds end
  if new then announce("f", entry) end
  return true
end
local function taken(id, n, how, quiet)
  local family = ns.findFamily(id)
  if not family or family == "fish" or not ns.findsUnlocked(family) then return end
  local c = char()
  local key = family == "plants" and "plants" or "materials"
  c[key] = c[key] or {}
  local rec, new = c[key][id], c[key][id] == nil
  if new then
    local first = now()
    first.how = how
    rec = { first = first, n = 0, gathered = 0, looted = 0, skinned = 0, zones = {} }
    c[key][id] = rec
  end
  rec.n = (rec.n or 0) + n
  if how ~= "other" then
    rec[how] = (rec[how] or 0) + n
    local zone = ns.atlasHere()
    if zone then rec.zones[zone] = (rec.zones[zone] or 0) + n end
  end
  if new and not quiet then announce(family == "plants" and "h" or "i", id) end
  return true
end

-- Skinning is established by the player's successful spell and the same
-- corpse's GUID, not by the item being leather. Without a matching corpse,
-- record it as looted rather than inventing a skinning count.
local skin, skinCast
local function skinSource(targetName)
  local source
  for _, unit in ipairs({ "target", "mouseover" }) do
    local guid = UnitGUID(unit)
    local kind = entity(guid)
    if kind == "Creature" and (not targetName or UnitName(unit) == targetName) then
      if source and source ~= guid then return nil end -- ambiguous corpses
      source = guid
    end
  end
  return source
end
ns.onUnit("UNIT_SPELLCAST_SENT", "player", function(_, targetName, cast, spell)
  skinCast = nil
  if secret(spell) or secret(cast) or not M.skinSpells[spell] then return end
  if secret(targetName) or targetName == "" then targetName = nil end
  skinCast = { cast = cast, source = skinSource(targetName) }
end)
ns.onUnit("UNIT_SPELLCAST_SUCCEEDED", "player", function(_, cast, spell)
  if secret(spell) or secret(cast) or not M.skinSpells[spell] then return end
  local source
  if skinCast and skinCast.cast == cast then
    source = skinCast.source
  else
    source = skinSource()
  end
  skin = source and { untilAt = time() + 3, source = source } or nil
  skinCast = nil
end)
for _, event in ipairs({ "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED" }) do
  ns.onUnit(event, "player", function(_, cast)
    if skinCast and not secret(cast) and skinCast.cast == cast then skinCast = nil end
  end)
end
local seen = {}
ns.on("LOOT_CLOSED", function()
  seen, skin, skinCast = {}, nil, nil
end)
local function readLoot()
  local fishing = IsFishingLoot()
  if secret(fishing) then fishing = false end
  local any = false
  for slot = 1, GetNumLootItems() do
    local id = itemOf(GetLootSlotLink(slot))
    if id and (ns.findInfo(id) or F.weights[id]) then
      local guid = GetLootSourceInfo(slot)
      local _, _, quantity = GetLootSlotInfo(slot)
      local count = (quantity and not secret(quantity) and quantity > 0) and quantity or 1
      local kind, source = entity(guid)
      local key = slot .. ":" .. id .. ":" .. tostring(not secret(guid) and guid or "")
      if not seen[key] then
        seen[key] = true
        if fishing then
          any = caught(id, count, kind == "GameObject" and F.schools[source] == true) or any
        elseif F.herbs[id] or M.items[id] then
          local how = "looted"
          if kind == "GameObject" and (F.herbNodes[source] or M.miningNodes[source]) then
            -- A node establishes the method only for its material family.
            if
              (F.herbs[id] and F.herbNodes[source])
              or (M.items[id] and M.items[id].family == "mining" and M.miningNodes[source])
            then
              how = "gathered"
            end
          elseif
            kind == "Creature"
            and M.items[id]
            and M.items[id].family == "leather"
            and skin
            and time() <= skin.untilAt
            and skin.source == guid
          then
            how = "skinned"
          end
          any = taken(id, count, how) or any
        end
      end
    end
  end
  if any then changed() end
end
ns.on("LOOT_READY", readLoot)
ns.on("LOOT_OPENED", readLoot)

-- /yonder probe remains useful for diagnosing loot provenance in game.
local probing = false
function ns.lootProbe()
  probing = true
  print(ns.PREFIX .. L["the next loot window will be described here: loot something."])
end
local function describe(event)
  if not probing then return end
  local parts = {}
  for slot = 1, GetNumLootItems() do
    local link = GetLootSlotLink(slot)
    local name = link and not secret(link) and link:match("%[(.-)%]") or L["money or nothing"]
    local guid = GetLootSourceInfo(slot)
    local from = guid and not secret(guid) and guid:match("^(%a+)") or "?"
    table.insert(parts, L["%s (%s)"]:format(name, from))
  end
  local fishing = IsFishingLoot()
  print(
    ns.PREFIX
      .. L["%s: %d slots%s%s"]:format(
        event,
        GetNumLootItems(),
        (not secret(fishing) and fishing) and L[", fishing"] or "",
        #parts > 0 and (": " .. table.concat(parts, ", ")) or ""
      )
  )
  if event == "LOOT_CLOSED" then probing = false end
end
for _, e in ipairs({ "LOOT_READY", "LOOT_OPENED", "LOOT_CLOSED" }) do
  ns.on(e, function() describe(e) end)
end

local function bagItem(bag, slot)
  if C_Container and C_Container.GetContainerItemID then return C_Container.GetContainerItemID(bag, slot) end
  return GetContainerItemID and GetContainerItemID(bag, slot)
end
local function bagSlots(bag)
  if C_Container and C_Container.GetContainerNumSlots then return C_Container.GetContainerNumSlots(bag) end
  return GetContainerNumSlots and GetContainerNumSlots(bag) or 0
end
local pending = false
lookInBags = function(quiet)
  pending = false
  if not char() then return end
  local any = false
  for bag = 0, 4 do
    for slot = 1, bagSlots(bag) or 0 do
      local id = bagItem(bag, slot)
      if id and not secret(id) and (F.herbs[id] or M.items[id]) and not ns.findRecord(id) then
        any = taken(id, 0, "other", quiet) or any
      end
    end
  end
  if any then
    changed(quiet)
  else
    -- Existing pages also change when their last stack leaves the bags.
    ns.onFlora()
  end
end
ns.on("BAG_UPDATE_DELAYED", function()
  if pending then return end
  pending = true
  C_Timer.After(1, function() lookInBags(false) end)
end)
ns.on("PLAYER_ENTERING_WORLD", function() C_Timer.After(3, ns.refreshFindsProfessions) end)
function ns.fishRecord(id)
  local c = char()
  return c and c.fish and c.fish[id]
end
function ns.plantRecord(id)
  local c = char()
  return c and c.plants and c.plants[id]
end
