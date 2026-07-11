class_name MemoryBank
extends RefCounted

## Manages memory records for an NPC.

var records: Array[MemoryRecord] = []

func add(record: MemoryRecord) -> void:
	# Merge related records where possible.
	for r in records:
		if r.category == record.category and r.target_id == record.target_id:
			if _is_related(r, record):
				r.strength += record.strength * 0.5
				r.relevance = maxf(r.relevance, record.relevance)
				r.valence = (r.valence + record.valence) * 0.5
				r.decay_policy = minf(r.decay_policy, record.decay_policy)
				return
	records.append(record)
	_prune()

func _is_related(a: MemoryRecord, b: MemoryRecord) -> bool:
	var a_tags: Array[String] = a.tags
	var b_tags: Array[String] = b.tags
	for tag in a_tags:
		if b_tags.has(tag):
			return true
	return false

func update(dt: float, current_time: float) -> void:
	for r in records:
		r.update(dt, current_time)
	_prune()

func _prune() -> void:
	records.sort_custom(_by_relevance)
	while records.size() > Constants.MAX_MEMORY_RECORDS:
		records.pop_back()

func _by_relevance(a: MemoryRecord, b: MemoryRecord) -> bool:
	# Critical first, then relevance descending.
	if a.category == MemoryRecord.Category.CRITICAL and b.category != MemoryRecord.Category.CRITICAL:
		return true
	if a.category != MemoryRecord.Category.CRITICAL and b.category == MemoryRecord.Category.CRITICAL:
		return false
	return a.relevance > b.relevance

func get_relevant_memories(category: MemoryRecord.Category = MemoryRecord.Category.TEMPORARY) -> Array[MemoryRecord]:
	var out: Array[MemoryRecord] = []
	for r in records:
		if r.category == category and r.relevance > 0.1:
			out.append(r)
	return out

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for r in records:
		arr.append(r.to_dict())
	return {"records": arr}

func from_dict(d: Dictionary) -> void:
	records.clear()
	for rd in d.get("records", []):
		var r: MemoryRecord = MemoryRecord.new()
		r.from_dict(rd)
		records.append(r)
