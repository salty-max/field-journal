-- The welcome (the kit's, Kit.lua): once per character, a few seconds after
-- its first login (out of combat; /yonder welcome shows it again), laid out
-- as the journal's window: on the left the logo and what the journal is; on
-- the right this character's choices (Settings.lua: the riddles' and
-- quarries' banners, the trophy's sound, milestone alerts, deaths on the world
-- map, tooltip hints, the minimap button), then another character's to take, chosen among this
-- game's or brought by a code (/yonder export there). Closing it, however,
-- is enough to have seen it.
local _, ns = ...
local L = ns.kit.L
local K = ns.kit

local W = K.welcome({
  name = "YonderWelcome",
  title = L["Welcome to Yonder"],
  art = "Interface\\AddOns\\Yonder\\Media\\Logo",
  logo = "Interface\\AddOns\\Yonder\\Media\\Logo",
  heading = "Yonder",
  tagline = L["Riddles, rare hunts and an explorer's journal."],
  intro = L["The zones you travel hide riddles: a verse that points to a place, and something to do once you stand there. Solve one without a hint and it earns a gold seal. Most zones also have a quarry, a rare creature whose poster tells you where it roams.\n\nOn the way, the journal fills in by itself: the creatures you slay and what they dropped, the lands you explore with your deaths and close calls, the fish and herbs you find, and milestones along the road."],
  profiles = ns.profiles,
  choices = function()
    local sounds = {}
    for _, s in ipairs(ns.SOUNDS) do
      table.insert(sounds, { value = s[1], text = s[2] })
    end
    return {
      {
        text = L["Banners for riddles and quarries"],
        hint = L["Among the game's alerts, when you solve a riddle or bring down a quarry."],
        get = function() return ns.option("banner") end,
        set = function(v) ns.setOption("banner", v) end,
      },
      {
        text = L["Sound for a trophy"],
        hint = L["Heard when you slay a rare or a boss for the first time."],
        options = sounds,
        get = function() return ns.option("sound") end,
        set = function(v)
          ns.setOption("sound", v)
          ns.playSound(v)
        end,
      },
      {
        text = L["Alerts for milestones"],
        hint = L["The game's achievement alert, with its fanfare."],
        get = function() return ns.option("milestoneToast") end,
        set = function(v) ns.setOption("milestoneToast", v) end,
      },
      {
        text = L["Deaths on the world map"],
        hint = L["Where you died and came close, marked on the game's map."],
        get = function() return ns.option("worldMapPins") end,
        set = function(v) ns.setOption("worldMapPins", v) end,
      },
      {
        text = L["Hints on tooltips"],
        hint = L["A creature not yet in the journal, or how many you have slain."],
        get = function() return ns.option("tooltipHints") end,
        set = function(v) ns.setOption("tooltipHints", v) end,
      },
      {
        text = L["The book by the minimap"],
        hint = L["Click it to open the journal; drag it around the minimap."],
        get = function() return not ns.option("minimapHidden") end,
        set = function(v) ns.setOption("minimapHidden", not v) end,
      },
    }
  end,
  footnote = L["Change them any time: /yonder settings, or a right-click on the minimap button. /yonder opens the book."],
  open = { text = L["Open the journal"], click = function() ns.toggle() end },
  exportHint = L["Copy it (Ctrl+C), then on another character: Use a code, or /yonder import CODE."],
  importHint = L["Paste the code (/yonder export on the other character), then press Enter."],
  refused = L["That isn't a Yonder settings code."],
})

-- The welcome; "export": with this character's code ready to copy.
ns.welcome = W -- (its frame, rows, picker and code: for the tests)
function ns.showWelcome(mode) W:Show(mode) end

K.welcomeOnce(W, ns.profiles, function() return ns.journal() ~= nil end)
