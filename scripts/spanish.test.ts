import { expect, test } from "bun:test";
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { readExpeditions } from "./expeditions";

const ROOT = join(import.meta.dir, "..");
const text = (file: string) => readFileSync(join(ROOT, file), "utf8");
const words = JSON.parse(text("i18n/esES/words.json")) as Record<string, string>;
const placeholders = (value: string) => value.match(/%(?:\d+\$)?[-+ #0]*\d*(?:\.\d+)?[cdeEfgGiouXxs%]/g) ?? [];

test("Spanish covers every interface key and preserves formatting arguments", () => {
  expect(Object.keys(words).sort()).toEqual(Object.keys(JSON.parse(text("i18n/words.json"))).sort());
  for (const [key, value] of Object.entries(words)) {
    expect(value.trim().length, key).toBeGreaterThan(0);
    expect(placeholders(value), key).toEqual(placeholders(key));
    expect(value, key).not.toMatch(/[;‘’“”]/);
  }
});

test("Spanish expedition files translate all fields and keep every authored solution", () => {
  const { expeditions, data } = readExpeditions(ROOT, (file, message) => { throw Error(`${file}: ${message}`); }, ["classic", "forever"]);
  const ownNames = new Set(["dun-morogh-range", "duskwood-unseen", "elwynn-forest-cats", "redridge-mountains-docks", "zephras-isle-gustjumpers", "zephras-isle-thendal-tree"]);
  for (const e of expeditions) {
    const file = join("i18n/esES/expeditions", e.file.split("/").at(-1)!);
    const parts = new Map(text(file).split(/^## /m).slice(1).map(part => {
      const [id, ...lines] = part.trim().split("\n");
      return [id, lines.filter(Boolean)] as const;
    }));
    expect([...parts.keys()].sort(), file).toEqual([...e.riddles.map(r => r.id), ...(e.quarry ? ["quarry"] : [])].sort());
    for (const r of e.riddles) {
      const lines = parts.get(r.id)!;
      for (const mark of ["?", "=", "+", "!"]) expect(lines.filter(l => l.startsWith(mark + " ")).length, `${r.id} ${mark}`).toBe(1);
      if (ownNames.has(r.id)) expect(lines.some(l => l.startsWith("@ ")), `${r.id} custom answer`).toBe(true);
      else expect(data.riddles[r.id].names?.esES, `${r.id} game answer`).toBeTruthy();
    }
  }
  expect(readdirSync(join(ROOT, "i18n/esES/expeditions")).length).toBe(expeditions.length);
});
