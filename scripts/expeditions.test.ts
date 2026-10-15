import { expect, test } from "bun:test";
import { cells, fnv, readExpeditions, veil } from "./expeditions";
import { mkdtempSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

test("fnv is 32-bit FNV-1a", () => {
  expect(fnv("")).toBe(2166136261);
  expect(fnv("a")).toBe(0xe40c292c);
  expect(fnv("foobar")).toBe(0xbf9cf968);
});

test("a veiled text is plain ASCII and comes back", () => {
  const text = "Eliza's Tombstone, \"beloved wife\" ~ {50%}";
  const veiled = veil(text, "duskwood-eliza");
  expect(veiled).not.toBe(text);
  expect(veiled).toMatch(/^[\x20-\x7e]*$/);
  expect(veil(veiled, "duskwood-eliza", true)).toBe(text);
});

test("the cells of a spot are those within its reach", () => {
  // a spot at 50%, 50% of a 1000 by 500 yard map: 500, 250 yards
  const got = cells([[50, 50]], 5, 1000, 500);
  expect(got).toContain("100|50");
  expect(got).toContain("99|49");
  expect(got).not.toContain("98|50");
  expect(got.length).toBe(4);
});

test("a paid clue may name an action while the verse still leaves it to infer", () => {
  const root = mkdtempSync(join(tmpdir(), "yonder-clue-"));
  try {
    mkdirSync(join(root, "data"));
    mkdirSync(join(root, "expeditions"));
    writeFileSync(join(root, "data/expeditions.json"), JSON.stringify({
      zones: { 1421: { w: 1000, h: 1000, areas: [] } }, quarries: {}, emotes: ["HELLO"],
      riddles: { "silverpine-greeting": { zone: 1421, of: "creature:3534", hint: [45, 84, 5], name: "A smith", npc: 3534 } },
    }));
    const file = join(root, "expeditions/silverpine.md");
    const source = `---
zone: 1421
riddles:
  - id: silverpine-greeting
    tier: off
    creature: 3534
    gestures: [HELLO]
    hint_area: { x: 45, y: 84, r: 5 }
    danger: Quiet
    sources: Test fixture
---
## silverpine-greeting
A smith waits beneath the wall.
Let him hear a greeting.
? Target the smith and say hello with an emote.
= A smith.
+ His workshop.
`;
    writeFileSync(file, source);
    const errors: string[] = [];
    readExpeditions(root, (_, message) => errors.push(message), ["classic", "forever"]);
    expect(errors).toEqual([]);
    writeFileSync(file, source.replace("Let him hear a greeting.", "Say hello to him."));
    readExpeditions(root, (_, message) => errors.push(message), ["classic", "forever"]);
    expect(errors.some((message) => message.includes("the verse names the gesture HELLO"))).toBe(true);
  } finally {
    rmSync(root, { recursive: true, force: true });
  }
});
