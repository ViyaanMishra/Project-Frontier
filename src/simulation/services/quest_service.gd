class_name QuestService
extends RefCounted

## Tracks story, dynamic, NPC, and world quests.

class Quest:
	var id: String
	var title: String
	var stage: int = 0
	var completed: bool = false
	var objectives: Array[Dictionary] = []

var quests: Array[Quest] = []

func add_quest(id: String, title: String, objectives: Array[Dictionary]) -> void:
	var q: Quest = Quest.new()
	q.id = id
	q.title = title
	q.objectives = objectives
	quests.append(q)

func advance(id: String, stage: int) -> void:
	for q in quests:
		if q.id == id:
			q.stage = stage
			GameSession.events.publish("quest_updated", [id, stage])
			if stage >= q.objectives.size():
				q.completed = true
			return

func to_dict() -> Dictionary:
	var arr: Array[Dictionary] = []
	for q in quests:
		arr.append({
			"id": q.id,
			"title": q.title,
			"stage": q.stage,
			"completed": q.completed,
			"objectives": q.objectives
		})
	return {"quests": arr}

func from_dict(d: Dictionary) -> void:
	quests.clear()
	for qd in d.get("quests", []):
		var q: Quest = Quest.new()
		q.id = qd.get("id", "")
		q.title = qd.get("title", "")
		q.stage = qd.get("stage", 0)
		q.completed = qd.get("completed", false)
		q.objectives = qd.get("objectives", [])
		quests.append(q)
