extends Node2D

# Upgraded Cinematic Intro for Echoes of Eternity: Rix's Journey & Desert Crash Landing

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var bg_texture: TextureRect = %Background
@onready var intermediate_planet: Sprite2D = %IntermediatePlanet
@onready var bg_camera: Camera2D = %Camera2D

# Spaceship Nodes
@onready var ship_node: Node2D = %ShipNode
@onready var ship_base: Sprite2D = %ShipBase
@onready var ship_thrust: Sprite2D = %ShipThrust
@onready var thrust_particles: CPUParticles2D = %ThrustParticles
@onready var warp_particles: CPUParticles2D = %WarpParticles
@onready var star_particles: CPUParticles2D = %StarParticles
@onready var reentry_particles: CPUParticles2D = %ReentryParticles
@onready var debris_particles: CPUParticles2D = %DebrisParticles

# Crash Aftermath
@onready var crash_aftermath: Node2D = %CrashAftermath

# UI Elements
@onready var cinematic_hud: Control = %CinematicHUD
@onready var narrative_box: PanelContainer = %NarrativeBox
@onready var narrative_label: Label = %NarrativeLabel
@onready var dialog_panel: PanelContainer = %DialogPanel
@onready var speaker_label: Label = %SpeakerLabel
@onready var dialog_text: Label = %DialogText
@onready var portrait_img: TextureRect = %Portrait
@onready var rix_holo: AnimatedSprite2D = %RixHolo
@onready var warning_panel: PanelContainer = %WarningPanel
@onready var warning_label: Label = %WarningLabel
@onready var warning_tag: Label = %WarningTag
@onready var emergency_flasher: ColorRect = %EmergencyFlasher
@onready var glitch_rect: ColorRect = %GlitchRect
@onready var skip_prompt: Label = %SkipPrompt
@onready var fade_rect: ColorRect = %FadeRect

# Audio
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var engine_sfx: AudioStreamPlayer = $EngineSFX
@onready var alarm_sfx: AudioStreamPlayer = $AlarmSFX
@onready var glitch_sfx: AudioStreamPlayer = $GlitchSFX
@onready var reentry_sfx: AudioStreamPlayer = $ReentrySFX
@onready var impact_sfx: AudioStreamPlayer = $ImpactSFX
@onready var wind_sfx: AudioStreamPlayer = $WindSFX

var _is_skipped: bool = false
var _camera_shake_intensity: float = 0.0
var _rng := RandomNumberGenerator.new()
var _typewriter_tween: Tween = null

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/planet_surface.tscn"

func _ready() -> void:
	_rng.randomize()
	_load_audio()
	_fit_crashed_ship_to_screen()

	# Initial states
	if ship_thrust:
		ship_thrust.visible = true
		ship_thrust.modulate.a = 0.0
	if thrust_particles:
		thrust_particles.emitting = false
	if warp_particles:
		warp_particles.emitting = false
	if reentry_particles:
		reentry_particles.emitting = false
	if debris_particles:
		debris_particles.emitting = false
	if crash_aftermath:
		crash_aftermath.modulate.a = 0.0
	if intermediate_planet:
		intermediate_planet.modulate.a = 0.0
	if rix_holo:
		rix_holo.play("idle_side")

	get_viewport().size_changed.connect(_fit_crashed_ship_to_screen)

	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play("intro_cinematic")

func _fit_crashed_ship_to_screen() -> void:
	# Cover-fit the crashed-ship image to 1920x1080 (16:9) without stretching
	var bg: Sprite2D = get_node_or_null("CrashAftermath/AftermathSprite")
	if bg == null or bg.texture == null:
		return
	var tex_size: Vector2 = Vector2(bg.texture.get_width(), bg.texture.get_height())
	if tex_size.x == 0 or tex_size.y == 0:
		return
	var viewport_size: Vector2 = Vector2(get_viewport_rect().size)
	if viewport_size.x == 0 or viewport_size.y == 0:
		viewport_size = Vector2(1920, 1080)
	var scale_factor: float = maxf(viewport_size.x / tex_size.x, viewport_size.y / tex_size.y)
	bg.scale = Vector2(scale_factor, scale_factor)
	bg.centered = true
	bg.position = viewport_size * 0.5
	# Move CrashAftermath origin to 0,0 so child is viewport-centered
	var aftermath: Node2D = get_node_or_null("CrashAftermath")
	if aftermath:
		aftermath.position = Vector2.ZERO

	# Ensure space background covers as well (TextureRect stretch_mode 5 handles it, just ensure it fills)
	var bg_rect: TextureRect = get_node_or_null("Background")
	if bg_rect:
		bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_rect.offset_left = 0
		bg_rect.offset_top = 0
		bg_rect.offset_right = 0
		bg_rect.offset_bottom = 0
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

