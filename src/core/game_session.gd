extends Node

## Composition root. Owns all services and drives the simulation loop.

@onready var events: EventBus = EventBus.new()

var world: WorldService
var navigation: NavigationService
var colony: ColonyService
var factions: FactionService
var economy: EconomyService
var event_service: EventService
var save_service: SaveService
var clock: SimulationClock

var player: EntityRecord
var is_running: bool = false
var _last_time: float = 0.0

func _ready() -> void:
	DataService.initialize()
	_start_new_run(0)

func _start_new_run(seed_value: int) -> void:
	Determinism.initialize(seed_value)
	clock = SimulationClock.new()
	world = WorldService.new(seed_value)
	navigation = NavigationService.new(world)
	colony = ColonyService.new()
	factions = FactionService.new()
	economy = EconomyService.new()
	event_service = EventService.new()
	save_service = SaveService.new()

	player = EntityRecord.new("player_0")
	player.display_name = "Player"
	player.type = EntityRecord.Type.PLAYER
	player.position = Vector2i(16, 16)
	player.chunk_id = "0,0"
	player.inventory.add_item("wood", 20)
	player.inventory.add_item("stone", 10)
	player.inventory.add_item("food_ration", 5)
	colony.add_member(player.id)

	world.ensure_chunk(0, 0)
	world.promote_chunk(0, 0)
	is_running = true
	events.publish("world_generated", [seed_value])

func _process(delta: float) -> void:
	if not is_running:
		return
	var scaled: float = clock.advance(delta)
	if scaled > 0.0:
		_update_simulation(scaled)
	events.publish("tick_processed", [delta, scaled])

func _update_simulation(scaled_delta: float) -> void:
	var current_time: float = clock.get_time()
	# Update world tiers based on player chunk.
	_update_chunk_tiers()
	economy.simulate_step(scaled_delta)
	event_service.update(scaled_delta, world, colony, factions)
	colony.update(scaled_delta)
	navigation.update(scaled_delta, current_time)
	# Update player stats.
	_update_player_stats(scaled_delta)

func _update_chunk_tiers() -> void:
	var pcx: int = floori(float(player.position.x) / Constants.CHUNK_SIZE)
	var pcy: int = floori(float(player.position.y) / Constants.CHUNK_SIZE)
	for y in range(maxi(0, pcy - 2), mini(Constants.CHUNK_COUNT, pcy + 3)):
		for x in range(maxi(0, pcx - 2), mini(Constants.CHUNK_COUNT, pcx + 3)):
			var chunk: WorldChunk = world.ensure_chunk(x, y)
			var dist: int = maxi(abs(x - pcx), abs(y - pcy))
			if dist <= 1:
				world.promote_chunk(x, y)
			elif dist == 2:
				chunk.state = WorldChunk.TierState.DISTANT
			else:
				world.demote_chunk(x, y)

func _update_player_stats(delta: float) -> void:
	player.hunger -= 0.5 * delta
	player.stamina += 1.0 * delta
	player.stamina = clampf(player.stamina, 0.0, 100.0)
	if player.hunger <= 0.0:
		player.health -= 1.0 * delta
	if player.health <= 0.0 and not player.is_dead:
		player.is_dead = true
		events.publish("player_died", [player.id])

func set_time_scale(scale: Constants.TimeScale) -> void:
	clock.set_time_scale(scale)
	events.publish("time_scale_changed", [scale])

func request_step() -> void:
	clock.request_step()

func save(slot: int) -> bool:
	return save_service.save(slot, world, colony, factions, economy, event_service, player, clock)

func load(slot: int) -> bool:
	var data: Dictionary = save_service.load(slot)
	if data.is_empty():
		return false
	var manifest: Dictionary = data.get("manifest", {})
	_start_new_run(manifest.get("seed", 0))
	# Apply loaded state.
	world.from_dict(data.get("world", world.to_dict()))
	colony.from_dict(data.get("colony", {}))
	factions.from_dict(data.get("factions", {}))
	economy.from_dict(data.get("economy", {}))
	event_service.from_dict(data.get("events", {}))
	player.from_dict(data.get("player", {}))
	clock.from_dict(data.get("clock", {}))
	return true

func get_seed() -> int:
	return world._seed

func get_telemetry() -> Dictionary:
	return {
		"simulation_time": clock.get_time(),
		"day": clock.get_day(),
		"player_position": player.position,
		"player_health": player.health,
		"player_hunger": player.hunger,
		"colony_morale": colony.morale,
		"colony_population": colony.population.size(),
		"nav_telemetry": navigation.get_telemetry()
	}
