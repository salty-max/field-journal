/**
 * i18n/<locale>/ → addon/Yonder/Text_<locale>.lua, one for every language the
 * game has (a stub where there is no translation yet, so the TOC never names
 * a missing file): each client loads its own, through Text_[TextLocale].lua in
 * the TOCs, and English stays wherever a translation says nothing (Locale.lua).
 *
 *   i18n/<locale>/meta.json        { "plural": "one" | "fr" | "ru" | "none",
 *                                     "flagged": true }  (a first translation,
 *                                     not reviewed by a native reader)
 *   i18n/<locale>/words.json       { "English": "translation" }: the interface's
 *                                   words, every L["..."] of the addon (its
 *                                   kit's included); i18n/words.json lists them
 *   i18n/<locale>/sections.json    { "<section id>": "title" }
 *   The game's names, by id, every language one as the others (English
 *   too: i18n/enUS/, each client loading its own), handed to ns.names:
 *   i18n/<locale>/creatures.json   the creatures', Forever's and Classic's
 *                                   where they differ (scripts/creature_names.py)
 *   i18n/<locale>/taxi.json        the flight points' (scripts/taxi_names.py)
 *   i18n/<locale>/subzones.json    the places inside buildings', which have no
 *                                   area id (../addon-kit/subzones.py)
 *   i18n/<locale>/areas-by-hand.json  { area id: name }: where the client's own
 *                                   name slips ("lle de l'effroi")
 *   i18n/<locale>/classic.json     Forever's names Classic writes otherwise
 *                                   (scripts/glossary.py)
 *   i18n/<locale>/families/<section>/<id>.md
 *                                   a family: front matter id, title and source
 *                                   (the English note's hash: when the English
 *                                   changes, the translation is stale), then its
 *                                   paragraphs, marked as the English ones
 *   i18n/<locale>/atlas/<zone>.md   a zone's note: zone, source, paragraphs
 *   i18n/<locale>/herbs.md, fish.md the notes/ files' "## <item id> <name>"
 *                                   sections; their sources a list in the front
 *                                   matter ("<item id> <hash>")
 *   i18n/<locale>/expeditions/<zone>.md
 *                                   zone and source in the front matter; a
 *                                   "## <riddle id>" section each: its verse,
 *                                   "? " its clue, "= " its note, "+ " its
 *                                   margin, "! " its danger, "@ " its answer's
 *                                   name, only one of its own ("Roger
 *                                   und Jamin": the thing's own name is
 *                                   the game's, data/expeditions.json's
 *                                   names); "## quarry": its verse, note,
 *                                   margin
 *   i18n/<locale>/names-ok.json     the names a translation writes otherwise
 *                                   than the game (scripts/names.ts), why
 *
 * A language not given its own folder may borrow another's (esMX: esES).
 *
 *   bun scripts/locales.ts             write the Text files
 *   bun scripts/locales.ts --check     fail if one isn't up to date; say what
 *                                      is stale or missing (never a failure)
 *   bun scripts/locales.ts --keys      write i18n/words.json, every word to translate
 *   bun scripts/locales.ts --stamp frFR <path> ...
 *                                      record the English sources' hashes in
 *                                      those translations (once translated):
 *                                      families/<section>/<id>, atlas/<zone>,
 *                                      herbs, fish, expeditions/<zone>
 */
import { createHash } from "node:crypto";
import { existsSync, readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, relative } from "node:path";
import { readExpeditions, veil } from "./expeditions";
import { misnamed } from "./names";
import { paragraphs, type Paragraph } from "./paragraphs";

const ROOT = new URL("..", import.meta.url).pathname;
const I18N = join(ROOT, "i18n");
const ADDON = join(ROOT, "addon/Yonder");
const LOCALES = ["enUS", "enGB", "deDE", "frFR", "esES", "esMX", "ruRU", "ptBR", "itIT", "koKR", "zhCN", "zhTW"];
const ENGLISH = new Set(["enUS", "enGB"]);
const BORROWS: Record<string, string> = { esMX: "esES", enGB: "enUS" };
const PLURALS = ["one", "fr", "ru", "none"];

