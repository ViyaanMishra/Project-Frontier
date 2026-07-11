class_name EntityService
extends RefCounted

## Owns canonical entity records and handles spawn/despawn.

var entities: Dictionary = {}

func register(entity: EntityRecord) -> void:
	entities[entity.id] = entity

func unregister(id: String) -> void:
	entities.erase(id)

func get_entity(id: String) -> EntityRecord:
	return entities.get(id, null)

func get_all() -> Array[EntityRecord]:
	var out: Array[EntityRecord] = []
	for id in entities:
		out.append(entities[id])
	return out

func get_by_type(type: EntityRecord.Type) -> Array[EntityRecord]:
	var out: Array[EntityRecord] = []
	for id in entities:
		if entities[id].type == type:
			out.append(entities[id])
	return out

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for id in entities:
		arr.append(entities[id].to_dict())
	return {"entities": arr}

func from_dict(d: Dictionary) -> void:
	entities.clear()
	for ed in d.get("entities", []):
		var entity: EntityRecord = EntityRecord.new()
		entity.from_dict(ed)
		entities[entity.id] = entity
