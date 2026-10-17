#!/usr/bin/env python3
"""Inventory Finds prerequisites in wow-data, without changing either database.

  WOW_DATA_CACHE=/path/to/cache python3 scripts/finds-audit.py

Writes .cache/finds-audit.json for investigation, not shipped addon data.
The inventories are candidates, not a curated collection or proof of live
availability. In particular, do not turn every skinning yield into leather.
"""
import json
import os
from finds_data import Inventory, ROOT


def main():
    out = {game: Inventory(game).audit() for game in ("classic", "forever")}
    cache = os.path.join(ROOT, ".cache")
    os.makedirs(cache, exist_ok=True)
    file = os.path.join(cache, "finds-audit.json")
    with open(file, "w") as stream:
        json.dump(out, stream, ensure_ascii=False, indent=2)
        stream.write("\n")
    for game, data in out.items():
        print(f"{game}: {len(data['mining_nodes'])} mining templates, "
              f"{len(data['mining_yields'])} mining yields, "
              f"{len(data['skinning_yields'])} skinning yields, "
              f"{len(data['baseline_cloth'])} baseline cloths")
        print(f"  {len(data['unresolved_node_candidates'])} unclassified node candidates, "
              f"{len(data['reference_issues'])} reference issues, "
              f"{len(data['missing_item_icons'])} missing candidate item icons")
        print(f"  {len(data['mining_nodes_without_yields'])} mining objects without yields, "
              f"{len(data['mining_nodes_without_spawns'])} without static spawn rows")
    print(os.path.relpath(file, ROOT))


if __name__ == "__main__":
    main()
