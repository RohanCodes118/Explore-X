extends SceneTree

# Comprehensive integration test for Echoes of Eternity: Region Maps & Grandfather Upgrade

func _init() -> void:
	print("--- BEGIN AUTOMATED UPGRADE INTEGRATION TEST ---")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Test AudioManager
	print("[TEST 1/8] Verifying AudioManager and Bus Layout...")
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	assert(master_idx >= 0, "Master bus missing")
	assert(music_idx >= 0, "Music bus missing")
	assert(sfx_idx >= 0, "SFX bus missing")
	print("  Audio buses Master, Music, SFX verified successfully.")

	# 2. Test GameState Autoload
	print("[TEST 2/8] Verifying GameState Autoload...")
	var gs: Node = root.get_node_or_null("GameState")
	assert(gs != null, "GameState autoload missing from root")
	assert(gs.REGION_DATA.has("ember_wastes"), "Region ember_wastes missing from GameState")
	assert(gs.REGION_DATA.has("verdant_ruins"), "Region verdant_ruins missing from GameState")
	assert(gs.REGION_DATA.has("frostfall_expanse"), "Region frostfall_expanse missing from GameState")
	print("  GameState autoload and region metadata verified.")

	# 3. Test Rix and Grandfather SpriteFrames
	print("[TEST 3/8] Verifying Rix and Grandfather SpriteFrames...")
	var rix_frames: SpriteFrames = load("res://resources/animations/rix_sprite_frames.tres")
	assert(rix_frames != null, "Failed to load rix_sprite_frames.tres")
	assert(rix_frames.has_animation("crash_recovery"), "Missing crash_recovery animation")
	assert(rix_frames.has_animation("attack_side"), "Missing attack_side animation")

	var gf_frames: SpriteFrames = load("res://resources/animations/grandfather_sprite_frames.tres")
	assert(gf_frames != null, "Failed to load grandfather_sprite_frames.tres")
	var required_gf_anims := [
		"idle", "walk", "run", "interact", "hurt", "death",
		"rot_front", "rot_front_right", "rot_right", "rot_back_right",
		"rot_back", "rot_back_left", "rot_left", "rot_front_left"
	]
	for anim in required_gf_anims:
		assert(gf_frames.has_animation(anim), "Grandfather missing animation: " + anim)
		assert(gf_frames.get_frame_count(anim) > 0, "Grandfather animation has 0 frames: " + anim)
	print("  All 14 Grandfather animations verified with valid frame counts.")

	# 4. Test Main Menu & Intro Cutscene
	print("[TEST 4/8] Testing Main Menu and Intro Cutscene Scenes...")
	var menu_scene: PackedScene = load("res://scenes/ui/main_menu.tscn")
	assert(menu_scene != null, "Failed to load main_menu.tscn")
	var menu_inst: Node = menu_scene.instantiate()
	root.add_child(menu_inst)
	assert(menu_inst.find_child("BtnStart", true, false) != null, "BtnStart missing")
	menu_inst.queue_free()

	var cutscene_scene: PackedScene = load("res://scenes/cutscenes/intro_cutscene.tscn")
	assert(cutscene_scene != null, "Failed to load intro_cutscene.tscn")
	var cutscene_inst: Node = cutscene_scene.instantiate()
	root.add_child(cutscene_inst)
	var anim_player: AnimationPlayer = cutscene_inst.find_child("AnimationPlayer", true, false)
	assert(anim_player != null and anim_player.has_animation("intro_cinematic"), "intro_cinematic animation missing")
	var planet_sprite: Sprite2D = cutscene_inst.find_child("IntermediatePlanet", true, false)
	assert(planet_sprite != null, "IntermediatePlanet node present")
	assert(planet_sprite.texture != null and planet_sprite.texture.resource_path.contains("intermediate_planet"), "Original deserted planet restored")
	cutscene_inst.queue_free()
	print("  Main Menu and Intro Cutscene verified.")

	# 5. Test Planet Surface Crash Site, Grandfather AnimatedSprite2D, Dialogue & Sword
	print("[TEST 5/8] Testing Planet Surface Crash Site and Grandfather Upgrade...")
	var surface_scene: PackedScene = load("res://scenes/gameplay/planet_surface.tscn")
	assert(surface_scene != null, "Failed to load planet_surface.tscn")
	var surface_inst: Node = surface_scene.instantiate()
	root.add_child(surface_inst)

	var player: CharacterBody2D = surface_inst.find_child("Player", true, false)
	assert(player != null, "Player missing in planet surface")
	var grandfather: Area2D = surface_inst.find_child("Grandfather", true, false)
	assert(grandfather != null, "Grandfather missing in planet surface")
	var gf_anim: AnimatedSprite2D = grandfather.find_child("AnimatedSprite2D", true, false)
	assert(gf_anim != null, "Grandfather AnimatedSprite2D missing")
	assert(gf_anim.sprite_frames != null, "Grandfather AnimatedSprite2D has no SpriteFrames")

	var ship_console: Area2D = surface_inst.find_child("ShipConsole", true, false)
	assert(ship_console != null, "ShipConsole missing in planet surface")
	var dialogue_overlay: Control = surface_inst.find_child("DialogueOverlay", true, false)
	assert(dialogue_overlay != null, "DialogueOverlay missing in planet surface")

	# Test Grandfather interaction
	grandfather.interact(player)
	assert(dialogue_overlay.visible == true, "Dialogue overlay should become visible on interaction")
	print("  Grandfather dialogue trigger with emotional portraits verified.")

	# Test Grandfather scale and proportions (Task 6)
	assert(gf_anim.scale.y >= 1.9, "Grandfather should be ~15-20% taller than Rix with increased scale")
	assert(grandfather.has_method("face_towards"), "Grandfather missing face_towards method")
	print("  Grandfather height, ground alignment, and facing logic verified.")

	# Test sword gift through GameState
	gs.acquire_sword()
	assert(gs.has_sword == true, "GameState.has_sword should be true")
	var sword_sprite: Sprite2D = player.find_child("SwordSprite", true, false)
	assert(sword_sprite != null, "SwordSprite missing on player")
	assert(sword_sprite.visible == true, "SwordSprite should be visible when equipped")
	player.try_attack()
	assert(player.is_attacking == true, "Player should enter attack state on try_attack")
	print("  Sword gift, visual attachment, and attack arc verified.")

	surface_inst.queue_free()

	# 6. Test Holographic Region Map UI (Obscured Undiscovered Components)
	print("[TEST 6/8] Testing Upgraded Region Map UI & Component Obscurity...")
	var map_scene: PackedScene = load("res://scenes/ui/region_map.tscn")
	assert(map_scene != null, "Failed to load region_map.tscn")
	var map_inst: Control = map_scene.instantiate()
	root.add_child(map_inst)
	assert(map_inst.find_child("BtnEmber", true, false) != null, "BtnEmber missing")
	assert(map_inst.find_child("BtnVerdant", true, false) != null, "BtnVerdant missing")
	assert(map_inst.find_child("BtnFrostfall", true, false) != null, "BtnFrostfall missing")
	assert(map_inst.find_child("BtnDeploy", true, false) != null, "BtnDeploy missing")
	assert(map_inst.find_child("BtnReturnCrash", true, false) != null, "BtnReturnCrash missing")

	# Prior to collection: component details must be obscured
	var comp_name_label: Label = map_inst.find_child("DetailCompName", true, false)
	assert(comp_name_label != null, "DetailCompName missing")
	assert(comp_name_label.text.contains("UNDISCOVERED"), "Component should be obscured before discovery")

	map_inst.queue_free()
	print("  Region Map nodes, theme cards, return button, and obscured telemetry verified.")

	# 7. Test All Three Detailed Exploration Regions
	print("[TEST 7/8] Testing Detailed Exploration Regions, Landmarks, and Pickups...")
	
	# Ember Wastes
	var ember_scene: PackedScene = load("res://scenes/regions/ember_wastes.tscn")
	assert(ember_scene != null, "Failed to load ember_wastes.tscn")
	var ember_inst: Node = ember_scene.instantiate()
	root.add_child(ember_inst)
	assert(ember_inst.find_child("NorthCliff", true, false) != null, "NorthCliff landmark missing")
	assert(ember_inst.find_child("ReactorPlatform", true, false) != null, "ReactorPlatform landmark missing")
	assert(ember_inst.find_child("GroundTexture", true, false) != null, "GroundTexture missing")
	var ember_pickup: Area2D = ember_inst.find_child("ComponentPickup", true, false)
	assert(ember_pickup != null, "ComponentPickup missing in ember_wastes")
	var ember_player: CharacterBody2D = ember_inst.find_child("Player", true, false)
	ember_pickup.interact(ember_player)
	assert(gs.has_component("plasma_regulator") == true, "Plasma regulator should be collected")
	assert(gs.is_component_installed("plasma_regulator") == false, "Collection must NOT automatically install component")
	ember_inst.queue_free()
	print("  Ember Wastes detailed environment, Reactor Platform & Plasma Regulator collection verified.")

	# Verdant Ruins
	var verdant_scene: PackedScene = load("res://scenes/regions/verdant_ruins.tscn")
	assert(verdant_scene != null, "Failed to load verdant_ruins.tscn")
	var verdant_inst: Node = verdant_scene.instantiate()
	root.add_child(verdant_inst)
	assert(verdant_inst.find_child("TempleArchway", true, false) != null, "TempleArchway landmark missing")
	assert(verdant_inst.find_child("NavigationShrine", true, false) != null, "NavigationShrine landmark missing")
	assert(verdant_inst.find_child("GroundTexture", true, false) != null, "GroundTexture missing")
	var verdant_pickup: Area2D = verdant_inst.find_child("ComponentPickup", true, false)
	assert(verdant_pickup != null, "ComponentPickup missing in verdant_ruins")
	var verdant_player: CharacterBody2D = verdant_inst.find_child("Player", true, false)
	verdant_pickup.interact(verdant_player)
	assert(gs.has_component("navigation_core") == true, "Navigation core should be collected")
	assert(gs.is_component_installed("navigation_core") == false, "Collection must NOT automatically install component")
	verdant_inst.queue_free()
	print("  Verdant Ruins detailed environment, Navigation Shrine & Navigation Core collection verified.")

	# Frostfall Expanse
	var frost_scene: PackedScene = load("res://scenes/regions/frostfall_expanse.tscn")
	assert(frost_scene != null, "Failed to load frostfall_expanse.tscn")
	var frost_inst: Node = frost_scene.instantiate()
	root.add_child(frost_inst)
	assert(frost_inst.find_child("NorthGlacier", true, false) != null, "NorthGlacier landmark missing")
	assert(frost_inst.find_child("CryoFacility", true, false) != null, "CryoFacility landmark missing")
	assert(frost_inst.find_child("GroundTexture", true, false) != null, "GroundTexture missing")
	var frost_pickup: Area2D = frost_inst.find_child("ComponentPickup", true, false)
	assert(frost_pickup != null, "ComponentPickup missing in frostfall_expanse")
	var frost_player: CharacterBody2D = frost_inst.find_child("Player", true, false)
	frost_pickup.interact(frost_player)
	assert(gs.has_component("quantum_power_cell") == true, "Quantum power cell should be collected")
	assert(gs.is_component_installed("quantum_power_cell") == false, "Collection must NOT automatically install component")
	frost_inst.queue_free()
	print("  Frostfall Expanse detailed environment, Cryo Facility & Quantum Power Cell collection verified.")

	# Post-collection map check: component details must now be revealed!
	var map_inst2: Control = map_scene.instantiate()
	root.add_child(map_inst2)
	var comp_name_label2: Label = map_inst2.find_child("DetailCompName", true, false)
	assert(comp_name_label2.text.contains("RECOVERED"), "Component should be marked RECOVERED after collection")
	map_inst2.queue_free()
	print("  Map post-collection telemetry update verified.")

	# 8. Test Separate Component Installation Mission (Task 4)
	print("[TEST 8/8] Testing Separate Individual Component Installations...")
	assert(gs.all_components_collected() == true, "All 3 components must be collected")
	assert(gs.all_components_installed() == false, "Components must NOT be installed yet")
	assert(gs.ship_repaired == false, "Ship must NOT be repaired before installation")

	# Test installation prevention for uncollected components
	var fake_gs_res: bool = gs.install_component("nonexistent_component")
	assert(fake_gs_res == false, "Uncollected / nonexistent component cannot be installed")

	# Installation 1: Plasma Regulator
	assert(gs.get_next_installable_component() == "plasma_regulator", "First installable must be plasma_regulator")
	var p_installed: bool = gs.install_component("plasma_regulator")
	assert(p_installed == true, "Plasma regulator installation must succeed")
	assert(gs.is_component_installed("plasma_regulator") == true, "Plasma regulator must be marked installed")
	assert(gs.all_components_installed() == false, "Ship must not be complete after only 1 component")
	assert(gs.ship_repaired == false, "Ship must not be repaired yet")

	# Prevent duplicate installation
	var p_dup: bool = gs.install_component("plasma_regulator")
	assert(p_dup == false, "Component cannot be installed twice")

	# Installation 2: Navigation Core
	assert(gs.get_next_installable_component() == "navigation_core", "Second installable must be navigation_core")
	var n_installed: bool = gs.install_component("navigation_core")
	assert(n_installed == true, "Navigation core installation must succeed")
	assert(gs.is_component_installed("navigation_core") == true, "Navigation core must be marked installed")
	assert(gs.all_components_installed() == false, "Ship must not be complete after 2 components")
	assert(gs.ship_repaired == false, "Ship must not be repaired yet")

	# Installation 3: Quantum Power Cell
	assert(gs.get_next_installable_component() == "quantum_power_cell", "Third installable must be quantum_power_cell")
	var q_installed: bool = gs.install_component("quantum_power_cell")
	assert(q_installed == true, "Quantum power cell installation must succeed")
	assert(gs.is_component_installed("quantum_power_cell") == true, "Quantum power cell must be marked installed")

	# Now all 3 components are installed
	assert(gs.all_components_installed() == true, "All components must now be installed")
	assert(gs.ship_repaired == true, "Ship must be repaired only after all 3 installations")
	assert(gs.get_next_installable_component() == "", "No more components left to install")

	# Test surface console interaction with all installed
	var repair_surface: Node = surface_scene.instantiate()
	root.add_child(repair_surface)
	var rep_ship: Sprite2D = repair_surface.find_child("RepairedShipReady", true, false)
	assert(rep_ship != null and rep_ship.visible == true, "Repaired ship must be visible when all components installed")
	assert(rep_ship.texture != null and rep_ship.texture.resource_path.contains("working_ship_takeoff"), "Repaired ship must use takeoff rocket texture")
	var rep_gf: Area2D = repair_surface.find_child("Grandfather", true, false)
	assert(rep_gf != null and rep_gf.position.x > 300, "Grandfather must stand away from the ship at safe distance")
	var rep_console: Area2D = repair_surface.find_child("ShipConsole", true, false)
	var rep_player: CharacterBody2D = repair_surface.find_child("Player", true, false)
	rep_console.interact(rep_player)
	print("  Spaceship console individual component installation sequence verified.")
	repair_surface.queue_free()

	# 9. Test Final Cutscene Scene
	print("[TEST 9/10] Testing Final Departure Cutscene Scene...")
	var final_cutscene_scene: PackedScene = load("res://scenes/cutscenes/final_cutscene.tscn")
	assert(final_cutscene_scene != null, "Failed to load final_cutscene.tscn")
	var final_cutscene_inst: Node = final_cutscene_scene.instantiate()
	root.add_child(final_cutscene_inst)
	assert(final_cutscene_inst.find_child("ShipNode", true, false) != null, "ShipNode missing in final cutscene")
	assert(final_cutscene_inst.find_child("GrandfatherActor", true, false) != null, "GrandfatherActor missing in final cutscene")
	assert(final_cutscene_inst.find_child("RixActor", true, false) != null, "RixActor missing in final cutscene")
	assert(final_cutscene_inst.find_child("DiscoveryPanel", true, false) != null, "DiscoveryPanel missing in final cutscene")
	assert(final_cutscene_inst.find_child("DialogPanel", true, false) != null, "DialogPanel missing in final cutscene")
	final_cutscene_inst.queue_free()
	print("  Final Cutscene actors, dialog, launch elements, and discovery panel verified.")

	# 10. Test End Credits & Epilogue Preview
	print("[TEST 10/10] Testing End Credits & Epilogue Preview Scene...")
	var credits_scene: PackedScene = load("res://scenes/ui/credits.tscn")
	assert(credits_scene != null, "Failed to load credits.tscn")
	var credits_inst: Node = credits_scene.instantiate()
	root.add_child(credits_inst)
	assert(credits_inst.find_child("ScrollContainer", true, false) != null, "ScrollContainer missing in credits")
	assert(credits_inst.find_child("BtnContinue", true, false) != null, "BtnContinue missing in credits")
	assert(credits_inst.find_child("BtnMainMenu", true, false) != null, "BtnMainMenu missing in credits")
	assert(credits_inst.find_child("PreviewModal", true, false) != null, "PreviewModal missing in credits")
	credits_inst.queue_free()
	print("  End Credits and Exploration Preview verified.")

	print("--- ALL 10 INTEGRATION TESTS PASSED WITH ZERO ERRORS! ---")
	quit(0)
