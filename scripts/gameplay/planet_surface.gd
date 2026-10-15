extends Node2D

# Planet Surface & Crash Site Exploration for Echoes of Eternity

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera2D
@onready var grandfather: Area2D = %Grandfather
@onready var ship_console: Area2D = %ShipConsole

# HUD elements
@onready var hud_avatar: TextureRect = %Avatar
@onready var health_bar: ProgressBar = %HealthBar
@onready var oxygen_bar: ProgressBar = %OxygenBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var coords_label: Label = %CoordsLabel
@onready var scan_popup: PanelContainer = %ScanPopup
@onready var scan_title: Label = %ScanTitle
@onready var scan_desc: Label = %ScanDesc
@onready var obj_checklist: Label = %ObjChecklist

# Intro Recovery UI
@onready var recovery_dialog: PanelContainer = %RecoveryDialog
@onready var recovery_text: Label = %RecoveryText
@onready var survival_banner: VBoxContainer = %SurvivalBanner
@onready var banner_title: Label = %BannerTitle
@onready var banner_status: Label = %BannerStatus

# Interactive Systems
@onready var dialogue_overlay: Control = %DialogueOverlay
@onready var region_map: Control = %RegionMap
@onready var ship_repair_banner: PanelContainer = %ShipRepairBanner
@onready var ship_repair_title: Label = %ShipRepairTitle
@onready var ship_repair_status: Label = %ShipRepairStatus

# Ship Repair VFX
@onready var ship_repair_sparks: CPUParticles2D = %ShipRepairSparks
@onready var ship_repair_glow: ColorRect = %ShipRepairGlow
@onready var repaired_ship_ready: Sprite2D = get_node_or_null("%RepairedShipReady")
@onready var smoke_particles: CPUParticles2D = get_node_or_null("CrashWreckage/SmokeParticles")
@onready var sparks_particles: CPUParticles2D = get_node_or_null("CrashWreckage/SparksParticles")

# Pause overlay & Modals
@onready var pause_overlay: Control = %PauseOverlay
@onready var btn_resume: Button = %BtnResume
@onready var btn_pause_settings: Button = %BtnPauseSettings
@onready var btn_pause_menu: Button = %BtnPauseMenu
@onready var btn_pause_map: Button = %BtnPauseMap
@onready var settings_modal: Control = %SettingsModal
@onready var fade_rect: ColorRect = %FadeRect

# Audio
@onready var ambient_wind: AudioStreamPlayer = %AmbientWind
@onready var repair_sfx: AudioStreamPlayer = %RepairSFX

var _is_paused: bool = false
var _scan_timer: float = 0.0
var _is_repairing: bool = false
var _is_recovering: bool = false
var _recovery_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	pause_overlay.visible = false
	scan_popup.visible = false
	settings_modal.visible = false
	if recovery_dialog: recovery_dialog.visible = false
	if survival_banner: survival_banner.visible = false
	if dialogue_overlay: dialogue_overlay.visible = false
	if region_map:
		region_map.visible = false
		region_map.map_closed.connect(_on_map_closed)
	if ship_repair_banner: ship_repair_banner.visible = false
	if ship_repair_sparks: ship_repair_sparks.emitting = false
	if ship_repair_glow: ship_repair_glow.visible = false
	
	_connect_signals()
	_update_ship_checklist()
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs and not gs.intro_recovery_done:
		_start_crash_recovery_sequence()
	else:
		_start_normal_arrival()

func _connect_signals() -> void:
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_pause_settings.pressed.connect(_on_settings_pressed)
	btn_pause_menu.pressed.connect(_on_main_menu_pressed)
	if btn_pause_map: btn_pause_map.pressed.connect(open_region_map)
	
	for btn in [btn_resume, btn_pause_settings, btn_pause_menu, btn_pause_map]:
		if btn:
			btn.mouse_entered.connect(_on_btn_hover)
			btn.focus_entered.connect(_on_btn_hover)
		
	if not settings_modal.closed.is_connected(_on_settings_closed):
		settings_modal.closed.connect(_on_settings_closed)
	
	if grandfather and grandfather.has_signal("dialogue_requested"):
		if not grandfather.dialogue_requested.is_connected(start_grandfather_dialogue):
			grandfather.dialogue_requested.connect(start_grandfather_dialogue)
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		if not gs.component_collected.is_connected(_on_ship_state_changed):
			gs.component_collected.connect(_on_ship_state_changed)
		if not gs.component_installed.is_connected(_on_ship_state_changed):
			gs.component_installed.connect(_on_ship_state_changed)
		if not gs.ship_restored.is_connected(_on_ship_state_changed):
			gs.ship_restored.connect(_on_ship_state_changed)

