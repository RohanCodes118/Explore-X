extends Area2D

# Spaceship Component Collectible Item with Proximity Glow Reveal

@export var component_id: String = "plasma_regulator" # "plasma_regulator", "navigation_core", "quantum_power_cell"
@export var component_name: String = "Plasma Regulator"
@export var prompt_message: String = "[E] RECOVER PLASMA REGULATOR"

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var aura_particles: CPUParticles2D = get_node_or_null("AuraParticles")
@onready var spark_particles: CPUParticles2D = get_node_or_null("SparkParticles")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var _time_passed: float = 0.0
var _initial_y: float = 0.0
var _is_collected: bool = false
var _cached_player: Node2D = null

func _ready() -> void:
	_initial_y = sprite.position.y if sprite else 0.0
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Check if already collected in persistent state
	var gs: Node = get_node_or_null("/root/GameState")
	if gs and gs.has_component(component_id):
		_is_collected = true
		visible = false
		monitoring = false
		monitorable = false
		set_process(false)

func _process(delta: float) -> void:
	if _is_collected:
		return
	_time_passed += delta
	if sprite:
		# Gentle levitation & glowing pulse
		sprite.position.y = _initial_y + sin(_time_passed * 2.5) * 8.0
		sprite.rotation = sin(_time_passed * 1.2) * 0.08
		
	# Proximity-based glow reveal: naturally reveals its brilliance as Rix approaches
	if _cached_player == null:
		var scene: Node = get_tree().current_scene
		if scene:
			_cached_player = scene.find_child("Player", true, false)
			
	if _cached_player and is_instance_valid(_cached_player):
		var dist: float = global_position.distance_to(_cached_player.global_position)
		var glow_factor: float = clampf(1.0 - (dist - 90.0) / 360.0, 0.25, 1.0)
		if sprite:
			sprite.modulate = Color(1.0, 1.0, 1.0, glow_factor)
		if aura_particles:
			aura_particles.emitting = (dist < 420.0)
			aura_particles.speed_scale = lerpf(0.5, 1.4, glow_factor)

func _on_body_entered(body: Node2D) -> void:
	if _is_collected:
		return
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self, prompt_message)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(null)

func interact(player: CharacterBody2D) -> void:
	if _is_collected:
		return
	_is_collected = true
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.collect_component(component_id)
		
	# Play collection effect
	if spark_particles:
		spark_particles.amount = 40
		spark_particles.restart()
		spark_particles.emitting = true
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
		
	# Inform scene HUD
	var scene: Node = get_tree().current_scene
	if scene and scene.has_method("show_component_obtained_banner"):
		scene.show_component_obtained_banner(component_name)
		
	# Shrink and disappear
	var tween := create_tween()
	if sprite:
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await tween.finished
	visible = false
	monitoring = false
