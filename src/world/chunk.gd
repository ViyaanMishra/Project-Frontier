class_name WorldChunk
extends Record

## Represents a 32x32 chunk of the 512x512 world.

enum TierState { OFFLINE, DISTANT, PREPARING, ACTIVE }

var cx: int = 0
var cy: int = 0
var tiles: Array[WorldTile] = []
var state: TierState = TierState.OFFLINE
var preparation_progress: float = 0.0
var nav_revision: int = 0
var entities: Array[String] = []
var dirty_tiles: Dictionary = {}
var portal_edges: Array[Vector2i] = []

func _init(p_id: String = "", p_cx: int = 0, p_cy: int = 0) -> void:
	super(p_id)
	cx = p_cx
	cy = p_cy
	tiles.resize(Constants.CHUNK_SIZE * Constants.CHUNK_SIZE)
	for i in range(tiles.size()):
		tiles[i] = WorldTile.new()

func get_tile(local_x: int, local_y: int) -> WorldTile:
	if local_x < 0 or local_x >= Constants.CHUNK_SIZE or local_y < 0 or local_y >= Constants.CHUNK_SIZE:
		return null
	return tiles[local_y * Constants.CHUNK_SIZE + local_x]

func set_tile(local_x: int, local_y: int, tile: WorldTile) -> void:
	if local_x < 0 or local_x >= Constants.CHUNK_SIZE or local_y < 0 or local_y >= Constants.CHUNK_SIZE:
		return
	tiles[local_y * Constants.CHUNK_SIZE + local_x] = tile
	dirty_tiles[str(local_x) + "," + str(local_y)] = tile.to_dict()
	mark_dirty()

func world_to_local(wx: int, wy: int) -> Vector2i:
	return Vector2i(wx - cx * Constants.CHUNK_SIZE, wy - cy * Constants.CHUNK_SIZE)

func global_to_chunk_id() -> String:
	return str(cx) + "," + str(cy)

func is_active() -> bool:
	return state == TierState.ACTIVE

func to_dict() -> Dictionary:
	var d: Dictionary = super()
	d["cx"] = cx
	d["cy"] = cy
	d["state"] = state
	d["preparation_progress"] = preparation_progress
	d["nav_revision"] = nav_revision
	d["entities"] = entities
	d["dirty_tiles"] = dirty_tiles
	d["portal_edges"] = []
	for v in portal_edges:
		d["portal_edges"].append({"x": v.x, "y": v.y})
	d["tile_count"] = tiles.size()
	return d

func from_dict(d: Dictionary) -> void:
	super(d)
	cx = d.get("cx", 0)
	cy = d.get("cy", 0)
	state = d.get("state", TierState.OFFLINE)
	preparation_progress = d.get("preparation_progress", 0.0)
	nav_revision = d.get("nav_revision", 0)
	entities.assign(d.get("entities", []))
	dirty_tiles = d.get("dirty_tiles", {})
	portal_edges.clear()
	for vd in d.get("portal_edges", []):
		portal_edges.append(Vector2i(vd.x, vd.y))
