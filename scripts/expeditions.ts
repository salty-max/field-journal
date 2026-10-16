/**
 * The expeditions' riddles: expeditions/<zone>.md + data/expeditions.json →
 * the `expeditions` table of Data_Classic.lua and Data_Forever.lua (build.ts).
 *
 * A zone's file: front matter (YAML: zone, home, client, riddles, quarry:
 * { id, sources }; a creature of Forever's own, which the data doesn't know,
 * with its name, level, rank and model), then a section per riddle:
 *
 *   ## <riddle id>
 *   the verse, a line each
 *   ? the first hint (prose)
 *   = the naturalist's note, read once solved
 *   + the margin, for the gold seal alone
 *
 * and the quarry's (`## quarry`: its poster's verse, the note once brought
 * down, the margin for the one who never tracked it).
 *
 * Where each riddle is solved comes from scripts/expeditions.py (the game's
 * data, resolved into data/expeditions.json); the build checks the two agree
 * and writes fingerprints of the answer, never the answer: the cells of the
 * spot (yards, CELL by CELL, on the zone's map), its sub-area, the creature to
 * stand by, the gestures it takes. The addon fingerprints where the reader is
 * and what they do the same way (Expeditions.lua).
 */
import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

export const CELL = 5;
const SALT = "FJX1";
const TIERS = ["near", "off", "hidden", "town"];
const FACTIONS = ["alliance", "horde"];
const SPOTS = ["object", "creature", "trigger", "area"];

/** 32-bit FNV-1a (Expeditions.lua computes the same). */
export function fnv(s: string) {
  let h = 2166136261;
  for (const c of Buffer.from(s, "utf8")) h = Math.imul(h ^ c, 16777619) >>> 0;
  return h;
}
const print = (...parts: (string | number)[]) => fnv([SALT, ...parts].join("|"));

/** What is read once a riddle is solved (its answer's name, the note, the
 * margin), veiled: each byte of plain ASCII turned within it by a stream
 * (MINSTD) seeded from the riddle's id, so the data never spells an answer
 * out; a translation's other bytes (UTF-8's letters) pass as they are, the
 * stream turning all the same. Expeditions.lua unveils it. */
export function veil(text: string, id: string, back = false) {
  let state = (fnv(`${SALT}|veil|${id}`) % 2147483646) + 1;
  const bytes = Buffer.from(text, "utf8");
  for (let i = 0; i < bytes.length; i++) {
    state = (state * 48271) % 2147483647;
    const c = bytes[i] - 32;
    if (c < 0 || c >= 95) continue;
    bytes[i] = 32 + ((((c + (back ? -1 : 1) * (state % 95)) % 95) + 95) % 95);
  }
  return bytes.toString("utf8");
}

type Spot = {
  zone: number;
  of: string;
  hint: number[];
  name: string;
  // (its name in every other language, the game's own, where the answer is the thing's own name)
  names?: Record<string, string>;
  spots?: number[][];
  r?: number;
  npc?: number;
  companions?: number[];
  areas?: number[];
  face?: number;
};
type Haunts = { id: number; name: string; names?: Record<string, string>; haunts: number[][] };
type Data = {
  zones: Record<string, { w: number; h: number; areas: number[] }>;
  riddles: Record<string, Spot>;
  quarries: Record<string, Haunts>;
  emotes: string[];
};
type Own = { name: string; rank: string; levels: [number, number]; model: number };
type Quarry = { id: number; verse: string[]; note: string; margin: string; haunts: number[][]; own?: Own };
const RANKS = ["rare", "rareelite"];
type Riddle = {
  id: string;
  tier: string;
  faction?: string;
  gestures: string[];
  reading?: string;
  night: boolean;
  danger: string;
  circle: number[];
  verse: string[];
  hint: string;
  note: string;
  margin: string;
  spot: Spot;
};
export type Expedition = { file: string; zone: number; home?: string; client: string; quarry?: Quarry; riddles: Riddle[] };

