import { expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { join } from "node:path";
import { cells, readExpeditions } from "./expeditions";

test("the abandoned camp and mortar range never share a discovery cell", () => {
  const { data } = readExpeditions(join(import.meta.dir, ".."), (file, message) => { throw Error(`${file}: ${message}`); }, ["classic", "forever"]);
  const range = data.riddles["dun-morogh-range"];
  const camp = data.riddles["dun-morogh-empty-camp"];
  expect(camp.of).toBe("landmark:dun-morogh-abandoned-camp");
  expect(camp.spots).toEqual([[39.2, 67.6]]);
  expect(camp.npc).toBeUndefined();
  const { w, h } = data.zones["1426"];
  const atRange = new Set(cells(range.spots!, range.r!, w, h));
  expect(cells(camp.spots!, camp.r!, w, h).filter(cell => atRange.has(cell))).toEqual([]);
});

test("distinct discoveries can share an action without duplicating a subject or passive arrival", () => {
  const result = spawnSync("python3", ["-c", `
import sys
sys.path.insert(0, 'scripts')
from expeditions import repeated_sites, reviewed_quests

def check(rs, spots, expected):
    errors = repeated_sites(rs, spots, 1000, 1000)
    assert len(errors) == expected, errors

# Different books, conversations and gestures remain separate discoveries.
check([{'id':'a','object':1,'reading':'Book A'}, {'id':'b','object':2,'reading':'Book B'}], {}, 0)
check([{'id':'a','creature':1,'found':'target'}, {'id':'b','creature':2,'found':'target'}], {}, 0)
check([{'id':'a','creature':1,'gestures':['SALUTE']}, {'id':'b','creature':2,'gestures':['SALUTE']}], {}, 0)
check([{'id':'a','object':1}, {'id':'b','object':2}], {'a':{'spots':[[10,10]],'r':10},'b':{'spots':[[60,60]],'r':10}}, 0)
# Renaming the riddle or selecting another group member cannot duplicate it.
check([{'id':'a','creature':1,'companions':[2]}, {'id':'b','creature':2}], {}, 1)
check([{'id':'a','area':'A'}, {'id':'b','area':'A'}], {}, 1)
# Nearby arrival circles must not award two discoveries for one visit.
check([{'id':'a','object':1}, {'id':'b','object':2}], {'a':{'spots':[[10,10]],'r':10},'b':{'spots':[[11,10]],'r':10}}, 1)

# A deliberate quest-location exception is narrow and documented.
known = {921, 97946, 97949}
assert reviewed_quests({}, known) == set()
assert reviewed_quests({'quest_overlap':[921], 'quest_context':'A drinking gesture, not filling a vial.'}, known) == {921}
for bad in ({'quest_overlap':[921]}, {'quest_context':'Different action'},
            {'quest_overlap':[921,921], 'quest_context':'A different action'},
            {'quest_overlap':[99999], 'quest_context':'A different action'},
            {'quest_overlap':['921'], 'quest_context':'A different action'}):
    try:
        reviewed_quests(bad, known)
    except ValueError:
        pass
    else:
        raise AssertionError(bad)
`], { encoding: "utf8" });
  expect(result.stderr).toBe("");
  expect(result.status).toBe(0);
});