func _start_normal_arrival() -> void:
	player.is_locked = false
	if ambient_wind and ambient_wind.stream and not ambient_wind.playing:
		ambient_wind.play()
		ambient_wind.volume_db = -8.0
	
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	await tween.finished
	fade_rect.visible = false
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs and (gs.ship_repaired or gs.all_components_installed()):
		_apply_repaired_ship_state(false)
	elif gs and gs.all_components_collected() and not gs.all_components_installed():
		if survival_banner and banner_title and banner_status:
			banner_title.text = "MISSION: RESTORE THE ODYSSEY-IV"
			banner_status.text = "OBJECTIVE: Return to the crash site and install all three recovered components."
			survival_banner.visible = true
			survival_banner.modulate.a = 0.0
			var b_tween := create_tween()
			b_tween.tween_property(survival_banner, "modulate:a", 1.0, 0.5)
			b_tween.tween_interval(4.0)
			b_tween.tween_property(survival_banner, "modulate:a", 0.0, 0.8)
			b_tween.tween_callback(func(): survival_banner.visible = false)

# Initial Rix awakening with instant skip capability
func _start_crash_recovery_sequence() -> void:
	_is_recovering = true
	player.is_locked = true
	
	if ambient_wind and ambient_wind.stream and not ambient_wind.playing:
		ambient_wind.play()
		ambient_wind.volume_db = -8.0
	
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	
	var anim_sprite: AnimatedSprite2D = player.get_node_or_null("%AnimatedSprite2D")
	if anim_sprite:
		if anim_sprite.sprite_frames.has_animation("crash_recovery"):
			anim_sprite.play("crash_recovery")
			anim_sprite.frame = 0
			anim_sprite.pause()
		else:
			anim_sprite.play("crouch_down")
	
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	await fade_tween.finished
	fade_rect.visible = false
	
	if not _is_recovering: return
	
	# Step 1: Stirring & getting up animation
	if anim_sprite and anim_sprite.sprite_frames.has_animation("crash_recovery"):
		anim_sprite.play("crash_recovery")
	await get_tree().create_timer(1.2).timeout
	if not _is_recovering: return
	if anim_sprite: anim_sprite.play("idle_down")
	
	# Step 2: Rix dialogue reveal
	if recovery_dialog and recovery_text:
		recovery_dialog.visible = true
		recovery_dialog.modulate.a = 0.0
		recovery_text.text = "“Rix: Systems are gone... Where am I?”"
		recovery_text.visible_ratio = 1.0
		
		var dlg_in := create_tween()
		dlg_in.tween_property(recovery_dialog, "modulate:a", 1.0, 0.25)
		dlg_in.tween_interval(1.5)
		dlg_in.tween_property(recovery_dialog, "modulate:a", 0.0, 0.3)
		await dlg_in.finished
		recovery_dialog.visible = false
	
	if not _is_recovering: return
	
	# Step 3: Cinematic Mission Banner
	if survival_banner:
		survival_banner.visible = true
		survival_banner.modulate.a = 0.0
		var banner_tween := create_tween()
		banner_tween.tween_property(survival_banner, "modulate:a", 1.0, 0.4)
		banner_tween.tween_interval(1.5)
		banner_tween.tween_property(survival_banner, "modulate:a", 0.0, 0.5)
		await banner_tween.finished
		survival_banner.visible = false
	
	_finish_crash_recovery()

func _skip_crash_recovery() -> void:
	if not _is_recovering:
		return
	_finish_crash_recovery()

