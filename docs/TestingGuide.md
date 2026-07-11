# Testing Guide

## Test Runner

All tests are run headless:

```bash
godot --headless src/tests/test_scene.tscn
```

## Test Suites

- `determinism` — RNG state reproducibility.
- `chunk_determinism` — Same seed generates identical chunks.
- `inventory` — Add/remove, weight, stacks.
- `clock` — Time scale, pause, step.
- `navigation` — Path request queue and A*.
- `save_roundtrip` — Save and load a slot.
- `memory_lifecycle` — Memory decay and prune.
- `utility_ai` — Action selection.

## Adding Tests

Open `src/tests/test_runner.gd`, add a `_test_*` method, and register it in `_register_suites`.

## Manual Smoke Tests

1. Start `scenes/main.tscn`.
2. Move with WASD.
3. Gather a resource.
4. Open inventory, crafting, build, and debug overlays.
5. Pause and step time.
6. Save and load a slot.

## CI

The test runner exits with a non-zero code if any test fails. Run it in GitHub Actions or any CI provider.
