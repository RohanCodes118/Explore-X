extends Node2D

# Final Cinematic for Echoes of Eternity: Rix's Farewell & Launch into the Unknown

@onready var bg_planet: TextureRect = %BgPlanet
@onready var bg_space: TextureRect = %BgSpace
@onready var camera: Camera2D = %Camera2D

# Actors & Props
@onready var ship_node: Node2D = %ShipNode
@onready var ship_sprite: Sprite2D = %ShipSprite
@onready var ship_thrust_sprite: Sprite2D = %ShipThrustSprite
@onready var thruster_particles: CPUParticles2D = %ThrusterParticles
@onready var ground_dust_particles: CPUParticles2D = %GroundDustParticles
@onready var star_particles: CPUParticles2D = %StarParticles
@onready var rix_actor: AnimatedSprite2D = %RixActor
@onready var grandfather_actor: AnimatedSprite2D = %GrandfatherActor

# Cinematic UI
@onready var narrative_banner: PanelContainer = %NarrativeBanner
@onready var narrative_text: Label = %NarrativeText
@onready var dialog_panel: PanelContainer = %DialogPanel
@onready var speaker_name: Label = %SpeakerName
@onready var dialog_text: Label = %DialogText
@onready var portrait_rect: TextureRect = %PortraitRect
@onready var skip_label: Label = %SkipLabel
@onready var fade_rect: ColorRect = %FadeRect
@onready var discovery_panel: PanelContainer = %DiscoveryPanel
@onready var discovery_title: Label = %DiscoveryTitle
@onready var discovery_sub: Label = %DiscoverySub

# Audio Players
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var engine_player: AudioStreamPlayer = $EnginePlayer
@onready var ambient_player: AudioStreamPlayer = $AmbientPlayer

var _is_skipped: bool = false
var _camera_shake: float = 0.0
var _current_dialog_idx: int = 0
var _dialog_active: bool = false
var _dialog_script: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()

const CREDITS_SCENE_PATH := "res://scenes/ui/credits.tscn"

func _ready() -> void:
	_rng.randomize()
	_setup_audio()
	
	# Initial visibility
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	bg_planet.visible = true
	bg_space.visible = false
	narrative_banner.visible = false
	dialog_panel.visible = false
	discovery_panel.visible = false
	ship_sprite.visible = true
	ship_thrust_sprite.visible = false
	ship_thrust_sprite.modulate = Color(1.0, 0.35, 0.15, 0.0)
	thruster_particles.emitting = false
	ground_dust_particles.emitting = false
	star_particles.emitting = false
	
	# Actor setups
	if rix_actor and rix_actor.sprite_frames and rix_actor.sprite_frames.has_animation("idle_right"):
		rix_actor.play("idle_right")
	if grandfather_actor and grandfather_actor.sprite_frames and grandfather_actor.sprite_frames.has_animation("idle"):
		grandfather_actor.play("idle")
		
	# Start Cinematic Sequence
	_start_cinematic()

func _setup_audio() -> void:
	if ResourceLoader.exists("res://assets/audio/sci_fi_ambient.wav"):
		ambient_player.stream = load("res://assets/audio/sci_fi_ambient.wav")
		ambient_player.volume_db = -6.0
		ambient_player.play()
	if ResourceLoader.exists("res://assets/audio/engine_thrust.wav"):
		engine_player.stream = load("res://assets/audio/engine_thrust.wav")
		engine_player.volume_db = -40.0

func _process(delta: float) -> void:
	if _camera_shake > 0.0:
		camera.offset = Vector2(
			_rng.randf_range(-_camera_shake, _camera_shake),
			_rng.randf_range(-_camera_shake, _camera_shake)
		)
		_camera_shake = maxf(0.0, _camera_shake - delta * 12.0)
	else:
		camera.offset = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if _is_skipped:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE)):
		skip_to_credits()
	elif _dialog_active and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or (event is InputEventKey and event.pressed and event.keycode == KEY_E)):
		_advance_dialogue()