export function readExpeditions(root: string, fail: (file: string, msg: string) => void, clients: string[]) {
  const data: Data = JSON.parse(readFileSync(join(root, "data/expeditions.json"), "utf8"));
  const emotes = new Set(data.emotes);
  const dir = join(root, "expeditions");
  const out: Expedition[] = [];
  const seen = new Set<string>();
  for (const f of readdirSync(dir).sort()) {
    if (!f.endsWith(".md")) continue;
    const file = join(dir, f);
    const slug = f.replace(/\.md$/, "");
    const source = readFileSync(file, "utf8");
    const odd = source.match(/[^\x00-\x7f]/);
    if (odd) fail(file, `non-ASCII character "${odd[0]}"`);
    const m = source.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!m) {
      fail(file, "no front matter");
      continue;
    }
    let meta: any;
    try {
      meta = Bun.YAML.parse(m[1]);
    } catch (e) {
      fail(file, `front matter: ${e}`);
      continue;
    }
    const zone = Number(meta.zone);
    const client = String(meta.client ?? "both");
    if (client !== "both" && !clients.includes(client)) fail(file, `client: both, ${clients.join(" or ")}`);
    if (meta.home && !FACTIONS.includes(meta.home)) fail(file, `home: ${FACTIONS.join(" or ")}`);
    const q = meta.quarry;
    if (q !== undefined && !(q && Number.isInteger(q.id) && typeof q.sources === "string" && q.sources))
      fail(file, "quarry: { id: a creature id, sources: what its poster stands on }");
    // a creature the data doesn't know (Forever's own): what the game says of it
    let own: Own | undefined;
    if (q && (q.name !== undefined || q.level !== undefined || q.rank !== undefined)) {
      if (typeof q.name !== "string" || !Number.isInteger(q.level) || !RANKS.includes(q.rank) || (q.model !== undefined && !Number.isInteger(q.model)))
        fail(file, `quarry: a creature of its own has name, level, rank (${RANKS.join(" or ")}) and model (a display id)`);
      else own = { name: q.name, rank: q.rank, levels: [q.level, q.level], model: q.model ?? 0 };
    }

    // the sections: ## <id>, then the verse and its ?, = and + lines
    const sections = new Map<string, string[]>();
    for (const part of m[2].split(/^## /m).slice(1)) {
      const [head, ...lines] = part.split("\n");
      if (sections.has(head.trim())) fail(file, `two sections ## ${head}`);
      sections.set(head.trim(), lines.map((l) => l.trim()).filter(Boolean));
    }
    let quarry: Quarry | undefined;
    if (q?.id) {
      const lines = sections.get("quarry");
      const resolved = data.quarries[String(zone)];
      if (!lines) fail(file, "quarry: no ## quarry section");
      else if (lines.some((l) => l.startsWith("? "))) fail(file, "## quarry: no clue (its help is the target)");
      if (!resolved || resolved.id !== q.id) fail(file, "quarry: changed since data/expeditions.json was made: run python3 scripts/expeditions.py");
      const verse = (lines ?? []).filter((l) => !/^[=+] /.test(l));
      const [note, margin] = ["=", "+"].map((mark) => (lines ?? []).filter((l) => l.startsWith(`${mark} `)).map((l) => l.slice(2).trim()));
      if (verse.length < 2) fail(file, "## quarry: a verse of two lines or more");
      if (note.length !== 1 || margin.length !== 1) fail(file, "## quarry: one note (=) and one margin (+) line");
      quarry = { id: q.id, verse, note: note[0] ?? "", margin: margin[0] ?? "", haunts: resolved?.haunts ?? [], own };
    } else if (sections.has("quarry")) fail(file, "## quarry: no quarry in the front matter");
    sections.delete("quarry");

    const riddles: Riddle[] = [];
    for (const r of Array.isArray(meta.riddles) ? meta.riddles : []) {
      const id = String(r.id ?? "");
      const where = `${id}:`;
      if (!id.startsWith(`${slug}-`) || !/^[a-z0-9-]+$/.test(id)) fail(file, `${where} an id is the file's name, a dash and lowercase words`);
      if (seen.has(id)) fail(file, `${where} a second riddle of that id`);
      seen.add(id);
      if (!TIERS.includes(r.tier)) fail(file, `${where} tier: one of ${TIERS.join(", ")}`);
      // (a town's is its side's; another, the side its keeper doesn't attack)
      if (r.tier === "town" && !r.faction) fail(file, `${where} a town's riddle has its faction`);
      if (r.faction && !FACTIONS.includes(r.faction)) fail(file, `${where} faction: ${FACTIONS.join(" or ")}`);
      const gestures: string[] = r.gestures ?? [];
      const companions: unknown = r.companions ?? [];
      if (!Array.isArray(companions) || companions.some((id) => !Number.isInteger(id) || id <= 0 || id === r.creature)
        || new Set(companions).size !== companions.length || (companions.length && (!r.creature || !gestures.length)))
        fail(file, `${where} companions: distinct other creature ids for a gesture's group`);
      for (const g of gestures) {
        if (!emotes.has(g)) fail(file, `${where} gesture ${g}: not one of the client's emote tokens`);
      }
      if (gestures.length && r.reading) fail(file, `${where} a gesture or a reading, not both`);
      const kinds = SPOTS.filter((k) => r[k] !== undefined);
      if (kinds.length !== 1) fail(file, `${where} one spot: ${SPOTS.join(", ")}`);
      const ha = r.hint_area;
      if (!ha || ![ha.x, ha.y, ha.r].every((n) => typeof n === "number")) fail(file, `${where} hint_area: { x, y, r }`);
      if (typeof r.danger !== "string" || !r.danger) fail(file, `${where} danger: how dangerous the place is`);
      if (typeof r.sources !== "string" || !r.sources) fail(file, `${where} sources: what the riddle stands on`);

      // the resolved spot must be this file's
      const spot = data.riddles[id];
      const of =
        kinds.length === 1
          ? `${kinds[0]}:${r[kinds[0]]}` +
            (r.anchor ? " " + Object.entries(r.anchor).map(([k, v]) => `${k}:${v}`).join(",") : "") +
            (r.found ? ` found:${r.found}` : "")
          : "";
      if (r.found !== undefined && (!["target", "place"].includes(r.found) || kinds[0] !== "creature"))
        fail(file, `${where} found: target or place, for a creature or its surroundings`);
      if (r.found === "place" && (!gestures.length || (companions as number[]).length
        || !Number.isInteger(r.radius) || r.radius < 10 || r.radius > 100))
        fail(file, `${where} found: place needs a gesture, no companions and a radius of 10 to 100 yards`);
      if (r.radius !== undefined && r.found !== "place") fail(file, `${where} radius needs found: place`);
      if (!spot) fail(file, `${where} not in data/expeditions.json: run python3 scripts/expeditions.py`);
      else if (spot.zone !== zone || spot.of !== of || String(spot.hint) !== String(ha && [ha.x, ha.y, ha.r])
        || String(spot.companions ?? []) !== String(companions) || (r.found === "place" && (spot.r !== r.radius || spot.npc)))
        fail(file, `${where} changed since data/expeditions.json was made: run python3 scripts/expeditions.py`);

      const lines = sections.get(id);
      sections.delete(id);
      if (!lines) {
        fail(file, `${where} no section ## ${id}`);
        continue;
      }
      const of1 = (mark: string) => lines.filter((l) => l.startsWith(`${mark} `)).map((l) => l.slice(2).trim());
      const verse = lines.filter((l) => !/^[?=+] /.test(l));
      const [hint, note, margin] = [of1("?"), of1("="), of1("+")];
      if (verse.length < 2) fail(file, `${where} a verse of two lines or more`);
      for (const [name, xs] of [["hint (?)", hint], ["note (=)", note], ["margin (+)", margin]] as const)
        if (xs.length !== 1) fail(file, `${where} one ${name} line`);
      // The verse leaves the gesture to infer. A paid clue may name the
      // ordinary action: repeating only the location strands a reader who
      // already found it. Neither needs to hand out a slash command.
      for (const g of gestures) {
        const word = new RegExp(`\\b${g}\\b`, "i");
        if (verse.some((l) => word.test(l))) fail(file, `${where} the verse names the gesture ${g}`);
      }
      riddles.push({
        id,
        tier: r.tier,
        faction: r.faction,
        gestures,
        reading: r.reading,
        night: r.night === true,
        danger: r.danger,
        circle: ha ? [ha.x, ha.y, ha.r] : [],
        verse,
        hint: hint[0] ?? "",
        note: note[0] ?? "",
        margin: margin[0] ?? "",
        spot: spot ?? ({} as Spot),
      });
    }
    for (const extra of sections.keys()) fail(file, `## ${extra}: no riddle of that id`);
    riddles.sort((a, b) => TIERS.indexOf(a.tier) - TIERS.indexOf(b.tier));
    out.push({ file, zone, home: meta.home, client, quarry, riddles });
  }
  for (const id of Object.keys(data.riddles))
    if (!seen.has(id)) fail(join(root, "data/expeditions.json"), `${id}: no such riddle in expeditions/: run python3 scripts/expeditions.py`);
  for (const zone of Object.keys(data.quarries))
    if (!out.some((e) => String(e.zone) === zone && e.quarry))
      fail(join(root, "data/expeditions.json"), `zone ${zone}'s quarry: not in expeditions/: run python3 scripts/expeditions.py`);
  return { expeditions: out, data };
}

