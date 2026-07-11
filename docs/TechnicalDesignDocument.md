# Technical Design Document

## Engine

- Godot 4.4.1 stable, GDScript, 1920×1080 target.
- `GL Compatibility` renderer for broad hardware support.
- 60 physics/second, `Viewport` stretch mode.

## World Simulation

- Seed-based deterministic 512×512 world.
- 32×32 chunks, each with `WorldChunk` canonical state.
- `WorldGenerator` uses a per-chunk deterministic `RandomNumberGenerator` offset from the run seed.
- `WorldService` owns chunks and handles tier transitions.
- `WorldChunk` stores `WorldTile` array, dirty tile deltas, entity IDs, and nav revision.

## Navigation

- `NavigationService` exposes `request_path(agent, start, goal, priority, callback)`.
- Hierarchical A*: per-chunk local pathfinding with `WorldTile` costs and walkability.
- Request queue with priority, retry backoffs (1/2/4/8/16 seconds).
- Per-chunk `nav_revision` and cache invalidation for `NavigationChangeEvents`.
- Debug telemetry: active/queued requests, average path time, failed paths, cache hit rate, dirty queue depth.

## AI

- `UtilityAI` registers evaluators (`Callable` returning score).
- Round-robin budget (default 24 per tick) plus forced reevaluations for emergencies.
- `MemoryBank` manages `MemoryRecord` lifecycle: merge, decay, prune to 64 active / 24 long-term.
- `NPCAgent` wraps entity, needs, schedule, and relationships.

## Persistence

- `Record` base class provides version, revision, dirty flag, and `to_dict`/`from_dict`.
- `SaveService` writes dirty chunks and records to a temporary directory, then atomically renames.
- Five manual slots, three rotating autosaves, optional Ironman mode.
- Manifests include version, seed, timestamp, and chunk list.
- Corrupt chunk recovery uses deterministic regeneration from seed plus saved deltas.

## Modding

- `DataService` loads `res://data` base definitions and `user://mods/<id>/manifest.json`.
- Mods validated for ID, version, dependencies, and cross-references.
- Missing-mod content is preserved as inert recoverable records.

## Networking

Single-player only. No client/server or rollback in this milestone.

## Performance Targets

- 500 active entities, 200 NPCs, 10,000 world objects at 1080p/60 FPS.
- Achieved through pooling, culling, tiered simulation, path budgets, dirty saves, and event-driven updates.
