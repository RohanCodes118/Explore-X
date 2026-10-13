extends Node

# Global GameState for Echoes of Eternity: Chapter Progression, Inventory & Missions

signal component_collected(component_id: String)
signal sword_acquired()
signal ship_restored()
signal region_status_changed(region_id: String, new_status: String)

# Story progression flags
var intro_recovery_done: bool = false
var grandfather_met: bool = false
var grandfather_revealed: bool = false
var sword_given: bool = false
var has_sword: bool = false
var map_unlocked: bool = false
var ship_repaired: bool = false

# Current location
var current_region: String = "crash_site"
var player_spawn_override: Vector2 = Vector2.ZERO

# Collectible ship components
var collected_components: Dictionary = {
	"plasma_regulator": false,
	"navigation_core": false,
	"quantum_power_cell": false
}

# Region status tracking: "NOT VISITED", "IN PROGRESS", "COMPLETE"
var region_status: Dictionary = {
	"ember_wastes": "NOT VISITED",
	"verdant_ruins": "NOT VISITED",
	"frostfall_expanse": "NOT VISITED"
}

# Metadata for regions and components
const REGION_DATA := {
	"ember_wastes": {
		"name": "Ember Wastes",
		"component_id": "plasma_regulator",
		"component_name": "Plasma Regulator",
		"subtitle": "SCORCHED CANYONS // GEOTHERMAL ACTIVITY // ANCIENT INDUSTRIAL RUINS",
		"description": "A hostile desert of fire and stone, where the planet's core still breathes. Abandoned facilities and ancient machinery lie buried beneath layers of volcanic sand.",
		"quote": "The Ember Wastes hide valuable technology... if you can survive the heat.",
		"terrain": "Desert / Canyon • Volcanic Activity • Industrial Ruins",
		"landmark": "Reactor Platform",
		"scene_path": "res://scenes/regions/ember_wastes.tscn",
		"icon_path": "res://assets/images/map_ember_icon.png",
		"thumb_path": "res://assets/images/map_ember_thumb.png",
		"map_art_path": "res://assets/images/map_ember_wastes.png",
		"theme_color": Color(0.95, 0.45, 0.15, 1.0)
	},
	"verdant_ruins": {
		"name": "Verdant Ruins",
		"component_id": "navigation_core",
		"component_name": "Navigation Core",
		"subtitle": "ANCIENT TEMPLES // LUSH VEGETATION // ALIEN TECHNOLOGY",
		"description": "An overgrown sanctuary of a forgotten civilization. Nature has reclaimed these ruins, but the ancient technology still pulses with energy beneath the foliage.",
		"quote": "The past is not gone... it just waits beneath the leaves.",
		"terrain": "Forest / Ruins • Ancient Structures • Bioluminescent Flora",
		"landmark": "Navigation Shrine",
		"scene_path": "res://scenes/regions/verdant_ruins.tscn",
		"icon_path": "res://assets/images/map_verdant_icon.png",
		"thumb_path": "res://assets/images/map_verdant_thumb.png",
		"map_art_path": "res://assets/images/map_verdant_ruins.png",
		"theme_color": Color(0.2, 0.9, 0.5, 1.0)
	},
	"frostfall_expanse": {
		"name": "Frostfall Expanse",
		"component_id": "quantum_power_cell",
		"component_name": "Quantum Power Cell",
		"subtitle": "GLACIAL PLAINS // ICY CAVERNS // RESEARCH FACILITY",
		"description": "A frozen wasteland of ice and endless storms. The remains of a lost research outpost lie beneath the glacier, waiting to be rediscovered.",
		"quote": "Cold, silent, and full of secrets... the ice remembers everything.",
		"terrain": "Ice / Glacier • Research Facility • Cryo Storms",
		"landmark": "Cryogenic Facility",
		"scene_path": "res://scenes/regions/frostfall_expanse.tscn",
		"icon_path": "res://assets/images/map_frostfall_icon.png",
		"thumb_path": "res://assets/images/map_frostfall_thumb.png",
		"map_art_path": "res://assets/images/map_frostfall_expanse.png",
		"theme_color": Color(0.3, 0.75, 1.0, 1.0)
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func collect_component(comp_id: String) -> bool:
	if not collected_components.has(comp_id):
		return false
	if collected_components[comp_id]:
		return false # Already collected
		
	collected_components[comp_id] = true
	
	# Update region status to complete
	for reg_key in REGION_DATA:
		if REGION_DATA[reg_key]["component_id"] == comp_id:
			region_status[reg_key] = "COMPLETE"
			region_status_changed.emit(reg_key, "COMPLETE")
			
	component_collected.emit(comp_id)
	return true

func has_component(comp_id: String) -> bool:
	return collected_components.get(comp_id, false)

func all_components_collected() -> bool:
	return collected_components["plasma_regulator"] and collected_components["navigation_core"] and collected_components["quantum_power_cell"]

func get_missing_component_names() -> Array[String]:
	var missing: Array[String] = []
	if not collected_components["plasma_regulator"]:
		missing.append("Plasma Regulator (Ember Wastes)")
	if not collected_components["navigation_core"]:
		missing.append("Navigation Core (Verdant Ruins)")
	if not collected_components["quantum_power_cell"]:
		missing.append("Quantum Power Cell (Frostfall Expanse)")
	return missing

func acquire_sword() -> void:
	has_sword = true
	sword_given = true
	sword_acquired.emit()

func unlock_map() -> void:
	map_unlocked = true

func complete_ship_repair() -> void:
	ship_repaired = true
	ship_restored.emit()

func deploy_to_region(region_id: String) -> void:
	if not REGION_DATA.has(region_id):
		return
	current_region = region_id
	if region_status[region_id] == "NOT VISITED":
		region_status[region_id] = "IN PROGRESS"
		region_status_changed.emit(region_id, "IN PROGRESS")
	var scene_path: String = REGION_DATA[region_id]["scene_path"]
	get_tree().change_scene_to_file(scene_path)

func return_to_crash_site() -> void:
	current_region = "crash_site"
	get_tree().change_scene_to_file("res://scenes/gameplay/planet_surface.tscn")
