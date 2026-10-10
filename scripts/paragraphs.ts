export type Client = "classic" | "forever";
export type Paragraph = { text: string; client?: Client };

// The same paragraph markers as the Codex. Selection happens while building:
// the installed book contains only the account belonging to its world.
export function paragraphs(body: string): Paragraph[] {
  return body.trim().split(/\n\s*\n/).filter(Boolean).map((raw) => {
    let text = raw.replace(/\s*\n\s*/g, " ").trim();
    const tag = text.match(/^\[([^\]]+)\](?:\s+|$)/);
    if (!tag) return { text };
    if (tag[1] !== "classic" && tag[1] !== "forever") {
      throw new Error(`unknown paragraph client [${tag[1]}]`);
    }
    text = text.slice(tag[0].length).trim();
    if (!text) throw new Error(`empty [${tag[1]}] paragraph`);
    return { text, client: tag[1] };
  });
}

export function forClient(paras: Paragraph[], client: string): string[] {
  return paras.filter((p) => !p.client || p.client === client).map((p) => p.text);
}