func _start_cinematic() -> void:
	# Fade in Scene A: Ship Restoration at Crash Site
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2)
	await tween.finished
	
	if _is_skipped: return
	
	# Show Narrative Banner
	_show_narrative("ODYSSEY-IV RESTORATION CONFIRMED // ALL PRIMARY SYSTEMS NOMINAL")
	await get_tree().create_timer(2.6).timeout
	if _is_skipped: return
	
	# Camera subtle pan toward Rix and Grandfather
	var cam_tween := create_tween()
	cam_tween.tween_property(camera, "position", Vector2(760, 480), 2.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await cam_tween.finished
	if _is_skipped: return
	
	# Begin Scene B: Farewell Dialogue
	_start_farewell_dialogue()

func _show_narrative(text: String) -> void:
	narrative_text.text = text
	narrative_banner.visible = true
	narrative_banner.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(narrative_banner, "modulate:a", 1.0, 0.4)
	t.tween_interval(2.8)
	t.tween_property(narrative_banner, "modulate:a", 0.0, 0.5)
	await t.finished
	narrative_banner.visible = false

func _start_farewell_dialogue() -> void:
	_dialog_script = [
		{
			"speaker": "GRANDFATHER",
			"portrait": "res://assets/images/characters/grandfather/face_calm.png",
			"text": "“You did it, Rix. Against all odds on this forgotten world, the Odyssey-IV breathes again. You've earned your wings—and that blade.”"
		},
		{
			"speaker": "RIX // EXPLORER",
			"portrait": "res://assets/images/rix_portrait.png",
			"text": "“Thank you, Grandpa. For the sword, for guiding me through the sectors, and for believing in me when the ship first went down.”"
		},
		{
			"speaker": "GRANDFATHER",
			"portrait": "res://assets/images/characters/grandfather/face_thoughtful.png",
			"text": "“The universe is vast, my boy, and teeming with ancient mysteries. Take what you've learned here. Keep your blade sharp, your sensors keen, and your heart steady.”"
		},
		{
			"speaker": "RIX // EXPLORER",
			"portrait": "res://assets/images/rix_portrait_focused.png",
			"text": "“I won't forget a single lesson. Will you be safe here alone at the sanctuary?”"
		},
		{
			"speaker": "GRANDFATHER",
			"portrait": "res://assets/images/characters/grandfather/face_determined.png",
			"text": "“This sanctuary has kept me safe for decades. Now, your destiny lies far beyond Kepler-884b. Go—the uncharted stars are calling your name.”"
		},
		{
			"speaker": "RIX // EXPLORER",
			"portrait": "res://assets/images/rix_portrait.png",
			"text": "“Farewell, Grandfather. I'll make you proud out there.”"
		}
	]
	_current_dialog_idx = 0
	_dialog_active = true
	dialog_panel.visible = true
	_render_dialogue_line()

func _render_dialogue_line() -> void:
	if _current_dialog_idx >= _dialog_script.size():
		_dialog_active = false
		dialog_panel.visible = false
		_start_boarding_and_launch()
		return
		
	var entry: Dictionary = _dialog_script[_current_dialog_idx]
	speaker_name.text = entry["speaker"]
	dialog_text.text = entry["text"]
	if ResourceLoader.exists(entry["portrait"]):
		portrait_rect.texture = load(entry["portrait"])
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()

func _advance_dialogue() -> void:
	_current_dialog_idx += 1
	_render_dialogue_line()

func _start_boarding_and_launch() -> void:
	if _is_skipped: return
	
	# Rix turns and walks toward the Odyssey-IV
	if rix_actor:
		rix_actor.flip_h = true
		if rix_actor.sprite_frames and rix_actor.sprite_frames.has_animation("walk_left"):
			rix_actor.play("walk_left")
		elif rix_actor.sprite_frames and rix_actor.sprite_frames.has_animation("walk_up"):
			rix_actor.play("walk_up")
	
	var walk_tween := create_tween()
	walk_tween.tween_property(rix_actor, "position", Vector2(ship_node.position.x + 60, ship_node.position.y + 40), 1.8)
	await walk_tween.finished
	if _is_skipped: return
	
	# Rix boards the ship (fades out)
	var board_tween := create_tween()
	board_tween.tween_property(rix_actor, "modulate:a", 0.0, 0.45)
	await board_tween.finished
	if _is_skipped: return
	
	# Scene C: Thruster Ignition & Liftoff
	_camera_shake = 6.0
	ship_thrust_sprite.visible = true
	ship_thrust_sprite.modulate.a = 0.0
	thruster_particles.emitting = true
	ground_dust_particles.emitting = true
	
	# Fade in engine audio
	if engine_player:
		engine_player.volume_db = -4.0
		engine_player.play()
		
	var ignite_tween := create_tween()
	ignite_tween.tween_property(ship_thrust_sprite, "modulate:a", 1.0, 0.5)
	await ignite_tween.finished
	if _is_skipped: return
	
	# Lift off with rising camera shake
	_camera_shake = 14.0
	var liftoff_tween := create_tween()
	liftoff_tween.set_parallel(true)
	liftoff_tween.tween_property(ship_node, "position:y", ship_node.position.y - 120.0, 1.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	liftoff_tween.tween_property(ship_node, "scale", Vector2(1.05, 1.05), 1.4)
	await liftoff_tween.finished
	if _is_skipped: return
	
	# Rocket acceleration into the stratosphere
	_camera_shake = 22.0
	var launch_tween := create_tween()
	launch_tween.set_parallel(true)
	launch_tween.tween_property(ship_node, "position:y", ship_node.position.y - 1400.0, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	launch_tween.tween_property(ship_node, "scale", Vector2(0.4, 0.4), 1.5)
	launch_tween.chain().tween_property(fade_rect, "modulate:a", 1.0, 0.8)
	await launch_tween.finished
	if _is_skipped: return
	
	# Scene D: Space Journey & Unknown World Detected
	_start_space_encounter()

func _start_space_encounter() -> void:
	if _is_skipped: return
	
	# Switch environment from surface to deep space
	bg_planet.visible = false
	ground_dust_particles.emitting = false
	rix_actor.visible = false
	grandfather_actor.visible = false
	
	bg_space.visible = true
	star_particles.emitting = true
	
	camera.position = Vector2(960, 540)
	ship_node.position = Vector2(150, 540)
	ship_node.scale = Vector2(0.55, 0.55)
	ship_node.rotation = 0.0
	ship_thrust_sprite.visible = true
	ship_thrust_sprite.modulate = Color(1.0, 0.35, 0.15, 0.85)
	thruster_particles.emitting = true
	
	# Soft ambient space audio
	if engine_player:
		var et := create_tween()
		et.tween_property(engine_player, "volume_db", -16.0, 1.0)
		
	# Fade in space scene
	var in_tween := create_tween()
	in_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2)
	await in_tween.finished
	if _is_skipped: return
	
	# Ship cruises gracefully across the cosmos into the uncharted sector
	var cruise_tween := create_tween()
	cruise_tween.tween_property(ship_node, "position", Vector2(1060, 520), 4.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await cruise_tween.finished
	if _is_skipped: return
	
	# Display Discovery Title Card
	discovery_title.text = "ECHOES OF ETERNITY"
	discovery_sub.text = "THE JOURNEY HAS JUST BEGUN"
	discovery_panel.visible = true
	discovery_panel.modulate.a = 0.0
	
	var title_tween := create_tween()
	title_tween.tween_property(discovery_panel, "modulate:a", 1.0, 1.0)
	title_tween.tween_interval(3.8)
	title_tween.tween_property(fade_rect, "modulate:a", 1.0, 1.4)
	await title_tween.finished
	
	_finish_to_credits()

func skip_to_credits() -> void:
	if _is_skipped:
		return
	_is_skipped = true
	
	# Smoothly fade audio
	var tween := create_tween().set_parallel(true)
	for p in [music_player, engine_player, ambient_player]:
		if p and p.playing:
			tween.tween_property(p, "volume_db", -40.0, 0.3)
			
	fade_rect.visible = true
	var ft := create_tween()
	ft.tween_property(fade_rect, "modulate:a", 1.0, 0.35)
	await ft.finished
	_finish_to_credits()

var _is_transitioning_to_credits: bool = false

func _finish_to_credits() -> void:
	if _is_transitioning_to_credits:
		return
	_is_transitioning_to_credits = true
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.complete_game()
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
