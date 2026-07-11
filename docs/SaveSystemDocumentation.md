# Save System Documentation

## Slots

Manual saves are stored under `user://saves/slot_<n>/` where `n` is 1–5.
Autosaves use slots `autosave_<n>` where `n` is 1–3.

## File Layout

```
user://saves/slot_1/
  data/
    manifest.json
    chunk_0_0.json
    chunk_1_0.json
    ...
    colony.json
    factions.json
    economy.json
    events.json
    player.json
    clock.json
    crafting.json
    building.json
    utility_ai.json
    disease.json
    quests.json
    research.json
    continuum.json
    entity_service.json
```

## Incremental Writes

- Only chunks marked dirty or in the active tier are written.
- Domain records are serialized only when dirty.
- Writes go to `slot_n/temp/` first, then the directory is atomically renamed to `slot_n/data/`.

## Manifest

```json
{
  "version": 0,
  "subversion": 1,
  "patch": 0,
  "timestamp": 1234567890,
  "seed": 12345,
  "world_chunks": ["0,0", "1,0"]
}
```

## Loading

1. Read `manifest.json`.
2. Regenerate world from seed.
3. Apply per-chunk delta files.
4. Load domain records from JSON.
5. Re-link player from entity service.
6. Restore dirty state for records changed during load.

## Recovery

- If a chunk file is corrupt, the tile deltas are skipped and the chunk is regenerated from seed.
- Missing mods preserve content as inert records.
- Save version mismatches are handled by migrators (planned).

## Ironman

Enable Ironman by writing only a single `ironman` slot and disabling manual save UI.
