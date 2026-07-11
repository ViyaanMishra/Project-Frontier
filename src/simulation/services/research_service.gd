class_name ResearchService
extends RefCounted

## Research branches across four technology tiers.

enum Tier { SURVIVAL, INDUSTRIAL, ADVANCED, EXPERIMENTAL }

class ResearchProject:
	var id: String
	var name: String
	var tier: Tier
	var cost: float
	var progress: float = 0.0
	var completed: bool = false
	var unlocks: Array[String] = []

var projects: Dictionary = {}
var completed: Array[String] = []

func _init() -> void:
	_add_project("fire_making", "Fire Making", Tier.SURVIVAL, 100.0, ["campfire"])
	_add_project("basic_crafting", "Basic Crafting", Tier.SURVIVAL, 150.0, ["crude_knife"])
	_add_project("metal_working", "Metal Working", Tier.INDUSTRIAL, 500.0, ["workshop"])
	_add_project("advanced_electronics", "Advanced Electronics", Tier.ADVANCED, 1500.0, ["comm_station"])
	_add_project("pre_collapse_tech", "Pre-Collapse Technology", Tier.EXPERIMENTAL, 5000.0, ["continuum_key"])

func _add_project(id: String, name: String, tier: Tier, cost: float, unlocks: Array[String]) -> void:
	var p: ResearchProject = ResearchProject.new()
	p.id = id
	p.name = name
	p.tier = tier
	p.cost = cost
	p.unlocks = unlocks
	projects[id] = p

func contribute(id: String, amount: float) -> void:
	var p: ResearchProject = projects.get(id, null)
	if p == null or p.completed:
		return
	p.progress += amount
	if p.progress >= p.cost:
		p.progress = p.cost
		p.completed = true
		completed.append(p.id)
		GameSession.events.publish("research_completed", [id])

func get_available() -> Array[ResearchProject]:
	var out: Array[ResearchProject] = []
	for id in projects:
		if not projects[id].completed:
			out.append(projects[id])
	return out

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for id in projects:
		var p: ResearchProject = projects[id]
		arr.append({
			"id": p.id,
			"name": p.name,
			"tier": p.tier,
			"cost": p.cost,
			"progress": p.progress,
			"completed": p.completed,
			"unlocks": p.unlocks
		})
	return {"projects": arr, "completed": completed}

func from_dict(d: Dictionary) -> void:
	projects.clear()
	completed.assign(d.get("completed", []))
	for pd in d.get("projects", []):
		var p: ResearchProject = ResearchProject.new()
		p.id = pd.get("id", "")
		p.name = pd.get("name", "")
		p.tier = pd.get("tier", Tier.SURVIVAL)
		p.cost = pd.get("cost", 0.0)
		p.progress = pd.get("progress", 0.0)
		p.completed = pd.get("completed", false)
		p.unlocks = pd.get("unlocks", [])
		projects[p.id] = p
