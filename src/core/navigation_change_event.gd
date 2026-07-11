class_name NavigationChangeEvent
extends RefCounted

enum Type { BLOCKED, OPENED, COST_CHANGED, PORTAL_CHANGED }

var type: Type
var chunk_id: String
var bounds: Rect2i
var data: Dictionary

func _init(p_type: Type, p_chunk_id: String, p_bounds: Rect2i, p_data: Dictionary = {}) -> void:
	type = p_type
	chunk_id = p_chunk_id
	bounds = p_bounds
	data = p_data

func to_dict() -> Dictionary:
	return {
		"type": type,
		"chunk_id": chunk_id,
		"bounds": { "x": bounds.position.x, "y": bounds.position.y, "w": bounds.size.x, "h": bounds.size.y },
		"data": data
	}

static func from_dict(d: Dictionary) -> NavigationChangeEvent:
	var b: Rect2i = Rect2i(d.bounds.x, d.bounds.y, d.bounds.w, d.bounds.h)
	return NavigationChangeEvent.new(d.type, d.chunk_id, b, d.data)
