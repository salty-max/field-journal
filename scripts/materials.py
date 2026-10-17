#!/usr/bin/env python3
"""Generate item-based Finds from wow-data, never from another source cache.

The reviewed identities live in data/finds-catalog.json. Nodes and creatures
only establish acquisition and places, never collection entries. Research
details are written to the ignored cache for checking authored notes.
"""
import collections
import json
import os
from finds_data import Inventory, ROOT, LOCALES
from flora import zone_tools

CATALOG = json.load(open(os.path.join(ROOT, "data/finds-catalog.json")))
MINERALS = {"ore", "questOre", "stone", "gem"}


def generate(game):
    inv = Inventory(game)
    area_zone, spot_zone, _, _, maps, _ = zone_tools(game)
    areas = dict(inv.db.execute("SELECT id,name FROM name WHERE kind='area' AND locale='enUS'"))
    uimaps = dict(inv.db.execute("SELECT id,name FROM name WHERE kind='ui_map' AND locale='enUS'"))
    spawns = collections.defaultdict(list)
    for r in inv.rows("SELECT * FROM spawn"):
        spawns[(r['kind'], r['entity_id'])].append(r)
    catalog = {kind: list(ids) for kind, ids in CATALOG.items() if kind != 'forever'}
    if game == 'forever':
        for kind, ids in CATALOG['forever'].items():
            catalog[kind].extend(ids)
    mining = inv.nodes(3)
    skills = {r['id']: r['skill'] for r in mining}
    node_items = {r['id']: set(r['items']) for r in mining}
    out, evidence = [], {}
    for kind, ids in catalog.items():
        for id in ids:
            if id not in inv.items:
                raise ValueError(f'{game}: missing catalog item {id}')
            if inv.items[id]['removed']:
                continue
            if kind in MINERALS:
                sources = [('object', n, 'gathered') for n, yields in node_items.items() if id in yields]
            elif kind in ('leather', 'hide'):
                sources = [('creature', c['id'], 'skinned') for c in inv.creatures.values()
                           if id in inv.yields('skinning', c['id'], c['skin_loot_id'])]
            else:
                sources = [('creature', c['id'], 'looted') for c in inv.creatures.values()
                           if id in inv.yields('creature', c['id'], c['loot_id'])]
            if not sources:
                raise ValueError(f'{game}: no confirmed {kind} source for {id}')
            counts, dungeons = collections.Counter(), set()
            for entity_kind, entity, _ in sources:
                for r in spawns[(entity_kind, entity)]:
                    zone = area_zone(r['area_id']) if r['area_id'] else None
                    if not zone and r['x'] is not None and r['y'] is not None:
                        zone = spot_zone(r['map_id'], r['x'], r['y'])
                    if zone:
                        counts[zone] += 1
                    elif r['area_id'] in maps.values():
                        dungeons.add(r['area_id'])
                    elif r['map_id'] not in (None, 0, 1) and maps.get(r['map_id']):
                        dungeons.add(maps[r['map_id']])
            total = sum(counts.values())
            zones = sorted(z for z, n in counts.items() if n >= 6 and n >= total * .03)
            # A rare creature or special source can have only one known spawn.
            if not zones and counts:
                zones = sorted(counts)
            family = 'mining' if kind in MINERALS else 'cloth' if kind == 'cloth' else 'leather'
            entry = {'id': id, 'name': inv.name('item', id), 'kind': 'ore' if kind == 'questOre' else kind,
                     'family': family, 'icon': inv.icons[id], 'zones': zones, 'dungeons': sorted(dungeons)}
            if kind == 'questOre':
                entry['quest'] = True
            if kind in MINERALS:
                entry['skill'] = min(skills[n] for _, n, _ in sources)
            out.append(entry)
            recipes = inv.rows('''SELECT DISTINCT r.SpellID AS id,n.name FROM client_SpellReagents r
                JOIN client_SkillLineAbility a ON a.Spell=r.SpellID
                JOIN name n ON n.kind='spell' AND n.id=r.SpellID AND n.locale='enUS'
                WHERE a.SkillLine IN (164,165,197,202,171,333,186,129) AND r.SpellID<40000
                AND ? IN (Reagent_0,Reagent_1,Reagent_2,Reagent_3,Reagent_4,Reagent_5,Reagent_6,Reagent_7)
                ORDER BY r.SpellID''', (id,))
            evidence[id] = {'name': entry['name'], 'kind': kind,
                            'zones': [uimaps.get(z, str(z)) for z in zones],
                            'dungeons': [areas.get(a, str(a)) for a in sorted(dungeons)],
                            'sources': [{'kind': k, 'id': n, 'name': inv.name(k, n)} for k, n, _ in sources],
                            'recipes': recipes}
    item_ids = {r['id'] for r in out}
    if len(item_ids) != len(out):
        raise ValueError('an item appears in two catalog groups')
    professions = inv.professions()
    aliases = {r['id']: family for family, rows in professions.items() for r in rows}
    names = {loc: {id: inv.names[('item', id, loc)][0] for id in sorted(item_ids)
                   if ('item', id, loc) in inv.names} for loc in LOCALES}
    prof_names = {loc: {inv.names[('skill_line', r['id'], loc)][0]: family
                       for family, rows in professions.items() for r in rows
                       if ('skill_line', r['id'], loc) in inv.names} for loc in LOCALES}
    # Effect 95 also means Mining/Herbalism on Forever. Only the Skinning
    # effect's actual subtype belongs here, not every spell with that effect.
    skin_spells = [spell for spell, in inv.db.execute(
        'SELECT DISTINCT SpellID FROM client_SpellEffect WHERE Effect=95 AND EffectMiscValue_0=0')]
    return {'items': out, 'miningNodes': sorted(node_items), 'skillAliases': aliases,
            'professionNames': prof_names, 'itemNames': names, 'skinSpells': skin_spells}, evidence


def main():
    research = {}
    for game in ('classic', 'forever'):
        data, research[game] = generate(game)
        path = os.path.join(ROOT, 'data', f'materials-{game}.json')
        with open(path, 'w') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            f.write('\n')
        print(f'{game}: {len(data["items"])} material item pages')
    os.makedirs(os.path.join(ROOT, '.cache'), exist_ok=True)
    with open(os.path.join(ROOT, '.cache/materials-evidence.json'), 'w') as f:
        json.dump(research, f, ensure_ascii=False, indent=2)


if __name__ == '__main__':
    main()
