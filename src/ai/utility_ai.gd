class_name UtilityAI
extends RefCounted

## Utility-based action selection for NPCs.

class UtilityCandidate:
	var action_id: String
	var score: float
	var context: Dictionary

var _evaluators: Dictionary = {}
var _queue: Array[EntityRecord] = []
var _budget: int = Constants.UTILITY_BUDGET_PER_TICK
var _forced_queue: Array[EntityRecord] = []

var _evaluations_per_tick: int = 0
var _forced_count: int = 0
var _average_duration: float = 0.0

func _init(budget: int = Constants.UTILITY_BUDGET_PER_TICK) -> void:
	_budget = budget

func register_evaluator(action_id: String, evaluator: Callable) -> void:
	_evaluators[action_id] = evaluator

func queue_evaluation(npc: EntityRecord, force: bool = false) -> void:
	if force:
		_forced_queue.append(npc)
		_forced_count += 1
	else:
		if not _queue.has(npc):
			_queue.append(npc)

func update(delta: float, current_time: float, colony: ColonyService, world: WorldService, nav: NavigationService) -> void:
	_evaluations_per_tick = 0
	var processed: int = 0
	# Process forced reevaluations first.
	while _forced_queue.size() > 0 and processed < _budget:
		var npc: EntityRecord = _forced_queue.pop_front()
		_evaluate(npc, delta, current_time, colony, world, nav)
		processed += 1
		_evaluations_per_tick += 1
	# Process normal queue round-robin.
	while _queue.size() > 0 and processed < _budget:
		var npc: EntityRecord = _queue.pop_front()
		_evaluate(npc, delta, current_time, colony, world, nav)
		processed += 1
		_evaluations_per_tick += 1

func _evaluate(npc: EntityRecord, delta: float, current_time: float, colony: ColonyService, world: WorldService, nav: NavigationService) -> void:
	var t0: float = Time.get_ticks_usec()
	var best: UtilityCandidate = null
	var best_score: float = -INF
	for action_id in _evaluators:
		var score: float = _evaluators[action_id].call(npc, colony, world, nav)
		if score > best_score:
			best_score = score
			best = UtilityCandidate.new()
			best.action_id = action_id
			best.score = score
			best.context = {"time": current_time, "delta": delta}
	if best != null:
		npc.current_task = {
			"action_id": best.action_id,
			"score": best.score,
			"context": best.context
		}
	var t1: float = Time.get_ticks_usec()
	var duration: float = (t1 - t0) / 1000.0
	_average_duration = _average_duration * 0.9 + duration * 0.1

func get_telemetry() -> Dictionary:
	return {
		"evaluations_per_tick": _evaluations_per_tick,
		"queue_size": _queue.size(),
		"average_evaluation_ms": _average_duration,
		"forced_reevaluations": _forced_count,
		"current_candidates": _evaluators.keys()
	}

func to_dict() -> Dictionary:
	return {"budget": _budget}

func from_dict(d: Dictionary) -> void:
	_budget = d.get("budget", Constants.UTILITY_BUDGET_PER_TICK)
