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
      const { expeditions } = readExpeditions(ROOT, (file, message) => { throw new Error(`${file}: ${message}`); }, ["classic", "forever"]);
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
