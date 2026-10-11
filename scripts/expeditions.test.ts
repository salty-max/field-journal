import { expect, test } from "bun:test";
import { cells, fnv, veil } from "./expeditions";

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
