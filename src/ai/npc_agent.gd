class_name NPCAgent
extends RefCounted

## Encapsulates NPC behavior: needs, schedule, relationships, and memory.

var entity: EntityRecord
var memory: MemoryBank
var schedule: Array[Dictionary] = []
var relationships: Dictionary = {}
var current_need: String = "none"
var last_evaluated: float = 0.0

func _init(p_entity: EntityRecord) -> void:
	entity = p_entity
	memory = MemoryBank.new()

func update_needs(delta: float) -> void:
	entity.hunger -= 0.3 * delta
	entity.stamina += 0.5 * delta
	entity.stamina = clampf(entity.stamina, 0.0, 100.0)
	if entity.hunger < 30.0:
		current_need = "hunger"
	elif entity.stamina < 30.0:
		current_need = "rest"
	else:
		current_need = "work"

func adjust_relationship(target_id: String, delta: float) -> void:
	var value: float = relationships.get(target_id, 0.0)
	value = clampf(value + delta, -100.0, 100.0)
	relationships[target_id] = value

func get_relationship(target_id: String) -> float:
	return relationships.get(target_id, 0.0)

func to_dict() -> Dictionary:
	return {
		"entity_id": entity.id,
		"relationships": relationships,
		"current_need": current_need,
		"last_evaluated": last_evaluated,
		"memory": memory.to_dict()
	}

func from_dict(d: Dictionary) -> void:
	relationships = d.get("relationships", {})
	current_need = d.get("current_need", "none")
	last_evaluated = d.get("last_evaluated", 0.0)
	memory = MemoryBank.new()
	memory.from_dict(d.get("memory", {}))
