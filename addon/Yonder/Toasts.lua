-- A milestone earned: the game's own achievement alert (the kit's: the
-- journal's book, "Yonder milestone", its name; the banner where the
-- client has none). The rest, banners (the kit's: a card in the book's look,
-- which the game's alert stack places with its own), each deed its own, so a
-- deed that earns two shows both, never one in place of the other: a riddle read aright, what it led to (its keeper's face, a
-- book, a place) with the seal earned as a medal on it; a quarry brought
-- down, its face and its seal. A click opens the book there, a right-click or
-- the cross dismisses it. Turned off in the settings, a milestone's
-- (milestoneToast) and the riddles' and quarries' (banner) apart; /yonder
-- toast shows one.
local _, ns = ...
local PREFIX = ns.PREFIX

local BOOK = "Interface\\AddOns\\Yonder\\Media\\Logo"
local SECONDS = 8
local banners, achievements

-- What a banner of this kind shows.
local function about(kind, id)
  if kind == "milestone" then
    return {
      picture = BOOK,
      kicker = "Yonder milestone",
      title = ns.milestoneById[id].title,
      tip = "Click to see your milestones",
      click = function() ns.openMilestones(id) end,
    }
  elseif kind == "riddle" then
    local r = ns.riddleById[id]
    return {
      picture = ns.riddlePicture(r),
      medal = ns.SEALS[ns.riddleSeal(ns.riddleRecord(id))],
      kicker = "A riddle read aright",
      title = ns.riddleName(r),
      tip = "Click to read it in the journal",
      click = function() ns.openRiddle(id) end,
    }
  end
  local q = ns.quarryById[id]
  local seal = ns.HUNT_SEALS[ns.huntSeal(ns.huntRecord(id))]
  return {
    picture = ns.quarryPicture(q),
    medal = seal[1] and seal or nil,
    kicker = "A quarry brought down",
    title = q.name,
    tip = "Click to see its poster",
    click = function() ns.openQuarry(id) end,
  }
end

local function show(kind, id)
  banners = banners or ns.kit.banners({ name = "YonderBanner", art = BOOK, seconds = SECONDS })
  achievements = achievements
    or ns.kit.achievements({ banners = banners, art = BOOK, say = function(m) print(PREFIX .. m) end })
  -- (what can't be told still shows: the journal's book and its name)
  local ok, b = pcall(about, kind, id)
  if not ok then b = { picture = BOOK, kicker = "Yonder", title = "" } end
  b.kind, b.id = kind, id
  if kind == "milestone" then
    achievements:show(b)
  else
    banners:show(b)
  end
  return banners
end

-- A banner: ("milestone", its id), ("riddle", its id), ("quarry", its creature id).
function ns.toast(kind, id)
  if not ns.option(kind == "milestone" and "milestoneToast" or "banner") then return end
  show(kind, id)
end

-- /yonder toast: the last riddle solved (else any of this character's), as
-- its banner would show it, and where it stands.
function ns.toastTest()
  local best, at
  for id, r in pairs(ns.riddleById) do
    local rec = ns.riddleRecord(id)
    if ns.riddleOpen(r) and (not best or (rec and rec.at or 0) > at) then
      best, at = id, rec and rec.at or 0
    end
  end
  if not best then
    print(PREFIX .. "no riddle in this game to show.")
    return
  end
  local b = show("riddle", best)
  print(
    PREFIX
      .. (
        b.frames[1].joined and "a riddle's banner, among the game's own alerts."
        or "a riddle's banner, at the top of the screen (the game's alerts couldn't take it)."
      )
  )
end