func _finish_crash_recovery() -> void:
	_is_recovering = false
	player.is_locked = false
	if recovery_dialog: recovery_dialog.visible = false
	if survival_banner: survival_banner.visible = false
	if fade_rect: fade_rect.visible = false
	
	var anim_sprite: AnimatedSprite2D = player.get_node_or_null("%AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("idle_down")
		
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.intro_recovery_done = true
		
	# Stranger approaches from the dust
	if grandfather and grandfather.has_method("approach_towards"):
		grandfather.approach_towards(Vector2(200, 20), 3.0)

# Grandfather Dialogue Flow
func start_grandfather_dialogue(_gf_node: Node2D = null) -> void:
	if dialogue_overlay.visible or _is_repairing:
		return
		
	player.is_locked = true
	var gs: Node = get_node_or_null("/root/GameState")
	var is_first_time: bool = gs and not gs.grandfather_revealed
	
	var lines: Array[Dictionary] = []
	
	if is_first_time:
		lines = [
			{
				"speaker": "MYSTERIOUS STRANGER",
				"portrait": "res://assets/images/characters/grandfather/face_serious.png",
				"text": "“You survived the fall. Not many ships survive this world's atmosphere.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“Who are you? Where am I?”"
			},
			{
				"speaker": "MYSTERIOUS STRANGER",
				"portrait": "res://assets/images/characters/grandfather/face_neutral.png",
				"text": "“A long way from the stars you were chasing.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“My ship... the engines are gone. I need to repair them.”"
			},
			{
				"speaker": "MYSTERIOUS STRANGER",
				"portrait": "res://assets/images/characters/grandfather/face_thoughtful.png",
				"text": "“Still chasing the horizon, just like you always did.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“Wait. That voice... Grandpa?!”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_calm.png",
				"text": "“You've grown, Rix. But you still run toward the unknown before checking whether your ship can bring you home.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“I thought I'd never see you again! How are you even here?”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_determined.png",
				"text": "“There will be time for stories. First, we get you flying again.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“Can you help me repair the Odyssey-IV?”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_speaking.png",
				"text": "“I can show you where to begin. But the rest of the journey is yours.”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_serious.png",
				"text": "“Take this. Out here, not everything you meet will welcome you.”",
				"event": "give_sword"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“A sword? I came here to explore, not fight.”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_thoughtful.png",
				"text": "“Then learn when not to fight. The sword is for protection, and for when there is no other choice.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“I'll keep it safe, Grandpa.”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_speaking.png",
				"text": "“Your ship cannot leave this planet in its current state. Three critical components are missing.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“Three components, scattered across an entire planet?”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_determined.png",
				"text": "“Not scattered by chance. Each lies somewhere that will test you in a different way.”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_calm.png",
				"text": "“Here. This ancient holographic star-chart links to orbital telemetry. Select a region to begin.”"
			}
		]
	else:
		# Subsequent conversation
		if gs and gs.all_components_installed():
			lines = [
				{
					"speaker": "GRANDFATHER",
					"portrait": "res://assets/images/characters/grandfather/face_calm.png",
					"text": "“The Odyssey-IV is fully restored, Rix! All three critical components are humming in perfect resonance.”"
				}
			]
		elif gs and gs.all_components_collected():
			var next_comp_name := "Plasma Regulator"
			var next_id: String = gs.get_next_installable_component()
			if next_id == "navigation_core": next_comp_name = "Navigation Core"
			elif next_id == "quantum_power_cell": next_comp_name = "Quantum Power Cell"
			lines = [
				{
					"speaker": "GRANDFATHER",
					"portrait": "res://assets/images/characters/grandfather/face_calm.png",
					"text": "“You've recovered all three components, Rix! Go to the Odyssey-IV console and install them. Next compartment: " + next_comp_name + "!”"
				}
			]
		else:
			var missing: Array[String] = gs.get_missing_component_names() if gs else []
			var missing_text := " • " + "\n • ".join(missing)
			lines = [
				{
					"speaker": "GRANDFATHER",
					"portrait": "res://assets/images/characters/grandfather/face_thoughtful.png",
					"text": "“Keep your blade sharp and your eyes keen. We still need:\n" + missing_text + "”"
				},
				{
					"speaker": "GRANDFATHER",
					"portrait": "res://assets/images/characters/grandfather/face_speaking.png",
					"text": "“Opening the holographic map now. Choose your destination wisely.”"
				}
			]
			
	dialogue_overlay.start_dialogue(lines)
	
	dialogue_overlay.dialogue_finished.connect(func():
		player.is_locked = false
		if gs:
			gs.grandfather_revealed = true
			gs.unlock_map()
			if not gs.all_components_collected():
				open_region_map()
		else:
			open_region_map()
	, CONNECT_ONE_SHOT)

# Spaceship Console Inspection & Individual Component Installation
func interact_ship_console() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs or _is_repairing:
		return
		
	if gs.ship_repaired or gs.all_components_installed():
		start_departure_sequence()
		return
		
	var next_comp: String = gs.get_next_installable_component()
	if next_comp != "":
		_install_component(next_comp)
	else:
		var reg_status := "INSTALLED" if gs.is_component_installed("plasma_regulator") else ("READY TO INSTALL" if gs.has_component("plasma_regulator") else "MISSING")
		var nav_status := "INSTALLED" if gs.is_component_installed("navigation_core") else ("READY TO INSTALL" if gs.has_component("navigation_core") else "MISSING")
		var cell_status := "INSTALLED" if gs.is_component_installed("quantum_power_cell") else ("READY TO INSTALL" if gs.has_component("quantum_power_cell") else "MISSING")
		
		var desc := "ODYSSEY-IV RESTORATION TELEMETRY:\n"
		desc += " • PLASMA REGULATOR: " + reg_status + "\n"
		desc += " • NAVIGATION CORE: " + nav_status + "\n"
		desc += " • QUANTUM POWER CELL: " + cell_status + "\n\n"
		desc += "Recover missing components across the planetary sectors."
		show_scan_result("ODYSSEY-IV RESTORATION STATUS", desc, 6.0)

func start_departure_sequence() -> void:
	if _is_repairing:
		return
	_is_repairing = true
	player.is_locked = true
	
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and ResourceLoader.exists("res://assets/audio/reentry.wav"):
		am.play_sfx(load("res://assets/audio/reentry.wav"), -3.0, 1.2)
	elif am:
		am.play_click()
		
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.start_final_departure()

func _install_component(comp_id: String) -> void:
	_is_repairing = true
	player.is_locked = true
	
	var gs: Node = get_node_or_null("/root/GameState")
	var anim_sprite: AnimatedSprite2D = player.get_node_or_null("%AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("interact_down")
		
	var am: Node = get_node_or_null("/root/AudioManager")
	
	# Flying component visual effect from Rix to ship socket
	var comp_tex_path: String = ""
	if comp_id == "plasma_regulator":
		comp_tex_path = "res://assets/images/plasma_regulator.png"
	elif comp_id == "navigation_core":
		comp_tex_path = "res://assets/images/navigation_core.png"
	elif comp_id == "quantum_power_cell":
		comp_tex_path = "res://assets/images/quantum_power_cell.png"
		
	if comp_tex_path != "" and ResourceLoader.exists(comp_tex_path):
		var comp_sprite := Sprite2D.new()
		comp_sprite.texture = load(comp_tex_path)
		comp_sprite.scale = Vector2(0.04, 0.04)
		comp_sprite.global_position = player.global_position + Vector2(0, -32)
		comp_sprite.z_index = 12
		add_child(comp_sprite)
		
		var target_socket: Vector2 = ship_console.global_position if ship_console else (player.global_position + Vector2(0, -55))
		var arc_tween := create_tween()
		arc_tween.set_parallel(true)
		arc_tween.tween_property(comp_sprite, "scale", Vector2(0.18, 0.18), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		arc_tween.tween_property(comp_sprite, "global_position:y", comp_sprite.global_position.y - 40.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		arc_tween.chain().tween_property(comp_sprite, "global_position", target_socket, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		arc_tween.parallel().tween_property(comp_sprite, "rotation", 6.28, 0.8)
		arc_tween.parallel().tween_property(comp_sprite, "scale", Vector2(0.02, 0.02), 0.8).set_delay(0.35)
		arc_tween.chain().tween_callback(comp_sprite.queue_free)
	
	if comp_id == "plasma_regulator":
		# Installation 1: Plasma Regulator — Orange electrical sparks and reactor illumination
		if ship_repair_sparks:
			ship_repair_sparks.emitting = true
		if ship_repair_glow:
			ship_repair_glow.color = Color(1.0, 0.5, 0.1, 0.55)
			ship_repair_glow.visible = true
			var g_tween := create_tween().set_loops(3)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.9, 0.25)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.2, 0.25)
		if repair_sfx and ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
			repair_sfx.stream = load("res://assets/audio/engine_thrust.wav")
			repair_sfx.volume_db = -6.0
			repair_sfx.play()
		elif am:
			am.play_click()
			
		await get_tree().create_timer(2.2).timeout
		if gs: gs.install_component("plasma_regulator")
		_show_installation_progress("PROPULSION COMPARTMENT // PLASMA REGULATOR INSTALLED", "plasma_regulator")
		
	elif comp_id == "navigation_core":
		# Installation 2: Navigation Core — Holographic navigation effects & avionics lights
		if ship_repair_sparks:
			ship_repair_sparks.emitting = true
		if ship_repair_glow:
			ship_repair_glow.color = Color(0.15, 0.95, 0.55, 0.6)
			ship_repair_glow.visible = true
			var g_tween := create_tween().set_loops(3)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.85, 0.22)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.25, 0.22)
		if am and ResourceLoader.exists("res://assets/audio/anomaly.wav"):
			am.play_sfx(load("res://assets/audio/anomaly.wav"), -5.0, 1.4)
		elif am:
			am.play_click()
			
		await get_tree().create_timer(2.2).timeout
		if gs: gs.install_component("navigation_core")
		_show_installation_progress("AVIONICS COMPARTMENT // NAVIGATION CORE INSTALLED", "navigation_core")
		
	elif comp_id == "quantum_power_cell":
		# Installation 3: Quantum Power Cell — Controlled blue energy surge & power illumination
		if ship_repair_sparks:
			ship_repair_sparks.emitting = true
		if ship_repair_glow:
			ship_repair_glow.color = Color(0.2, 0.65, 1.0, 0.7)
			ship_repair_glow.visible = true
			var g_tween := create_tween().set_loops(4)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.95, 0.2)
			g_tween.tween_property(ship_repair_glow, "modulate:a", 0.3, 0.2)
		if repair_sfx and ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
			repair_sfx.stream = load("res://assets/audio/engine_thrust.wav")
			repair_sfx.volume_db = -4.0
			repair_sfx.play()
		elif am:
			am.play_click()
			
		await get_tree().create_timer(2.4).timeout
		if gs: gs.install_component("quantum_power_cell")
		_show_installation_progress("POWER COMPARTMENT // QUANTUM POWER CELL INSTALLED", "quantum_power_cell")

