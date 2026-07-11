class_name CraftingService
extends RefCounted

## Queues crafting recipes and produces items over time.

class CraftingJob:
	var recipe_id: String
	var progress: float = 0.0
	var required_time: float = 0.0
	var assigned_station: String = ""
	var output_inventory: Inventory

var _queue: Array[CraftingJob] = []
var _active: CraftingJob = null

func can_craft(inventory: Inventory, recipe_id: String) -> bool:
	var recipe: Dictionary = DataService.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	for input in recipe.inputs:
		if not inventory.has_item(input.item, input.quantity):
			return false
	return true

func start_craft(inventory: Inventory, recipe_id: String, station: String = "any") -> bool:
	if not can_craft(inventory, recipe_id):
		return false
	var recipe: Dictionary = DataService.get_recipe(recipe_id)
	if station != "any" and recipe.get("station", "any") != station:
		return false
	for input in recipe.inputs:
		inventory.remove_item(input.item, input.quantity)
	var job: CraftingJob = CraftingJob.new()
	job.recipe_id = recipe_id
	job.required_time = recipe.get("time", 1.0)
	job.assigned_station = station
	job.output_inventory = inventory
	_queue.append(job)
	return true

func update(delta: float) -> void:
	if _active == null and _queue.size() > 0:
		_active = _queue.pop_front()
	if _active != null:
		_active.progress += delta
		if _active.progress >= _active.required_time:
			_complete(_active)
			_active = null

func _complete(job: CraftingJob) -> void:
	var recipe: Dictionary = DataService.get_recipe(job.recipe_id)
	for output in recipe.outputs:
		job.output_inventory.add_item(output.item, output.quantity)

func get_queue() -> Array[CraftingJob]:
	var out: Array[CraftingJob] = _queue.duplicate()
	if _active != null:
		out.append(_active)
	return out

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for j in get_queue():
		arr.append({
			"recipe_id": j.recipe_id,
			"progress": j.progress,
			"required_time": j.required_time,
			"assigned_station": j.assigned_station
		})
	return {"queue": arr}

func from_dict(d: Dictionary) -> void:
	_queue.clear()
	_active = null
	for jd in d.get("queue", []):
		var j: CraftingJob = CraftingJob.new()
		j.recipe_id = jd.get("recipe_id", "")
		j.progress = jd.get("progress", 0.0)
		j.required_time = jd.get("required_time", 0.0)
		j.assigned_station = jd.get("assigned_station", "")
		_queue.append(j)
