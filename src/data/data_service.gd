class_name DataService
extends RefCounted

## Central registry for game definitions. Supports base definitions and JSON mods.

static var _items: Dictionary = {}
static var _recipes: Dictionary = {}
static var _buildings: Dictionary = {}
static var _research: Dictionary = {}
static var _factions: Dictionary = {}
static var _quests: Dictionary = {}
static var _events: Dictionary = {}

static func initialize() -> void:
	_load_base_definitions()
	_load_mods()

static func _load_base_definitions() -> void:
	# Primitive fallback if no JSON files present.
	_register_item(ItemDefinition.new(), {
		"id": "wood",
		"display_name": "Wood",
		"weight": 0.5,
		"max_stack": 64,
		"category": "resource"
	})
	_register_item(ItemDefinition.new(), {
		"id": "stone",
		"display_name": "Stone",
		"weight": 1.0,
		"max_stack": 32,
		"category": "resource"
	})
	_register_item(ItemDefinition.new(), {
		"id": "metal_scrap",
		"display_name": "Metal Scrap",
		"weight": 0.8,
		"max_stack": 32,
		"category": "resource"
	})
	_register_item(ItemDefinition.new(), {
		"id": "food_ration",
		"display_name": "Food Ration",
		"weight": 0.2,
		"max_stack": 20,
		"category": "consumable",
		"use_effects": [{"type": "hunger", "value": 20.0}]
	})
	_register_item(ItemDefinition.new(), {
		"id": "knife",
		"display_name": "Crude Knife",
		"weight": 1.5,
		"max_stack": 1,
		"category": "weapon",
		"equip_slot": "main_hand"
	})

	_register_recipe({
		"id": "crude_knife",
		"inputs": [{"item": "stone", "quantity": 2}, {"item": "wood", "quantity": 1}],
		"outputs": [{"item": "knife", "quantity": 1}],
		"station": "any",
		"time": 5.0
	})

	_register_building({
		"id": "campfire",
		"display_name": "Campfire",
		"costs": [{"item": "wood", "quantity": 5}],
		"size": Vector2i(1, 1),
		"category": "production"
	})

static func _load_mods() -> void:
	var mod_dir: String = "user://mods/"
	var dir: DirAccess = DirAccess.open(mod_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	var folder: String = dir.get_next()
	while folder != "":
		if dir.current_is_dir():
			var manifest_path: String = mod_dir + folder + "/manifest.json"
			var manifest: Dictionary = _load_json(manifest_path)
			if _validate_mod_manifest(manifest):
				# Load mod items/recipes.
				pass
		folder = dir.get_next()
	dir.list_dir_end()

static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var err: Error = json.parse(text)
	if err != OK:
		return {}
	return json.data as Dictionary

static func _validate_mod_manifest(manifest: Dictionary) -> bool:
	return manifest.has("id") and manifest.has("version") and manifest.has("dependencies")

static func _register_item(template: ItemDefinition, d: Dictionary) -> void:
	var item: ItemDefinition = ItemDefinition.new()
	item.from_dict(d)
	_items[item.id] = item

static func _register_recipe(d: Dictionary) -> void:
	_recipes[d.id] = d

static func _register_building(d: Dictionary) -> void:
	_buildings[d.id] = d

static func get_item(id: String) -> ItemDefinition:
	return _items.get(id, null)

static func get_recipe(id: String) -> Dictionary:
	return _recipes.get(id, {})

static func get_building(id: String) -> Dictionary:
	return _buildings.get(id, {})

static func get_all_items() -> Dictionary:
	return _items.duplicate()

static func get_all_recipes() -> Dictionary:
	return _recipes.duplicate()
