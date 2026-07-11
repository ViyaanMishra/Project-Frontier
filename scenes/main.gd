extends Node2D

## Main gameplay scene: draws the world, player, and debug UI.

var session: Node = GameSession
var controller: PlayerController = PlayerController.new()
var ui: UIManager
@onready var tile_size: int = 1
@onready var camera: Camera2D = $Camera2D

var _world_texture: ImageTexture
var _image: Image

func _ready() -> void:
	ui = UIManager.new()
	add_child(ui)
	camera.zoom = Vector2(0.4, 0.4)
	camera.position = session.player.position
	_image = Image.create(Constants.WORLD_SIZE, Constants.WORLD_SIZE, false, Image.FORMAT_RGB8)
	_world_texture = ImageTexture.create_from_image(_image)
	_update_world_image()

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_world_image()
	camera.position = session.player.position
	queue_redraw()

func _handle_input(delta: float) -> void:
	var player: EntityRecord = session.player
	var world: WorldService = session.world
	var direction: Vector2i = controller.handle_input(player, world, delta)
	if direction != Vector2i.ZERO:
		var speed: float = 1.0 if not Input.is_action_pressed("sprint") else 2.0
		controller.move_player(player, world, direction, speed)
	if Input.is_action_just_pressed("interact"):
		controller.interact(player, world)
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()
	if Input.is_action_just_pressed("inventory"):
		ui.toggle_inventory()
	if Input.is_action_just_pressed("crafting"):
		ui.toggle_crafting()
	if Input.is_action_just_pressed("building"):
		ui.toggle_build()
	if Input.is_action_just_pressed("debug"):
		ui.toggle_debug()

func _toggle_pause() -> void:
	if session.clock.paused:
		session.set_time_scale(Constants.TimeScale.NORMAL)
	else:
		session.set_time_scale(Constants.TimeScale.PAUSED)

func _update_world_image() -> void:
	var active: Array[String] = session.world.get_active_chunk_ids()
	for id in active:
		var chunk: WorldChunk = session.world.chunks[id]
		for y in range(Constants.CHUNK_SIZE):
			for x in range(Constants.CHUNK_SIZE):
				var wx: int = chunk.cx * Constants.CHUNK_SIZE + x
				var wy: int = chunk.cy * Constants.CHUNK_SIZE + y
				var tile: WorldTile = chunk.get_tile(x, y)
				if wx >= 0 and wy >= 0 and wx < Constants.WORLD_SIZE and wy < Constants.WORLD_SIZE:
					_image.set_pixel(wx, wy, _tile_color(tile))
	_world_texture.update(_image)

func _tile_color(tile: WorldTile) -> Color:
	var biomes: Dictionary = Biome.get_biomes()
	var biome: Biome = biomes[tile.biome]
	var c: Color = biome.color
	if tile.resource_quantity > 0:
		c = c.lightened(0.2)
	if not tile.is_walkable:
		c = Color.BLACK
	return c

func _draw() -> void:
	draw_texture(_world_texture, Vector2.ZERO)
	var ppos: Vector2 = Vector2(session.player.position) * tile_size
	draw_circle(ppos, 4.0, Color.BLUE)
	var telemetry: Dictionary = session.get_telemetry()
	var lines: Array[String] = [
		"Time: %.1f Day %d" % [telemetry.simulation_time, telemetry.day],
		"Pos: %s" % str(telemetry.player_position),
		"Health: %.1f Hunger: %.1f" % [telemetry.player_health, telemetry.player_hunger],
		"Morale: %.1f Pop: %d" % [telemetry.colony_morale, telemetry.colony_population],
		"Paused: %s" % session.clock.paused,
	]
	var font: SystemFont = SystemFont.new()
	for i in range(lines.size()):
		draw_string(font, Vector2(10, 20 + i * 14), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
