class_name WorldGenerator
extends RefCounted

## Deterministic 512x512 world generator with six biomes, safe starts, and resource regions.

var _seed: int = 0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init(p_seed: int) -> void:
	_seed = p_seed
	_rng.seed = _seed

func generate_chunk(chunk: WorldChunk) -> void:
	var base: int = chunk.cx * 374761 + chunk.cy * 668265
	_rng.seed = _seed + base
	for y in range(Constants.CHUNK_SIZE):
		for x in range(Constants.CHUNK_SIZE):
			var wx: int = chunk.cx * Constants.CHUNK_SIZE + x
			var wy: int = chunk.cy * Constants.CHUNK_SIZE + y
			var tile: WorldTile = _generate_tile(wx, wy)
			chunk.set_tile(x, y, tile)
	chunk.mark_dirty()

func _generate_tile(wx: int, wy: int) -> WorldTile:
	var tile: WorldTile = WorldTile.new()
	var biomes: Dictionary = Biome.get_biomes()
	var value: float = _noise(wx, wy, 16.0)
	var biome_id: int
	if wx < 64 and wy < 64:
		biome_id = Constants.BIOME_SAFE_START
	elif _distance_to_center(wx, wy) > 200 and _rng.randf() < 0.05:
		biome_id = Constants.BIOME_ANOMALY
	else:
		if value < -0.2:
			biome_id = Constants.BIOME_DESERT
		elif value < 0.0:
			biome_id = Constants.BIOME_WASTELAND
		elif value < 0.3:
			biome_id = Constants.BIOME_FOREST
		else:
			biome_id = Constants.BIOME_MOUNTAIN
	tile.biome = biome_id
	var biome: Biome = biomes[biome_id]
	tile.movement_cost = biome.movement_cost
	tile.is_walkable = biome_id != Constants.BIOME_MOUNTAIN or _rng.randf() > 0.3
	if _rng.randf() < 0.1 and biome.resource_weights.size() > 0:
		var keys: Array = biome.resource_weights.keys()
		var weights: Array[float] = []
		for k in keys:
			weights.append(biome.resource_weights[k])
		var idx: int = _weighted_choice(weights)
		tile.resource_id = keys[idx]
		tile.resource_quantity = _rng.randi_range(3, 10)
	return tile

func _noise(x: int, y: int, scale: float) -> float:
	var fx: float = float(x) / scale
	var fy: float = float(y) / scale
	return sin(fx * 12.9898 + fy * 78.233) * 43758.5453

func _distance_to_center(wx: int, wy: int) -> float:
	var cx: float = Constants.WORLD_SIZE / 2.0
	var cy: float = Constants.WORLD_SIZE / 2.0
	return sqrt((wx - cx) * (wx - cx) + (wy - cy) * (wy - cy))

func _weighted_choice(weights: Array[float]) -> int:
	var total: float = 0.0
	for w in weights:
		total += w
	var roll: float = _rng.randf() * total
	var acc: float = 0.0
	for i in range(weights.size()):
		acc += weights[i]
		if roll <= acc:
			return i
	return weights.size() - 1
