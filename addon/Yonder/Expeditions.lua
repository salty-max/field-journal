-- The expeditions: riddles that lead to the land's overlooked corners (a grave
-- beside a path, a statue, a book on a shelf), zone by zone (D.expeditions,
-- written by scripts/expeditions.ts from expeditions/). A riddle is solved
-- where it leads, outside combat: by being there, by a gesture made there
-- (the emote's token, every language), by reading there (the game's reader
-- opening), some only by night. Its zone's own riddles are everyone's;
-- a starting zone's and a capital's are its faction's, a faction town's
-- riddle that faction's.
--
-- The data holds no answer, only its fingerprints: where the reader stands
-- (their cell, CELL yards a side on the zone's map; the sub-area they are in;
-- the creature they have targeted near them) and what they do (the gesture),
-- fingerprinted the same way, must match the riddle's. What is read once it
-- is solved (its answer's name, the note, the margin) is veiled likewise.
--
-- Each zone with rares has a quarry too: a foe its lore tells of, brought down
-- as the Bestiary tells a kill; one at a time is the target, its haunts
-- shaded on the world map.
--
--   YonderChar.expeditions = {
--     riddles[id] = { at, level, hints, x, y }   solved (at; x, y: where,
--                                          percents of its zone's map);
--                                          hints: 0, 1 (the clue), 2 (the
--                                          map), taken even before it is
--                                          solved
--     hunts[creature id] = { at, level, tracked, retro, x, y }   brought
--                                          down (at; retro: before the
--                                          journal kept the hunts; x, y:
--                                          where I stood), ever the target
--     target                               the quarry tracked now
--     pinned, pinAt                        the riddle ("<id>") or quarry
--                                          ("quarry:<id>") pinned to the
--                                          screen, and where its card stands
--   }
-- The seal: gold without a hint (and only gold opens the margin), silver
-- with the clue, plain with the map; a quarry's gold if never tracked, plain
-- if it was.
local _, ns = ...
local D = ns.data
local X = D.expeditions or {}
local PREFIX = ns.PREFIX
local secret = ns.secret

local CELL = 5 -- yards (scripts/expeditions.ts)
local SALT = "FJX1"

-- ── fingerprints ─────────────────────────────────────────────────────────────
-- 32-bit FNV-1a in Lua's numbers: the low byte xored, the product by the
-- prime (2^24 + 403) taken apart so it never leaves the exact integers.
local bxor = bit.bxor
local function fnv(s)
  local h = 2166136261
  for i = 1, #s do
    local low = h % 256
    h = h - low + bxor(low, s:byte(i))
    h = (h * 403 + (h % 256) * 16777216) % 4294967296
  end
  return h
end
local function print_(...) return fnv(table.concat({ SALT, ... }, "|")) end
ns.expeditionPrint = print_ -- for the tests

-- A veiled text, read (MINSTD's stream from the riddle's id, as the build's).
local function unveil(text, id)
  local state = fnv(SALT .. "|veil|" .. id) % 2147483646 + 1
  local out = {}
  for i = 1, #text do
    state = (state * 48271) % 2147483647
    out[i] = string.char(32 + (text:byte(i) - 32 - state % 95) % 95)
  end
  return table.concat(out)
end

-- ── the riddles ──────────────────────────────────────────────────────────────
local byId = {}
ns.riddleById = byId
local function set(list)
  local s = {}
  for _, v in ipairs(list or {}) do
    s[v] = true
  end
  return s
end
for uiMap, z in pairs(X) do
  for _, r in ipairs(z.riddles) do
    r.zone, r.atSet, r.bySet = uiMap, set(r.at), set(r.by)
    byId[r.id] = r
  end
end

function ns.riddleName(r) return unveil(r.name, r.id) end
-- its keeper's face (a display id), if it leads to a creature the data knows
function ns.riddleFace(r) return r.face and tonumber(unveil(r.face, r.id)) end
function ns.riddleNote(r) return unveil(r.note, r.id) end
function ns.riddleMargin(r) return unveil(r.margin, r.id) end

local function faction()
  local f = UnitFactionGroup("player")
  return f and not secret(f) and f:lower() or nil
end

-- A riddle this character may solve: its zone's and its town's faction.
function ns.riddleOpen(r)
  local mine = faction()
  local home = X[r.zone].home
  return (not home or home == mine) and (not r.faction or r.faction == mine)
end

-- A zone's riddles this character may solve, in the book's order.
function ns.riddlesOf(uiMap)
  local out = {}
  for _, r in ipairs(X[uiMap] and X[uiMap].riddles or {}) do
    if ns.riddleOpen(r) then table.insert(out, r) end
  end
  return out
end

function ns.expeditions()
  local c = ns.journal()
  if not c then return end
  c.expeditions = c.expeditions or { riddles = {} }
  c.expeditions.hunts = c.expeditions.hunts or {}
  return c.expeditions
end

function ns.riddleRecord(id)
  local e = ns.expeditions()
  return e and e.riddles[id]
end

function ns.riddleSolved(id)
  local rec = ns.riddleRecord(id)
  return rec ~= nil and rec.at ~= nil
end

-- The seals' coins (the book's, the toasts', the pinned cards').
ns.SEAL_ICON = {
  gold = "Interface\\Icons\\INV_Misc_Coin_01",
  silver = "Interface\\Icons\\INV_Misc_Coin_03",
  plain = "Interface\\Icons\\INV_Misc_Coin_05",
}

-- gold, silver or plain: by the hints taken.
function ns.riddleSeal(rec)
  local hints = rec and rec.hints or 0
  return hints == 0 and "gold" or hints == 1 and "silver" or "plain"
end

-- A hint asked for (1: the clue, 2: the map), kept even unsolved.
function ns.takeHint(id, n)
  local e = ns.expeditions()
  if not (e and byId[id]) then return end
  local rec = e.riddles[id] or {}
  rec.hints = math.max(rec.hints or 0, n)
  e.riddles[id] = rec
  if ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
  ns.onRecord()
end

-- ── where the reader is ──────────────────────────────────────────────────────
-- The zone with riddles the reader stands in (a cave's or a building's map
-- belongs to its zone's), and the position on it; nothing while the game
-- hides it.
local function where()
  local uiMap = C_Map.GetBestMapForUnit("player")
  if not uiMap or secret(uiMap) then return end
  for _ = 1, 6 do
    if X[uiMap] then break end
    local info = C_Map.GetMapInfo(uiMap)
    uiMap = info and info.parentMapID
    if not uiMap or uiMap == 0 then return end
  end
  if not X[uiMap] then return end
  local pos = C_Map.GetPlayerMapPosition(uiMap, "player")
  if not pos or secret(pos) then return uiMap end
  local x, y
  if pos.GetXY then
    x, y = pos:GetXY()
  else
    x, y = pos.x, pos.y
  end
  if not x or secret(x) or secret(y) then return uiMap end
  return uiMap, x, y
end

-- The zone's sub-areas the reader stands in (the game names the sub-area in
-- the reader's language: its id is found by that name).
local areaNames = {}
local function areasHere(uiMap)
  local sub = GetSubZoneText()
  if not sub or secret(sub) or sub == "" then return {} end
  sub = strtrim(sub)
  local out = {}
  for _, id in ipairs(X[uiMap].areas) do
    if areaNames[id] == nil then areaNames[id] = strtrim(C_Map.GetAreaInfo(id) or "") end
    if areaNames[id] == sub then table.insert(out, id) end
  end
  return out
end

-- The creature the reader has targeted, near enough to talk to (never one only
-- under the mouse: a passing glance is no meeting).
local function creatureNear(unit)
  local guid = UnitGUID(unit)
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind ~= "Creature" then return end
  local near = CheckInteractDistance(unit, 2)
  if not near or secret(near) then return end
  return tonumber(id)
end

-- The creature the reader is speaking to: a window it opened when spoken to
-- (its words, a quest, its wares, its lessons, its flights).
local function speakingTo()
  local guid = UnitGUID("npc")
  if not guid or secret(guid) then return end
  local kind, _, _, _, _, id = strsplit("-", guid)
  if kind ~= "Creature" then return end
  return tonumber(id)
end

-- Is the reader at the riddle's place? (here: where(), its sub-areas)
local function there(r, here)
  if r.area then
    for _, id in ipairs(here.areas) do
      if r.atSet[print_(r.id, "area", id)] then return true end
    end
    return false
  end
  if here.x then
    local z = X[r.zone]
    local i, j = math.floor(here.x * z.w / CELL), math.floor(here.y * z.h / CELL)
    if r.atSet[print_(r.id, i, j)] then return true end
  end
  if r.npc then
    for _, id in ipairs(here.creatures) do
      if r.npc == print_(r.id, "npc", id) then return true end
    end
  end
  return false
end

-- Night: 6 PM to 6 AM by the game's clock (as the fish's).
local function night()
  local h = GetGameTime()
  return h ~= nil and not secret(h) and (h < 6 or h >= 18)
end

-- ── solving ──────────────────────────────────────────────────────────────────
local function percent(v) return v and math.floor(v * 1000 + 0.5) / 10 end

local function solve(r, x, y)
  local e = ns.expeditions()
  local rec = e.riddles[r.id] or {}
  rec.at, rec.level = time(), UnitLevel("player")
  rec.x, rec.y = percent(x), percent(y)
  e.riddles[r.id] = rec
  if ns.option("chat") then
    print(
      PREFIX
        .. ("a riddle read aright: |cffffd100|Hyonder:x%s|h[%s]|h|r, %s, with a %s seal."):format(
          r.id,
          ns.riddleName(r),
          ns.zoneName(r.zone),
          ns.riddleSeal(rec)
        )
    )
  end
  ns.playSound()
  ns.toast("riddle", r.id)
  ns.checkMilestones()
  if ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
  ns.onRecord()
end

-- The riddles of the reader's zone a deed may solve (asks: what it is, or
-- nil for being there; token: the gesture's), solved if it is theirs: never
-- in combat, nor flown over on a taxi, nor passed by as a ghost. A keeper's
-- riddle that asks no gesture asks a word with the keeper ("talk": spoken
-- to); one that asks a gesture, the keeper targeted.
local function attempt(asks, token)
  if UnitAffectingCombat("player") or UnitOnTaxi("player") or UnitIsDeadOrGhost("player") then return end
  local uiMap, x, y = where()
  if not uiMap then return end
  local here = { x = x, y = y, creatures = {} }
  local gotAreas = false
  for _, r in ipairs(X[uiMap].riddles) do
    local wants = r.asks or (r.npc and "talk") or nil
    if wants == asks and not ns.riddleSolved(r.id) and ns.riddleOpen(r) and (not r.night or night()) then
      if r.area and not gotAreas then
        here.areas, gotAreas = areasHere(uiMap), true
      end
      if r.npc and #here.creatures == 0 then
        local id
        if asks == "talk" then
          id = speakingTo()
        else
          id = creatureNear("target")
        end
        if id then table.insert(here.creatures, id) end
      end
      if (asks ~= "gesture" or r.bySet[print_(r.id, token)]) and there(r, here) then solve(r, x, y) end
    end
  end
end
ns.expeditionAttempt = attempt -- for the tests

-- Being there: each second.
local function tick() attempt(nil) end

-- A gesture: the emote's token, from the chat (/kneel), the emote menu or a
-- macro alike: C_ChatInfo.PerformEmote on today's clients (their DoEmote
-- calls it), DoEmote where there is none.
local function gestured(token)
  if type(token) == "string" and ns.journal() then attempt("gesture", token:upper()) end
end
if C_ChatInfo and C_ChatInfo.PerformEmote then
  hooksecurefunc(C_ChatInfo, "PerformEmote", gestured)
else
  hooksecurefunc("DoEmote", gestured)
end

-- A reading: the game's reader opening on a book, a plaque, a stone.
ns.on("ITEM_TEXT_BEGIN", function() attempt("reading") end)

-- A word with someone: any window a creature opens when spoken to.
for _, event in ipairs({
  "GOSSIP_SHOW",
  "QUEST_GREETING",
  "QUEST_DETAIL",
  "QUEST_PROGRESS",
  "QUEST_COMPLETE",
  "MERCHANT_SHOW",
  "TRAINER_SHOW",
  "TAXIMAP_OPENED",
}) do
  ns.on(event, function() attempt("talk") end)
end

ns.on("PLAYER_LOGIN", function() C_Timer.NewTicker(1, tick) end)

-- ── the hunts ────────────────────────────────────────────────────────────────
local quarryById = {}
ns.quarryById = quarryById
for uiMap, z in pairs(X) do
  if z.quarry then
    z.quarry.zone = uiMap
    quarryById[z.quarry.id] = z.quarry
  end
end

-- Its portrait's display id: a creature of Forever's own carries it, the
-- data knows the others', the Bestiary the rest once met.
function ns.quarryDisplay(q)
  local rec = ns.journal() and ns.journal().creatures[q.id]
  return q.model or (D.models and D.models[q.id]) or (rec and rec.display)
end

function ns.quarryNote(q) return unveil(q.note, "quarry-" .. q.id) end
function ns.quarryMargin(q) return unveil(q.margin, "quarry-" .. q.id) end

-- A quarry this character may hunt: its zone's faction.
function ns.quarryOpen(q)
  local home = X[q.zone].home
  return not home or home == faction()
end

function ns.huntRecord(id)
  local e = ns.expeditions()
  return e and e.hunts[id]
end

function ns.quarryDown(id)
  local rec = ns.huntRecord(id)
  return rec ~= nil and rec.at ~= nil
end

-- gold, never tracked; plain, tracked; before, brought down before the
-- journal kept the hunts (no seal).
function ns.huntSeal(rec)
  if rec and rec.retro then return "before" end
  return rec and rec.tracked and "plain" or "gold"
end

function ns.huntTarget()
  local e = ns.expeditions()
  return e and e.target and quarryById[e.target]
end

-- The quarry tracked (nil: none): ever tracked, it can't earn the gold seal.
function ns.setHuntTarget(id)
  local e = ns.expeditions()
  if not e then return end
  if id then
    local rec = e.hunts[id] or {}
    rec.tracked = true
    e.hunts[id] = rec
  end
  e.target = id
  if ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
  ns.onRecord()
end

-- Brought down (Creatures.lua, at each kill the Bestiary tells).
function ns.quarrySlain(id)
  local q = quarryById[id]
  if not (q and ns.quarryOpen(q)) or ns.quarryDown(id) then return end
  local e = ns.expeditions()
  local rec = e.hunts[id] or {}
  rec.at, rec.level = time(), UnitLevel("player")
  local uiMap, x, y = where()
  if uiMap == q.zone then
    rec.x, rec.y = percent(x), percent(y)
  end
  e.hunts[id] = rec
  if e.target == id then e.target = nil end
  if ns.option("chat") then
    print(
      PREFIX
        .. ("a quarry brought down: |cffffd100|Hyonder:q%d|h[%s]|h|r, %s, with a %s seal."):format(
          id,
          q.name,
          ns.zoneName(q.zone),
          ns.huntSeal(rec)
        )
    )
  end
  -- (a rare's trophy has its own sound)
  local c = ns.journal().creatures[id]
  if not (c and c.trophy and c.trophy.at == rec.at) then ns.playSound() end
  ns.toast("quarry", id)
  if ns.refreshWorldMapPins then ns.refreshWorldMapPins() end
end

-- Quarries brought down before the journal kept the hunts: stamped quietly,
-- at the login, before the milestones they deserve are (Core.lua).
function ns.expeditionsLogin()
  local e = ns.expeditions()
  for id, q in pairs(quarryById) do
    local c = ns.journal().creatures[id]
    if c and (c.slain or 0) > 0 and not (e.hunts[id] and e.hunts[id].at) and ns.quarryOpen(q) then
      local first = c.firstSlain or {}
      local rec = e.hunts[id] or {}
      rec.at, rec.level, rec.retro = first.at or time(), first.level, true
      e.hunts[id] = rec
    end
  end
  -- (the card pinned last time, back where it was left)
  if ns.refreshPin then ns.refreshPin() end
end

-- ── /yonder where: the map and the position, to confirm a spot ──────────────
function ns.whereReport()
  local best = C_Map.GetBestMapForUnit("player")
  local uiMap, x, y = where()
  if not best or secret(best) then
    print(PREFIX .. "the game doesn't say where you are here.")
    return
  end
  local map = uiMap or best
  local pos = x and ("%.2f, %.2f"):format(x * 100, y * 100) or "no position"
  local sub = GetSubZoneText()
  local text = (sub and not secret(sub) and sub ~= "") and (", in %s"):format(sub) or ""
  print(PREFIX .. ("%s (map %d): %s%s."):format(ns.zoneName(map), map, pos, text))
  if uiMap then
    local open, solved = 0, 0
    for _, r in ipairs(ns.riddlesOf(uiMap)) do
      open = open + 1
      if ns.riddleSolved(r.id) then solved = solved + 1 end
    end
    print(("  riddles here: %d, %d solved."):format(open, solved))
  end
end