func _show_installation_progress(banner_header: String, installed_comp: String) -> void:
	if ship_repair_sparks: ship_repair_sparks.emitting = false
	if ship_repair_glow: ship_repair_glow.visible = false
	
	var gs: Node = get_node_or_null("/root/GameState")
	var is_all_done: bool = gs and gs.all_components_installed()
	
	var reg_stat := "INSTALLED" if (gs and gs.is_component_installed("plasma_regulator")) else ("READY TO INSTALL" if (gs and gs.has_component("plasma_regulator")) else "MISSING")
	var nav_stat := "INSTALLED" if (gs and gs.is_component_installed("navigation_core")) else ("READY TO INSTALL" if (gs and gs.has_component("navigation_core")) else "MISSING")
	var cell_stat := "INSTALLED" if (gs and gs.is_component_installed("quantum_power_cell")) else ("READY TO INSTALL" if (gs and gs.has_component("quantum_power_cell")) else "MISSING")
	
	var status_text := "PLASMA REGULATOR: %s\nNAVIGATION CORE: %s\nQUANTUM POWER CELL: %s" % [reg_stat, nav_stat, cell_stat]
	
	if ship_repair_banner and ship_repair_title and ship_repair_status:
		ship_repair_title.text = banner_header if not is_all_done else "ODYSSEY-IV — SYSTEMS RESTORATION COMPLETE"
		ship_repair_status.text = status_text if not is_all_done else "PROPULSION, AVIONICS, AND PRIMARY POWER HARMONIZED.\nALL THREE COMPONENTS INSTALLED // READY FOR FLIGHT."
		ship_repair_banner.visible = true
		ship_repair_banner.modulate.a = 0.0
		var b_tween := create_tween()
		b_tween.tween_property(ship_repair_banner, "modulate:a", 1.0, 0.5)
		b_tween.tween_interval(3.5 if not is_all_done else 5.0)
		b_tween.tween_property(ship_repair_banner, "modulate:a", 0.0, 0.8)
		b_tween.tween_callback(func():
			ship_repair_banner.visible = false
		)
	
	if is_all_done:
		_apply_repaired_ship_state(true)
		# Reactor activation & engine ignition
		if ship_repair_glow:
			ship_repair_glow.color = Color(0.2, 0.75, 1.0, 0.7)
			ship_repair_glow.visible = true
			var g_loop := create_tween().set_loops(4)
			g_loop.tween_property(ship_repair_glow, "modulate:a", 1.0, 0.3)
			g_loop.tween_property(ship_repair_glow, "modulate:a", 0.4, 0.3)
			
		var am_power: Node = get_node_or_null("/root/AudioManager")
		if am_power and ResourceLoader.exists("res://assets/audio/reentry.wav"):
			am_power.play_sfx(load("res://assets/audio/reentry.wav"), -4.0, 1.5)
			
		# Grandfather speaks praise
		var lines: Array[Dictionary] = [
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_calm.png",
				"text": "“You did it, Rix! All three components are installed and the Odyssey-IV breathes again. You've earned your wings—and that blade.”"
			},
			{
				"speaker": "RIX // EVA-SUIT",
				"portrait": "res://assets/images/rix_portrait.png",
				"text": "“All reactor indicators are green. Sub-light drives and navigation are humming. We're ready for launch!”"
			},
			{
				"speaker": "GRANDFATHER",
				"portrait": "res://assets/images/characters/grandfather/face_determined.png",
				"text": "“Approach the console whenever you are ready to initiate the departure sequence. Your new voyage begins now.”"
			}
		]
		dialogue_overlay.start_dialogue(lines)
		dialogue_overlay.dialogue_finished.connect(func():
			player.is_locked = false
			_is_repairing = false
			if ship_console and ship_console.has_method("update_prompt_for_player"):
				ship_console.update_prompt_for_player(player)
		, CONNECT_ONE_SHOT)
	else:
		player.is_locked = false
		_is_repairing = false
		if ship_console and ship_console.has_method("update_prompt_for_player"):
			ship_console.update_prompt_for_player(player)
