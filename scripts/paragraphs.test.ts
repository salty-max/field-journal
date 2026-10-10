import { expect, test } from "bun:test";
import { cpSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { forClient, paragraphs } from "./paragraphs";

test("shared prose and each world's account keep their order without markers", () => {
  const source = "A shared\nopening.\n\n[classic] The dome stands.\n\n[forever] The city needs help.\n\nA shared ending.";
  const parsed = paragraphs(source);
  expect(forClient(parsed, "classic")).toEqual(["A shared opening.", "The dome stands.", "A shared ending."]);
  expect(forClient(parsed, "forever")).toEqual(["A shared opening.", "The city needs help.", "A shared ending."]);
});

test("a misspelled game or an empty variant fails rather than leaking into both books", () => {
  expect(() => paragraphs("[forver] A different history.")).toThrow("unknown paragraph client");
  expect(() => paragraphs("[classic]")).toThrow("empty [classic] paragraph");
  expect(paragraphs("\n\n")).toEqual([]);
});

test("invalid notes fail without replacing either book", () => {
  const root = join(import.meta.dir, "..");
  const fixture = mkdtempSync(join(tmpdir(), "field-journal-notes-"));
  try {
    for (const dir of ["content", "atlas", "notes", "data"])
      cpSync(join(root, dir), join(fixture, dir), { recursive: true });
    mkdirSync(join(fixture, "scripts"));
    for (const file of ["build.ts", "paragraphs.ts"])
      cpSync(join(root, "scripts", file), join(fixture, "scripts", file));
    mkdirSync(join(fixture, "addon/FieldJournal"), { recursive: true });
    const build = () => Bun.spawnSync([process.execPath, "scripts/build.ts"], { cwd: fixture });
    expect(build().exitCode).toBe(0);
    const outputs = ["Classic", "Forever"].map((client) => join(fixture, `addon/FieldJournal/Data_${client}.lua`));
    const original = outputs.map((file) => readFileSync(file, "utf8"));
    const cases = [
      ["content/beasts/wolves.md", (s: string) => s.replace(/(---\n[\s\S]*?\n---\n)[\s\S]*/, "$1[forever] Only this world's note.\n"), "no paragraphs for classic"],
      ["atlas/alterac-mountains.md", (s: string) => s + "\n\n[forver] A different history.\n", "unknown paragraph client"],
      ["notes/herbs.md", (s: string) => s.replace(/(^## [^\n]+\n\n)/m, "$1[forver] "), "unknown paragraph client"],
      ["atlas/alterac-mountains.md", (s: string) => s.replace("zone: 1416", "zone: 999999"), "unknown zone 999999"],
    ] as const;
    for (const [path, invalid, message] of cases) {
      const file = join(fixture, path);
      const source = readFileSync(file, "utf8");
      writeFileSync(file, invalid(source));
      const result = build();
      expect(result.exitCode).not.toBe(0);
      expect(result.stderr.toString()).toContain(message);
      expect(outputs.map((output) => readFileSync(output, "utf8"))).toEqual(original);
      writeFileSync(file, source);
    }
  } finally {
    rmSync(fixture, { recursive: true, force: true });
  }
});
