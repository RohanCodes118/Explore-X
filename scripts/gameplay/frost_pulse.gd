extends Area2D

# Cryo Sentinel Retaliation Projectile (Frost Pulse)

@export var speed: float = 260.0
@export var damage: float = 2.0 # Balanced low-powered retaliation: exactly 2 HP per hit
@export var max_range: float = 550.0

var direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var particles: CPUParticles2D = get_node_or_null("TrailParticles")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if particles:
		particles.emitting = true

func _physics_process(delta: float) -> void:
	var move_step := direction * speed * delta
	global_position += move_step
	_distance_traveled += move_step.length()
	
	if sprite:
		sprite.rotation += delta * 8.0
		
	if _distance_traveled >= max_range:
		_dissolve()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		_explode()
	elif body is StaticBody2D or body is TileMap:
		_explode()

func _on_area_entered(area: Area2D) -> void:
	pass

func _explode() -> void:
	set_physics_process(false)
	monitoring = false
	monitorable = false
	if sprite:
		sprite.visible = false
	if particles:
		particles.amount = 18
		particles.speed_scale = 2.5
		particles.emitting = true
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
		am.play_sfx(load("res://assets/audio/impact.wav"), -12.0, 1.6)
	await get_tree().create_timer(0.25).timeout
	queue_free()

func _dissolve() -> void:
	set_physics_process(false)
	var tween := create_tween()
	if sprite:
		tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	await tween.finished
	queue_free()
