extends SceneTree

# Comprehensive integration test for Echoes of Eternity

func _init() -> void:
	print("--- BEGIN AUTOMATED INTEGRATION TEST ---")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Test AudioManager
	print("[TEST 1/5] Verifying AudioManager and Bus Layout...")
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")
	assert(master_idx >= 0, "Master bus missing")
	assert(music_idx >= 0, "Music bus missing")
	assert(sfx_idx >= 0, "SFX bus missing")
	print("  Audio buses Master, Music, SFX verified successfully.")

	# 2. Test Rix SpriteFrames
	print("[TEST 2/5] Verifying Rix SpriteFrames animations...")
	var frames: SpriteFrames = load("res://resources/animations/rix_sprite_frames.tres")
	assert(frames != null, "Failed to load rix_sprite_frames.tres")
	var required_anims := [
		"idle_down", "idle_side", "idle_up",
		"walk_down", "walk_side", "walk_up",
		"run_down", "run_side", "run_up",
		"jump_side",
		"crouch_down", "crouch_side", "crouch_up",
		"attack_side",
		"interact_down",
		"hurt_down",
		"death_down",
		"crash_recovery"
	]
	for anim in required_anims:
		assert(frames.has_animation(anim), "Missing animation: " + anim)
		assert(frames.get_frame_count(anim) > 0, "Animation has 0 frames: " + anim)
	print("  All 18 Rix animations verified with valid frame counts.")

	# 3. Test Main Menu Scene Instantiation & Elements
	print("[TEST 3/5] Testing Main Menu Scene...")
	var menu_scene: PackedScene = load("res://scenes/ui/main_menu.tscn")
	assert(menu_scene != null, "Failed to load main_menu.tscn")
	var menu_inst: Node = menu_scene.instantiate()
	root.add_child(menu_inst)
	
	var btn_start: Button = menu_inst.find_child("BtnStart", true, false)
	var btn_settings: Button = menu_inst.find_child("BtnSettings", true, false)
	var btn_exit: Button = menu_inst.find_child("BtnExit", true, false)
	var settings_menu: Control = menu_inst.find_child("SettingsMenu", true, false)
	
	assert(btn_start != null, "Start button missing")
	assert(btn_settings != null, "Settings button missing")
	assert(btn_exit != null, "Exit button missing")
	assert(settings_menu != null, "Settings menu missing in main menu")
	print("  Main menu UI elements verified.")

	# Test opening settings
	btn_settings.emit_signal("pressed")
	assert(settings_menu.visible == true, "Settings menu should become visible")
	print("  Settings menu opened successfully.")
	
	# Test closing settings
	var back_btn: Button = settings_menu.find_child("BackButton", true, false)
	assert(back_btn != null, "Settings back button missing")
	back_btn.emit_signal("pressed")
	menu_inst.queue_free()

	# 4. Test Intro Cutscene Scene Instantiation & Cinematic Systems
	print("[TEST 4/5] Testing Upgraded Intro Cutscene Scene...")
	var cutscene_scene: PackedScene = load("res://scenes/cutscenes/intro_cutscene.tscn")
	assert(cutscene_scene != null, "Failed to load intro_cutscene.tscn")
	var cutscene_inst: Node = cutscene_scene.instantiate()
	root.add_child(cutscene_inst)
	
	var anim_player: AnimationPlayer = cutscene_inst.find_child("AnimationPlayer", true, false)
	assert(anim_player != null, "AnimationPlayer missing in cutscene")
	assert(anim_player.has_animation("intro_cinematic"), "intro_cinematic animation missing")
	print("  Intro cinematic timeline verified (length: %0.1fs)." % anim_player.get_animation("intro_cinematic").length)
	
	var inter_planet: Node = cutscene_inst.find_child("IntermediatePlanet", true, false)
	assert(inter_planet != null, "IntermediatePlanet missing in cutscene")
	var crash_aftermath: Node = cutscene_inst.find_child("CrashAftermath", true, false)
	assert(crash_aftermath != null, "CrashAftermath missing in cutscene")
	var rix_holo: Node = cutscene_inst.find_child("RixHolo", true, false)
	assert(rix_holo != null, "RixHolo AnimatedSprite2D missing in cutscene")
	
	assert(cutscene_inst.has_method("skip_cinematic"), "Cutscene skip method missing")
	assert(cutscene_inst.has_method("reveal_dialog"), "Cutscene reveal_dialog method missing")
	assert(cutscene_inst.has_method("sputter_engine"), "Cutscene sputter_engine method missing")
	print("  Cinematic timeline, intermediate planet, crash aftermath, and Rix systems verified.")
	cutscene_inst.queue_free()

	# 5. Test Planet Surface Gameplay Scene & Rix Player Recovery
	print("[TEST 5/5] Testing Planet Surface Gameplay Scene...")
	var surface_scene: PackedScene = load("res://scenes/gameplay/planet_surface.tscn")
	assert(surface_scene != null, "Failed to load planet_surface.tscn")
	var surface_inst: Node = surface_scene.instantiate()
	root.add_child(surface_inst)
	
	var player: CharacterBody2D = surface_inst.find_child("Player", true, false)
	assert(player != null, "Player missing in planet surface")
	var player_anim: AnimatedSprite2D = player.find_child("AnimatedSprite2D", true, false)
	assert(player_anim != null, "Player AnimatedSprite2D missing")
	assert(player_anim.sprite_frames != null, "Player SpriteFrames missing")
	
	var health_bar: ProgressBar = surface_inst.find_child("HealthBar", true, false)
	assert(health_bar != null, "HealthBar missing in HUD")
	var beacon: Area2D = surface_inst.find_child("EmergencyBeacon", true, false)
	assert(beacon != null, "EmergencyBeacon missing")
	assert(beacon.has_method("interact"), "EmergencyBeacon interact method missing")
	
	var wreckage: Node = surface_inst.find_child("CrashWreckage", true, false)
	assert(wreckage != null, "CrashWreckage missing")
	var recovery_dlg: Node = surface_inst.find_child("RecoveryDialog", true, false)
	assert(recovery_dlg != null, "RecoveryDialog missing")
	var survival_banner: Node = surface_inst.find_child("SurvivalBanner", true, false)
	assert(survival_banner != null, "SurvivalBanner missing")
	
	# Test scanning interaction
	beacon.interact(player)
	var scan_popup: Control = surface_inst.find_child("ScanPopup", true, false)
	assert(scan_popup.visible == true, "ScanPopup should become visible after scan")
	print("  Planet surface crash site, Rix recovery sequence, and scan interaction verified.")
	
	surface_inst.queue_free()

	print("--- ALL 5 INTEGRATION TESTS PASSED WITH ZERO ERRORS! ---")
	quit(0)
