extends CharacterBody2D

# Verdant Ruins NPC Guardian — patrols, detects Rix, attacks, can be defeated

signal guardian_defeated

@export var patrol_speed: float  = 60.0
@export var chase_speed:  float  = 110.0
@export var detect_range: float  = 300.0
@export var attack_range: float  = 60.0
@export var max_hp:       int    = 40
@export var patrol_left:  float  = -200.0
@export var patrol_right: float  =  200.0

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var guard_sprite: Sprite2D        = get_node_or_null("GuardSprite")
@onready var hp_bar:      ProgressBar      = get_node_or_null("HpBar/ProgressBar")
@onready var hitbox:      Area2D           = get_node_or_null("Hitbox")
@onready var detection:   Area2D           = get_node_or_null("DetectionArea")

enum State { PATROL, CHASE, ATTACK, STAGGER, DEAD }
var state:      State = State.PATROL
var hp:         int   = 40
var _dir:       float = 1.0          # 1 right / -1 left
var _player:    Node2D = null
var _time:      float  = 0.0
var _attack_cd: float  = 0.0
var _dead:      bool   = false
var _attacking: bool  = false
var _has_anims: bool   = false
var _origin_x:  float  = 0.0        # store spawn x for patrol bounds

func _ready() -> void:
	hp = max_hp
	_origin_x = global_position.x
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
	if hitbox and not hitbox.area_entered.is_connected(_on_sword_hit):
		hitbox.area_entered.connect(_on_sword_hit)
	if detection:
		if not detection.body_entered.is_connected(_on_player_entered):
			detection.body_entered.connect(_on_player_entered)
		if not detection.body_exited.is_connected(_on_player_exited):
			detection.body_exited.connect(_on_player_exited)

	# Check if AnimatedSprite2D actually has frames assigned
	_has_anims = (anim_sprite != null
		and anim_sprite.sprite_frames != null
		and anim_sprite.sprite_frames.has_animation("patrol"))
	if _has_anims:
		anim_sprite.play("patrol")
	else:
		# Hide the empty AnimatedSprite2D, use static GuardSprite instead
		if anim_sprite:
			anim_sprite.visible = false

func _physics_process(delta: float) -> void:
	if _dead:
		return

	_time      += delta
	_attack_cd  = maxf(0.0, _attack_cd - delta)

	match state:
		State.PATROL:  _do_patrol(delta)
		State.CHASE:   _do_chase(delta)
		State.ATTACK:  _do_attack(delta)
		State.STAGGER: pass

func _do_patrol(delta: float) -> void:
	# patrol_left / patrol_right are absolute x positions
	var target_x := patrol_right if _dir > 0 else patrol_left
	if abs(global_position.x - target_x) < 12.0:
		_dir *= -1.0
	velocity.x = _dir * patrol_speed
	velocity.y = 0.0
	_flip(_dir < 0)
	_try_play("patrol")
	move_and_slide()

func _do_chase(delta: float) -> void:
	if not is_instance_valid(_player):
		state = State.PATROL
		return
	var diff := _player.global_position - global_position
	if diff.length() < attack_range and _attack_cd <= 0.0:
		state = State.ATTACK
		return
	if diff.length() > detect_range * 1.6:
		state = State.PATROL
		return
	var dir_to := diff.normalized()
	velocity   = dir_to * chase_speed
	_dir       = sign(dir_to.x) if dir_to.x != 0 else _dir
	_flip(_dir < 0)
	_try_play("chase")
	move_and_slide()

func _do_attack(_delta: float) -> void:
	if _attacking:
		return
	_attacking = true
	velocity = Vector2.ZERO
	move_and_slide()

	if _has_anims and anim_sprite.sprite_frames.has_animation("attack"):
		anim_sprite.play("attack")
		await anim_sprite.animation_finished
	else:
		# Simple visual lunge without animated frames
		var tween := create_tween()
		tween.tween_property(self, "modulate", Color(1.5, 0.6, 0.6), 0.15)
		tween.tween_interval(0.2)
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1)
		await tween.finished

	# Deal damage to player if still in range
	if is_instance_valid(_player) and global_position.distance_to(_player.global_position) < attack_range + 20:
		if _player.has_method("take_damage"):
			_player.take_damage(8)
	_attack_cd = 1.4
	state = State.CHASE if is_instance_valid(_player) else State.PATROL
	_attacking = false

func _on_sword_hit(area: Area2D) -> void:
	if _dead or area.name != "SwordHitbox":
		return
	take_damage(15)

func take_damage(dmg: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	if _dead:
		return
	hp -= dmg
	if hp_bar:
		hp_bar.value = hp
	# Flash red
	modulate = Color(1.8, 0.4, 0.4)
	await get_tree().create_timer(0.15).timeout
	if not _dead:
		modulate = Color(1, 1, 1)

	if hp <= 0:
		_die()
	else:
		if from_pos != Vector2.ZERO:
			velocity = (global_position - from_pos).normalized() * 120.0
		state = State.CHASE   # always aggro after getting hit

func _die() -> void:
	_dead = true
	state = State.DEAD
	velocity = Vector2.ZERO
	guardian_defeated.emit()
	
	var col := get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if detection:
		detection.set_deferred("monitoring", false)
		detection.set_deferred("monitorable", false)

	if _has_anims and anim_sprite.sprite_frames.has_animation("death"):
		anim_sprite.play("death")
		await anim_sprite.animation_finished
	else:
		# Simple fade out
		var tween := create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.6)
		await tween.finished
	queue_free()

func _on_player_entered(body: Node2D) -> void:
	if body.has_method("try_attack"):
		_player = body
		if body is CollisionObject2D:
			add_collision_exception_with(body)
		if state == State.PATROL:
			state = State.CHASE

func _on_player_exited(body: Node2D) -> void:
	if body == _player:
		# Keep chasing for a while; handled in _do_chase range check
		pass

# ─── Helpers ────────────────────────────────────────────────────────────────

func _flip(face_left: bool) -> void:
	if _has_anims:
		anim_sprite.flip_h = face_left
	if guard_sprite:
		guard_sprite.flip_h = face_left

func _try_play(anim_name: String) -> void:
	if _has_anims and anim_sprite.sprite_frames.has_animation(anim_name):
		if anim_sprite.animation != anim_name:
			anim_sprite.play(anim_name)
