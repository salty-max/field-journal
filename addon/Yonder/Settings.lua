-- The addon's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in YonderSettings so that one character
-- can take another's: chosen among this game's characters, or brought by a
-- code (/yonder export, /yonder import CODE). Their page in the game's
-- Options (AddOns tab): /yonder settings, or a right-click on the minimap
-- button; the welcome page (Welcome.lua) offers them too.
--
--   YonderSettings.profiles["Name - Realm"] = { banner, sound,
--     minimapHidden, minimapAngle, tooltipHints, milestoneToast, worldMapPins,
--     welcomed }
--   (banner: a riddle's and a quarry's; milestoneToast: a milestone's, the
--   game's achievement alert. The chat lines have no setting any more,
--   always shown: a profile's old chat value is left unread)
--   (the account-wide values of 0.6.0 and before, at the top of the table:
--   the first profile of a character who kept a journal before takes them)
local _, ns = ...
local L = ns.kit.L
local K = ns.kit

-- (minimapAngle: the button's place around the minimap, in degrees; 225 is
-- lower left, clear of the game's buttons; welcomed: never copied)
local DEFAULTS = {
  banner = true,
  sound = 3175,
  minimapHidden = false,
  minimapAngle = 225,
  tooltipHints = true,
  milestoneToast = true,
  worldMapPins = true,
  welcomed = false,
}
local SHARED = { "banner", "sound", "milestoneToast", "worldMapPins", "tooltipHints", "minimapHidden", "minimapAngle" }

-- Sounds for a trophy: all from the original game's interface. -1 is the
-- sting heard on discovering a new zone, which differs by race.
ns.SOUNDS = {
  { -1, L["Zone discovery"] },
  { 878, L["Quest complete"] },
  { 3175, L["Map ping"] },
  { 8960, L["Ready check"] },
  { 836, L["Page turn"] },
  { 844, L["Book opening (quiet)"] },
  { 0, L["None"] },
}

-- The profiles: a code "YD1:b1:s3175:m1:w1:t1:h0:a225" (the banners, the
-- trophy's sound, milestone alerts, the world map's marks, tooltip hints, the minimap
-- button hidden, its angle; an older code's c, the chat lines, is left out).
local P = K.profiles({
  saved = function()
    if type(YonderSettings) ~= "table" then YonderSettings = {} end
    return YonderSettings
  end,
  defaults = DEFAULTS,
  shared = SHARED,
  letters = {
    banner = "b",
    sound = "s",
    milestoneToast = "m",
    worldMapPins = "w",
    tooltipHints = "t",
    minimapHidden = "h",
    minimapAngle = "a",
  },
  tag = "YD1",
  changed = function(key)
    if key == "minimapHidden" or key == "minimapAngle" then ns.updateMinimapButton() end
    if key == "worldMapPins" and ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
  end,
})
-- (a code made before the rename, Explorer's Field Journal's FJ1, still taken)
local import = P.import
function P:import(code)
  if type(code) == "string" then code = code:gsub("^%s*FJ1:", "YD1:") end
  return import(self, code)
end
ns.profiles = P

-- This character's profile at its login: its own, else a new one (the
-- account's old values for a character who kept a journal before, the
-- defaults for a new one).
function ns.loadProfile(before)
  P:load(function(profile, saved)
    if not before then return end
    for _, k in ipairs(SHARED) do
      profile[k] = saved[k]
    end
  end)
end
function ns.option(key) return P:get(key) end
function ns.setOption(key, value) P:set(key, value) end

-- The exploration sound kit of each race (Undead's token is Scourge).
local DISCOVERY =
  { Human = 4140, Orc = 4141, Scourge = 4142, Tauren = 4143, Troll = 4144, NightElf = 4145, Gnome = 4146, Dwarf = 4147 }

function ns.playSound(id)
  id = id or ns.option("sound")
  if id == -1 then
    local _, race = UnitRace("player")
    id = DISCOVERY[race] or DISCOVERY.Human
  end
  if id and id > 0 and PlaySound then PlaySound(id) end
end

-- The opt-in that shares what the game tells of the world with the addons'
-- database (the kit's, K.collect): account-wide, in YonderCollect, which
-- Ravenpost sends; off until the player says yes.
ns.collect = K.collect({
  saved = function()
    if type(YonderCollect) ~= "table" then YonderCollect = {} end
    return YonderCollect
  end,
})

local category

function ns.createSettingsPanel()
  if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
  category = Settings.RegisterVerticalLayoutCategory("Yonder")

  local function checkbox(key, name, tooltip, invert)
    invert = invert or false
    local setting = Settings.RegisterProxySetting(
      category,
      "YONDER_" .. key:upper(),
      Settings.VarType.Boolean,
      name,
      not DEFAULTS[key] == invert,
      function() return ns.option(key) ~= invert end,
      function(value) ns.setOption(key, value ~= invert) end
    )
    Settings.CreateCheckbox(category, setting, tooltip)
  end
  checkbox(
    "banner",
    L["Banners for riddles and quarries"],
    L["A banner among the game's alerts when you solve a riddle or bring down a quarry (the sounds and the chat lines stay)."]
  )

  local sound = Settings.RegisterProxySetting(
    category,
    "YONDER_SOUND",
    Settings.VarType.Number,
    L["Sound for a trophy"],
    DEFAULTS.sound,
    function() return ns.option("sound") end,
    function(value)
      ns.setOption("sound", value)
      ns.playSound(value)
    end
  )
  Settings.CreateDropdown(category, sound, function()
    local options = Settings.CreateControlTextContainer()
    for _, s in ipairs(ns.SOUNDS) do
      options:Add(s[1], s[2])
    end
    return options:GetData()
  end, L["Played when you slay a rare or a boss for the first time."])

  checkbox(
    "milestoneToast",
    L["Alerts for achievements"],
    L["The game's achievement alert when you earn an achievement (the fanfare and the chat line stay)."]
  )
  checkbox(
    "worldMapPins",
    L["Deaths on the world map"],
    L["Mark on the game's world map where you died and came close, from the Atlas."]
  )
  checkbox(
    "tooltipHints",
    L["Hints on tooltips"],
    L["A line on creature tooltips: not yet in the journal, or how many you have slain."]
  )

  checkbox(
    "minimapHidden",
    L["Minimap button"],
    L["The book by the minimap: click to open the journal, drag to move it."],
    true
  )

  K.collectSetting(category, "YONDER_SHARE", ns.collect)

  -- Another character's settings (of this game), for this one.
  K.copySetting(
    category,
    "YONDER_COPYFROM",
    P,
    L["Another character's choices, for this one (of this game: Classic and Forever keep their own). From elsewhere: /yonder export there, then /yonder import CODE here."],
    function(other) print(ns.PREFIX .. (L["%s's settings copied."]):format(other)) end
  )

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