func _load_audio() -> void:
	if ResourceLoader.exists("res://assets/audio/sci_fi_ambient.wav"):
		music_player.stream = load("res://assets/audio/sci_fi_ambient.wav")
	if ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
		engine_sfx.stream = load("res://assets/audio/engine_thrust.wav")
	if ResourceLoader.exists("res://assets/audio/warning_alarm.wav"):
		alarm_sfx.stream = load("res://assets/audio/warning_alarm.wav")
	if ResourceLoader.exists("res://assets/audio/glitch.wav"):
		glitch_sfx.stream = load("res://assets/audio/glitch.wav")
	if ResourceLoader.exists("res://assets/audio/reentry.wav"):
		reentry_sfx.stream = load("res://assets/audio/reentry.wav")
	if ResourceLoader.exists("res://assets/audio/impact.wav"):
		impact_sfx.stream = load("res://assets/audio/impact.wav")
	if ResourceLoader.exists("res://assets/audio/desert_wind.wav"):
		wind_sfx.stream = load("res://assets/audio/desert_wind.wav")

func _process(delta: float) -> void:
	if _camera_shake_intensity > 0.0:
		bg_camera.offset = Vector2(
			_rng.randf_range(-_camera_shake_intensity, _camera_shake_intensity),
			_rng.randf_range(-_camera_shake_intensity, _camera_shake_intensity)
		)
		_camera_shake_intensity = lerpf(_camera_shake_intensity, 0.0, delta * 4.5)
	else:
		bg_camera.offset = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if _is_skipped:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		get_viewport().set_input_as_handled()
		skip_cinematic()

func set_camera_shake(intensity: float) -> void:
	_camera_shake_intensity = intensity

# Typewriter text reveal effect for dialogue
func reveal_dialog(full_text: String, duration: float = 1.2) -> void:
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	if dialog_text:
		dialog_text.text = full_text
		dialog_text.visible_ratio = 0.0
		_typewriter_tween = create_tween()
		_typewriter_tween.tween_property(dialog_text, "visible_ratio", 1.0, duration).set_ease(Tween.EASE_OUT)
	if rix_holo:
		rix_holo.play("interact_down")
		# Return to idle_side after short interaction
		get_tree().create_timer(1.0).timeout.connect(func():
			if rix_holo:
				rix_holo.play("idle_side")
		)

# Realistic engine sputter before shutdown
func sputter_engine() -> void:
	var sputter_tween := create_tween()
	# Rapid flickering drop
	sputter_tween.tween_property(ship_thrust, "modulate:a", 0.0, 0.08)
	sputter_tween.tween_property(ship_thrust, "modulate:a", 0.7, 0.06)
	sputter_tween.tween_property(ship_thrust, "modulate:a", 0.0, 0.09)
	sputter_tween.tween_property(ship_thrust, "modulate:a", 0.4, 0.06)
	sputter_tween.tween_property(ship_thrust, "modulate:a", 0.0, 0.12)
	await sputter_tween.finished
	ship_thrust.modulate.a = 0.0
	thrust_particles.emitting = false

func play_wind_audio() -> void:
	if wind_sfx and wind_sfx.stream:
		wind_sfx.volume_db = -10.0
		wind_sfx.play()
		var tween := create_tween()
		tween.tween_property(wind_sfx, "volume_db", 0.0, 2.0)

func skip_cinematic() -> void:
	if _is_skipped or _is_transitioning:
		return
	_is_skipped = true
	anim_player.stop()
	# Cancel any shake
	_camera_shake_intensity = 0.0
	if bg_camera:
		bg_camera.offset = Vector2.ZERO

	# Stop all audio players smoothly
	var tween := create_tween().set_parallel(true)
	for p in [music_player, engine_sfx, alarm_sfx, reentry_sfx, wind_sfx]:
		if p and p.playing:
			tween.tween_property(p, "volume_db", -40.0, 0.35)

	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 1.0, 0.45)
	await fade_tween.finished

	_load_gameplay()

var _is_transitioning: bool = false

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "intro_cinematic" and not _is_skipped:
		_load_gameplay()

func _load_gameplay() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	# Smooth crash -> gameplay crossfade: hold white flash a beat, then fade through black
	# Impact flash already at 39.1-39.6; we add a proper crossfade dissolve
	var t := create_tween()
	# Ensure aftermath is fully visible during hold
	var aftermath: Node2D = get_node_or_null("CrashAftermath")
	if aftermath:
		t.tween_property(aftermath, "modulate:a", 1.0, 0.2)
	t.tween_interval(0.35)
	# Flash white via EmergencyFlasher then dip to black
	var flasher: ColorRect = get_node_or_null("CanvasLayer/EmergencyFlasher")
	if flasher:
		t.tween_property(flasher, "color", Color(1, 0.97, 0.92, 1.0), 0.12)
		t.tween_property(flasher, "color", Color(1, 0.97, 0.92, 1.0), 0.18)
	t.parallel().tween_property(fade_rect, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await t.finished
	# Small hold on black so the scene swap doesn't pop
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file(GAMEPLAY_SCENE_PATH)