func _apply_repaired_ship_state(animate: bool = false) -> void:
	if repaired_ship_ready:
		repaired_ship_ready.visible = true
		if animate:
			repaired_ship_ready.modulate.a = 0.0
			var t := create_tween()
			t.tween_property(repaired_ship_ready, "modulate:a", 1.0, 1.2)
		else:
			repaired_ship_ready.modulate.a = 1.0
		var engines: CPUParticles2D = repaired_ship_ready.get_node_or_null("ReadyEnginesGlow")
		if engines:
			engines.visible = true
			engines.emitting = true
			
	if smoke_particles:
		smoke_particles.emitting = false
	if sparks_particles:
		sparks_particles.emitting = false
		
	# Grandpa stands away from the ship at a safe distance overlooking the launch site
	var safe_pos := Vector2(380, 140)
	if grandfather and is_instance_valid(grandfather):
		if animate and grandfather.has_method("approach_towards"):
			grandfather.approach_towards(safe_pos, 2.5)
		else:
			grandfather.position = safe_pos
			if grandfather.has_method("face_towards"):
				grandfather.face_towards(-260.0)

func _on_ship_state_changed(_arg = null) -> void:
	_update_ship_checklist()

func _update_ship_checklist() -> void:
	if not obj_checklist:
		return
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs:
		return
		
	if gs.ship_repaired or gs.all_components_installed():
		obj_checklist.text = "MISSION: ODYSSEY-IV RESTORED // Approach console to initiate launch [E]!"
		obj_checklist.modulate = Color(0.3, 1.0, 0.5, 1.0)
		return
		
	var reg := "✔ INSTALLED" if gs.is_component_installed("plasma_regulator") else ("⏳ READY" if gs.has_component("plasma_regulator") else "✖ MISSING")
	var nav := "✔ INSTALLED" if gs.is_component_installed("navigation_core") else ("⏳ READY" if gs.has_component("navigation_core") else "✖ MISSING")
	var cell := "✔ INSTALLED" if gs.is_component_installed("quantum_power_cell") else ("⏳ READY" if gs.has_component("quantum_power_cell") else "✖ MISSING")
	
	if gs.all_components_collected():
		obj_checklist.text = "MISSION: RESTORE THE ODYSSEY-IV // OBJECTIVE: Install recovered components at console.\n[%s] Plasma Reg.   [%s] Nav Core   [%s] Quantum Cell" % [reg, nav, cell]
		obj_checklist.modulate = Color(0.4, 0.9, 1.0, 1.0)
	else:
		obj_checklist.text = "MISSION: RECOVER COMPONENTS // [%s] Plasma Reg.   [%s] Nav Core   [%s] Quantum Cell   [M: Map]" % [reg, nav, cell]
		obj_checklist.modulate = Color(1.0, 0.8, 0.3, 1.0)

