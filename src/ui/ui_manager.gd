class_name UIManager
extends CanvasLayer

## Manages main menu, HUD, inventory, crafting, build, and debug overlays.

enum Screen { HUD, INVENTORY, CRAFTING, BUILDING, MENU, DEBUG, MAP }

var current_screen: Screen = Screen.HUD
var _screens: Dictionary = {}

func _ready() -> void:
	layer = 10
	_create_hud()
	_create_inventory()
	_create_crafting()
	_create_build()
	_create_menu()
	_create_debug()
	show_screen(Screen.HUD)

func _create_hud() -> void:
	var panel: Panel = Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE, 10)
	panel.custom_minimum_size = Vector2(200, 120)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.hud_frame
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "HudLabel"
	label.position = Vector2(10, 10)
	panel.add_child(label)
	_screens[Screen.HUD] = panel
	add_child(panel)

func _create_inventory() -> void:
	var panel: Panel = Panel.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel.custom_minimum_size = Vector2(400, 300)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.ui_panel
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "InventoryLabel"
	label.position = Vector2(10, 10)
	panel.add_child(label)
	_screens[Screen.INVENTORY] = panel
	add_child(panel)

func _create_crafting() -> void:
	var panel: Panel = Panel.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel.custom_minimum_size = Vector2(400, 300)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.ui_panel
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "CraftingLabel"
	label.position = Vector2(10, 10)
	panel.add_child(label)
	_screens[Screen.CRAFTING] = panel
	add_child(panel)

func _create_build() -> void:
	var panel: Panel = Panel.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel.custom_minimum_size = Vector2(400, 300)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.ui_panel
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "BuildLabel"
	label.position = Vector2(10, 10)
	panel.add_child(label)
	_screens[Screen.BUILDING] = panel
	add_child(panel)

func _create_menu() -> void:
	var panel: Panel = Panel.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel.custom_minimum_size = Vector2(300, 200)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.menu_panel
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "MenuLabel"
	label.position = Vector2(10, 10)
	label.text = "Main Menu\n1. Resume\n2. Save\n3. Load\n4. Quit"
	panel.add_child(label)
	_screens[Screen.MENU] = panel
	add_child(panel)

func _create_debug() -> void:
	var panel: Panel = Panel.new()
	panel.visible = false
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE)
	panel.custom_minimum_size = Vector2(300, 150)
	var bg: TextureRect = TextureRect.new()
	bg.texture = AssetLibrary.ui_panel
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.add_child(bg)
	var label: Label = Label.new()
	label.name = "DebugLabel"
	label.position = Vector2(10, 10)
	panel.add_child(label)
	_screens[Screen.DEBUG] = panel
	add_child(panel)

func _process(delta: float) -> void:
	if current_screen == Screen.HUD:
		_update_hud()
	elif current_screen == Screen.INVENTORY:
		_update_inventory()
	elif current_screen == Screen.CRAFTING:
		_update_crafting()
	elif current_screen == Screen.BUILDING:
		_update_build()
	elif current_screen == Screen.DEBUG:
		_update_debug()

func _update_hud() -> void:
	var label: Label = _screens[Screen.HUD].get_node("HudLabel")
	var telemetry: Dictionary = GameSession.get_telemetry()
	label.text = "Time: %.1f\nHealth: %.1f\nHunger: %.1f\nMorale: %.1f" % [telemetry.simulation_time, telemetry.player_health, telemetry.player_hunger, telemetry.colony_morale]

func _update_inventory() -> void:
	var label: Label = _screens[Screen.INVENTORY].get_node("InventoryLabel")
	var lines: Array[String] = ["Inventory:"]
	for slot in GameSession.player.inventory.slots:
		lines.append("%s x%d (%.2f)" % [slot.item_id, slot.quantity, slot.quality])
	label.text = "\n".join(lines)

func _update_crafting() -> void:
	var label: Label = _screens[Screen.CRAFTING].get_node("CraftingLabel")
	var recipes: Array = DataService.get_all_recipes().keys()
	var lines: Array[String] = ["Recipes: " + str(recipes)]
	lines.append("Queue: " + str(GameSession.crafting.get_queue().size()))
	label.text = "\n".join(lines)

func _update_build() -> void:
	var label: Label = _screens[Screen.BUILDING].get_node("BuildLabel")
	var buildings: Array = DataService.get_all_buildings().keys()
	label.text = "Buildings: " + str(buildings)

func _update_debug() -> void:
	var label: Label = _screens[Screen.DEBUG].get_node("DebugLabel")
	var nav: Dictionary = GameSession.navigation.get_telemetry()
	label.text = "Nav: active=%d queued=%d failed=%d" % [nav.active_requests, nav.queued_requests, nav.failed_paths]

func show_screen(screen: Screen) -> void:
	for s in _screens:
		_screens[s].visible = (s == screen)
	current_screen = screen

func toggle_inventory() -> void:
	if current_screen == Screen.INVENTORY:
		show_screen(Screen.HUD)
	else:
		show_screen(Screen.INVENTORY)

func toggle_crafting() -> void:
	if current_screen == Screen.CRAFTING:
		show_screen(Screen.HUD)
	else:
		show_screen(Screen.CRAFTING)

func toggle_build() -> void:
	if current_screen == Screen.BUILDING:
		show_screen(Screen.HUD)
	else:
		show_screen(Screen.BUILDING)

func toggle_menu() -> void:
	if current_screen == Screen.MENU:
		show_screen(Screen.HUD)
	else:
		show_screen(Screen.MENU)

func toggle_debug() -> void:
	if current_screen == Screen.DEBUG:
		show_screen(Screen.HUD)
	else:
		show_screen(Screen.DEBUG)
