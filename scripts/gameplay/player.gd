extends CharacterBody2D

# Protagonist Rix controller for Echoes of Eternity

signal scanned_anomaly(anomaly_name: String, anomaly_data: String)

@export var walk_speed: float = 175.0
@export var run_speed: float = 290.0

@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var dust_particles: CPUParticles2D = %DustParticles
@onready var interact_label: Label = %InteractPrompt

var stamina: float = 100.0
var max_stamina: float = 100.0
var oxygen: float = 100.0
var suit_integrity: float = 88.0

var _current_interactable: Area2D = null
var _facing: String = "down" # "down", "side", "up"
var is_locked: bool = false # Lock movement during scripted cutscene/recovery

func _ready() -> void:
	if interact_label:
		interact_label.visible = false
	if anim_sprite:
		anim_sprite.play("idle_down")

func _physics_process(delta: float) -> void:
	if is_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Also allow WASD explicitly
	if input_vec == Vector2.ZERO:
		var raw_x: float = 0.0
		var raw_y: float = 0.0
		if Input.is_key_pressed(KEY_A): raw_x -= 1.0
		if Input.is_key_pressed(KEY_D): raw_x += 1.0
		if Input.is_key_pressed(KEY_W): raw_y -= 1.0
		if Input.is_key_pressed(KEY_S): raw_y += 1.0
		input_vec = Vector2(raw_x, raw_y)
		if input_vec.length() > 1.0:
			input_vec = input_vec.normalized()
			
	var is_running := Input.is_key_pressed(KEY_SHIFT) and stamina > 10.0 and input_vec != Vector2.ZERO
	var current_speed := run_speed if is_running else walk_speed
	
	if is_running:
		stamina = maxf(0.0, stamina - delta * 22.0)
	else:
		stamina = minf(max_stamina, stamina + delta * 16.0)
		
	# Subtle oxygen consumption
	oxygen = maxf(12.0, oxygen - delta * 0.07)
	
	velocity = input_vec * current_speed
	move_and_slide()
	
	# Determine facing direction
	if input_vec != Vector2.ZERO:
		if abs(input_vec.x) > abs(input_vec.y) * 0.7:
			_facing = "side"
			anim_sprite.flip_h = (input_vec.x < 0.0)
		elif input_vec.y < 0.0:
			_facing = "up"
			anim_sprite.flip_h = false
		else:
			_facing = "down"
			anim_sprite.flip_h = false
			
		var anim_action := "run_" if is_running else "walk_"
		var target_anim := anim_action + _facing
		if anim_sprite.animation != target_anim:
			anim_sprite.play(target_anim)
			
		if dust_particles:
			dust_particles.emitting = true
	else:
		var target_idle := "idle_" + _facing
		if anim_sprite.animation != target_idle and not anim_sprite.animation.begins_with("interact"):
			anim_sprite.play(target_idle)
		if dust_particles:
			dust_particles.emitting = false

func _unhandled_input(event: InputEvent) -> void:
	if is_locked:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if _current_interactable and _current_interactable.has_method("interact"):
				anim_sprite.play("interact_down")
				_current_interactable.interact(self)

func set_nearby_interactable(area: Area2D, prompt_text: String = "[E] SCAN ANOMALY") -> void:
	_current_interactable = area
	if interact_label:
		if area:
			interact_label.text = prompt_text
			interact_label.visible = true
		else:
			interact_label.visible = false
