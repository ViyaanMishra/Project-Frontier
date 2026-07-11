extends Node2D

## Main gameplay scene: draws the world, player, and debug UI.

var session: Node = GameSession
@onready var tile_size: int = 1

var _world_texture: ImageTexture
var _image: Image

func _ready() -> void:
	_image = Image.create(Constants.WORLD_SIZE, Constants.WORLD_SIZE, false, Image.FORMAT_RGB8)
	_world_texture = ImageTexture.create_from_image(_image)
	_update_world_image()

func _process(delta: float) -> void:
	_handle_input(delta)
	_update_world_image()
	queue_redraw()

func _handle_input(delta: float) -> void:
	var move: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("ui_left"):
		move.x -= 1
	if Input.is_action_pressed("ui_right"):
		move.x += 1
	if Input.is_action_pressed("ui_up"):
		move.y -= 1
	if Input.is_action_pressed("ui_down"):
		move.y += 1
	if move != Vector2i.ZERO:
		var target: Vector2i = session.player.position + move
		if _is_valid_tile(target):
			session.player.position = target
			session.player.chunk_id = session.world.get_chunk_at_world(target.x, target.y).id
	if Input.is_action_just_pressed("ui_accept"):
		_interact()
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()

func _is_valid_tile(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0 or pos.x >= Constants.WORLD_SIZE or pos.y >= Constants.WORLD_SIZE:
		return false
	var tile: WorldTile = session.world.get_tile(pos.x, pos.y)
	return tile != null and tile.is_walkable

func _interact() -> void:
	var tile: WorldTile = session.world.get_tile(session.player.position.x, session.player.position.y)
	if tile.resource_quantity > 0:
		var qty: int = mini(1, tile.resource_quantity)
		session.player.inventory.add_item(tile.resource_id, qty)
		tile.resource_quantity -= qty
		if tile.resource_quantity <= 0:
			tile.resource_id = ""
		session.world.set_tile(session.player.position.x, session.player.position.y, tile)

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
	# Draw player.
	var ppos: Vector2 = Vector2(session.player.position) * tile_size
	draw_circle(ppos, tile_size * 0.5, Color.BLUE)
	# Draw debug text.
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
