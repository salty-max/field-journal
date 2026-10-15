import { expect, test } from "bun:test";
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { readExpeditions } from "./expeditions";

const ROOT = join(import.meta.dir, "..");
const LOCALES = ["enUS", "enGB", "frFR", "deDE", "esES", "esMX", "itIT", "ptBR", "ruRU", "koKR", "zhCN", "zhTW"];
const lua = (s: string) => JSON.stringify(s);

// Exercise authored solutions through the real Lua resolver, with each
// shipped language file loaded first. Checking translated text alone missed
// a GUID's Creature token being compared with Créature / Kreatur.
for (const game of ["classic", "forever"]) {
  test(`every authored solution works in all client languages (${game})`, () => {
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
    // Reuse the game's API and setup from sim.lua, stopping before that
    // file's synthetic translation fixtures register extra emote hooks.
    const prefix = readFileSync(join(ROOT, "addon/test/sim.lua"), "utf8").split("-- A translation: its words and plural rule")[0];
    const run = `${prefix}
do
  local cases = {${cases.join(",\n")}}
  -- Reproduce the reader's report through the actual emote hook and NPC
  -- window event before installing the isolated language readers below.
  do
    local id = "silverpine-forest-wallace"
    ns.expeditions().riddles[id] = nil
    state.map, state.x, state.y = 1421, 0.465, 0.865
    state.health, state.taxi, state.faction, inCombat = 100, false, "Alliance", false
    state.target, state.npc, state.near = 3534, 3534, true
    ns.takeHint(id, 1)
    fire("MERCHANT_SHOW")
    assert(not ns.riddleSolved(id), "Wallace: opening his shop must not solve a greeting")
    for _, token in ipairs({"WAVE", "BOW", "POINT"}) do
      DoEmote(token)
      assert(not ns.riddleSolved(id), "Wallace: wrong action "..token)
    end
    inCombat = true
    DoEmote("HELLO")
    assert(not ns.riddleSolved(id), "Wallace: combat must not solve a riddle")
    inCombat = false
    DoEmote("HELLO")
    assert(ns.riddleSolved(id), "Wallace: nearby targeted hello must work")
    assert(ns.riddleSeal(ns.riddleRecord(id)) == "silver", "Wallace: a paid clue keeps the silver seal")
  end
  local function nothing() end
  local solved, groupTargets = 0, 0
  for _, locale in ipairs({${LOCALES.map(lua).join(",")}}) do
    local journal = {}
    local reader = {PREFIX="", secret=function() return false end, on=nothing,
      journal=function() return journal end, playSound=nothing, toast=nothing,
      checkMilestones=nothing, onRecord=nothing, zoneName=function() return "Zone" end}
    for _, file in ipairs({"Kit.lua", FOREVER and "Data_Forever.lua" or "Data_Classic.lua",
      "Locale.lua", "Text_"..locale..".lua", "Expeditions.lua"}) do
      assert(loadfile(DIR..file))("Yonder", reader)
    end
    -- A future UI label must never alter a protocol-token comparison.
    reader.kit.L["Creature"] = locale == "frFR" and "Créature" or locale == "deDE" and "Kreatur" or "UI label"
    C_Map.GetAreaInfo = function(id) return locale.." area "..id end
    for _, c in ipairs(cases) do
      state.map, state.x, state.y = c.zone, c.x, c.y
      state.sub = c.area and C_Map.GetAreaInfo(c.area) or ""
      state.health, state.taxi, inCombat = 100, false, false
      state.faction = c.side == "horde" and "Horde" or "Alliance"
      state.target, state.npc, state.near = c.npc, c.npc, true
      for _, token in ipairs(c.tokens) do
        journal.expeditions = nil
        if c.action == "arrival" then reader.expeditionAttempt()
        else reader.expeditionAttempt(c.action, token) end
        assert(reader.riddleSolved(c.id), locale..": "..c.id.." "..c.action.." "..token)
      end
      solved = solved + 1
      for _, id in ipairs(c.companions) do
        -- Far from the anchor cells, so this must recognize this companion
        -- through the targeted NPC path rather than pass by location.
        state.x, state.y, state.target = 0.01, 0.01, id
        journal.expeditions = nil
        reader.expeditionAttempt("gesture", c.tokens[1])
        assert(reader.riddleSolved(c.id), locale..": companion "..id.." for "..c.id)
        journal.expeditions = nil
        state.near = false
        reader.expeditionAttempt("gesture", c.tokens[1])
        assert(not reader.riddleSolved(c.id), locale..": distant companion incorrectly counted")
        state.near, state.target = true, 999999
        reader.expeditionAttempt("gesture", c.tokens[1])
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
      env: { ...process.env, FOREVER: game === "forever" ? "1" : "0" },
      stdin: Buffer.from(run), stdout: "pipe", stderr: "pipe",
    });
    expect(result.stderr.toString()).toBe("");
    expect(result.exitCode).toBe(0);
    expect(result.stdout.toString()).toContain(`RIDDLE MATRIX: ${cases.length * LOCALES.length} localized solutions`);
  }, 30000);
}
