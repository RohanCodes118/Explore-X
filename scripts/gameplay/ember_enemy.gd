extends CharacterBody2D

@export var max_health: float = 60.0
@export var move_speed: float = 48.0
@export var detection_radius: float = 420.0
@export var attack_radius: float = 72.0
@export var contact_damage: float = 8.0
@export var component_guardian: bool = false

@onready var health_bar: ProgressBar = get_node_or_null("HealthBar")
@onready var body_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")

var health: float
var _player: CharacterBody2D
var _attack_timer: float = 0.0
var _hit_flash_timer: float = 0.0
var _defeated: bool = false

func _ready() -> void:
	health = max_health
	_player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health

func _physics_process(delta: float) -> void:
	if _defeated:
		return
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_hit_flash_timer = maxf(0.0, _hit_flash_timer - delta)
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
		return

	var to_player := _player.global_position - global_position
	var distance := to_player.length()
	if distance <= detection_radius and distance > attack_radius:
		velocity = to_player.normalized() * move_speed
		move_and_slide()
	elif distance <= attack_radius:
		velocity = Vector2.ZERO
		if _attack_timer <= 0.0 and not _player.is_locked:
			_player.suit_integrity = maxf(0.0, _player.suit_integrity - contact_damage)
			_attack_timer = 1.0
	else:
		velocity = Vector2.ZERO

func take_damage(amount: float) -> void:
	if _defeated:
		return
	health = maxf(0.0, health - amount)
	if health_bar:
		health_bar.value = health
	modulate = Color(1.0, 0.35, 0.2, 1.0)
	_hit_flash_timer = 0.12
	if health <= 0.0:
		_defeat()

func _process(_delta: float) -> void:
	if _hit_flash_timer <= 0.0:
		modulate = Color.WHITE

func _defeat() -> void:
	_defeated = true
	velocity = Vector2.ZERO
	if body_shape:
		body_shape.set_deferred("disabled", true)
	if component_guardian:
		var pickup := get_tree().current_scene.find_child("ComponentPickup", true, false)
		if pickup:
			if pickup.has_method("reveal"):
				pickup.reveal(global_position)
			else:
				pickup.visible = true
				pickup.monitoring = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.35)
	tween.tween_callback(queue_free)
