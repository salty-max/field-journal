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
 *   The naturalist's note: paragraphs separated by blank lines. Prefix a
 *   paragraph with [classic] or [forever] for an account specific to that world.
 *
 * Each creature goes to the first rule that claims it, in this order: ids,
 * people, name (of the creature's own type), beast, name (from a family with
 * anytype: another type's pattern), fallback. So a raptor stays a raptor even
 * if a plant's pattern matches its name. Two families claiming a creature at the same
 * level is an error (except names: the family with the lower order wins, and
 * the build lists such overlaps with --verbose).
 *
 *   bun scripts/build.ts             write the data files
 *   bun scripts/build.ts --check     fail if one isn't up to date
 *   bun scripts/build.ts --verbose   also list name overlaps and unsorted creatures
 */
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";
import { forClient, paragraphs, type Paragraph } from "./paragraphs";

const ROOT = join(import.meta.dir, "..");
const CONTENT = join(ROOT, "content");
const VERBOSE = process.argv.includes("--verbose");
const CLIENTS = ["classic", "forever"];

type Creature = { id: number; name: string; type: string; family: number; rank: string; levels: [number, number]; model: number };
type Rule = { kind: "ids"; ids: number[] } | { kind: "people"; people: string } | { kind: "name"; re: RegExp } | { kind: "beast"; family: number } | { kind: "fallback" };
type Family = { id: string; title: string; order: number; section: string; type: string; anytype: boolean; client: string; rules: Rule[]; note: Paragraph[]; file: string };
type Section = { id: string; title: string; type: string; order: number };

const errors: string[] = [];
const fail = (file: string, msg: string) => errors.push(`${relative(ROOT, file)}: ${msg}`);

function note(file: string, body: string): Paragraph[] {
  try { return paragraphs(body); }
  catch (error) { fail(file, String(error)); return []; }
}

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
      note: note(file, body),
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
const LEVELS = ["ids", "people", "name", "beast", "anyname", "fallback"] as const;
const claims = (f: Family, c: Creature, level: (typeof LEVELS)[number]) =>
  f.rules.some((r) => {
    if (level === "anyname") return r.kind === "name" && f.anytype && c.type !== f.type && r.re.test(c.name);
    if (r.kind !== level) return false;
    if (r.kind === "ids") return r.ids.includes(c.id);
    if (r.kind === "people") return peoples[r.people]?.includes(c.id);
    if (r.kind === "name") return c.type === f.type && r.re.test(c.name);
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
      if (level === "name" || level === "anyname") overlaps.push(msg);
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

// Rares by zone (data/rare-zones.json, from scripts/rare_zones.py), and the
// zones' English names (the client's UiMap, cached by that script).
const rareZone: Record<string, number> = JSON.parse(readFileSync(join(ROOT, "data/rare-zones.json"), "utf8"));
const zoneNames: Record<number, string> = Object.fromEntries(
  readFileSync(join(ROOT, "data/zones.csv"), "utf8").trim().split("\n").slice(1).map((l) => {
    const [id, ...name] = l.split(",");
    return [Number(id), name.join(",")];
  }),
);
// Forever's own rares (data/rare-zones-forever.json, scripts/forever_rares.py):
// unknown to the data until met, filed then from what the game says of them.
const foreverZones: { id: number; name: string }[] = JSON.parse(readFileSync(join(ROOT, "data/zones-forever.json"), "utf8")).zones;
const foreverRares: Record<string, { name: string; zone: number }> =
  JSON.parse(readFileSync(join(ROOT, "data/rare-zones-forever.json"), "utf8"));
function zoneRares(kept: Creature[], client: string) {
  const by = new Map<number, number[]>();
  for (const c of kept) {
    const zone = rareZone[String(c.id)];
    if (zone && RANK[c.rank] !== "b") by.set(zone, [...(by.get(zone) ?? []), c.id]);
  }
  if (client === "forever")
    for (const [id, r] of Object.entries(foreverRares)) by.set(r.zone, [...(by.get(r.zone) ?? []), Number(id)]);
  for (const zone of by.keys())
    if (!zoneNames[zone]) zoneNames[zone] = foreverZones.find((z) => z.id === zone)?.name ?? "?";
  return [...by.entries()].sort((a, b) => a[0] - b[0]);
}

// The Atlas's zones, per game (data/zones-<client>.json, scripts/zones.py):
// a zone's name, its continent, and its places (name, the overlay's hover
// rectangle on the map art: left, top, right, bottom; the areas it covers).
type Zone = { id: number; name: string; continent: number; places: { name: string; areas: number[]; rect: number[]; visit?: boolean }[] };
const zoneData: Record<string, { continents: Record<string, string>; zones: Zone[] }> = Object.fromEntries(
  CLIENTS.map((client) => [client, JSON.parse(readFileSync(join(ROOT, `data/zones-${client}.json`), "utf8"))]),
);
// The surveyor's notes: atlas/<zone>.md (front matter: zone: <uiMap>; then
// paragraphs), plain ASCII like the naturalist's.
const zoneNotes = new Map<number, Paragraph[]>();
for (const f of readdirSync(join(ROOT, "atlas"))) {
  if (!f.endsWith(".md")) continue;
  const file = join(ROOT, "atlas", f);
  const source = readFileSync(file, "utf8");
  const odd = source.match(/[^\x00-\x7f]/);
  if (odd) fail(file, `non-ASCII character "${odd[0]}"`);
  const { meta, body } = frontMatter(file, source);
  const zone = Number(meta.zone);
  if (!zone) fail(file, "zone: the zone's uiMap id");
  if (!CLIENTS.some((client) => zoneData[client].zones.some((z) => z.id === zone))) fail(file, `unknown zone ${zone}`);
  if (zoneNotes.has(zone)) fail(file, `zone ${zone} has two notes`);
  zoneNotes.set(zone, note(file, body));
}

// The herbs and fish (data/flora.json, scripts/flora.py), for the Plants and
// Fish tabs: zones by name, turned into this game's uiMaps (a name it doesn't
// have is reported and left out).
type Herb = { id: number; name: string; skill: number | null; zones: string[]; dungeons: string[]; nodeIds: number[]; inside?: boolean };
type Fish = { id: number; name: string; kind: string; zones: string[]; subzones: string[]; dungeons: string[]; schoolIds: number[]; season?: string; weights?: { id: number; pounds: number }[] };
const flora: { herbs: Herb[]; fish: Fish[]; schools: number[] } = JSON.parse(readFileSync(join(ROOT, "data/flora.json"), "utf8"));

// The naturalist's notes on them: notes/herbs.md and notes/fish.md, one
// "## <item id> <name>" heading per kind, then paragraphs; plain ASCII. Every
// herb and fish must have one, and no note may name a kind the data lacks.
function floraNotes(file: string, kinds: { id: number; name: string }[]) {
  const source = readFileSync(file, "utf8");
  const odd = source.match(/[^\x00-\x7f]/);
  if (odd) fail(file, `non-ASCII character "${odd[0]}"`);
  const notes = new Map<number, Paragraph[]>();
  const byId = new Map(kinds.map((k) => [k.id, k.name]));
  for (const part of source.replace(/<!--[\s\S]*?-->/g, "").split(/^## /m).slice(1)) {
    const [head, ...rest] = part.split("\n");
    const m = head.match(/^(\d+) (.+)$/);
    if (!m) { fail(file, `a heading without "<id> <name>": ${head}`); continue; }
    const id = Number(m[1]);
    if (!byId.has(id)) fail(file, `no kind ${id} (${m[2]}) in data/flora.json`);
    else if (byId.get(id) !== m[2].trim()) fail(file, `${id} is ${byId.get(id)}, not ${m[2]}`);
    if (notes.has(id)) fail(file, `${id} has two notes`);
    const paras = note(file, rest.join("\n"));
    if (!paras.length) fail(file, `${id} ${m[2]}: an empty note`);
    notes.set(id, paras);
  }
  for (const k of kinds) if (!notes.has(k.id)) fail(file, `no note for ${k.id} ${k.name}`);
  return notes;
}
const herbNotes = floraNotes(join(ROOT, "notes/herbs.md"), flora.herbs);
const fishNotes = floraNotes(join(ROOT, "notes/fish.md"), flora.fish);
const noteLua = (paras: Paragraph[] | undefined, client: string) => (paras ? `, note = { ${forClient(paras, client).map(q).join(", ")} }` : "");

function floraLua(client: string) {
  const { zones } = zoneData[client];
  const byName = new Map(zones.map((z) => [z.name, z.id]));
  const ids = (names: string[], who: string) =>
    names.flatMap((n) => {
      const id = byName.get(n);
      if (id === undefined) console.warn(`  ${client}: ${who}: no zone "${n}" in data/zones-${client}.json`);
      return id === undefined ? [] : [id];
    });
  const list = (xs: string[]) => `{ ${xs.map(q).join(", ")} }`;
  const nodes = new Map<number, number>();
  for (const h of flora.herbs) for (const n of h.nodeIds) if (!nodes.has(n)) nodes.set(n, h.id);
  return `  -- the herbs (item id = { name, skill, zones (uiMaps), dungeons, inside: in
  -- another herb's node }), by the Herbalism skill they need; their nodes (game
  -- object id = an herb it gives); the fish (item id = { name, kind, zones,
  -- subzones, dungeons, season }), the weighed catches (item id = { the kind's
  -- entry, pounds }), and every school (fishing hole object id)
  flora = {
    herbs = {
${flora.herbs.map((h) => `      [${h.id}] = { name = ${q(h.name)}, skill = ${Math.max(1, h.skill ?? 1)}, zones = { ${ids(h.zones, h.name).join(", ")} }, dungeons = ${list(h.dungeons)}${h.inside ? ", inside = true" : ""}${noteLua(herbNotes.get(h.id), client)} },`).join("\n")}
    },
    herbOrder = { ${[...flora.herbs].sort((a, b) => (a.skill ?? 1) - (b.skill ?? 1) || a.name.localeCompare(b.name)).map((h) => h.id).join(", ")} },
    herbNodes = { ${[...nodes].map(([n, h]) => `[${n}]=${h}`).join(", ")} },
    fish = {
${flora.fish.map((f) => `      [${f.id}] = { name = ${q(f.name)}, kind = ${q(f.kind)}, zones = { ${ids(f.zones, f.name).join(", ")} }, subzones = ${list(f.subzones)}, dungeons = ${list(f.dungeons)}${f.season ? `, season = ${q(f.season)}` : ""}${noteLua(fishNotes.get(f.id), client)} },`).join("\n")}
    },
    fishOrder = { ${flora.fish.map((f) => f.id).join(", ")} },
    weights = { ${flora.fish.flatMap((f) => (f.weights ?? []).map((w) => `[${w.id}]={ ${f.id}, ${w.pounds} }`)).join(", ")} },
    schools = { ${flora.schools.map((s) => `[${s}]=true`).join(", ")} },
  },`;
}

function atlasLua(client: string) {
  const { continents, zones } = zoneData[client];
  const kept = zones.filter((z) => z.continent || z.places.length);
  const used = [...new Set(kept.map((z) => z.continent).filter(Boolean))].sort((a, b) => a - b);
  return `  atlas = {
    continents = { ${used.map((c) => `[${c}] = ${q(continents[String(c)])}`).join(", ")} },
    zones = {
${kept
  .map((z) => `      [${z.id}] = { name = ${q(z.name)}, continent = ${z.continent},${zoneNotes.has(z.id) ? ` note = { ${forClient(zoneNotes.get(z.id)!, client).map(q).join(", ")} },` : ""} places = { ${z.places.map((p) => `{ ${q(p.name)}, ${p.rect.join(", ")}, ${p.areas.join(", ")}${p.visit ? ", visit = true" : ""} }`).join(", ")} } },`)
  .join("\n")}
    },
  },`;
}

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
  .map((f) => `    { id = ${q(f.id)}, title = ${q(f.title)}, section = ${q(f.section)}, note = { ${forClient(f.note, client).map(q).join(", ")} } },`)
  .join("\n")}
  },
  -- creatures the data doesn't know (Forever's new ones): a beast by its
  -- family (CreatureFamily id = family index), anything else by its type
  beasts = { ${kept.flatMap((f) => f.rules.flatMap((r) => (r.kind === "beast" ? [`[${r.family}]=${index.get(f.id)}`] : []))).join(", ")} },
  fallbacks = { ${kept.filter((f) => f.rules.some((r) => r.kind === "fallback")).map((f) => `${f.type}=${index.get(f.id)}`).join(", ")} },
  -- creature id = family index (into families above)
  creatures = {
${chunks(sorted.map((c) => `[${c.id}]=${index.get(familyOf.get(c.id)!.id)}`), 12).join("\n")}
  },
  -- creature id = display id (the 3D portrait)
  models = {
${chunks(sorted.filter((c) => c.model).map((c) => `[${c.id}]=${c.model}`), 10).join("\n")}
  },
  -- creature id = its levels in the world ("5-6", or 7)
  levels = {
${chunks(sorted.filter((c) => c.levels?.[0]).map((c) => `[${c.id}]=${c.levels[0] === c.levels[1] ? c.levels[0] : `"${c.levels[0]}-${c.levels[1]}"`}`), 12).join("\n")}
  },
  -- the rares of each zone (uiMap id = creature ids; the English name for
  -- clients that can't name the map), for the trophies-by-zone milestones
  rareZones = {
${[...zoneRares(sorted, client)].map(([zone, ids]) => `    [${zone}] = { name = ${q(zoneNames[zone] ?? "?")}, ${ids.join(", ")} },`).join("\n")}
  },
${atlasLua(client)}
${floraLua(client)}
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

// Validate every source before writing either package, including Atlas/flora
// errors discovered after family matching. A variant must leave a readable note.
for (const client of CLIENTS) {
  for (const f of families.filter((f) => !f.client || f.client === client))
    if (f.note.length && !forClient(f.note, client).length) fail(f.file, `no paragraphs for ${client}`);
  for (const [zone, paras] of zoneNotes)
    if (zoneData[client].zones.some((z) => z.id === zone) && !forClient(paras, client).length)
      fail(join(ROOT, "atlas"), `zone ${zone}: no paragraphs for ${client}`);
  for (const [file, notes] of [["notes/herbs.md", herbNotes], ["notes/fish.md", fishNotes]] as const)
    for (const [id, paras] of notes)
      if (!forClient(paras, client).length) fail(join(ROOT, file), `${id}: no paragraphs for ${client}`);
}
if (errors.length) {
  console.error(errors.map((e) => `✗ ${e}`).join("\n"));
  process.exit(1);
}

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
