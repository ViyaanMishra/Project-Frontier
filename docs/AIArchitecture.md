# AI Architecture

## Utility AI

`UtilityAI` is a service that selects NPC actions by scoring candidates. The core formula is:

```
Utility Score = Need Score + Colony Priority + Relationship Modifier + Morale Modifier + Threat Modifier + Directive Modifier + Environment Modifier
```

Each evaluator is a `Callable` registered with `register_evaluator(action_id, evaluator)`.

## Evaluation Budget

- Normal evaluations are processed in a deterministic round-robin queue.
- Default budget: 24 normal evaluations per high-fidelity tick.
- Combat, fire, raid, injury, starvation, and evacuation events force immediate reevaluation for affected NPCs.

## Memory

`MemoryBank` stores up to 64 active and 24 long-term `MemoryRecord` objects:

- Critical: deaths, betrayals, disasters, severe injuries, major discoveries.
- Relationship: trust, fear, affinity, resentment.
- Event: raids, shortages, disease, faction encounters, anomalies.
- Temporary: short-lived tactical observations.

Records merge by category + target + shared tags, decay by relevance, and prune by relevance.

## NPC Agent

`NPCAgent` wraps an `EntityRecord`, tracking:

- Current need (hunger, rest, work).
- Relationships with other entities.
- Schedule and memory.

## Path Planning

NPCs request paths from `NavigationService`. Replanning triggers on blocking, deviation, nav changes, or target movement. Failed paths use deterministic backoff.

## Debug Telemetry

The debug UI shows evaluations per tick, queue size, average evaluation duration, forced reevaluation count, candidates, score components, reservations, paths, and throttling.
