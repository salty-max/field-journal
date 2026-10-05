/**
 * content/<section>/<family>.md + data/creatures.json → the Bestiary's data,
 * one Lua file per game: addon/FieldJournal/Data_Classic.lua,
 * Data_Forever.lua (scripts/package.ts ships each as Data.lua).
 *
 * A section (content/<section>/_section.md: title, type, order) holds the
 * families of one creature type. A family:
 *
 *   ---
 *   id: wolves
 *   title: Wolves
 *   order: 10
 *   client: forever            # optional: on this game only
 *   match:                     # how creatures are sorted into it
 *     - ids: 1132, 525         # these creature ids (any type)
 *     - people: gnolls         # a people's id list (data/peoples.json, any type)
 *     - name: "\b(Wolf|Worg)\b" # a name pattern (the section's type only,
 *     - anytype: true          #   or every type with this flag)
 *     - beast: 1               # a tameable beast family (CreatureFamily id)
 *     - fallback: true         # every creature of the section's type left over
 *   ---
 *   The naturalist's note: paragraphs separated by blank lines.
 *
 * Each creature goes to the first rule that claims it, in this order: ids,
 * people, name, beast, fallback. Two families claiming a creature at the same
 * level is an error (except names: the family with the lower order wins, and
 * the build lists such overlaps with --verbose).
 *
 *   bun scripts/build.ts             write the data files
 *   bun scripts/build.ts --check     fail if one isn't up to date
 *   bun scripts/build.ts --verbose   also list name overlaps and unsorted creatures
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";

const ROOT = join(import.meta.dir, "..");
const CONTENT = join(ROOT, "content");
const VERBOSE = process.argv.includes("--verbose");
const CLIENTS = ["classic", "forever"];

type Creature = { id: number; name: string; type: string; family: number; rank: string; levels: [number, number]; model: number };
type Rule = { kind: "ids"; ids: number[] } | { kind: "people"; people: string } | { kind: "name"; re: RegExp } | { kind: "beast"; family: number } | { kind: "fallback" };
type Family = { id: string; title: string; order: number; section: string; type: string; anytype: boolean; client: string; rules: Rule[]; note: string[]; file: string };
type Section = { id: string; title: string; type: string; order: number };

const errors: string[] = [];
const fail = (file: string, msg: string) => errors.push(`${relative(ROOT, file)}: ${msg}`);

function frontMatter(file: string, src: string): { meta: Record<string, string | string[]>; body: string } {
  const m = src.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!m) {
    fail(file, "no front matter");
    return { meta: {}, body: src };
  }
  const meta: Record<string, string | string[]> = {};
  let list: string[] | null = null;
  for (const raw of m[1].split("\n")) {
    const line = raw.replace(/\s+#\s.*$/, "");
    if (!line.trim()) continue;
    const item = line.match(/^\s+-\s+(.*)$/);
    if (item && list) {
      list.push(item[1].trim());
      continue;
    }
    const kv = line.match(/^([a-z]+):\s*(.*)$/);
    if (!kv) {
      fail(file, `can't read "${raw}"`);
      continue;
    }
    if (kv[2] === "") meta[kv[1]] = list = [];
    else {
      meta[kv[1]] = kv[2].trim();
      list = null;
    }
  }
  return { meta, body: m[2] };
}

const creatures: Creature[] = JSON.parse(readFileSync(join(ROOT, "data/creatures.json"), "utf8"));
const peoples: Record<string, number[]> = JSON.parse(readFileSync(join(ROOT, "data/peoples.json"), "utf8"));

// ── sections and families ─────────────────────────────────────────────────────
const sections = new Map<string, Section>();
const families: Family[] = [];
for (const dir of readdirSync(CONTENT).sort()) {
  const path = join(CONTENT, dir);
  if (!statSync(path).isDirectory()) continue;
  const head = join(path, "_section.md");
  const { meta: s } = frontMatter(head, readFileSync(head, "utf8"));
  const section: Section = { id: dir, title: String(s.title ?? dir), type: String(s.type ?? ""), order: Number(s.order ?? 99) };
  sections.set(dir, section);
  for (const f of readdirSync(path).sort()) {
    if (!f.endsWith(".md") || f === "_section.md") continue;
    const file = join(path, f);
    const source = readFileSync(file, "utf8");
    const odd = source.match(/[^\x00-\x7f]/);
    if (odd) fail(file, `non-ASCII character "${odd[0]}": use ' for apostrophes, plain quotes and dashes`);
    const { meta, body } = frontMatter(file, source);
    const rules: Rule[] = [];
    let anytype = false;
    for (const r of Array.isArray(meta.match) ? meta.match : []) {
      const m = r.match(/^(\w+):\s*(.*)$/);
      if (!m) {
        fail(file, `match: can't read "${r}"`);
        continue;
      }
      const [, key, value] = m;
      if (key === "ids") rules.push({ kind: "ids", ids: value.split(",").map((s) => Number(s.trim())).filter(Boolean) });
      else if (key === "people") {
        if (!peoples[value]) fail(file, `people: no list "${value}" in data/peoples.json`);
        rules.push({ kind: "people", people: value });
      } else if (key === "name") {
        try {
          rules.push({ kind: "name", re: new RegExp(value.replace(/^"|"$/g, "")) });
        } catch (e) {
          fail(file, `name: ${e}`);
        }
      } else if (key === "beast") rules.push({ kind: "beast", family: Number(value) });
      else if (key === "fallback") rules.push({ kind: "fallback" });
      else if (key === "anytype") anytype = value === "true";
      else fail(file, `match: unknown rule "${key}"`);
    }
    const id = String(meta.id ?? "");
    if (!/^[a-z0-9-]+$/.test(id)) fail(file, "id: lowercase words joined by dashes");
    const client = typeof meta.client === "string" ? meta.client : "";
    if (client && !CLIENTS.includes(client)) fail(file, `client: one of ${CLIENTS.join(", ")}`);
    families.push({
      id,
      title: String(meta.title ?? id),
      order: Number(meta.order ?? 999),
      section: dir,
      type: section.type,
      anytype,
      client,
      rules,
      note: body.trim() ? body.trim().split(/\n\s*\n/).map((p) => p.replace(/\s*\n\s*/g, " ").trim()) : [],
      file,
    });
  }
}
families.sort((a, b) => a.order - b.order);
const ids = new Set<string>();
for (const f of families) {
  if (ids.has(f.id)) fail(f.file, `duplicate id ${f.id}`);
  ids.add(f.id);
}

