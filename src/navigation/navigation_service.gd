class_name NavigationService
extends RefCounted

## Hierarchical navigation with request queueing, budgets, and cache invalidation.

class PathRequest:
	var agent_id: String
	var start: Vector2i
	var goal: Vector2i
	var priority: int
	var retry_at: float
	var retry_count: int
	var result: Array[Vector2i]
	var callback: Callable

	func _init(p_agent: String, p_start: Vector2i, p_goal: Vector2i, p_priority: int, p_callback: Callable):
		agent_id = p_agent
		start = p_start
		goal = p_goal
		priority = p_priority
		callback = p_callback
		retry_count = 0
		retry_at = 0.0

var _world: WorldService
var _requests: Array[PathRequest] = []
var _active: Array[PathRequest] = []
var _cache: Dictionary = {}
var _nav_revisions: Dictionary = {}
var _budget: int = 4
var _cache_budget: int = 16
var _dirty_queue: Dictionary = {}
var _failed_count: int = 0
var _cache_hits: int = 0
var _cache_misses: int = 0
var _total_time: float = 0.0
var _path_count: int = 0

func _init(world: WorldService, budget: int = 4, cache_budget: int = 16) -> void:
	_world = world
	_budget = budget
	_cache_budget = cache_budget

func request_path(agent_id: String, start: Vector2i, goal: Vector2i, priority: int = 0, callback: Callable = Callable()) -> PathRequest:
	var req: PathRequest = PathRequest.new(agent_id, start, goal, priority, callback)
	_requests.append(req)
	_requests.sort_custom(_priority_sort)
	return req

func _priority_sort(a: PathRequest, b: PathRequest) -> bool:
	return a.priority > b.priority

func update(delta: float, current_time: float) -> void:
	_process_dirty_queue(current_time)
	var budget_remaining: int = _budget
	var cache_remaining: int = _cache_budget
	var i: int = 0
	while i < _requests.size() and budget_remaining > 0:
		var req: PathRequest = _requests[i]
		if req.retry_at > current_time:
			i += 1
			continue
		var path: Array[Vector2i] = _compute_path(req.start, req.goal)
		if path.size() > 0:
			req.result = path
			if req.callback.is_valid():
				req.callback.call(path)
			_active.append(req)
			_requests.remove_at(i)
			budget_remaining -= 1
		else:
			_failed_count += 1
			req.retry_count += 1
			var backoff: float = _backoff_seconds(req.retry_count)
			req.retry_at = current_time + backoff
			i += 1
			budget_remaining -= 1

func _process_dirty_queue(current_time: float) -> void:
	var keys: Array = _dirty_queue.keys()
	for chunk_id in keys:
		var bounds: Rect2i = _dirty_queue[chunk_id]
		_invalidate_cache(chunk_id, bounds)
		_nav_revisions[chunk_id] = _nav_revisions.get(chunk_id, 0) + 1
	_dirty_queue.clear()

func _invalidate_cache(chunk_id: String, bounds: Rect2i) -> void:
	var to_remove: Array = []
	for key in _cache:
		if key.begins_with(chunk_id + ":"):
			to_remove.append(key)
	for key in to_remove:
		_cache.erase(key)

func _backoff_seconds(retry: int) -> float:
	if retry <= 1:
		return 1.0
	elif retry == 2:
		return 2.0
	elif retry == 3:
		return 4.0
	elif retry == 4:
		return 8.0
	else:
		return 16.0

func _compute_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var key: String = _cache_key(start, goal)
	if _cache.has(key):
		_cache_hits += 1
		return _cache[key]
	_cache_misses += 1
	var t0: float = Time.get_ticks_usec()
	var path: Array[Vector2i] = _a_star(start, goal)
	var t1: float = Time.get_ticks_usec()
	_total_time += (t1 - t0) / 1000.0
	_path_count += 1
	if path.size() > 0:
		_cache[key] = path
	return path

func _cache_key(start: Vector2i, goal: Vector2i) -> String:
	return str(start.x) + "," + str(start.y) + "->" + str(goal.x) + "," + str(goal.y)

func _a_star(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	if start == goal:
		return [start]
	var open_set: Array[Vector2i] = [start]
	var came_from: Dictionary = {}
	var g_score: Dictionary = {str(start): 0.0}
	var f_score: Dictionary = {str(start): _heuristic(start, goal)}
	var visited: Dictionary = {}
	var iterations: int = 0
	var max_iterations: int = 1024
	while open_set.size() > 0 and iterations < max_iterations:
		iterations += 1
		open_set.sort_custom(_f_score_sort.bind(f_score))
		var current: Vector2i = open_set.pop_front()
		if current == goal:
			return _reconstruct_path(came_from, current)
		visited[str(current)] = true
		for neighbor in _neighbors(current):
			if visited.has(str(neighbor)):
				continue
			var tile: WorldTile = _world.get_tile(neighbor.x, neighbor.y)
			if tile == null or not tile.is_walkable:
				continue
			var move_cost: float = tile.movement_cost
			var tentative_g: float = g_score.get(str(current), INF) + move_cost
			if tentative_g < g_score.get(str(neighbor), INF):
				came_from[str(neighbor)] = current
				g_score[str(neighbor)] = tentative_g
				f_score[str(neighbor)] = tentative_g + _heuristic(neighbor, goal)
				if not open_set.has(neighbor):
					open_set.append(neighbor)
	return []

func _f_score_sort(a: Vector2i, b: Vector2i, f_score: Dictionary) -> bool:
	return f_score.get(str(a), INF) < f_score.get(str(b), INF)

func _heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _neighbors(pos: Vector2i) -> Array[Vector2i]:
	return [Vector2i(pos.x + 1, pos.y), Vector2i(pos.x - 1, pos.y), Vector2i(pos.x, pos.y + 1), Vector2i(pos.x, pos.y - 1)]

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [current]
	while came_from.has(str(current)):
		current = came_from[str(current)]
		path.append(current)
	path.reverse()
	return path

func mark_dirty(chunk_id: String, bounds: Rect2i) -> void:
	if _dirty_queue.has(chunk_id):
		var existing: Rect2i = _dirty_queue[chunk_id]
		_dirty_queue[chunk_id] = existing.merge(bounds)
	else:
		_dirty_queue[chunk_id] = bounds

func get_telemetry() -> Dictionary:
	var avg: float = 0.0 if _path_count == 0 else _total_time / _path_count
	var total_cache: int = _cache_hits + _cache_misses
	var hit_rate: float = 0.0 if total_cache == 0 else float(_cache_hits) / total_cache
	return {
		"active_requests": _active.size(),
		"queued_requests": _requests.size(),
		"average_path_ms": avg,
		"failed_paths": _failed_count,
		"cache_hit_rate": hit_rate,
		"dirty_queue_depth": _dirty_queue.size(),
		"nav_revisions": _nav_revisions
	}

func to_dict() -> Dictionary:
	return {"revisions": _nav_revisions, "requests": _requests.size()}

func from_dict(d: Dictionary) -> void:
	_nav_revisions = d.get("revisions", {})
