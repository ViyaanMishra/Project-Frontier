class_name PlayerController
extends RefCounted

## Handles player movement, sprint, and interaction.

var sprint_cost: float = 10.0
var base_speed: float = 1.0

func handle_input(player: EntityRecord, world: WorldService, delta: float) -> Vector2i:
	var move: Vector2i = Vector2i.ZERO
	if Input.is_action_pressed("move_left"):
		move.x -= 1
	if Input.is_action_pressed("move_right"):
		move.x += 1
	if Input.is_action_pressed("move_up"):
		move.y -= 1
	if Input.is_action_pressed("move_down"):
		move.y += 1
	if move == Vector2i.ZERO:
		return Vector2i.ZERO
	var sprint: bool = Input.is_action_pressed("sprint")
	var speed: float = base_speed * (2.0 if sprint else 1.0)
	if sprint and player.stamina > sprint_cost * delta:
		player.stamina -= sprint_cost * delta
	else:
		speed = base_speed
	# For grid movement, move one tile per step.
	return move

func move_player(player: EntityRecord, world: WorldService, direction: Vector2i, speed: float) -> bool:
	var target: Vector2i = player.position + direction
	if target.x < 0 or target.y < 0 or target.x >= Constants.WORLD_SIZE or target.y >= Constants.WORLD_SIZE:
		return false
	var tile: WorldTile = world.get_tile(target.x, target.y)
	if tile == null or not tile.is_walkable:
		return false
	player.position = target
	player.chunk_id = world.get_chunk_at_world(target.x, target.y).id
	return true

func interact(player: EntityRecord, world: WorldService) -> void:
	var tile: WorldTile = world.get_tile(player.position.x, player.position.y)
	if tile.resource_quantity > 0:
		var qty: int = mini(1, tile.resource_quantity)
		player.inventory.add_item(tile.resource_id, qty)
		tile.resource_quantity -= qty
		if tile.resource_quantity <= 0:
			tile.resource_id = ""
		world.set_tile(player.position.x, player.position.y, tile)
	elif tile.building_id != "":
		# Open building/production UI.
		pass
