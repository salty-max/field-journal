-- The reader's language. The client loads its own Text_<locale>.lua (the
-- TOCs name Text_[TextLocale].lua; scripts/locales.ts writes them from
-- i18n/), which hands its words and texts to ns.translate; English stays
-- wherever it says nothing. Loaded before any file reads a word.
local _, ns = ...
local K = ns.kit
local D = ns.data

-- (is n the "one" form? English, German, Spanish, Italian: 1; French and
-- Brazilian Portuguese: 0 and 1; Russian: 1, 21, 31... but not 11; Korean
-- and Chinese have one form)
local PLURALS = {
  one = function(n) return n == 1 end,
  fr = function(n) return n == 0 or n == 1 end,
  ru = function(n) return n % 10 == 1 and n % 100 ~= 11 end,
  none = function() return false end,
}

-- A plain replacement (names hold the pattern characters: "Comte-du-Lac").
local function replace(s, from, to)
  local out, i = {}, 1
  while true do
    local a, b = s:find(from, i, true)
    if not a then break end
    out[#out + 1] = s:sub(i, a - 1)
    out[#out + 1] = to
    i = b + 1
  end
  out[#out + 1] = s:sub(i)
  return table.concat(out)
end

-- A translated text as this reader reads it: the reader's gender (the game's
-- own token, $gmasculine:feminine;) and, on Classic, its own names for the
-- places Forever renamed (a translation is written with Forever's). English
-- passes as it is. The riddles' veiled texts pass here once unveiled.
ns.localize = function(s) return s end

-- A translation's paragraphs for this game (it holds both games', marked as
-- the English source is).
local function forThisGame(paras, words)
  if not paras then return end
  local out = {}
  for _, p in ipairs(paras) do
    if not p.client or p.client == D.client then table.insert(out, words(p[1])) end
  end
  return out
end

function ns.translate(t)
  ns.locale = t.locale
  K.isOne = PLURALS[t.plural] or K.isOne
  local female = UnitSex and UnitSex("player") == 3
  local swaps = D.client == "classic" and t.classic or nil
  local function words(s)
    if type(s) ~= "string" then return s end
    s = s:gsub("%$g([^:;]*):([^;]*);", function(m, f) return female and f or m end)
    for _, pair in ipairs(swaps or {}) do
      if s:find(pair[1], 1, true) then s = replace(s, pair[1], pair[2]) end
    end
    return s
  end
  ns.localize = words
  -- the creatures' names, this game's (Classic's own where they differ)
  local names = {}
  for id, n in pairs(t.creatures or {}) do
    names[id] = n
  end
  if D.client == "classic" then
    for id, n in pairs(t.creaturesClassic or {}) do
      names[id] = n
    end
  end
  ns.creatureNames = names
  -- the places inside buildings (no area id to ask the client), this game's
  local inside = {}
  for en, tr in pairs(t.subzones or {}) do
    inside[en] = tr
  end
  if D.client == "classic" then
    for en, tr in pairs(t.subzonesClassic or {}) do
      inside[en] = tr
    end
  end
  ns.subzoneNames = inside
  local L = K.L
  for english, word in pairs(t.words or {}) do
    L[english] = words(word)
  end
  for _, s in ipairs(D.sections) do
    s.title = words(t.sections and t.sections[s.id]) or s.title
  end
  for _, f in ipairs(D.families) do
    local tr = t.families and t.families[f.id]
    if tr then
      f.title = words(tr.title) or f.title
      f.note = forThisGame(tr.note, words) or f.note
    end
  end
  for uiMap, z in pairs(D.atlas and D.atlas.zones or {}) do
    z.note = forThisGame(t.atlas and t.atlas[uiMap], words) or z.note
  end
  -- the herbs' and fish's notes; their names are the game's (their items),
  -- their waters' and dungeons' a translation's list
  local places = t.places or {}
  local function named(list)
    for i, name in ipairs(list or {}) do
      list[i] = words(places[name]) or name
    end
  end
  for kind, list in pairs({ herbs = D.flora and D.flora.herbs, fish = D.flora and D.flora.fish }) do
    for id, d in pairs(list or {}) do
      d.note = forThisGame(t[kind] and t[kind][id], words) or d.note
      named(d.subzones)
      named(d.dungeons)
    end
  end
  -- the expeditions: each riddle's verse, hint and danger; what its solving
  -- reads (its answer's name, its note and margin) veiled as the English is;
  -- each quarry's name and poster
  for uiMap, e in pairs(D.expeditions or {}) do
    local tz = t.expeditions and t.expeditions[uiMap]
    if tz then
      for _, r in ipairs(e.riddles or {}) do
        local tr = tz.riddles and tz.riddles[r.id]
        if tr then
          for _, k in ipairs({ "hint", "danger" }) do
            r[k] = words(tr[k]) or r[k]
          end
          for _, k in ipairs({ "name", "note", "margin" }) do
            r[k] = tr[k] or r[k]
          end
          if tr.verse then
            local verse = {}
            for i, line in ipairs(tr.verse) do
              verse[i] = words(line)
            end
            r.verse = verse
          end
        end
      end
      local q, tq = e.quarry, tz.quarry
      if q and tq then
        q.name = words(tq.name) or q.name
        q.note, q.margin = tq.note or q.note, tq.margin or q.margin
        if tq.verse then
          local verse = {}
          for i, line in ipairs(tq.verse) do
            verse[i] = words(line)
          end
          q.verse = verse
        end
      end
    end
  end
end

-- The Atlas's names as the client gives them, in its own language: the zones
-- by their maps, the places by their areas (keyed by those, never by name:
-- a journal is unchanged), the continents. At the login: the game's map
-- tables are ready then.
function ns.localNames()
  local maps = C_Map or {}
  local function mapName(id)
    local info = maps.GetMapInfo and maps.GetMapInfo(id)
    return info and info.name ~= "" and info.name or nil
  end
  local atlas = D.atlas or {}
  for id, name in pairs(atlas.continents or {}) do
    atlas.continents[id] = mapName(id) or name
  end
  for id, z in pairs(atlas.zones or {}) do
    z.name = mapName(id) or z.name
    for _, place in ipairs(z.places or {}) do
      local name = maps.GetAreaInfo and maps.GetAreaInfo(place[6])
      if name and name ~= "" then place[1] = name end
    end
  end
end