func _process(delta: float) -> void:
	if not _is_paused:
		health_bar.value = player.suit_integrity
		oxygen_bar.value = player.oxygen
		stamina_bar.value = player.stamina
		
		var lat := 42.109 + (player.position.y * 0.001)
		var lon := -88.402 + (player.position.x * 0.001)
		coords_label.text = "SECTOR ZERO // LAT: %0.3f  LON: %0.3f" % [lat, lon]
		
		camera.position = camera.position.lerp(player.position, delta * 6.0)
		
		if scan_popup.visible:
			_scan_timer -= delta
			if _scan_timer <= 0.0:
				_hide_scan_popup()

func _unhandled_input(event: InputEvent) -> void:
	if _is_recovering and event.is_pressed():
		get_viewport().set_input_as_handled()
		_skip_crash_recovery()
		return
		
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if settings_modal.visible:
			settings_modal.close_settings()
		elif region_map and region_map.visible:
			region_map.close_map()
		elif not dialogue_overlay.visible and not _is_repairing:
			toggle_pause()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if not dialogue_overlay.visible and not _is_repairing:
			get_viewport().set_input_as_handled()
			if region_map and region_map.visible:
				region_map.close_map()
			else:
				open_region_map()

func toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	pause_overlay.visible = _is_paused
	if _is_paused:
		btn_resume.grab_focus()
		var am: Node = get_node_or_null("/root/AudioManager")
		if am: am.play_click()

