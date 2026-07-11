# Project Frontier

A Godot 4.4.1 / GDScript top-down real-time survival RPG with a continuously simulated 512×512 colony frontier.

## Quick Start

1. Install **Godot 4.4.1 stable** for your platform.
2. Open `project.godot` in the Godot Project Manager.
3. Run the `scenes/main.tscn` scene.
4. Use WASD / arrow keys to move, `Shift` to sprint, `E` to interact, `I` / `C` / `B` for inventory / crafting / build overlays, `F12` for debug, and `Esc` for pause.

## Headless Tests

```bash
godot --headless src/tests/test_scene.tscn
```

All suites must pass before a release.

## Project Structure

- `src/core/` — Game session, deterministic RNG, event bus, records.
- `src/world/` — 512×512 chunk generation, biomes, tier promotion/demotion.
- `src/navigation/` — Hierarchical A* with request queues, cache, and budgets.
- `src/ai/` — Utility AI, memory, NPC agents.
- `src/gameplay/` — Player, inventory, crafting, building, combat.
- `src/simulation/` — Clock, economy, events, factions, disease, quests, research, Continuum Array.
- `src/persistence/` — Incremental dirty saves, rotating autosaves, Ironman support.
- `src/data/` — Item/recipe/building definitions and JSON mod loading.
- `src/ui/` — HUD, menus, overlays.
- `src/debug/` — Developer commands and diagnostics.
- `src/tests/` — Headless test runner and suites.
- `docs/` — Architecture, design, modding, testing, and performance guides.

## Key Features

- Deterministic seed-based world generation with six biomes and a Continuum Array.
- Tiered simulation (active / distant / offline chunks).
- Utility AI with memory, reevaluation budgets, and colony priorities.
- Grid building, crafting queues, production, research, and economy.
- Persistence with incremental dirty saves, versioned manifests, and mod recovery.
- Headless test runner for unit, integration, determinism, and save round-trips.

## License

Copyright (c) 2026 ViyaanMishra. All rights reserved.
