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
		
	settings_modal.closed.connect(_on_settings_closed)
	
	if grandfather and grandfather.has_signal("dialogue_requested"):
		grandfather.dialogue_requested.connect(start_grandfather_dialogue)
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.component_collected.connect(func(_id): _update_ship_checklist())
		gs.ship_restored.connect(func(): _update_ship_checklist())

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

# Initial Rix awakening
func _start_crash_recovery_sequence() -> void:
	player.is_locked = true
	
	if ambient_wind and ambient_wind.stream:
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
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.4).set_ease(Tween.EASE_OUT)
	await fade_tween.finished
	fade_rect.visible = false
	
	# Step 1: Stirring & getting up animation
	await get_tree().create_timer(0.6).timeout
	if anim_sprite:
		if anim_sprite.sprite_frames.has_animation("crash_recovery"):
			anim_sprite.play("crash_recovery")
			await get_tree().create_timer(1.8).timeout
		anim_sprite.play("idle_down")
	
	# Step 2: Rix dialogue reveal
	if recovery_dialog and recovery_text:
		recovery_dialog.visible = true
		recovery_dialog.modulate.a = 0.0
		recovery_text.text = "“Rix: Systems are gone... Where am I?”"
		recovery_text.visible_ratio = 0.0
		
		var dlg_in := create_tween()
		dlg_in.tween_property(recovery_dialog, "modulate:a", 1.0, 0.3)
		dlg_in.parallel().tween_property(recovery_text, "visible_ratio", 1.0, 1.4).set_ease(Tween.EASE_OUT)
		await dlg_in.finished
		
		await get_tree().create_timer(2.0).timeout
		
		var dlg_out := create_tween()
		dlg_out.tween_property(recovery_dialog, "modulate:a", 0.0, 0.4)
		await dlg_out.finished
		recovery_dialog.visible = false
	
	# Step 3: Cinematic Mission Banner
	if survival_banner:
		survival_banner.visible = true
		survival_banner.modulate.a = 0.0
		var banner_tween := create_tween()
		banner_tween.tween_property(survival_banner, "modulate:a", 1.0, 0.6)
		banner_tween.tween_interval(2.0)
		banner_tween.tween_property(survival_banner, "modulate:a", 0.0, 0.8)
		await banner_tween.finished
		survival_banner.visible = false
	
	# Step 4: Unlock player control & have the mysterious stranger approach slowly
	player.is_locked = false
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.intro_recovery_done = true
		
	# Stranger approaches from the dust
	if grandfather and grandfather.has_method("approach_towards"):
		grandfather.approach_towards(Vector2(200, 20), 4.0)

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
		if gs and gs.all_components_collected():
			lines = [
				{
					"speaker": "GRANDFATHER",
					"portrait": "res://assets/images/characters/grandfather/face_calm.png",
					"text": "“You've gathered all three components, Rix! Go to the Odyssey-IV console and initiate the repair sequence!”"
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
		open_region_map()
	, CONNECT_ONE_SHOT)

# Spaceship Console Inspection & Repair
func interact_ship_console() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs or _is_repairing:
		return
		
	if gs.ship_repaired:
		show_scan_result("ODYSSEY-IV REPAIR STATUS", "All three critical components installed. Sub-light thrusters and hyperdrive manifold operational.", 5.0)
		return
		
	if gs.all_components_collected():
		_commence_ship_repair()
	else:
		var missing: Array[String] = gs.get_missing_component_names() if gs else []
		var desc := "PROPULSION SYSTEM OFFLINE.\nMissing components required for ignition:\n • " + "\n • ".join(missing)
		show_scan_result("ODYSSEY-IV ENGINE TELEMETRY", desc, 6.0)

func _commence_ship_repair() -> void:
	_is_repairing = true
	player.is_locked = true
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.complete_ship_repair()
	
	# Turn Rix toward ship
	var anim_sprite: AnimatedSprite2D = player.get_node_or_null("%AnimatedSprite2D")
	if anim_sprite:
		anim_sprite.play("interact_down")
		
	# Spark and glow surge
	if ship_repair_sparks:
		ship_repair_sparks.emitting = true
	if ship_repair_glow:
		ship_repair_glow.visible = true
		var g_tween := create_tween().set_loops(4)
		g_tween.tween_property(ship_repair_glow, "modulate:a", 0.6, 0.25)
		g_tween.tween_property(ship_repair_glow, "modulate:a", 0.1, 0.25)
		
	if repair_sfx and ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
		repair_sfx.stream = load("res://assets/audio/engine_thrust.wav")
		repair_sfx.volume_db = -4.0
		repair_sfx.play()
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()
	
	await get_tree().create_timer(2.6).timeout
	
	if ship_repair_sparks: ship_repair_sparks.emitting = false
	if ship_repair_glow: ship_repair_glow.visible = false
		
	# Grandfather congratulates Rix
	var lines: Array[Dictionary] = [
		{
			"speaker": "GRANDFATHER",
			"portrait": "res://assets/images/characters/grandfather/face_calm.png",
			"text": "“You did it, Rix! The Odyssey-IV breathes again. You've earned your wings—and that blade.”"
		},
		{
			"speaker": "RIX // EVA-SUIT",
			"portrait": "res://assets/images/rix_portrait.png",
			"text": "“We did it together, Grandpa. The stars are waiting for us.”"
		}
	]
	
	dialogue_overlay.start_dialogue(lines)
	dialogue_overlay.dialogue_finished.connect(func():
		player.is_locked = false
		_is_repairing = false
		# Show grand celebratory banner
		if ship_repair_banner:
			ship_repair_banner.visible = true
			ship_repair_banner.modulate.a = 0.0
			var b_tween := create_tween()
			b_tween.tween_property(ship_repair_banner, "modulate:a", 1.0, 0.8)
			b_tween.tween_interval(5.0)
			b_tween.tween_property(ship_repair_banner, "modulate:a", 0.0, 1.0)
			await b_tween.finished
			ship_repair_banner.visible = false
	, CONNECT_ONE_SHOT)

func _update_ship_checklist() -> void:
	if not obj_checklist:
		return
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs:
		return
		
	if gs.ship_repaired:
		obj_checklist.text = "ODYSSEY-IV STATUS: FULLY REPAIRED [PROPULSION READY]"
		obj_checklist.modulate = Color(0.3, 1.0, 0.5, 1.0)
		return
		
	var reg := "✔" if gs.has_component("plasma_regulator") else "✖"
	var nav := "✔" if gs.has_component("navigation_core") else "✖"
	var cell := "✔" if gs.has_component("quantum_power_cell") else "✖"
	
	obj_checklist.text = "SHIP REPAIR: [%s] Plasma Reg.  [%s] Nav Core  [%s] Quantum Cell  [M: Map]" % [reg, nav, cell]
	if gs.all_components_collected():
		obj_checklist.modulate = Color(0.4, 1.0, 0.6, 1.0)
	else:
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
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if settings_modal.visible:
			settings_modal.close_settings()
		elif region_map and region_map.visible:
			region_map.close_map()
		elif not dialogue_overlay.visible and not _is_repairing:
			toggle_pause()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_M:
		var gs: Node = get_node_or_null("/root/GameState")
		if gs and gs.map_unlocked and not dialogue_overlay.visible and not _is_repairing:
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