/** The cells (CELL yards a side) within r yards of a spot, on a map w by h yards. */
export function cells(spots: number[][], r: number, w: number, h: number) {
  const out = new Set<string>();
  for (const [x, y] of spots) {
    const X = (x / 100) * w;
    const Y = (y / 100) * h;
    for (let i = Math.floor((X - r) / CELL); i <= Math.floor((X + r) / CELL); i++)
      for (let j = Math.floor((Y - r) / CELL); j <= Math.floor((Y + r) / CELL); j++) {
        const cx = Math.max(i * CELL, Math.min(X, (i + 1) * CELL));
        const cy = Math.max(j * CELL, Math.min(Y, (j + 1) * CELL));
        if ((cx - X) ** 2 + (cy - Y) ** 2 < r * r) out.add(`${i}|${j}`);
      }
  }
  return [...out];
}

type Creature = { id: number; name: string; rank: string; levels: [number, number]; model: number };

export function expeditionsLua(ex: Expedition[], data: Data, client: string, q: (s: string) => string, creatures: Map<number, Creature>) {
  const zones = ex.filter((e) => e.client === "both" || e.client === client).sort((a, b) => a.zone - b.zone);
  const nums = (xs: number[]) => `{ ${xs.join(", ")} }`;
  const riddle = (r: Riddle, w: number, h: number) => {
    const s = r.spot;
    const at = s.areas ? s.areas.map((a) => print(r.id, "area", a)) : cells(s.spots ?? [], s.r ?? 0, w, h).map((c) => print(r.id, c));
    const fields = [
      `id = ${q(r.id)}`,
      `tier = ${q(r.tier)}`,
      r.faction ? `faction = ${q(r.faction)}` : "",
      r.gestures.length ? `asks = "gesture"` : r.reading ? `asks = "reading"` : "",
      r.night ? "night = true" : "",
      `danger = ${q(r.danger)}`,
      `circle = ${nums(r.circle)}`,
      `verse = { ${r.verse.map(q).join(", ")} }`,
      `hint = ${q(r.hint)}`,
      `name = ${q(veil(s.name, r.id))}`,
      s.face ? `face = ${q(veil(String(s.face), r.id))}` : "",
      `note = ${q(veil(r.note, r.id))}`,
      `margin = ${q(veil(r.margin, r.id))}`,
      s.areas ? "area = true" : "",
      `at = ${nums(at.sort((a, b) => a - b))}`,
      s.npc ? `npc = ${print(r.id, "npc", s.npc)}` : "",
      s.companions?.length ? `npcs = ${nums(s.companions.map((id) => print(r.id, "npc", id)))}` : "",
      r.gestures.length ? `by = ${nums(r.gestures.map((g) => print(r.id, g)).sort((a, b) => a - b))}` : "",
    ];
    return `        { ${fields.filter(Boolean).join(", ")} },`;
  };
  return `  -- the expeditions' riddles, by zone (uiMap; scripts/expeditions.ts): the
  -- zone's size in yards (w, h: the answers' cells are ${CELL} yards a side), its
  -- faction when it is one's alone (home), its sub-areas (the one the reader
  -- stands in is found by name); each riddle's tier, faction (one side's), what
  -- it asks (a gesture, a reading), the night, its danger, its hint's circle
  -- (x, y, r: percent of the map's width), its verse and first hint; what is
  -- read once it is solved, veiled (its answer's name, its keeper's face, the
  -- note, the margin);
  -- and its answer as fingerprints only: at (the cells of its spot, or its
  -- sub-area), npc (the creature it may be found by), npcs (other keepers
  -- of a group), by (the gestures it takes);
  -- its quarry: the creature, its poster, its haunts (x, y, r) shaded once it is
  -- the target, the note and margin veiled
  expeditions = {
${zones
  .map((e) => {
    const z = data.zones[String(e.zone)];
    const p = e.quarry;
    const c = p && (creatures.get(p.id) ?? p.own);
    const level = c ? (c.levels[0] === c.levels[1] ? `${c.levels[0]}` : `${c.levels[0]}-${c.levels[1]}`) : "";
    const quarry = p && c
      ? `
      quarry = { id = ${p.id}, name = ${q(c.name)}, level = ${q(level)}, rank = ${q(c.rank)}, model = ${c.model || 0}, haunts = { ${p.haunts.map(nums).join(", ")} }, verse = { ${p.verse.map(q).join(", ")} }, note = ${q(veil(p.note, `quarry-${p.id}`))}, margin = ${q(veil(p.margin, `quarry-${p.id}`))} },`
      : "";
    return `    [${e.zone}] = {
      w = ${z.w}, h = ${z.h},${e.home ? ` home = ${q(e.home)},` : ""}${quarry}
      areas = ${nums(z.areas)},
      riddles = {
${e.riddles.map((r) => riddle(r, z.w, z.h)).join("\n")}
      },
    },`;
  })
  .join("\n")}
  },`;
}

/** Every zone is one of its games', every quarry a creature of the data. */
export function checkZones(ex: Expedition[], zoneIds: (client: string) => Set<number>, creatureIds: Set<number>, clients: string[], fail: (file: string, msg: string) => void) {
  for (const e of ex) {
    for (const client of clients)
      if ((e.client === "both" || e.client === client) && !zoneIds(client).has(e.zone))
        fail(e.file, `zone ${e.zone}: not one of ${client}'s (data/zones-${client}.json)`);
    if (e.quarry?.own && (e.client !== "forever" || creatureIds.has(e.quarry.id)))
      fail(e.file, `quarry ${e.quarry.id}: a name, level and rank of its own only for a creature of Forever's own, which data/creatures.json doesn't know`);
    if (e.quarry && !e.quarry.own && !creatureIds.has(e.quarry.id)) fail(e.file, `quarry ${e.quarry.id}: not in data/creatures.json`);
  }
}
