-- The addon's settings, each character's own (its profile, "Name - Realm",
-- the kit's: Kit.lua), all kept in FieldJournalSettings so that one character
-- can take another's: chosen among this game's characters, or brought by a
-- code (/journal export, /journal import CODE). Their page in the game's
-- Options (AddOns tab): /journal settings, or a right-click on the minimap
-- button; the welcome page (Welcome.lua) offers them too.
--
--   FieldJournalSettings.profiles["Name - Realm"] = { chat, sound,
--     minimapHidden, minimapAngle, tooltipHints, milestoneToast, worldMapPins,
--     welcomed }
--   (the account-wide values of 0.6.0 and before, at the top of the table:
--   the first profile of a character who kept a journal before takes them)
local _, ns = ...
local K = ns.kit

-- (minimapAngle: the button's place around the minimap, in degrees; 225 is
-- lower left, clear of the game's buttons; welcomed: never copied)
local DEFAULTS = {
  chat = true,
  sound = 3175,
  minimapHidden = false,
  minimapAngle = 225,
  tooltipHints = true,
  milestoneToast = true,
  worldMapPins = true,
  welcomed = false,
}
local SHARED = { "chat", "sound", "milestoneToast", "worldMapPins", "tooltipHints", "minimapHidden", "minimapAngle" }

-- Sounds for a trophy: all from the original game's interface. -1 is the
-- sting heard on discovering a new zone, which differs by race.
ns.SOUNDS = {
  { -1, "Zone discovery" },
  { 878, "Quest complete" },
  { 3175, "Map ping" },
  { 8960, "Ready check" },
  { 836, "Page turn" },
  { 844, "Book opening (quiet)" },
  { 0, "None" },
}

-- The profiles: a code "FJ1:c1:s3175:m1:w1:t1:h0:a225" (chat, the trophy's
-- sound, milestone alerts, the world map's marks, tooltip hints, the minimap
-- button hidden, its angle).
local P = K.profiles({
  saved = function()
    if type(FieldJournalSettings) ~= "table" then FieldJournalSettings = {} end
    return FieldJournalSettings
  end,
  defaults = DEFAULTS,
  shared = SHARED,
  letters = {
    chat = "c",
    sound = "s",
    milestoneToast = "m",
    worldMapPins = "w",
    tooltipHints = "t",
    minimapHidden = "h",
    minimapAngle = "a",
  },
  tag = "FJ1",
  changed = function(key)
    if key == "minimapHidden" or key == "minimapAngle" then ns.updateMinimapButton() end
    if key == "worldMapPins" and ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
  end,
})
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

local category

function ns.createSettingsPanel()
  if category or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
  category = Settings.RegisterVerticalLayoutCategory("Explorer's Field Journal")

  local function checkbox(key, name, tooltip, invert)
    invert = invert or false
    local setting = Settings.RegisterProxySetting(
      category,
      "FIELDJOURNAL_" .. key:upper(),
      Settings.VarType.Boolean,
      name,
      not DEFAULTS[key] == invert,
      function() return ns.option(key) ~= invert end,
      function(value) ns.setOption(key, value ~= invert) end
    )
    Settings.CreateCheckbox(category, setting, tooltip)
  end
  checkbox(
    "chat",
    "Announce in chat",
    "A line in chat for each new creature recorded, each trophy (a rare or a boss slain) and each milestone, with a link."
  )

  local sound = Settings.RegisterProxySetting(
    category,
    "FIELDJOURNAL_SOUND",
    Settings.VarType.Number,
    "Sound for a trophy",
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
  end, "Played when you slay a rare or a boss for the first time.")

  checkbox(
    "milestoneToast",
    "Milestone alerts",
    "The game's achievement alert when you earn a milestone (the fanfare and the chat line stay)."
  )
  checkbox(
    "worldMapPins",
    "Deaths on the world map",
    "Mark on the game's world map where you died and came close, from the Atlas."
  )
  checkbox(
    "tooltipHints",
    "Hints on tooltips",
    "A line on creature tooltips: not yet in the journal, or how many you have slain."
  )

  checkbox(
    "minimapHidden",
    "Minimap button",
    "The book by the minimap: click to open the journal, drag to move it.",
    true
  )

  -- Another character's settings (of this game), for this one.
  K.copySetting(
    category,
    "FIELDJOURNAL_COPYFROM",
    P,
    "Another character's choices, for this one (of this game: Classic and Forever keep their own). From elsewhere: /journal export there, then /journal import CODE here.",
    function(other) print(ns.PREFIX .. ("%s's settings copied."):format(other)) end
  )

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
