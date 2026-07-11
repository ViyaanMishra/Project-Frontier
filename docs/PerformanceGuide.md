# Performance Guide

## Target

Stable 60 FPS at 1920×1080 with 500 active entities, 200 NPCs, and 10,000 world objects.

## Strategies

1. **Tiered Simulation** — Active chunks run full simulation; distant chunks run reduced updates; offline chunks run aggregate math.
2. **Chunk Promotion** — `PREPARING` state loads visual proxies, physics shapes, and navigation without exposing partial state.
3. **Navigation Budgets** — Four portal recalculations and 16 cache repairs per frame; path requests queued and prioritized.
4. **Utility AI Budget** — 24 normal evaluations per tick; emergencies bypass the queue.
5. **Memory Pruning** — 64 active and 24 long-term records cap per NPC.
6. **Dirty Saves** — Only changed chunks and records are serialized.
7. **Event-Driven Updates** — `NavigationChangeEvents` are coalesced and processed per frame.
8. **Visual Culling** — `Camera2D` zoom ensures only the relevant area is rendered.

## Telemetry

- `GameSession.get_telemetry()` returns simulation time, player state, colony state, and navigation metrics.
- `NavigationService.get_telemetry()` returns active/queued paths, cache hit rate, failed paths, and dirty queue depth.
- Threshold warnings are surfaced in the debug UI.

## Profiling

Use the Godot Profiler (`F12` or `Debugger > Profiler`) to inspect frame time, draw calls, and physics.

## Stress Testing

The headless test suite includes planned stress tests. Run with `--headless` and large entity counts to measure CPU throughput.
