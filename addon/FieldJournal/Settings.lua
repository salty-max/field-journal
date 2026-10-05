-- The addon's settings, kept for the whole account in FieldJournalSettings,
-- and their page in the game's Options (AddOns tab). /journal settings opens it;
-- so does a right-click on the minimap button.
local _, ns = ...

local DEFAULTS = { chat = true, sound = 3175, minimapHidden = false, tooltipHints = true }

-- Sounds for a new family or a trophy: all from the original game's interface. -1 is the
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

function ns.option(key)
  FieldJournalSettings = FieldJournalSettings or {}
  local v = FieldJournalSettings[key]
  if v == nil then return DEFAULTS[key] end
  return v
end

function ns.setOption(key, value)
  FieldJournalSettings = FieldJournalSettings or {}
  FieldJournalSettings[key] = value
  if key == "minimapHidden" then ns.updateMinimapButton() end
end

-- The exploration sound kit of each race (Undead's token is Scourge).
local DISCOVERY = { Human = 4140, Orc = 4141, Scourge = 4142, Tauren = 4143, Troll = 4144, NightElf = 4145, Gnome = 4146, Dwarf = 4147 }

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
    local setting = Settings.RegisterProxySetting(category, "FIELDJOURNAL_" .. key:upper(), Settings.VarType.Boolean, name,
      not DEFAULTS[key] == invert,
      function() return ns.option(key) ~= invert end,
      function(value) ns.setOption(key, value ~= invert) end)
    Settings.CreateCheckbox(category, setting, tooltip)
  end
  checkbox("chat", "Announce in chat", "A line in chat for each new family met and each trophy (a rare or a boss slain).")

  local sound = Settings.RegisterProxySetting(category, "FIELDJOURNAL_SOUND", Settings.VarType.Number, "Sound for a new family",
    DEFAULTS.sound,
    function() return ns.option("sound") end,
    function(value) ns.setOption("sound", value); ns.playSound(value) end)
  Settings.CreateDropdown(category, sound, function()
    local options = Settings.CreateControlTextContainer()
    for _, s in ipairs(ns.SOUNDS) do options:Add(s[1], s[2]) end
    return options:GetData()
  end, "Played when a new family or a trophy is added to the journal.")

  checkbox("tooltipHints", "Hints on tooltips", "A line on creature tooltips: not yet in the journal, or how many you have slain.")

  checkbox("minimapHidden", "Minimap button", "The book by the minimap: click to open the journal, drag to move it.", true)

  Settings.RegisterAddOnCategory(category)
end

function ns.openSettings()
  if category then Settings.OpenToCategory(category:GetID()) end
  return category ~= nil
end
