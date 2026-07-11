class_name WorldService
extends RefCounted

## Owns chunks, world generation, and tier promotion/demotion.

var chunks: Dictionary = {}
var generator: WorldGenerator
var _seed: int = 0

func _init(p_seed: int) -> void:
	_seed = p_seed
	generator = WorldGenerator.new(p_seed)

func ensure_chunk(cx: int, cy: int) -> WorldChunk:
	var id: String = str(cx) + "," + str(cy)
	if not chunks.has(id):
		var chunk: WorldChunk = WorldChunk.new(id, cx, cy)
		generator.generate_chunk(chunk)
		chunks[id] = chunk
	return chunks[id]

func get_chunk_at_world(wx: int, wy: int) -> WorldChunk:
	var cx: int = floori(float(wx) / Constants.CHUNK_SIZE)
	var cy: int = floori(float(wy) / Constants.CHUNK_SIZE)
	return ensure_chunk(cx, cy)

func get_tile(wx: int, wy: int) -> WorldTile:
	var chunk: WorldChunk = get_chunk_at_world(wx, wy)
	var local: Vector2i = chunk.world_to_local(wx, wy)
	return chunk.get_tile(local.x, local.y)

func set_tile(wx: int, wy: int, tile: WorldTile) -> void:
	var chunk: WorldChunk = get_chunk_at_world(wx, wy)
	var local: Vector2i = chunk.world_to_local(wx, wy)
	chunk.set_tile(local.x, local.y, tile)

func promote_chunk(cx: int, cy: int) -> bool:
	var chunk: WorldChunk = ensure_chunk(cx, cy)
	if chunk.state == WorldChunk.TierState.ACTIVE:
		return true
	if chunk.state == WorldChunk.TierState.OFFLINE or chunk.state == WorldChunk.TierState.DISTANT:
		chunk.state = WorldChunk.TierState.PREPARING
		chunk.preparation_progress = 0.0
		return false
	if chunk.state == WorldChunk.TierState.PREPARING:
		chunk.preparation_progress += 0.1
		# Simulate asset prep steps.
		if chunk.preparation_progress >= 1.0:
			chunk.state = WorldChunk.TierState.ACTIVE
			chunk.preparation_progress = 0.0
			return true
		return false
	return false

func demote_chunk(cx: int, cy: int) -> void:
	var id: String = str(cx) + "," + str(cy)
	if not chunks.has(id):
		return
	var chunk: WorldChunk = chunks[id]
	chunk.state = WorldChunk.TierState.DISTANT
	chunk.preparation_progress = 0.0

func get_active_chunk_ids() -> Array[String]:
	var out: Array[String] = []
	for id in chunks:
		var chunk: WorldChunk = chunks[id]
		if chunk.state == WorldChunk.TierState.ACTIVE:
			out.append(id)
	return out

func to_dict() -> Dictionary:
	var d: Dictionary = {}
	d["seed"] = _seed
	var chunks_arr: Array[Dictionary] = []
	for id in chunks:
		chunks_arr.append(chunks[id].to_dict())
	d["chunks"] = chunks_arr
	return d

func from_dict(d: Dictionary) -> void:
	_seed = d.get("seed", 0)
	chunks.clear()
	generator = WorldGenerator.new(_seed)
	for cd in d.get("chunks", []):
		var chunk: WorldChunk = WorldChunk.new(cd.id, cd.get("cx", 0), cd.get("cy", 0))
		chunk.from_dict(cd)
		chunks[chunk.id] = chunk