const errors: string[] = [];
const fail = (file: string, msg: string) => errors.push(`${relative(ROOT, file)}: ${msg}`);
const walk = (dir: string): string[] =>
  existsSync(dir)
    ? readdirSync(dir)
        .sort()
        .flatMap((f) => (statSync(join(dir, f)).isDirectory() ? walk(join(dir, f)) : f.endsWith(".md") ? [join(dir, f)] : []))
    : [];
const hash = (...parts: string[]) => createHash("sha1").update(parts.join("\n")).digest("hex").slice(0, 12);

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
function paras(file: string, body: string): Paragraph[] {
  try {
    return paragraphs(body);
  } catch (error) {
    fail(file, String(error));
    return [];
  }
}
const parasText = (ps: Paragraph[]) => ps.map((p) => `${p.client ?? ""}|${p.text}`).join("\n");

// ── English: every source a translation follows, by its path ─────────────────
type Source = { hash: string; label: string };
const english = new Map<string, Source>();
for (const dir of readdirSync(join(ROOT, "content")).sort()) {
  for (const file of walk(join(ROOT, "content", dir))) {
    if (file.endsWith("_section.md")) continue;
    const { meta, body } = frontMatter(file, readFileSync(file, "utf8"));
    english.set(`families/${dir}/${meta.id}`, { hash: hash(String(meta.title), parasText(paras(file, body))), label: String(meta.id) });
  }
}
const sectionIds = readdirSync(join(ROOT, "content")).filter((d) => existsSync(join(ROOT, "content", d, "_section.md")));
for (const file of walk(join(ROOT, "atlas"))) {
  const { meta, body } = frontMatter(file, readFileSync(file, "utf8"));
  english.set(`atlas/${meta.zone}`, { hash: hash(parasText(paras(file, body))), label: `atlas ${meta.zone}` });
}
// (the flora's notes: each "## <id> <name>" section)
function floraSections(file: string) {
  const out = new Map<number, { name: string; body: string }>();
  const src = readFileSync(file, "utf8").replace(/^---\n[\s\S]*?\n---\n?/, "").replace(/<!--[\s\S]*?-->/g, "");
  for (const part of src.split(/^## /m).slice(1)) {
    const [head, ...rest] = part.split("\n");
    const m = head.match(/^(\d+) (.+)$/);
    if (!m) fail(file, `a heading without "<id> <name>": ${head}`);
    else out.set(Number(m[1]), { name: m[2].trim(), body: rest.join("\n") });
  }
  return out;
}
for (const kind of ["herbs", "fish"]) {
  for (const [id, s] of floraSections(join(ROOT, "notes", `${kind}.md`))) {
    english.set(`${kind}/${id}`, { hash: hash(parasText(paras(kind, s.body))), label: `${kind} ${id}` });
  }
}
// (the expeditions: a zone's riddles and quarry, and the answers' names)
const { expeditions, data: expeditionData } = readExpeditions(ROOT, fail, ["classic", "forever"]);
const creatureNames = new Map<number, string>(
  (JSON.parse(readFileSync(join(ROOT, "data/creatures.json"), "utf8")) as { id: number; name: string }[]).map((c) => [c.id, c.name]),
);
const zoneOfFile = new Map<string, number>();
for (const e of expeditions) {
  const slug = e.file.replace(/^.*\//, "").replace(/\.md$/, "");
  zoneOfFile.set(slug, e.zone);
  const parts: string[] = [];
  for (const r of e.riddles) parts.push(r.id, ...r.verse, r.hint, r.note, r.margin, r.danger, expeditionData.riddles[r.id]?.name ?? "");
  if (e.quarry) parts.push("quarry", ...e.quarry.verse, e.quarry.note, e.quarry.margin, e.quarry.own?.name ?? creatureNames.get(e.quarry.id) ?? "");
  english.set(`expeditions/${e.zone}`, { hash: hash(...parts), label: `expeditions ${slug}` });
}

// ── the interface's words: every L["..."] and plural("one", "many") ─────────
function keys(): string[] {
  const found = new Set<string>();
  for (const f of readdirSync(ADDON)) {
    if (!f.endsWith(".lua") || /^(Data|Text)_/.test(f)) continue;
    const src = readFileSync(join(ADDON, f), "utf8");
    for (const m of src.matchAll(/\bL\["((?:[^"\\]|\\.)*)"\]/g)) found.add(m[1].replace(/\\"/g, '"').replace(/\\n/g, "\n"));
    for (const m of src.matchAll(/plural\([^,]+,\s*"((?:[^"\\]|\\.)*)",\s*"((?:[^"\\]|\\.)*)"\s*\)/g)) {
      found.add(m[1]);
      found.add(m[2]);
    }
  }
  // the kit's month names, read through L by K.day; the login line's counts,
  // read through the kit's plural from a table (Core.lua)
  for (const m of ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]) found.add(m);
  const core = readFileSync(join(ADDON, "Core.lua"), "utf8");
  for (const m of core.matchAll(/\{ \w+, "(%d [^"]+)", "(%d [^"]+)" \}/g)) {
    found.add(m[1]);
    found.add(m[2]);
  }
  return [...found].sort();
}

