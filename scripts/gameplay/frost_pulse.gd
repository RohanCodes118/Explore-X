extends Area2D

# Cryo Sentinel Retaliation Projectile (Frost Pulse)

@export var speed: float = 260.0
@export var damage: float = 2.0 # Balanced low-powered retaliation: exactly 2 HP per hit
@export var max_range: float = 550.0

var direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0
var _is_exploded: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var particles: CPUParticles2D = get_node_or_null("TrailParticles")
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	if particles:
		particles.emitting = true

func _physics_process(delta: float) -> void:
	if _is_exploded:
		return
	var move_step := direction * speed * delta
	global_position += move_step
	_distance_traveled += move_step.length()
	
	if sprite:
		sprite.rotation += delta * 8.0
		
	if _distance_traveled >= max_range:
		_dissolve()

func _on_body_entered(body: Node2D) -> void:
	if _is_exploded:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, global_position)
		_explode()
	elif body is StaticBody2D or body is TileMap or body is TileMapLayer:
		_explode()

func _on_area_entered(area: Area2D) -> void:
	if _is_exploded:
		return
	if area.name == "SwordHitbox" or area.is_in_group("player_attack"):
		_explode()

func _explode() -> void:
	if _is_exploded:
		return
	_is_exploded = true
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if sprite:
		sprite.visible = false
	if particles:
		particles.amount = 18
		particles.speed_scale = 2.5
		particles.emitting = true
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
		am.play_sfx(load("res://assets/audio/impact.wav"), -12.0, 1.6)
	if is_inside_tree() and get_tree() != null:
		await get_tree().create_timer(0.25).timeout
	queue_free()

func _dissolve() -> void:
	if _is_exploded:
		return
	_is_exploded = true
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if sprite and is_inside_tree():
		var tween := create_tween()
		if tween:
			tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
			await tween.finished
	queue_free()
