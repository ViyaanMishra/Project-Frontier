class_name WorldTile
extends RefCounted

## Represents a single tile in the 512x512 world.

var biome: int = Constants.BIOME_WASTELAND
var is_walkable: bool = true
var movement_cost: float = 1.0
var resource_id: String = ""
var resource_quantity: int = 0
var building_id: String = ""
var is_water: bool = false
var is_door: bool = false
var is_open: bool = false

func to_dict() -> Dictionary:
	return {
		"biome": biome,
		"is_walkable": is_walkable,
		"movement_cost": movement_cost,
		"resource_id": resource_id,
		"resource_quantity": resource_quantity,
		"building_id": building_id,
		"is_water": is_water,
		"is_door": is_door,
		"is_open": is_open
	}

func from_dict(d: Dictionary) -> void:
	biome = d.get("biome", Constants.BIOME_WASTELAND)
	is_walkable = d.get("is_walkable", true)
	movement_cost = d.get("movement_cost", 1.0)
	resource_id = d.get("resource_id", "")
	resource_quantity = d.get("resource_quantity", 0)
	building_id = d.get("building_id", "")
	is_water = d.get("is_water", false)
	is_door = d.get("is_door", false)
	is_open = d.get("is_open", false)
