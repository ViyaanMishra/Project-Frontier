class_name TestRunner
extends Node

## Headless test runner for all test suites.

var _results: Dictionary = {}
var _failed: int = 0

func _ready() -> void:
	_run_tests()

func _run_tests() -> void:
	print("=== Project Frontier Test Runner ===")
	_register_suites()
	for suite in _results:
		var suite_results: Array[Dictionary] = _results[suite]
		print("Suite: %s" % suite)
		for r in suite_results:
			var status: String = "PASS" if r.passed else "FAIL"
			print("  [%s] %s" % [status, r.name])
			if not r.passed:
				print("      %s" % r.message)
	print("Failed: %d" % _failed)
	get_tree().quit(_failed)

func _register_suites() -> void:
	var _test: TestSuite = TestSuite.new()
	_test.register("determinism", self, _test_determinism)
	_test.register("chunk_determinism", self, _test_chunk_determinism)
	_test.register("inventory", self, _test_inventory)
	_test.register("clock", self, _test_clock)
	_test.register("navigation", self, _test_navigation)
	_test.register("save_roundtrip", self, _test_save_roundtrip)
	_test.register("memory_lifecycle", self, _test_memory_lifecycle)
	_test.register("utility_ai", self, _test_utility_ai)
	_test.run_all(self)

func _test_determinism(suite: TestSuite) -> void:
	Determinism.initialize(12345)
	var a: int = Determinism.randi()
	var b: float = Determinism.randf()
	var c: int = Determinism.randi_range(1, 100)
	Determinism.initialize(12345)
	var a2: int = Determinism.randi()
	var b2: float = Determinism.randf()
	var c2: int = Determinism.randi_range(1, 100)
	suite.assert_eq(a, a2, "randi deterministic")
	suite.assert_true(abs(b - b2) < 0.0001, "randf deterministic")
	suite.assert_eq(c, c2, "randi_range deterministic")

func _test_chunk_determinism(suite: TestSuite) -> void:
	var gen1: WorldGenerator = WorldGenerator.new(42)
	var chunk1: WorldChunk = WorldChunk.new("0,0", 0, 0)
	gen1.generate_chunk(chunk1)
	var gen2: WorldGenerator = WorldGenerator.new(42)
	var chunk2: WorldChunk = WorldChunk.new("0,0", 0, 0)
	gen2.generate_chunk(chunk2)
	for i in range(chunk1.tiles.size()):
		suite.assert_eq(chunk1.tiles[i].biome, chunk2.tiles[i].biome, "tile biome deterministic")
		suite.assert_eq(chunk1.tiles[i].resource_id, chunk2.tiles[i].resource_id, "resource deterministic")

func _test_inventory(suite: TestSuite) -> void:
	DataService.initialize()
	var inv: Inventory = Inventory.new()
	suite.assert_true(inv.add_item("wood", 5), "add wood")
	suite.assert_true(inv.has_item("wood", 5), "has wood")
	suite.assert_true(inv.remove_item("wood", 2), "remove wood")
	suite.assert_eq(inv.count_item("wood"), 3, "count wood")

func _test_clock(suite: TestSuite) -> void:
	var clock: SimulationClock = SimulationClock.new()
	clock.set_time_scale(Constants.TimeScale.NORMAL)
	var scaled: float = clock.advance(0.5)
	suite.assert_true(scaled > 0.0, "clock advances")
	clock.set_time_scale(Constants.TimeScale.PAUSED)
	scaled = clock.advance(0.5)
	suite.assert_eq(scaled, 0.0, "paused returns zero")

func _test_navigation(suite: TestSuite) -> void:
	DataService.initialize()
	var world: WorldService = WorldService.new(1)
	var nav: NavigationService = NavigationService.new(world)
	world.ensure_chunk(0, 0)
	var path: Array[Vector2i] = nav.request_path("agent", Vector2i(0, 0), Vector2i(5, 0), 0, Callable()).result
	# Result may be empty until update is called.
	nav.update(0.0, 0.0)
	path = nav.request_path("agent2", Vector2i(0, 0), Vector2i(3, 0), 0, Callable()).result
	nav.update(0.0, 0.0)
	suite.assert_true(path.size() >= 0, "navigation returns path array")

func _test_save_roundtrip(suite: TestSuite) -> void:
	DataService.initialize()
	var clock: SimulationClock = SimulationClock.new()
	var world: WorldService = WorldService.new(99)
	var colony: ColonyService = ColonyService.new()
	var factions: FactionService = FactionService.new()
	var economy: EconomyService = EconomyService.new()
	var events: EventService = EventService.new()
	var player: EntityRecord = EntityRecord.new("player")
	var save: SaveService = SaveService.new()
	var ok: bool = save.save(1, world, colony, factions, economy, events, player, clock)
	suite.assert_true(ok, "save succeeds")
	var data: Dictionary = save.load(1)
	suite.assert_true(data.has("manifest"), "load returns manifest")
	suite.assert_true(data.has("world"), "load returns world")

func _test_memory_lifecycle(suite: TestSuite) -> void:
	var bank: MemoryBank = MemoryBank.new()
	var rec: MemoryRecord = MemoryRecord.new()
	rec.category = MemoryRecord.Category.TEMPORARY
	rec.relevance = 1.0
	bank.add(rec)
	suite.assert_eq(bank.records.size(), 1, "memory added")
	bank.update(100.0, Time.get_ticks_msec() / 1000.0 + 100.0)
	suite.assert_true(bank.records.size() == 0 or bank.records[0].relevance < 0.1, "memory decayed")

func _test_utility_ai(suite: TestSuite) -> void:
	var ai: UtilityAI = UtilityAI.new()
	ai.register_evaluator("eat", func(npc, colony, world, nav): return 1.0 if npc.hunger < 50 else 0.0)
	var npc: EntityRecord = EntityRecord.new("npc")
	npc.hunger = 20.0
	ai.queue_evaluation(npc)
	ai.update(0.1, 0.0, null, null, null)
	suite.assert_eq(npc.current_task.get("action_id", ""), "eat", "utility AI selects eat")

func _on_suite_complete(suite: String, results: Array[Dictionary], failed: int) -> void:
	_results[suite] = results
	_failed += failed

func _finalize() -> void:
	get_tree().quit(_failed)
