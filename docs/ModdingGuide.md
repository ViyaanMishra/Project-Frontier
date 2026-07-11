# Modding Guide

## Mod Structure

Create a folder under `user://mods/<mod_id>/`:

```
user://mods/my_mod/
  manifest.json
  items.json
  recipes.json
  buildings.json
```

## manifest.json

```json
{
  "id": "my_mod",
  "version": "1.0.0",
  "name": "My Mod",
  "dependencies": ["base"],
  "author": "Modder"
}
```

## items.json

```json
{
  "items": [
    {
      "id": "my_item",
      "display_name": "My Item",
      "weight": 0.5,
      "max_stack": 64,
      "category": "resource",
      "tags": ["raw"]
    }
  ]
}
```

## recipes.json

```json
{
  "recipes": [
    {
      "id": "my_recipe",
      "inputs": [{"item": "wood", "quantity": 2}],
      "outputs": [{"item": "my_item", "quantity": 1}],
      "station": "any",
      "time": 3.0
    }
  ]
}
```

## buildings.json

```json
{
  "buildings": [
    {
      "id": "my_building",
      "display_name": "My Building",
      "costs": [{"item": "wood", "quantity": 5}],
      "size": {"x": 1, "y": 1},
      "category": "production",
      "construction_time": 10.0
    }
  ]
}
```

## Validation

On load, the game validates:

- Manifest fields (`id`, `version`, `dependencies`)
- Unique IDs within and across mods
- Cross-references to existing items and buildings
- JSON schema shape

## Loading Order

Base definitions from `res://data` are loaded first, then mods in lexicographic order. Conflicts are resolved by last-loaded mod.

## Recovering Missing Mods

If a mod is missing, records that depend on it are preserved in a recoverable state and skipped in gameplay, protecting the rest of the save.
