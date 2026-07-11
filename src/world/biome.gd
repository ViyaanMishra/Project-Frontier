class_name Biome
extends RefCounted

var id: int = 0
var name: String = "Wasteland"
var color: Color = Color.GRAY
var movement_cost: float = 1.0
var resource_weights: Dictionary = {}
var danger: float = 0.0

func _init(p_id: int, p_name: String, p_color: Color, p_cost: float, p_danger: float, p_resources: Dictionary = {}) -> void:
	id = p_id
	name = p_name
	color = p_color
	movement_cost = p_cost
	danger = p_danger
	resource_weights = p_resources

static func get_biomes() -> Dictionary:
	var b: Dictionary = {}
	b[Constants.BIOME_SAFE_START] = Biome.new(Constants.BIOME_SAFE_START, "Safe Start", Color.GREEN, 1.0, 0.0, {"wood": 0.3, "stone": 0.2})
	b[Constants.BIOME_WASTELAND] = Biome.new(Constants.BIOME_WASTELAND, "Wasteland", Color.DARK_GRAY, 1.2, 0.1, {"stone": 0.4, "metal_scrap": 0.2})
	b[Constants.BIOME_FOREST] = Biome.new(Constants.BIOME_FOREST, "Forest", Color.DARK_GREEN, 1.0, 0.2, {"wood": 0.8})
	b[Constants.BIOME_DESERT] = Biome.new(Constants.BIOME_DESERT, "Desert", Color.YELLOW, 1.5, 0.3, {"stone": 0.5, "metal_scrap": 0.1})
	b[Constants.BIOME_MOUNTAIN] = Biome.new(Constants.BIOME_MOUNTAIN, "Mountain", Color.SADDLE_BROWN, 2.0, 0.5, {"stone": 0.9, "metal_scrap": 0.3})
	b[Constants.BIOME_ANOMALY] = Biome.new(Constants.BIOME_ANOMALY, "Anomaly", Color.PURPLE, 1.5, 0.9, {"metal_scrap": 0.5})
	return b