// ── sorting creatures into families ───────────────────────────────────────────
const LEVELS = ["ids", "people", "name", "beast", "fallback"] as const;
const claims = (f: Family, c: Creature, level: (typeof LEVELS)[number]) =>
  f.rules.some((r) => {
    if (r.kind !== level) return false;
    if (r.kind === "ids") return r.ids.includes(c.id);
    if (r.kind === "people") return peoples[r.people]?.includes(c.id);
    if (r.kind === "name") return (f.anytype || c.type === f.type) && r.re.test(c.name);
    if (r.kind === "beast") return c.type === "Beast" && c.family === r.family;
    return c.type === f.type;
  });

const familyOf = new Map<number, Family>();
const overlaps: string[] = [];
const unsorted: Creature[] = [];
for (const c of creatures) {
  let chosen: Family | undefined;
  for (const level of LEVELS) {
    const hits = families.filter((f) => claims(f, c, level));
    if (!hits.length) continue;
    if (hits.length > 1) {
      const msg = `${c.id} ${c.name} (${c.type}): ${hits.map((f) => f.id).join(", ")}`;
      if (level === "name") overlaps.push(msg);
      else errors.push(`claimed twice at "${level}": ${msg}`);
    }
    chosen = hits[0];
    break;
  }
  if (chosen) familyOf.set(c.id, chosen);
  else unsorted.push(c);
}

if (errors.length) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}

