@tool
class_name AssetLibrary
extends RefCounted

## Preloads all game textures so code and UI can reference them without placeholders.

static var player: Texture2D = preload("res://src/assets/textures/characters/player.png")
static var npc_settler: Texture2D = preload("res://src/assets/textures/characters/npc_settler.png")
static var npc_settler2: Texture2D = preload("res://src/assets/textures/characters/npc_settler2.png")
static var npc_guard: Texture2D = preload("res://src/assets/textures/characters/npc_guard.png")
static var enemy_raider: Texture2D = preload("res://src/assets/textures/characters/enemy_raider.png")
static var enemy_warband: Texture2D = preload("res://src/assets/textures/characters/enemy_warband.png")
static var enemy_anomaly: Texture2D = preload("res://src/assets/textures/characters/enemy_anomaly.png")
static var enemy_drone: Texture2D = preload("res://src/assets/textures/characters/enemy_drone.png")
static var boss_warlord: Texture2D = preload("res://src/assets/textures/characters/boss_warlord.png")

static var wood: Texture2D = preload("res://src/assets/textures/items/wood.png")
static var stone: Texture2D = preload("res://src/assets/textures/items/stone.png")
static var metal_scrap: Texture2D = preload("res://src/assets/textures/items/metal_scrap.png")
static var food_ration: Texture2D = preload("res://src/assets/textures/items/food_ration.png")
static var knife: Texture2D = preload("res://src/assets/textures/items/knife.png")

static var campfire: Texture2D = preload("res://src/assets/textures/buildings/campfire.png")
static var workshop: Texture2D = preload("res://src/assets/textures/buildings/workshop.png")
static var house: Texture2D = preload("res://src/assets/textures/buildings/house.png")
static var storage: Texture2D = preload("res://src/assets/textures/buildings/storage.png")
static var farm: Texture2D = preload("res://src/assets/textures/buildings/farm.png")

static var biome_safe_start: Texture2D = preload("res://src/assets/textures/world/biome_safe_start.png")
static var biome_wasteland: Texture2D = preload("res://src/assets/textures/world/biome_wasteland.png")
static var biome_forest: Texture2D = preload("res://src/assets/textures/world/biome_forest.png")
static var biome_desert: Texture2D = preload("res://src/assets/textures/world/biome_desert.png")
static var biome_mountain: Texture2D = preload("res://src/assets/textures/world/biome_mountain.png")
static var biome_anomaly: Texture2D = preload("res://src/assets/textures/world/biome_anomaly.png")

static var tree: Texture2D = preload("res://src/assets/textures/objects/tree.png")
static var rock: Texture2D = preload("res://src/assets/textures/objects/rock.png")
static var scrap_pile: Texture2D = preload("res://src/assets/textures/objects/scrap_pile.png")
static var ruins: Texture2D = preload("res://src/assets/textures/objects/ruins.png")
static var anomaly_crystal: Texture2D = preload("res://src/assets/textures/objects/anomaly_crystal.png")

static var ui_panel: Texture2D = preload("res://src/assets/textures/ui/ui_panel.png")
static var menu_panel: Texture2D = preload("res://src/assets/textures/ui/menu_panel.png")
static var hud_frame: Texture2D = preload("res://src/assets/textures/ui/hud_frame.png")
static var ui_button: Texture2D = preload("res://src/assets/textures/ui/ui_button.png")
static var title_background: Texture2D = preload("res://src/assets/textures/ui/title_background.png")
static var game_icon: Texture2D = preload("res://src/assets/textures/ui/game_icon.png")
static var continuum_array: Texture2D = preload("res://src/assets/textures/ui/continuum_array.png")

static var icon_inventory: Texture2D = preload("res://src/assets/textures/ui/icon_inventory.png")
static var icon_crafting: Texture2D = preload("res://src/assets/textures/ui/icon_crafting.png")
static var icon_building: Texture2D = preload("res://src/assets/textures/ui/icon_building.png")
static var icon_research: Texture2D = preload("res://src/assets/textures/ui/icon_research.png")
static var icon_quest: Texture2D = preload("res://src/assets/textures/ui/icon_quest.png")
static var icon_map: Texture2D = preload("res://src/assets/textures/ui/icon_map.png")
static var icon_stats: Texture2D = preload("res://src/assets/textures/ui/icon_stats.png")
static var icon_settings: Texture2D = preload("res://src/assets/textures/ui/icon_settings.png")
static var icon_save: Texture2D = preload("res://src/assets/textures/ui/icon_save.png")
static var icon_load: Texture2D = preload("res://src/assets/textures/ui/icon_load.png")
static var icon_pause: Texture2D = preload("res://src/assets/textures/ui/icon_pause.png")
static var icon_debug: Texture2D = preload("res://src/assets/textures/ui/icon_debug.png")

static func get_item_texture(item_id: String) -> Texture2D:
	if item_id == "wood":
		return wood
	if item_id == "stone":
		return stone
	if item_id == "metal_scrap":
		return metal_scrap
	if item_id == "food_ration":
		return food_ration
	if item_id == "knife":
		return knife
	return wood

static func get_biome_texture(biome_id: int) -> Texture2D:
	if biome_id == Constants.BIOME_SAFE_START:
		return biome_safe_start
	if biome_id == Constants.BIOME_WASTELAND:
		return biome_wasteland
	if biome_id == Constants.BIOME_FOREST:
		return biome_forest
	if biome_id == Constants.BIOME_DESERT:
		return biome_desert
	if biome_id == Constants.BIOME_MOUNTAIN:
		return biome_mountain
	if biome_id == Constants.BIOME_ANOMALY:
		return biome_anomaly
	return biome_wasteland

static func get_building_texture(building_id: String) -> Texture2D:
	if building_id == "campfire":
		return campfire
	if building_id == "workshop":
		return workshop
	if building_id == "house":
		return house
	if building_id == "storage":
		return storage
	if building_id == "farm":
		return farm
	return campfire

static func get_character_texture(type: EntityRecord.Type, faction: String = "", id: String = "") -> Texture2D:
	if type == EntityRecord.Type.PLAYER:
		return player
	if type == EntityRecord.Type.NPC:
		if id.ends_with("0") or id.ends_with("2"):
			return npc_settler
		return npc_settler2
	if faction == "raider":
		return enemy_raider
	if faction == "warband":
		return enemy_warband
	if faction == "anomaly":
		return enemy_anomaly
	return enemy_raider