func open_region_map() -> void:
	if _is_paused:
		toggle_pause()
	if region_map:
		if player:
			player.is_locked = true
		region_map.process_mode = Node.PROCESS_MODE_ALWAYS
		region_map.move_to_front()
		region_map.open_map()

func _on_map_closed() -> void:
	if player:
		player.is_locked = false
		player.grab_focus()

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_settings_pressed() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()
	settings_modal.open_settings()

func _on_settings_closed() -> void:
	btn_pause_settings.grab_focus()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
		am.stop_music(0.5)
	
	if ambient_wind and ambient_wind.playing:
		var w_tween := create_tween()
		w_tween.tween_property(ambient_wind, "volume_db", -40.0, 0.4)
	
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_btn_hover() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_hover()

func show_scan_result(title: String, desc: String, duration: float = 5.0) -> void:
	scan_title.text = title
	scan_desc.text = desc
	scan_popup.visible = true
	scan_popup.modulate.a = 0.0
	_scan_timer = duration
	
	var tween := create_tween()
	tween.tween_property(scan_popup, "modulate:a", 1.0, 0.3)
	
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()

func _hide_scan_popup() -> void:
	var tween := create_tween()
	tween.tween_property(scan_popup, "modulate:a", 0.0, 0.3)
	await tween.finished
	scan_popup.visible = false
