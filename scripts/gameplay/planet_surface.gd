extends Node2D

# Planet Surface & Crash Site Exploration for Echoes of Eternity

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera2D

# HUD elements
@onready var hud_avatar: TextureRect = %Avatar
@onready var health_bar: ProgressBar = %HealthBar
@onready var oxygen_bar: ProgressBar = %OxygenBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var coords_label: Label = %CoordsLabel
@onready var scan_popup: PanelContainer = %ScanPopup
@onready var scan_title: Label = %ScanTitle
@onready var scan_desc: Label = %ScanDesc

# Intro Scripted Recovery Sequence UI
@onready var recovery_dialog: PanelContainer = %RecoveryDialog
@onready var recovery_text: Label = %RecoveryText
@onready var survival_banner: VBoxContainer = %SurvivalBanner
@onready var banner_title: Label = %BannerTitle
@onready var banner_status: Label = %BannerStatus

# Pause overlay & Modals
@onready var pause_overlay: Control = %PauseOverlay
@onready var btn_resume: Button = %BtnResume
@onready var btn_pause_settings: Button = %BtnPauseSettings
@onready var btn_pause_menu: Button = %BtnPauseMenu
@onready var settings_modal: Control = %SettingsModal
@onready var fade_rect: ColorRect = %FadeRect

# Audio
@onready var ambient_wind: AudioStreamPlayer = %AmbientWind

var _is_paused: bool = false
var _scan_timer: float = 0.0
var _is_scripted_intro_running: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	pause_overlay.visible = false
	scan_popup.visible = false
	settings_modal.visible = false
	if recovery_dialog:
		recovery_dialog.visible = false
	if survival_banner:
		survival_banner.visible = false
		
	_connect_signals()
	_start_crash_recovery_sequence()

func _connect_signals() -> void:
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_pause_settings.pressed.connect(_on_settings_pressed)
	btn_pause_menu.pressed.connect(_on_main_menu_pressed)
	
	for btn in [btn_resume, btn_pause_settings, btn_pause_menu]:
		btn.mouse_entered.connect(_on_btn_hover)
		btn.focus_entered.connect(_on_btn_hover)
		
	settings_modal.closed.connect(_on_settings_closed)

# Section 8: Rix emerges from wreckage sequence
func _start_crash_recovery_sequence() -> void:
	# Lock player movement during sequence
	player.is_locked = true
	_is_scripted_intro_running = true
	
	# Start ambient desert wind
	if ambient_wind and ambient_wind.stream:
		ambient_wind.play()
		ambient_wind.volume_db = -8.0
	
	# Initial fade from black
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	
	# Put Rix in prone recovery pose initially
	var anim_sprite: AnimatedSprite2D = player.get_node_or_null("%AnimatedSprite2D")
	if anim_sprite:
		if anim_sprite.sprite_frames.has_animation("crash_recovery"):
			anim_sprite.play("crash_recovery")
			anim_sprite.frame = 0
			anim_sprite.pause()
		else:
			anim_sprite.play("crouch_down")
	
	# Fade screen in from black
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.4).set_ease(Tween.EASE_OUT)
	await fade_tween.finished
	fade_rect.visible = false
	
	# Step 1: Stirring & getting up animation
	await get_tree().create_timer(0.6).timeout
	if anim_sprite:
		if anim_sprite.sprite_frames.has_animation("crash_recovery"):
			# Step through recovery frames smoothly
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
		
		# Give player time to read
		await get_tree().create_timer(2.2).timeout
		
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
		banner_tween.tween_interval(2.2)
		banner_tween.tween_property(survival_banner, "modulate:a", 0.0, 0.8)
		await banner_tween.finished
		survival_banner.visible = false
	
	# Step 4: Unlock player control
	player.is_locked = false
	_is_scripted_intro_running = false

func _process(delta: float) -> void:
	if not _is_paused:
		# Update HUD bars from player state
		health_bar.value = player.suit_integrity
		oxygen_bar.value = player.oxygen
		stamina_bar.value = player.stamina
		
		# Telemetry coords update based on position
		var lat := 42.109 + (player.position.y * 0.001)
		var lon := -88.402 + (player.position.x * 0.001)
		coords_label.text = "SECTOR ZERO // LAT: %0.3f  LON: %0.3f" % [lat, lon]
		
		# Smooth camera follow
		camera.position = camera.position.lerp(player.position, delta * 6.0)
		
		if scan_popup.visible:
			_scan_timer -= delta
			if _scan_timer <= 0.0:
				_hide_scan_popup()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if settings_modal.visible:
			settings_modal.close_settings()
		else:
			toggle_pause()

func toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	pause_overlay.visible = _is_paused
	if _is_paused:
		btn_resume.grab_focus()
		var am: Node = get_node_or_null("/root/AudioManager")
		if am:
			am.play_click()

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_settings_pressed() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
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
	if am:
		am.play_hover()

func show_scan_result(title: String, desc: String, duration: float = 5.0) -> void:
	scan_title.text = title
	scan_desc.text = desc
	scan_popup.visible = true
	scan_popup.modulate.a = 0.0
	_scan_timer = duration
	
	var tween := create_tween()
	tween.tween_property(scan_popup, "modulate:a", 1.0, 0.3)
	
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()

func _hide_scan_popup() -> void:
	var tween := create_tween()
	tween.tween_property(scan_popup, "modulate:a", 0.0, 0.3)
	await tween.finished
	scan_popup.visible = false
