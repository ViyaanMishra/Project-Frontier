class_name EventBus
extends RefCounted

## Typed event bus for cross-domain communication without direct coupling.

signal world_generated(seed: int)
signal time_scale_changed(scale: int)
signal tick_processed(delta: float, scaled_delta: float)
signal navigation_changed(event: NavigationChangeEvent)
signal chunk_tier_changed(chunk_id: String, old_tier: int, new_tier: int)
signal entity_spawned(entity_id: String, entity: EntityRecord)
signal entity_died(entity_id: String, reason: String)
signal player_died(entity_id: String)
signal colony_failure(colony_id: String)
signal raid_started(raid_event: Dictionary)
signal research_completed(research_id: String)
signal quest_updated(quest_id: String, stage: int)
signal save_completed(slot: int, success: bool)
signal load_completed(slot: int, success: bool)

var _queues: Dictionary = {}

func subscribe(event_name: String, callback: Callable) -> void:
	if not _queues.has(event_name):
		_queues[event_name] = []
	_queues[event_name].append(callback)

func unsubscribe(event_name: String, callback: Callable) -> void:
	if not _queues.has(event_name):
		return
	var arr: Array = _queues[event_name]
	if arr.has(callback):
		arr.erase(callback)

func publish(event_name: String, args: Array = []) -> void:
	if not _queues.has(event_name):
		return
	for cb in _queues[event_name]:
		if cb.is_valid():
			cb.callv(args)
