-- A small game for the solution matrix. Each reader gets fresh data, event
-- listeners and emote hooks, independent of the journal's story in sim.lua.
return function(locale, forever, modernEmotes)
  local state = { health = 100, level = 10, near = true, faction = "Alliance", hour = 12 }
  local events, ticker = {}, nil
  local journal = { creatures = {} }
  local function nothing() end
  local ns = {
    PREFIX = "",
    secret = function() return false end,
    journal = function() return journal end,
    playSound = nothing,
    toast = nothing,
    checkMilestones = nothing,
    onRecord = nothing,
    zoneName = function() return "Zone" end,
    on = function(event, fn) events[event] = fn end,
  }
  function GetLocale() return locale end
  function time() return 1790900000 end
  function print() end
  function UnitLevel() return state.level end
  function UnitSex() return 2 end
  function UnitFactionGroup() return state.faction end
  function UnitAffectingCombat() return state.combat == true end
  function UnitOnTaxi() return state.taxi == true end
  function UnitIsDeadOrGhost() return state.health == 0 end
  function IsIndoors() return state.indoors == true end
  function UnitGUID(unit)
    local id = unit == "target" and state.target or unit == "npc" and state.npc
    return id and ("Creature-0-4170-0-12-%d-0000ABCDEF"):format(id) or nil
  end
  function CheckInteractDistance() return state.near end
  function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
  function strsplit(separator, text)
    local out = {}
    for part in (text .. separator):gmatch("(.-)" .. separator:gsub("%-", "%%-")) do
      table.insert(out, part)
    end
    return unpack(out)
  end
  function GetSubZoneText() return state.sub or "" end
  function GetGameTime() return state.hour, 0 end
  C_Map = {
    GetBestMapForUnit = function() return state.map end,
    GetPlayerMapPosition = function() return { x = state.x, y = state.y } end,
    GetMapInfo = function() return nil end,
    GetAreaInfo = function(id) return locale .. " area " .. id end,
  }
  C_Timer = { NewTicker = function(_, fn) ticker = fn end }
  function hooksecurefunc(owner, key, hook)
    if type(owner) == "string" then
      owner, key, hook = _G, owner, key
    end
    local original = owner[key]
    owner[key] = function(...)
      original(...)
      hook(...)
    end
  end
  if modernEmotes then
    C_ChatInfo = { PerformEmote = nothing }
    function DoEmote(token) C_ChatInfo.PerformEmote(token) end
  else
    C_ChatInfo = nil
    DoEmote = nothing
  end
  for _, file in ipairs({
    "Kit.lua",
    forever and "Data_Forever.lua" or "Data_Classic.lua",
    "Locale.lua",
    "Text_" .. locale .. ".lua",
    "Expeditions.lua",
  }) do
    assert(loadfile("addon/Yonder/" .. file))("Yonder", ns)
  end
  local function fire(event) assert(events[event], "event not registered: " .. event)() end
  fire("PLAYER_LOGIN")
  return { reader = ns, state = state, journal = journal, fire = fire, emote = DoEmote, tick = ticker }
end
