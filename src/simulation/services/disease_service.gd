class_name DiseaseService
extends RefCounted

## Tracks diseases and their effects on colonists and colony.

class Disease:
	var id: String
	var name: String
	var contagion: float
	var severity: float
	var affected: Array[String] = []

var active_diseases: Array[Disease] = []

func outbreak(disease_id: String, name: String, contagion: float, severity: float, population: Array[String]) -> void:
	var disease: Disease = Disease.new()
	disease.id = disease_id
	disease.name = name
	disease.contagion = contagion
	disease.severity = severity
	for p in population:
		if Determinism.randf() < contagion:
			disease.affected.append(p)
	active_diseases.append(disease)

func update(delta: float, colony: ColonyService, world: WorldService) -> void:
	for disease in active_diseases:
		# Reduce work efficiency and morale.
		colony.morale -= disease.severity * disease.affected.size() * 0.01 * delta
		colony.morale = clampf(colony.morale, 0.0, 100.0)
		disease.contagion = maxf(0.0, disease.contagion - 0.001 * delta)
		if disease.affected.size() == 0:
			active_diseases.erase(disease)

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for d in active_diseases:
		arr.append({
			"id": d.id,
			"name": d.name,
			"contagion": d.contagion,
			"severity": d.severity,
			"affected": d.affected
		})
	return {"diseases": arr}

func from_dict(data: Dictionary) -> void:
	active_diseases.clear()
	for dd in data.get("diseases", []):
		var d: Disease = Disease.new()
		d.id = dd.get("id", "")
		d.name = dd.get("name", "")
		d.contagion = dd.get("contagion", 0.0)
		d.severity = dd.get("severity", 0.0)
		d.affected.assign(dd.get("affected", []))
		active_diseases.append(d)
