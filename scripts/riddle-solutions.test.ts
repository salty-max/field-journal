import { expect, test } from "bun:test";
import { join } from "node:path";
import { readExpeditions } from "./expeditions";

const ROOT = join(import.meta.dir, "..");
const LOCALES = ["enUS", "enGB", "frFR", "deDE", "esES", "esMX", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW"];
const lua = (s: string) => JSON.stringify(s);

// Exercise authored solutions through the real Lua resolver, with each
// shipped language file loaded first. Checking translated text alone missed
// a GUID's Creature token being compared with Créature / Kreatur.
for (const game of ["classic", "forever"]) {
  for (const emotes of ["modern", "legacy"]) {
    test(`every authored solution works in all client languages (${game}, ${emotes} emotes)`, () => {
      const { expeditions, data } = readExpeditions(ROOT, (file, message) => { throw new Error(`${file}: ${message}`); }, ["classic", "forever"]);
      const patrol = data.riddles["teldrassil-tree-on-watch"].spots!;
      const patrolSamples = [patrol[0], patrol[Math.floor(patrol.length / 2)], patrol[patrol.length - 1]]
        .map(([x, y]) => `{${x / 100},${y / 100}}`).join(",");
      const cases = expeditions.filter((e) => e.client === "both" || e.client === game).flatMap((e) => e.riddles.map((r) => {
        const s = r.spot;
        const action = r.gestures.length ? "gesture" : r.reading ? "reading" : s.npc ? "talk" : "arrival";
        const tokens = r.gestures.length ? r.gestures : [""];
        return `{id=${lua(r.id)}, zone=${e.zone}, side=${lua(r.faction ?? e.home ?? "alliance")},
          action=${lua(action)}, tokens={${tokens.map(lua).join(",")}},
          x=${(s.spots?.[0]?.[0] ?? 10) / 100}, y=${(s.spots?.[0]?.[1] ?? 10) / 100},
          area=${s.areas?.[0] ?? "nil"}, npc=${s.npc ?? "nil"}, companions={${(s.companions ?? []).join(",")}}}`;
      }));
      const run = `
local makeGame = assert(loadfile("addon/test/riddle-game.lua"))()
local FOREVER = ${game === "forever"}
local MODERN_EMOTES = ${emotes === "modern"}
do
  local cases = {${cases.join(",\n")}}
  -- Reproduce the reader's report through the actual emote hook and NPC
  -- window event before installing the fresh language readers below.
  do
    local game = makeGame("enUS", FOREVER, MODERN_EMOTES)
    local ns, state = game.reader, game.state
    local id = "silverpine-forest-wallace"
    ns.expeditions().riddles[id] = nil
    state.map, state.x, state.y = 1421, 0.465, 0.865
    state.health, state.taxi, state.faction, state.combat = 100, false, "Alliance", false
    state.target, state.npc, state.near = 3534, 3534, true
    ns.takeHint(id, 1)
    game.fire("MERCHANT_SHOW")
    assert(not ns.riddleSolved(id), "Wallace: opening his shop must not solve a greeting")
    for _, token in ipairs({"WAVE", "BOW", "POINT"}) do
      game.emote(token)
      assert(not ns.riddleSolved(id), "Wallace: wrong action "..token)
    end
    state.combat = true
    game.emote("HELLO")
    assert(not ns.riddleSolved(id), "Wallace: combat must not solve a riddle")
    state.combat = false
    game.emote("HELLO")
    assert(ns.riddleSolved(id), "Wallace: nearby targeted hello must work")
    assert(ns.riddleSeal(ns.riddleRecord(id)) == "silver", "Wallace: a paid clue keeps the silver seal")
  end
  -- Cover your own ears: no dwarf target, throughout the camp and
  -- firing range. Targeting Klemmy elsewhere must not bypass the place.
  for _, locale in ipairs({${LOCALES.map(lua).join(",")}}) do
    local game = makeGame(locale, FOREVER, MODERN_EMOTES)
    local ns, state = game.reader, game.state
    local id = "dun-morogh-range"
    state.map, state.target, state.near = 1426, nil, false
    for _, point in ipairs({{0.4066, 0.6488}, {0.412, 0.656}, {0.408, 0.666}}) do
      state.x, state.y = point[1], point[2]
      for _, token in ipairs({"COVEREARS", "DUCK", "COWER", "CRINGE"}) do
        game.journal.expeditions = nil
        game.emote("CHEER")
        assert(not ns.riddleSolved(id), locale..": range: cheering must not count")
        game.emote(token)
        assert(ns.riddleSolved(id), locale..": range: untargeted "..token.." must count")
      end
    end
    game.journal.expeditions = nil
    state.x, state.y, state.target, state.near = 0.5, 0.5, 10805, true
    game.emote("COVEREARS")
    assert(not ns.riddleSolved(id), locale..": range: Klemmy must not bypass the location")
    state.x, state.y, state.target = 0.412, 0.656, nil
    state.combat = true
    game.emote("COVEREARS")
    assert(not ns.riddleSolved(id), locale..": range: combat must not count")
  end
  -- A moonwell visit is its own experience, independent of the water-vial
  -- quest. Other pools, a keeper targeted elsewhere, and simply arriving
  -- must not satisfy the drinking gesture.
  for _, locale in ipairs({${LOCALES.map(lua).join(",")}}) do
    local game = makeGame(locale, FOREVER, MODERN_EMOTES)
    local ns, state = game.reader, game.state
    local id = "teldrassil-shadowglen-moonwell"
    state.map, state.target, state.npc, state.near = 1438, nil, nil, false
    for _, point in ipairs({{0.5995, 0.3305}, {0.599, 0.331}}) do
      state.x, state.y = point[1], point[2]
      for _, token in ipairs({"DRINK", "THIRSTY"}) do
        game.journal.expeditions = nil
        game.tick()
        assert(not ns.riddleSolved(id), locale..": moonwell: arrival must not count")
        game.emote("BOW")
        assert(not ns.riddleSolved(id), locale..": moonwell: wrong gesture must not count")
        game.emote(token)
        assert(ns.riddleSolved(id), locale..": moonwell: untargeted "..token.." must count")
      end
    end
    for _, point in ipairs({{0.6338, 0.5809}, {0.4241, 0.6708}, {0.3844, 0.3406}, {0.5603, 0.6195}}) do
      game.journal.expeditions = nil
      state.x, state.y, state.target, state.near = point[1], point[2], 3514, true
      game.emote("DRINK")
      assert(not ns.riddleSolved(id), locale..": moonwell: another pool or target must not count")
    end
    state.x, state.y, state.target, state.near = 0.5995, 0.3305, nil, false
    for _, gate in ipairs({"combat", "taxi", "ghost", "horde"}) do
      state.combat, state.taxi = gate == "combat", gate == "taxi"
      state.health, state.faction = gate == "ghost" and 0 or 100, gate == "horde" and "Horde" or "Alliance"
      game.emote("DRINK")
      assert(not ns.riddleSolved(id), locale..": moonwell: "..gate.." must not count")
    end
  end
  -- New discoveries: source positions alone must not substitute for the
  -- intended place or deed, or reuse another NPC with the same entry ID.
  for _, locale in ipairs({${LOCALES.map(lua).join(",")}}) do
    local game = makeGame(locale, FOREVER, MODERN_EMOTES)
    local ns, state, journal = game.reader, game.state, game.journal
    local function fresh(map, x, y, inside, target, near)
      journal.expeditions = nil
      state.map, state.x, state.y, state.indoors = map, x, y, inside
      state.target, state.npc, state.near = target, nil, near
      state.faction, state.combat, state.taxi, state.health = "Alliance", false, false, 100
    end
    local inn = "teldrassil-keldamyr"
    for _, token in ipairs({"SLEEP", "LAYDOWN"}) do
      -- An area and a rest gesture. No indoor flag, target or live keeper.
      for _, point in ipairs({{0.5562, 0.5979}, {0.56, 0.60}, {0.551, 0.595}}) do
        fresh(1438, point[1], point[2], false, nil, false)
        game.tick()
        game.emote("SIT")
        assert(not ns.riddleSolved(inn), locale..": inn: arrival or sitting is not sleeping")
        game.emote(token)
        assert(ns.riddleSolved(inn), locale..": inn: untargeted rest in the inn area must count without an indoor flag")
      end
      fresh(1438, 0.5562, 0.5979, true, 3605, true)
      game.emote(token)
      assert(ns.riddleSolved(inn), locale..": inn: an incidental target must not block rest")
      fresh(1438, 0.57, 0.60, true, 6736, true)
      game.emote(token)
      assert(not ns.riddleSolved(inn), locale..": inn: targeting Keldamyr outside the area must not count")
      fresh(1438, nil, nil, true, 6736, true)
      game.emote(token)
      assert(not ns.riddleSolved(inn), locale..": inn: a target cannot bypass the area check")
    end
    local tree = "teldrassil-tree-on-watch"
    -- Independently checked Classic route waypoints 13 and 14 lie just beyond
    -- the hint circle. They still need to fit the actual patrol tolerance.
    for _, point in ipairs({${patrolSamples}, {0.5415168589376046, 0.5829804788213627}, {0.5425479555335762, 0.5834460405156538}}) do
      for _, token in ipairs({"SALUTE", "BOW", "THANK"}) do
        fresh(1438, point[1], point[2], false, nil, true)
        game.emote(token)
        assert(not ns.riddleSolved(tree), locale..": patrol: position alone must not count")
        state.target = 3571
        game.emote(token)
        assert(not ns.riddleSolved(tree), locale..": patrol: a sentinel is not the tree")
        state.target, state.near = 2041, false
        game.emote(token)
        assert(not ns.riddleSolved(tree), locale..": patrol: distant target must not count")
        state.near = true
        game.emote(token)
        assert(ns.riddleSolved(tree), locale..": patrol: nearby tree along the route must count")
      end
    end
    fresh(1438, 0.3683, 0.5527, false, 2041, true)
    game.emote("SALUTE")
    assert(not ns.riddleSolved(tree), locale..": patrol: Darnassus protector with same ID must not count")
    fresh(1438, nil, nil, false, 2041, true)
    game.emote("SALUTE")
    assert(not ns.riddleSolved(tree), locale..": patrol: missing position must not bypass locality")
    local crypt = "badlands-hidden-crypt"
    fresh(1418, 0.538, 0.433, false, nil, false)
    game.tick()
    assert(not ns.riddleSolved(crypt), locale..": crypt: Sigrun's actual camp is not the sword's position")
    fresh(1418, 0.57252, 0.40027, false, nil, false)
    game.tick()
    assert(ns.riddleSolved(crypt), locale..": crypt: sword position counts without an unverified indoor flag")
    local farm = "arathi-highlands-coastal-farm"
    fresh(1417, 0.91346, 0.70007, false, nil, false)
    state.faction = "Horde"
    game.tick()
    assert(ns.riddleSolved(farm), locale..": farm: no live ram, target, conversation or faction restriction")
    fresh(1417, 0.5, 0.5, false, 2098, true)
    game.tick()
    assert(not ns.riddleSolved(farm), locale..": farm: a ram elsewhere cannot substitute for the stable")
    local camp = "dun-morogh-empty-camp"
    fresh(1426, 0.407, 0.649, false, 1128, true)
    game.tick()
    assert(not ns.riddleSolved(camp), locale..": camp: range and targeted bear are not the abandoned camp")
    fresh(1426, 0.419, 0.669, false, nil, false)
    game.tick()
    assert(not ns.riddleSolved(camp), locale..": camp: the old bear-spawn guess must not count")
    fresh(1426, 0.392, 0.676, false, nil, false)
    game.tick()
    assert(ns.riddleSolved(camp), locale..": camp: owner-confirmed 39.2, 67.6 solves by arrival, no bear needed")
    game.emote("COVEREARS")
    assert(not ns.riddleSolved("dun-morogh-range"), locale..": camp: visit must not double as the mortar solution")
    fresh(1426, 0.397, 0.676, false, nil, false)
    game.tick()
    assert(not ns.riddleSolved(camp), locale..": camp: being elsewhere in Dun Morogh must not count")
  end
  local solved, groupTargets = 0, 0
  for _, locale in ipairs({${LOCALES.map(lua).join(",")}}) do
    local game = makeGame(locale, FOREVER, MODERN_EMOTES)
    local reader, state, journal = game.reader, game.state, game.journal
    -- A future UI label must never alter a protocol-token comparison.
    reader.kit.L["Creature"] = locale == "frFR" and "Créature" or locale == "deDE" and "Kreatur" or "UI label"
    for _, c in ipairs(cases) do
      state.map, state.x, state.y = c.zone, c.x, c.y
      state.sub = c.area and C_Map.GetAreaInfo(c.area) or ""
      state.health, state.taxi, state.combat = 100, false, false
      state.faction = c.side == "horde" and "Horde" or "Alliance"
      state.target, state.npc, state.near = c.npc, c.npc, true
      for _, token in ipairs(c.tokens) do
        journal.expeditions = nil
        if c.action == "arrival" then game.tick()
        elseif c.action == "gesture" then game.emote(token)
        elseif c.action == "reading" then game.fire("ITEM_TEXT_BEGIN")
        else game.fire("GOSSIP_SHOW") end
        assert(reader.riddleSolved(c.id), locale..": "..c.id.." "..c.action.." "..token)
      end
      solved = solved + 1
      for _, id in ipairs(c.companions) do
        -- Far from the anchor cells, so this must recognize this companion
        -- through the targeted NPC path rather than pass by location.
        state.x, state.y, state.target = 0.01, 0.01, id
        journal.expeditions = nil
        game.emote(c.tokens[1])
        assert(reader.riddleSolved(c.id), locale..": companion "..id.." for "..c.id)
        journal.expeditions = nil
        state.near = false
        game.emote(c.tokens[1])
        assert(not reader.riddleSolved(c.id), locale..": distant companion incorrectly counted")
        state.near, state.target = true, 999999
        game.emote(c.tokens[1])
        assert(not reader.riddleSolved(c.id), locale..": unrelated NPC incorrectly counted")
        groupTargets = groupTargets + 1
      end
    end
  end
  io.write("RIDDLE MATRIX: "..solved.." localized solutions, "..groupTargets.." companion targets\\n")
end
      `;
      const result = Bun.spawnSync(["luajit", "-"], {
        cwd: ROOT,
        stdin: Buffer.from(run), stdout: "pipe", stderr: "pipe",
      });
      expect(result.stderr.toString()).toBe("");
      expect(result.exitCode).toBe(0);
      expect(result.stdout.toString()).toContain(`RIDDLE MATRIX: ${cases.length * LOCALES.length} localized solutions`);
    }, 30000);
  }
}
