extends Control

@onready var bg_texture: TextureRect = %Background
@onready var ship_container: Node2D = %ShipContainer
@onready var ship_base: Sprite2D = %ShipBase
@onready var ship_thrust: Sprite2D = %ShipThrust
@onready var thruster_particles: CPUParticles2D = %ThrusterParticles
@onready var starfield_particles: CPUParticles2D = %StarfieldParticles

@onready var btn_start: Button = %BtnStart
@onready var btn_settings: Button = %BtnSettings
@onready var btn_exit: Button = %BtnExit

@onready var settings_menu: Control = %SettingsMenu
@onready var fade_rect: ColorRect = %FadeRect

var _time_passed: float = 0.0
var _initial_ship_pos: Vector2
var _target_mouse_offset: Vector2 = Vector2.ZERO
var _current_mouse_offset: Vector2 = Vector2.ZERO
var _is_transitioning: bool = false

func _ready() -> void:
	_initial_ship_pos = ship_container.position
	_connect_buttons()
	_setup_focus()
	_start_music()
	
	# In the starting menu layout, use spaceship.png only without overlapping thrusts
	ship_thrust.visible = false
	ship_thrust.modulate.a = 0.0
	thruster_particles.emitting = false
	
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	await tween.finished
	fade_rect.visible = false

func _connect_buttons() -> void:
	btn_start.pressed.connect(_on_start_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	for btn in [btn_start, btn_settings, btn_exit]:
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.focus_entered.connect(_on_button_focus.bind(btn))
	
	settings_menu.closed.connect(_on_settings_closed)

func _setup_focus() -> void:
	btn_start.grab_focus()

func _start_music() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and am.ambient_music:
		am.play_music(am.ambient_music, 1.5)

func _process(delta: float) -> void:
	_time_passed += delta
	
	# Gentle zero-gravity drift for the spaceship
	var float_x := sin(_time_passed * 0.7) * 16.0
	var float_y := cos(_time_passed * 0.9) * 22.0
	var float_rot := sin(_time_passed * 0.5) * 0.02
	
	# Smooth mouse parallax
	_current_mouse_offset = _current_mouse_offset.lerp(_target_mouse_offset, delta * 3.0)
	
	if not _is_transitioning:
		ship_container.position = _initial_ship_pos + Vector2(float_x, float_y) + _current_mouse_offset * 15.0
		ship_container.rotation = float_rot
	
	# Background subtle parallax drift
	bg_texture.position = _current_mouse_offset * -10.0
	
	# Thrusters only animate when transitioning after START GAME
	if _is_transitioning and ship_thrust.visible:
		var base_pulse := 0.85 + 0.15 * sin(_time_passed * 16.0)
		var noise_flicker := randf_range(-0.05, 0.05)
		ship_thrust.modulate.a = clampf(base_pulse + noise_flicker, 0.7, 1.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var vp_size := get_viewport_rect().size
		if vp_size.x > 0.0 and vp_size.y > 0.0:
			var norm_x: float = (event.position.x / vp_size.x) - 0.5
			var norm_y: float = (event.position.y / vp_size.y) - 0.5
			_target_mouse_offset = Vector2(norm_x, norm_y)

func _on_button_hover(btn: Button) -> void:
	if _is_transitioning or settings_menu.visible:
		return
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_hover()

func _on_button_focus(btn: Button) -> void:
	if _is_transitioning or settings_menu.visible:
		return
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_hover()

func _on_start_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
		am.stop_music(0.8)
		if ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
			am.play_sfx(load("res://assets/audio/engine_thrust.wav"), 0.0, 1.0)
	
	# Enable thrust image and particles on Start Game
	ship_thrust.visible = true
	ship_thrust.modulate.a = 0.0
	thruster_particles.emitting = true
	
	# Enhanced cinematic launch animation:
	# Phase 1: Thruster ignition burst & slight recoil
	var launch_tween := create_tween()
	launch_tween.tween_property(ship_thrust, "modulate:a", 1.0, 0.15)
	launch_tween.parallel().tween_property(ship_container, "position:x", ship_container.position.x - 28.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	launch_tween.parallel().tween_property(ship_container, "rotation", ship_container.rotation - 0.03, 0.18)
	
	# Phase 2: High-speed surge across the screen into warp
	launch_tween.chain().tween_property(ship_container, "position:x", ship_container.position.x + 1200.0, 1.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	launch_tween.parallel().tween_property(ship_container, "scale", Vector2(1.1, 1.1), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Fade screen as the ship streaks into hyperspace
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 1.0, 0.7).set_delay(0.35)
	await fade_tween.finished
	
	get_tree().change_scene_to_file("res://scenes/cutscenes/intro_cutscene.tscn")

func _on_settings_pressed() -> void:
	if _is_transitioning:
		return
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
	settings_menu.open_settings()

func _on_settings_closed() -> void:
	btn_settings.grab_focus()

func _on_exit_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
		am.stop_music(0.5)
	
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 1.0, 0.4)
	await fade_tween.finished
	get_tree().quit()
