class_name ColonyService
extends Record

## Tracks colony state, priorities, policies, and production targets.

var name: String = "New Colony"
var population: Array[String] = []
var priorities: Dictionary = {}
var policies: Dictionary = {}
var production_targets: Dictionary = {}
var stockpile: Inventory = Inventory.new()
var morale: float = 50.0
var research_progress: Dictionary = {}

func _init(p_id: String = "colony") -> void:
	super(p_id)

func add_member(entity_id: String) -> void:
	if not population.has(entity_id):
		population.append(entity_id)
		mark_dirty()

func remove_member(entity_id: String) -> void:
	if population.has(entity_id):
		population.erase(entity_id)
		mark_dirty()

func set_priority(name: String, value: float) -> void:
	priorities[name] = value
	mark_dirty()

func get_priority(name: String) -> float:
	return priorities.get(name, 0.0)

func set_policy(name: String, value: bool) -> void:
	policies[name] = value
	mark_dirty()

func update(delta: float) -> void:
	# Morale decay and recovery based on food/safety.
	if stockpile.count_item("food_ration") < population.size():
		morale -= 0.5 * delta
	else:
		morale += 0.2 * delta
	morale = clampf(morale, 0.0, 100.0)

func to_dict() -> Dictionary:
	var d: Dictionary = super()
	d["name"] = name
	d["population"] = population
	d["priorities"] = priorities
	d["policies"] = policies
	d["production_targets"] = production_targets
	d["stockpile"] = stockpile.to_dict()
	d["morale"] = morale
	d["research_progress"] = research_progress
	return d

func from_dict(d: Dictionary) -> void:
	super(d)
	name = d.get("name", "New Colony")
	population.assign(d.get("population", []))
	priorities = d.get("priorities", {})
	policies = d.get("policies", {})
	production_targets = d.get("production_targets", {})
	stockpile = Inventory.new()
	stockpile.from_dict(d.get("stockpile", {}))
	morale = d.get("morale", 50.0)
	research_progress = d.get("research_progress", {})