// ── Lua ─────────────────────────────────────────────────────────────────────
const q = (s: string) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;
// Ranks worth a mark: rare, rare elite, boss (elite and normal are the default).
const RANK = { rare: "r", rareelite: "R", boss: "b" } as Record<string, string>;
const GAMES = [
  { client: "classic", out: join(ROOT, "addon/FieldJournal/Data_Classic.lua") },
  { client: "forever", out: join(ROOT, "addon/FieldJournal/Data_Forever.lua") },
];

function luaFor(client: string) {
  const kept = families.filter((f) => !f.client || f.client === client);
  const index = new Map(kept.map((f, i) => [f.id, i + 1]));
  const sorted = creatures.filter((c) => familyOf.has(c.id) && index.has(familyOf.get(c.id)!.id));
  const lua = `-- Generated by scripts/build.ts from content/ and data/: edit those, not this file.
local _, ns = ...
ns.data = {
  client = ${q(client)},
  sections = {
${[...sections.values()]
  .sort((a, b) => a.order - b.order)
  .map((s) => `    { id = ${q(s.id)}, title = ${q(s.title)}, type = ${q(s.type)} },`)
  .join("\n")}
  },
  families = {
${kept
  .map((f) => `    { id = ${q(f.id)}, title = ${q(f.title)}, section = ${q(f.section)}, note = { ${f.note.map(q).join(", ")} } },`)
  .join("\n")}
  },
  -- creature id = family index (into families above)
  creatures = {
${chunks(sorted.map((c) => `[${c.id}]=${index.get(familyOf.get(c.id)!.id)}`), 12).join("\n")}
  },
  -- creature id = display id (the 3D portrait)
  models = {
${chunks(sorted.filter((c) => c.model).map((c) => `[${c.id}]=${c.model}`), 10).join("\n")}
  },
  -- marks: r rare, R rare elite, b boss
  ranks = {
${chunks(sorted.filter((c) => RANK[c.rank]).map((c) => `[${c.id}]="${RANK[c.rank]}"`), 12).join("\n")}
  },
}
`;
  return { lua, families: kept.length, creatures: sorted.length };
}

function chunks(items: string[], n: number) {
  const out: string[] = [];
  for (let i = 0; i < items.length; i += n) out.push("    " + items.slice(i, i + n).join(", ") + ",");
  return out;
}

// ── report and write ─────────────────────────────────────────────────────────
const perFamily = new Map<string, number>();
for (const f of familyOf.values()) perFamily.set(f.id, (perFamily.get(f.id) ?? 0) + 1);
const empty = families.filter((f) => !perFamily.get(f.id));
const noNote = families.filter((f) => !f.note.length);
if (VERBOSE) {
  for (const f of families) console.log(`  ${String(perFamily.get(f.id) ?? 0).padStart(4)}  ${f.id}`);
  if (overlaps.length) console.log(`name overlaps (lower order wins):\n  ${overlaps.join("\n  ")}`);
  if (unsorted.length) console.log(`unsorted:\n  ${unsorted.map((c) => `${c.id} ${c.name} (${c.type})`).join("\n  ")}`);
}
if (empty.length) console.log(`! families with no creature: ${empty.map((f) => f.id).join(", ")}`);
if (unsorted.length) console.log(`! ${unsorted.length} creatures fit no family (--verbose lists them)`);
if (noNote.length) console.log(`! ${noNote.length} of ${families.length} families have no note yet`);

if (process.argv.includes("--check")) {
  let stale = false;
  for (const g of GAMES) {
    const { lua, creatures: n } = luaFor(g.client);
    let current = "";
    try {
      current = readFileSync(g.out, "utf8");
    } catch {}
    if (current !== lua) {
      console.error(`✗ ${relative(ROOT, g.out)} is out of date: run bun scripts/build.ts`);
      stale = true;
    } else console.log(`✓ ${relative(ROOT, g.out)} up to date (${n} creatures)`);
  }
  if (stale) process.exit(1);
} else {
  for (const g of GAMES) {
    const { lua, families: nf, creatures: nc } = luaFor(g.client);
    writeFileSync(g.out, lua);
    console.log(`✓ ${g.client}: ${nc} creatures in ${nf} families → ${relative(ROOT, g.out)}`);
  }
}
