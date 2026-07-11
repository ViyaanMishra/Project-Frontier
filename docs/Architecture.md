# Architecture

## Overview

`Project Frontier` is a top-down real-time survival RPG built in Godot 4.4.1 with GDScript. The architecture is service-oriented and event-driven, with a strict composition root and no circular dependencies.

## Composition Root

`GameSession` (autoload) is the single composition root. It owns all services and coordinates the simulation loop. It is not a generic manager; each service has a narrow domain.

## Service Ownership

| Service | Responsibility |
|---|---|
| `WorldService` | Chunk generation, tier promotion/demotion, tile mutation |
| `NavigationService` | Path requests, hierarchical A*, cache, dirty navigation queue |
| `EntityService` | Canonical entity records and spawn/despawn |
| `ColonyService` | Colony priorities, policies, morale, population |
| `FactionService` | Faction relations and territories |
| `EconomyService` | Supply/demand pricing |
| `EventService` | Dynamic events, story events, Continuum pulses |
| `DiseaseService` | Disease outbreaks and colony effects |
| `QuestService` | Quest stages and objectives |
| `ResearchService` | Four-tier technology tree |
| `ContinuumArray` | Persistent global pressure and final threat |
| `CraftingService` | Recipe queues and production |
| `BuildingService` | Grid building, construction sites, upgrades |
| `CombatSystem` | Damage resolution and status effects |
| `UtilityAI` | NPC action selection with budgets |
| `SaveService` | Versioned incremental persistence |
| `DebugService` | Developer commands and diagnostics |

## Event Bus

Cross-domain effects use `EventBus` typed signals. `NavigationChangeEvents` are emitted for world changes and coalesced into a dirty queue.

## Determinism

`Determinism` (autoload) wraps a single `RandomNumberGenerator` and is initialized from the run seed. All simulation outcomes derive from this RNG.

## Tiered Simulation

World chunks are in one of four tiers: `ACTIVE` (full fidelity), `PREPARING`, `DISTANT` (reduced rate), and `OFFLINE` (aggregate). Promotion requires preparation checks; demotion preserves canonical state and releases visual proxies.

## Persistence

Every domain mutation marks its owning record dirty. `SaveService` writes only dirty chunks and records, then atomically swaps a temporary directory into the slot. Saves are versioned and include manifests for recovery and migration.

## Dependency Rules

- `src/core/` has no dependencies outside core.
- `src/world/` depends on `core` only.
- `src/navigation/` depends on `world` and `core`.
- `src/ai/` depends on `simulation`, `world`, `navigation`.
- `src/gameplay/` depends on `data`, `core`, `world`.
- `src/ui/` depends on `core` and `gameplay` abstractions.
- `src/persistence/` depends on `core`, `world`, `simulation`, `gameplay`.
- `src/debug/` depends on all other domains.

## Tooling

`DebugService` exposes commands for spawning, event control, save validation, seed setting, and loaded-chunk inspection. `UIManager` exposes HUD, inventory, crafting, build, and debug overlays.
