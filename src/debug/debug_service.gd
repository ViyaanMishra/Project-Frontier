class_name DebugService
extends RefCounted

## Developer commands and world mutation tools.

func spawn_entity(world: WorldService, type: EntityRecord.Type, pos: Vector2i, faction: String = "") -> EntityRecord:
	var entity: EntityRecord = EntityRecord.new("debug_" + str(Determinism.randi()))
	entity.type = type
	entity.position = pos
	entity.chunk_id = world.get_chunk_at_world(pos.x, pos.y).id
	entity.faction_id = faction
	world.get_chunk_at_world(pos.x, pos.y).entities.append(entity.id)
	return entity

func set_seed(seed_value: int) -> void:
	Determinism.initialize(seed_value)

func trigger_event(event_id: String) -> void:
	GameSession.event_service.trigger(event_id)

func inspect_entity(id: String) -> Dictionary:
	# Placeholder: scan loaded chunks for entity.
	for chunk_id in GameSession.world.chunks:
		var chunk: WorldChunk = GameSession.world.chunks[chunk_id]
		if chunk.entities.has(id):
			return {"chunk": chunk_id, "found": true}
	return {"found": false}

func validate_save(slot: int) -> bool:
	var data: Dictionary = GameSession.save_service.load(slot)
	return data.has("manifest")

func list_loaded_chunks() -> Array[String]:
	var out: Array[String] = []
	for id in GameSession.world.chunks:
		out.append(id)
	return out
