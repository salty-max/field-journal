-- The welcome (the kit's, Kit.lua): once per character, a few seconds after
-- its first login (out of combat; /journal welcome shows it again), laid out
-- as the journal's window: on the left the logo and what the journal is; on
-- the right this character's choices (Settings.lua: chat lines, the trophy's
-- sound, milestone alerts, deaths on the world map, tooltip hints, the
-- minimap button), then another character's to take, chosen among this
-- game's or brought by a code (/journal export there). Closing it, however,
-- is enough to have seen it.
local _, ns = ...
local K = ns.kit

local W = K.welcome({
  name = "FieldJournalWelcome",
  title = "Welcome to Explorer's Field Journal",
  art = "Interface\\Icons\\INV_Misc_Book_11",
  logo = "Interface\\AddOns\\FieldJournal\\Media\\Logo",
  heading = "Field Journal",
  tagline = "A bestiary, an atlas, fish and herbs, filled in as you travel.",
  intro = "A naturalist of the Explorers' League has left you a field journal. Slay a creature of the wild "
    .. "and it is written down, with where you met it and what you took from it; the rare ones become trophies.\n\n"
    .. "The Atlas keeps the lands you have explored, with your deaths and close calls on their maps; the fish "
    .. "and the herbs have their own pages, and milestones mark the way.",
  profiles = ns.profiles,
  choices = function()
    local sounds = {}
    for _, s in ipairs(ns.SOUNDS) do
      table.insert(sounds, { value = s[1], text = s[2] })
    end
    return {
      {
        text = "Announce in chat",
        hint = "A line for each new creature, trophy and milestone, with a link.",
        get = function() return ns.option("chat") end,
        set = function(v) ns.setOption("chat", v) end,
      },
      {
        text = "Sound for a trophy",
        hint = "Heard when you slay a rare or a boss for the first time.",
        options = sounds,
        get = function() return ns.option("sound") end,
        set = function(v)
          ns.setOption("sound", v)
          ns.playSound(v)
        end,
      },
      {
        text = "Milestone alerts",
        hint = "The game's achievement alert for each milestone.",
        get = function() return ns.option("milestoneToast") end,
        set = function(v) ns.setOption("milestoneToast", v) end,
      },
      {
        text = "Deaths on the world map",
        hint = "Where you died and came close, marked on the game's map.",
        get = function() return ns.option("worldMapPins") end,
        set = function(v) ns.setOption("worldMapPins", v) end,
      },
      {
        text = "Hints on tooltips",
        hint = "A creature not yet in the journal, or how many you have slain.",
        get = function() return ns.option("tooltipHints") end,
        set = function(v) ns.setOption("tooltipHints", v) end,
      },
      {
        text = "The book by the minimap",
        hint = "Click it to open the journal; drag it around the minimap.",
        get = function() return not ns.option("minimapHidden") end,
        set = function(v) ns.setOption("minimapHidden", not v) end,
      },
    }
  end,
  footnote = "Change them any time: /journal settings, or a right-click on the minimap button. /journal opens "
    .. "the book.",
  open = { text = "Open the journal", click = function() ns.toggle() end },
  exportHint = "Copy it (Ctrl+C), then on another character: Use a code, or /journal import CODE.",
  importHint = "Paste the code (/journal export on the other character), then press Enter.",
  refused = "That isn't an Explorer's Field Journal settings code.",
})

-- The welcome; "export": with this character's code ready to copy.
ns.welcome = W -- (its frame, rows, picker and code: for the tests)
function ns.showWelcome(mode) W:Show(mode) end

K.welcomeOnce(W, ns.profiles, function() return ns.journal() ~= nil end)
