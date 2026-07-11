class_name BuildingService
extends RefCounted

## Grid building with placement validation, costs, construction progress, and upgrades.

class BuildingSite:
	var id: String
	var building_id: String
	var position: Vector2i
	var progress: float = 0.0
	var max_progress: float = 10.0
	var completed: bool = false

var _sites: Array[BuildingSite] = []

func can_place(world: WorldService, building_id: String, pos: Vector2i, size: Vector2i, inventory: Inventory) -> bool:
	var def: Dictionary = DataService.get_building(building_id)
	if def.is_empty():
		return false
	for x in range(pos.x, pos.x + size.x):
		for y in range(pos.y, pos.y + size.y):
			if x < 0 or y < 0 or x >= Constants.WORLD_SIZE or y >= Constants.WORLD_SIZE:
				return false
			var tile: WorldTile = world.get_tile(x, y)
			if tile == null or not tile.is_walkable or tile.building_id != "":
				return false
	for cost in def.get("costs", []):
		if not inventory.has_item(cost.item, cost.quantity):
			return false
	return true

func place_building(world: WorldService, building_id: String, pos: Vector2i, inventory: Inventory) -> BuildingSite:
	var def: Dictionary = DataService.get_building(building_id)
	var size: Vector2i = def.get("size", Vector2i(1, 1))
	if not can_place(world, building_id, pos, size, inventory):
		return null
	for cost in def.get("costs", []):
		inventory.remove_item(cost.item, cost.quantity)
	var site: BuildingSite = BuildingSite.new()
	site.id = building_id + "_" + str(pos.x) + "_" + str(pos.y)
	site.building_id = building_id
	site.position = pos
	site.max_progress = def.get("construction_time", 10.0)
	_sites.append(site)
	return site

func build_tick(site: BuildingSite, delta: float, work_amount: float = 1.0) -> void:
	if site.completed:
		return
	site.progress += work_amount * delta
	if site.progress >= site.max_progress:
		site.completed = true
		# Mark tile as building.
		var def: Dictionary = DataService.get_building(site.building_id)
		var size: Vector2i = def.get("size", Vector2i(1, 1))
		for x in range(site.position.x, site.position.x + size.x):
			for y in range(site.position.y, site.position.y + size.y):
				var tile: WorldTile = GameSession.world.get_tile(x, y)
				if tile != null:
					tile.building_id = site.building_id
					GameSession.world.set_tile(x, y, tile)

func get_sites() -> Array[BuildingSite]:
	return _sites

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for s in _sites:
		arr.append({
			"id": s.id,
			"building_id": s.building_id,
			"position": {"x": s.position.x, "y": s.position.y},
			"progress": s.progress,
			"max_progress": s.max_progress,
			"completed": s.completed
		})
	return {"sites": arr}

func from_dict(d: Dictionary) -> void:
	_sites.clear()
	for sd in d.get("sites", []):
		var s: BuildingSite = BuildingSite.new()
		s.id = sd.get("id", "")
		s.building_id = sd.get("building_id", "")
		s.position = Vector2i(sd.position.x, sd.position.y)
		s.progress = sd.get("progress", 0.0)
		s.max_progress = sd.get("max_progress", 10.0)
		s.completed = sd.get("completed", false)
		_sites.append(s)