// ── a language's folder ──────────────────────────────────────────────────────
// (straight quotes: the game's fonts lack the curly ones)
const CURLY = /[‘’“”]/;
type Riddle = { verse: string[]; hint?: string; note?: string; margin?: string; danger?: string; name?: string };
type Zone = { riddles: Map<string, Riddle>; quarry?: Riddle };
function read(locale: string) {
  const dir = join(I18N, locale);
  const json = <T>(f: string, empty: T): T => (existsSync(join(dir, f)) ? JSON.parse(readFileSync(join(dir, f), "utf8")) : empty);
  const meta = json<{ plural?: string; flagged?: boolean }>("meta.json", {});
  if (meta.plural && !PLURALS.includes(meta.plural)) fail(join(dir, "meta.json"), `plural: one of ${PLURALS.join(", ")}`);
  const words = json<Record<string, string>>("words.json", {});
  const sections = json<Record<string, string>>("sections.json", {});
  for (const id of Object.keys(sections)) if (!sectionIds.includes(id)) fail(join(dir, "sections.json"), `no section "${id}"`);
  const areas = json<Record<string, string>>("areas-by-hand.json", {});
  // (the creatures' names in this language, each game's, from Wowhead's
  // tooltips: scripts/creature_names.py; Classic's only where they differ)
  const creatures = json<{ forever?: Record<string, string>; classic?: Record<string, string> }>("creatures.json", {});
  // (the flight points' names in this language, by id, where they differ from
  // the English: scripts/taxi_names.py)
  const taxi = json<{ forever?: Record<string, string>; classic?: Record<string, string> }>("taxi.json", {});
  // (the places inside buildings, which have no area id: ../addon-kit/subzones.py)
  const subzones = json<{ forever?: Record<string, string>; classic?: Record<string, string> }>("subzones.json", {});
  const classic = json<Record<string, string>>("classic.json", {});
  const stale = new Set<string>();
  const done = new Set<string>();
  const sourced = (file: string, path: string, source: string | undefined) => {
    const en = english.get(path);
    if (!en) return fail(file, `no English "${path}"`);
    done.add(path);
    if (source !== en.hash) stale.add(en.label);
  };
  const checked = (file: string, src: string) => {
    const odd = src.match(CURLY);
    if (odd) fail(file, `curly quote "${odd[0]}": use straight quotes`);
  };
  const families = new Map<string, { title: string; note: Paragraph[] }>();
  for (const file of walk(join(dir, "families"))) {
    const src = readFileSync(file, "utf8");
    checked(file, src);
    const { meta: m, body } = frontMatter(file, src);
    const section = relative(join(dir, "families"), file).split("/")[0];
    sourced(file, `families/${section}/${m.id}`, m.source as string);
    families.set(String(m.id), { title: String(m.title), note: paras(file, body) });
  }
  const atlas = new Map<number, Paragraph[]>();
  for (const file of walk(join(dir, "atlas"))) {
    const src = readFileSync(file, "utf8");
    checked(file, src);
    const { meta: m, body } = frontMatter(file, src);
    sourced(file, `atlas/${m.zone}`, m.source as string);
    atlas.set(Number(m.zone), paras(file, body));
  }
  const flora: Record<string, Map<number, Paragraph[]>> = { herbs: new Map(), fish: new Map() };
  for (const kind of ["herbs", "fish"]) {
    const file = join(dir, `${kind}.md`);
    if (!existsSync(file)) continue;
    const src = readFileSync(file, "utf8");
    checked(file, src);
    const sources = new Map(
      ([].concat((frontMatter(file, src).meta.sources as never) ?? []) as string[]).map((s) => s.split(/\s+/) as [string, string]),
    );
    for (const [id, s] of floraSections(file)) {
      sourced(file, `${kind}/${id}`, sources.get(String(id)));
      flora[kind].set(id, paras(file, s.body));
    }
  }
  const zones = new Map<number, Zone>();
  for (const file of walk(join(dir, "expeditions"))) {
    const src = readFileSync(file, "utf8");
    checked(file, src);
    const { meta: m, body } = frontMatter(file, src);
    sourced(file, `expeditions/${m.zone}`, m.source as string);
    const zone: Zone = { riddles: new Map() };
    for (const part of body.split(/^## /m).slice(1)) {
      const [head, ...rest] = part.split("\n");
      const lines = rest.map((l) => l.trim()).filter(Boolean);
      const of1 = (mark: string) => lines.find((l) => l.startsWith(`${mark} `))?.slice(2).trim();
      const r: Riddle = {
        verse: lines.filter((l) => !/^[?=+!@] /.test(l)),
        hint: of1("?"),
        note: of1("="),
        margin: of1("+"),
        danger: of1("!"),
        name: of1("@"),
      };
      if (head.trim() === "quarry") zone.quarry = r;
      else zone.riddles.set(head.trim(), r);
    }
    // (an answer that is the thing's own name is the game's, by its id: the
    // data's, from wow-data's databases; a translation writes only its own)
    const same = (s: string) => s.replace(/\u00a0/g, " ").replace(/[\u2018\u2019]/g, "'").replace(/[\u201c\u201d]/g, '"');
    const answers: [string, Riddle, string | undefined][] = [
      ...[...zone.riddles].map(([rid, r]) => [rid, r, expeditionData.riddles[rid]?.names?.[locale]] as [string, Riddle, string | undefined]),
      ...(zone.quarry ? [["quarry", zone.quarry, expeditionData.quarries[String(m.zone)]?.names?.[locale]] as [string, Riddle, string | undefined]] : []),
    ];
    for (const [rid, r, game] of answers) {
      if (game && r.name && same(r.name) !== same(game)) fail(file, `${rid}: the answer is the game's own name "${game}": leave out its @ line`);
      r.name ??= game && same(game);
    }
    zones.set(Number(m.zone), zone);
  }
  return { meta, words, sections, areas, creatures, taxi, subzones, classic, families, atlas, flora, zones, stale, done };
}

// ── Lua ─────────────────────────────────────────────────────────────────────
const q = (s: string) => `"${s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n")}"`;
const parasLua = (ps: Paragraph[]) => `{ ${ps.map((p) => `{ ${p.client ? `client = ${q(p.client)}, ` : ""}${q(p.text)} }`).join(", ")} }`;
const field = (k: string, v: string | undefined) => (v ? `${k} = ${q(v)}, ` : "");
const veiled = (k: string, v: string | undefined, id: string) => (v ? `${k} = ${q(veil(v, id))}, ` : "");
const verseLua = (vs: string[]) => (vs.length ? `verse = { ${vs.map(q).join(", ")} }, ` : "");

// The game's names in a language, by id (ns.names), each language's own list,
// English one of them.
function namesLua(t: ReturnType<typeof read>): string[] {
  const lines = ["ns.names({"];
  for (const [key, list] of [
    ["creatures", t.creatures.forever],
    ["creaturesClassic", t.creatures.classic],
    ["taxi", t.taxi.forever],
    ["taxiClassic", t.taxi.classic],
    ["inside", t.subzones.forever],
    ["insideClassic", t.subzones.classic],
    ["areas", t.areas],
  ] as const) {
    const entries = Object.entries(list ?? {}).sort(([a], [b]) => Number(a) - Number(b));
    lines.push(`  ${key} = {`);
    for (let i = 0; i < entries.length; i += 4) lines.push(`    ${entries.slice(i, i + 4).map(([id, n]) => `[${id}] = ${q(n)},`).join(" ")}`);
    lines.push("  },");
  }
  lines.push("})");
  return lines;
}

// (a language's own folder, else the one it borrows, that holds this file)
const holding = (locale: string, file: string) =>
  [locale, BORROWS[locale]].find((l) => l && existsSync(join(I18N, l, file)));

function luaFor(locale: string): string {
  // the game's names: every language its own, translated or not
  const namesFrom = holding(locale, "taxi.json");
  const names = namesFrom ? namesLua(read(namesFrom)) : [];
  const from = ENGLISH.has(locale) ? undefined : holding(locale, "words.json");
  if (!from) {
    if (!names.length) return `-- Generated by scripts/locales.ts: no names or translation for ${locale} (yet).\n`;
    return [
      `-- Generated by scripts/locales.ts from i18n/${namesFrom}/: the game's names in this language, by id${ENGLISH.has(locale) ? "" : " (no translation of the journal's own words yet: English)"}.`,
      "local _, ns = ...",
      ...names,
      "",
    ].join("\n");
  }
  const t = read(from);
  const sorted = <K, V>(m: Map<K, V>) => [...m.entries()].sort(([a], [b]) => String(a).localeCompare(String(b)));
  const lines: string[] = [];
  lines.push(`-- Generated by scripts/locales.ts from i18n/${from}/: edit those, not this file.`);
  lines.push("local _, ns = ...");
  lines.push("ns.translate({");
  lines.push(`  locale = ${q(locale)},`, `  plural = ${q(t.meta.plural ?? "one")},`);
  lines.push("  words = {");
  for (const [k, v] of Object.entries(t.words).filter(([, v]) => v).sort(([a], [b]) => a.localeCompare(b))) lines.push(`    [${q(k)}] = ${q(v)},`);
  lines.push("  },");
  lines.push("  sections = {");
  for (const [k, v] of Object.entries(t.sections).sort()) lines.push(`    [${q(k)}] = ${q(v)},`);
  lines.push("  },");
  lines.push("  families = {");
  for (const [id, f] of sorted(t.families)) lines.push(`    [${q(id)}] = { title = ${q(f.title)}, note = ${parasLua(f.note)} },`);
  lines.push("  },");
  lines.push("  atlas = {");
  for (const [zone, ps] of sorted(t.atlas)) lines.push(`    [${zone}] = ${parasLua(ps)},`);
  lines.push("  },");
  for (const kind of ["herbs", "fish"]) {
    lines.push(`  ${kind} = {`);
    for (const [id, ps] of sorted(t.flora[kind])) lines.push(`    [${id}] = ${parasLua(ps)},`);
    lines.push("  },");
  }
  lines.push("  -- what a riddle's solving reads (its answer's name, note, margin) veiled as the English");
  lines.push("  expeditions = {");
  for (const [zone, z] of sorted(t.zones)) {
    lines.push(`    [${zone}] = {`);
    lines.push("      riddles = {");
    for (const [id, r] of sorted(z.riddles)) {
      lines.push(
        `        [${q(id)}] = { ${verseLua(r.verse)}${field("hint", r.hint)}${field("danger", r.danger)}${veiled("name", r.name, id)}${veiled("note", r.note, id)}${veiled("margin", r.margin, id)}},`,
      );
    }
    lines.push("      },");
    const qu = z.quarry;
    const e = expeditions.find((x) => x.zone === zone);
    if (qu && e?.quarry) {
      const id = `quarry-${e.quarry.id}`;
      lines.push(`      quarry = { ${field("name", qu.name)}${verseLua(qu.verse)}${veiled("note", qu.note, id)}${veiled("margin", qu.margin, id)}},`);
    }
    lines.push("    },");
  }
  lines.push("  },");
  lines.push("  -- on Classic, its own names for the places Forever renamed (the longest first)");
  lines.push("  classic = {");
  for (const [fv, cl] of Object.entries(t.classic).sort(([a], [b]) => b.length - a.length || a.localeCompare(b))) lines.push(`    { ${q(fv)}, ${q(cl)} },`);
  lines.push("  },");
  lines.push("})");
  lines.push(...names);
  return `${lines.join("\n")}\n`;
}

// ── commands ─────────────────────────────────────────────────────────────────
const args = process.argv.slice(2);
if (args[0] === "--keys") {
  const all = keys();
  writeFileSync(join(I18N, "words.json"), `${JSON.stringify(Object.fromEntries(all.map((k) => [k, ""])), null, 2)}\n`);
  console.log(`✓ i18n/words.json: ${all.length} words to translate`);
  process.exit(0);
}
if (args[0] === "--stamp") {
  const [, locale, ...paths] = args;
  for (const rel of paths) {
    const kind = rel.replace(/\.md$/, "");
    if (kind === "herbs" || kind === "fish") {
      const file = join(I18N, locale, `${kind}.md`);
      const src = readFileSync(file, "utf8");
      const ids = [...floraSections(file).keys()];
      const list = ids.map((id) => `  - ${id} ${english.get(`${kind}/${id}`)?.hash ?? "?"}`).join("\n");
      const body = src.replace(/^---\n[\s\S]*?\n---\n?/, "");
      writeFileSync(file, `---\nsources:\n${list}\n---\n${body}`);
      console.log(`✓ ${kind}: ${ids.length} sources`);
      continue;
    }
    const file = join(I18N, locale, `${kind}.md`);
    const src = readFileSync(file, "utf8");
    const { meta } = frontMatter(file, src);
    const path = kind.startsWith("families/")
      ? `families/${kind.split("/")[1]}/${meta.id}`
      : kind.startsWith("atlas/")
        ? `atlas/${meta.zone}`
        : `expeditions/${meta.zone}`;
    const en = english.get(path);
    if (!en) {
      console.error(`✗ ${rel}: no English "${path}"`);
      continue;
    }
    const stamped = /^source:/m.test(src) ? src.replace(/^source:.*$/m, `source: ${en.hash}`) : src.replace(/^---\n/, `---\nsource: ${en.hash}\n`);
    writeFileSync(file, stamped);
    console.log(`✓ ${rel}: source ${en.hash}`);
  }
  process.exit(0);
}

const check = args.includes("--check");
let outdated = false;
const known = new Set(keys());
for (const locale of LOCALES) {
  const out = join(ADDON, `Text_${locale}.lua`);
  const lua = luaFor(locale);
  if (check) {
    const current = existsSync(out) ? readFileSync(out, "utf8") : "";
    if (current !== lua) {
      console.error(`✗ ${relative(ROOT, out)} is out of date: run bun scripts/locales.ts`);
      outdated = true;
    }
  } else writeFileSync(out, lua);
  if (existsSync(join(I18N, locale, "words.json")) && !ENGLISH.has(locale)) {
    const t = read(locale);
    const missingWords = [...known].filter((k) => !t.words[k]);
    const unused = Object.keys(t.words).filter((k) => !known.has(k));
    console.log(
      `${locale}: ${t.done.size}/${english.size} texts (${t.stale.size} stale), ${known.size - missingWords.length}/${known.size} words, ${Object.keys(t.sections).length}/${sectionIds.length} sections${t.meta.flagged ? ", flagged" : ""}`,
    );
    if (t.stale.size) console.log(`  stale (the English changed): ${[...t.stale].join(", ")}`);
    if (unused.length) console.log(`  words no longer used: ${unused.join(" | ")}`);
    // (every family's, zone's, herb's, fish's and expedition's text with its translation)
    const md = (dir: string) => (existsSync(join(ROOT, dir)) ? (readdirSync(join(ROOT, dir), { recursive: true }) as string[]) : []).filter((f) => f.endsWith(".md"));
    const pairs: [string, string][] = [
      ...md("content")
        .filter((f) => !f.endsWith("_section.md"))
        .map((f) => [join(ROOT, "content", f), join(I18N, locale, "families", f)] as [string, string]),
      ...["atlas", "expeditions"].flatMap((dir) => md(dir).map((f) => [join(ROOT, dir, f), join(I18N, locale, dir, f)] as [string, string])),
      ...["herbs", "fish"].map((n) => [join(ROOT, "notes", `${n}.md`), join(I18N, locale, `${n}.md`)] as [string, string]),
    ];
    for (const m of misnamed(I18N, locale, pairs))
      errors.push(`i18n/${locale}: a name not as the game writes it (or i18n/${locale}/names-ok.json says why): ${m}`);
  }
}
if (errors.length) {
  for (const e of errors) console.error(`✗ ${e}`);
  process.exit(1);
}
if (outdated) process.exit(1);
if (!check) console.log(`✓ Text_<locale>.lua for ${LOCALES.length} languages`);
