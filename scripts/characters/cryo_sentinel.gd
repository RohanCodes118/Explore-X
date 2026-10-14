extends CharacterBody2D

# 2.5D Cryo Sentinel (Guardian Automaton) for Frostfall Expanse
# Autonomous combat NPC with 2.5D depth, floating HP bar, retaliatory attacks

signal defeated(sentinel: Node2D)

@export var max_health: float = 100.0
@export var move_speed: float = 47.5
@export var chase_speed: float = 72.5
@export var detection_radius: float = 380.0
@export var melee_range: float = 90.0
@export var projectile_scene: PackedScene = preload("res://scenes/gameplay/frost_pulse.tscn")
@export var patrol_points: Array[Vector2] = []
@export var enemy_name: String = "CRYO SENTINEL MK-III"

var health: float = 100.0
var _current_patrol_idx: int = 0
var _target_player: Node2D = null

enum State { IDLE, PATROL, CHASE, WINDUP, RETALIATE, HURT, DEAD }
var current_state: State = State.IDLE

@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var shadow_sprite: Sprite2D = get_node_or_null("%ShadowSprite")
@onready var cryo_particles: CPUParticles2D = %CryoParticles
@onready var hit_particles: CPUParticles2D = %HitParticles
@onready var health_bar_container: Node2D = %HealthBarContainer
@onready var hp_bar: ProgressBar = %HpBar
@onready var hp_label: Label = %HpLabel
@onready var name_label: Label = %NameLabel
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var melee_hitbox: Area2D = get_node_or_null("%MeleeHitbox")
@onready var alert_sprite: Sprite2D = get_node_or_null("%AlertSprite")

var _attack_timer: float = 0.0
var _retaliate_cooldown: float = 0.0
var _initial_pos: Vector2 = Vector2.ZERO
var _hover_time: float = 0.0

func _ready() -> void:
	health = max_health
	_initial_pos = global_position
	y_sort_enabled = true
	_ensure_nodes()
	
	if hp_bar:
		hp_bar.max_value = max_health
		hp_bar.value = health
	if hp_label:
		hp_label.text = "%d / %d" % [int(health), int(max_health)]
	if name_label:
		name_label.text = enemy_name
	if alert_sprite:
		alert_sprite.visible = false
	if cryo_particles:
		cryo_particles.emitting = true
		
	# Setup initial patrol if empty
	if patrol_points.is_empty():
		patrol_points.append(_initial_pos + Vector2(-120, -40))
		patrol_points.append(_initial_pos + Vector2(120, 50))
		patrol_points.append(_initial_pos)
		
	current_state = State.PATROL
	_play_anim("idle")

func _ensure_nodes() -> void:
	if collision_shape == null:
		collision_shape = get_node_or_null("%CollisionShape2D")
	if melee_hitbox == null:
		melee_hitbox = get_node_or_null("%MeleeHitbox")
	if shadow_sprite == null:
		shadow_sprite = get_node_or_null("%ShadowSprite")
	if alert_sprite == null:
		alert_sprite = get_node_or_null("%AlertSprite")
	if hp_bar == null:
		hp_bar = get_node_or_null("%HpBar")
	if hp_label == null:
		hp_label = get_node_or_null("%HpLabel")
	if hit_particles == null:
		hit_particles = get_node_or_null("%HitParticles")
	if cryo_particles == null:
		cryo_particles = get_node_or_null("%CryoParticles")
	if anim_sprite == null:
		anim_sprite = get_node_or_null("%AnimatedSprite2D")
	if health_bar_container == null:
		health_bar_container = get_node_or_null("%HealthBarContainer")

func _get_am() -> Node:
	return get_node_or_null("/root/AudioManager") if is_inside_tree() else null

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	_hover_time += delta
	_retaliate_cooldown = maxf(0.0, _retaliate_cooldown - delta)
	
	# Gentle 2.5D hover bobbing on sprite
	if anim_sprite and current_state != State.HURT:
		anim_sprite.position.y = -44.0 + sin(_hover_time * 3.5) * 4.0
	if shadow_sprite:
		var shadow_scale := 1.0 + sin(_hover_time * 3.5) * 0.08
		shadow_sprite.scale = Vector2(0.9 * shadow_scale, 0.45 * shadow_scale)
		
	# Find player if null
	if _target_player == null or not is_instance_valid(_target_player):
		if is_inside_tree() and get_tree() != null:
			var scene: Node = get_tree().current_scene
			if scene:
				_target_player = scene.find_child("Player", true, false)
				if _target_player is CollisionObject2D:
					add_collision_exception_with(_target_player)
			
	var dist_to_player: float = 9999.0
	if _target_player and is_instance_valid(_target_player):
		dist_to_player = global_position.distance_to(_target_player.global_position)
		
	match current_state:
		State.IDLE, State.PATROL:
			# Player proximity detection
			if dist_to_player < detection_radius:
				_trigger_alert()
			else:
				_handle_patrol(delta)
				
		State.CHASE:
			if dist_to_player > detection_radius * 1.5:
				current_state = State.PATROL
				_play_anim("walk")
			elif dist_to_player <= melee_range and _retaliate_cooldown <= 0.0:
				_start_retaliate_attack(true)
			elif dist_to_player <= 280.0 and _retaliate_cooldown <= 0.0 and randf() < 0.015:
				_start_retaliate_attack(false) # Ranged pulse
			else:
				# Move towards player
				var dir := (_target_player.global_position - global_position).normalized()
				velocity = dir * chase_speed
				_update_facing(dir.x)
				_play_anim("walk")
				move_and_slide()
				
		State.WINDUP, State.RETALIATE, State.HURT:
			velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)
			move_and_slide()

func _handle_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		return
	var dest := patrol_points[_current_patrol_idx]
	var dist := global_position.distance_to(dest)
	if dist < 24.0:
		_current_patrol_idx = (_current_patrol_idx + 1) % patrol_points.size()
	else:
		var dir := (dest - global_position).normalized()
		velocity = dir * move_speed
		_update_facing(dir.x)
		_play_anim("walk")
		move_and_slide()

func _trigger_alert() -> void:
	current_state = State.CHASE
	if alert_sprite and is_inside_tree():
		alert_sprite.visible = true
		var tween := create_tween()
		if tween:
			tween.tween_property(alert_sprite, "scale", Vector2(1.2, 1.2), 0.15)
			tween.tween_property(alert_sprite, "scale", Vector2.ZERO, 0.25).set_delay(0.4)
			tween.tween_callback(func(): alert_sprite.visible = false)
		
	var am: Node = _get_am()
	if am and ResourceLoader.exists("res://assets/audio/warning_alarm.wav"):
		am.play_sfx(load("res://assets/audio/warning_alarm.wav"), -14.0, 1.8)

func _update_facing(dir_x: float) -> void:
	if abs(dir_x) > 0.05:
		var flip := (dir_x < 0.0)
		if anim_sprite:
			anim_sprite.flip_h = flip
		if melee_hitbox:
			melee_hitbox.position.x = -36.0 if flip else 36.0

func _start_retaliate_attack(is_melee: bool) -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	current_state = State.WINDUP
	_retaliate_cooldown = 3.5 # Longer cooldown between attacks for fairer combat
	
	if _target_player and is_instance_valid(_target_player):
		_update_facing(_target_player.global_position.x - global_position.x)
		
	# Visual telegraph: flash yellow/red warning glow
	if anim_sprite:
		anim_sprite.modulate = Color(1.8, 0.8, 0.4, 1.0)
	_play_anim("attack")
	
	# Wind-up interval before release
	if not is_inside_tree() or get_tree() == null:
		return
	await get_tree().create_timer(0.35).timeout
	if current_state == State.DEAD or not is_inside_tree() or get_tree() == null:
		return
		
	current_state = State.RETALIATE
	if anim_sprite:
		anim_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		
	if is_melee:
		_execute_melee_slash()
	else:
		_execute_ranged_frost_pulse()
		
	if is_inside_tree() and get_tree() != null:
		await get_tree().create_timer(0.45).timeout
	if current_state != State.DEAD:
		current_state = State.CHASE
		_play_anim("idle")

func _execute_melee_slash() -> void:
	var am: Node = _get_am()
	if am and ResourceLoader.exists("res://assets/audio/reentry.wav"):
		am.play_sfx(load("res://assets/audio/reentry.wav"), -10.0, 2.5)
		
	# Check if player is within slash strike zone
	if _target_player and is_instance_valid(_target_player):
		var d := global_position.distance_to(_target_player.global_position)
		if d < melee_range + 30.0:
			if _target_player.has_method("take_damage"):
				_target_player.take_damage(2.0, global_position)
				
	# Spawn cold slash particles
	if cryo_particles:
		cryo_particles.amount = 25
		cryo_particles.restart()

func _execute_ranged_frost_pulse() -> void:
	if projectile_scene and _target_player and is_instance_valid(_target_player):
		var proj := projectile_scene.instantiate()
		proj.global_position = global_position + Vector2(0, -35)
		proj.direction = (_target_player.global_position - proj.global_position).normalized()
		var p := get_parent()
		if p:
			p.add_child(proj)
		
		var am: Node = _get_am()
		if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
			am.play_sfx(load("res://assets/audio/impact.wav"), -14.0, 1.8)

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	if current_state == State.DEAD:
		return
		
	_ensure_nodes()
	health = maxf(0.0, health - amount)
	
	# Update 2.5D Health Bar
	if hp_bar:
		if is_inside_tree():
			var tween := create_tween()
			if tween:
				tween.tween_property(hp_bar, "value", health, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			hp_bar.value = health
	if hp_label:
		hp_label.text = "%d / %d" % [int(health), int(max_health)]
		
	# Damage reaction particles
	if hit_particles:
		hit_particles.restart()
		hit_particles.emitting = true
		
	# Floating damage number
	_spawn_damage_number(amount)
	
	# White hurt flash
	if anim_sprite and is_inside_tree():
		anim_sprite.modulate = Color(3.0, 3.0, 3.0, 1.0)
		var flash_tween := create_tween()
		if flash_tween:
			flash_tween.tween_property(anim_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		
	# Play hit audio
	var am: Node = _get_am()
	if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
		am.play_sfx(load("res://assets/audio/impact.wav"), -4.0, randf_range(1.1, 1.3))
		
	# Slight knockback
	if from_pos != Vector2.ZERO:
		var knock_dir := (global_position - from_pos).normalized()
		velocity = knock_dir * 180.0
		
	if health <= 0.0:
		_die()
	else:
		# If damaged while idling/patrolling, retaliate immediately!
		if current_state in [State.IDLE, State.PATROL]:
			_trigger_alert()
		elif randf() < 0.65 and _retaliate_cooldown <= 0.8:
			# Quick retaliatory counter-strike!
			_start_retaliate_attack(randf() > 0.4)

func _spawn_damage_number(amt: float) -> void:
	if not is_inside_tree():
		return
	var lbl := Label.new()
	lbl.text = "-%d" % int(amt)
	lbl.modulate = Color(1.0, 0.3, 0.3, 1.0)
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.position = Vector2(randf_range(-20, 20), -95)
	add_child(lbl)
	
	var tween := create_tween()
	if tween:
		tween.tween_property(lbl, "position:y", lbl.position.y - 30.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.5)
		tween.tween_callback(lbl.queue_free)

func _die() -> void:
	current_state = State.DEAD
	defeated.emit(self)
	
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", true)
	if is_instance_valid(melee_hitbox):
		melee_hitbox.set_deferred("monitoring", false)
		melee_hitbox.set_deferred("monitorable", false)
	var hb := get_node_or_null("%Hurtbox")
	if is_instance_valid(hb):
		hb.set_deferred("monitoring", false)
		hb.set_deferred("monitorable", false)
		
	# Smoothly hide floating UI
	if is_instance_valid(health_bar_container) and is_inside_tree():
		var ui_tween := create_tween()
		if ui_tween:
			ui_tween.tween_property(health_bar_container, "modulate:a", 0.0, 0.25)
		
	_play_anim("death")
	
	var am: Node = _get_am()
	if am and ResourceLoader.exists("res://assets/audio/glitch.wav"):
		am.play_sfx(load("res://assets/audio/glitch.wav"), -6.0, 1.2)
		
	# Stage 1: Stagger impact — flash red and shake
	if is_inside_tree() and get_tree() != null:
		if anim_sprite:
			anim_sprite.modulate = Color(2.0, 0.3, 0.3, 1.0)
			var stagger_tween := create_tween()
			if stagger_tween:
				for i in range(6):
					var offset_x := randf_range(-5, 5)
					var offset_y := randf_range(-3, 3)
					stagger_tween.tween_property(anim_sprite, "position", Vector2(offset_x, -44.0 + offset_y), 0.04)
				stagger_tween.tween_property(anim_sprite, "position", Vector2(0, -44.0), 0.04)
				stagger_tween.tween_property(anim_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
		
		await get_tree().create_timer(0.35).timeout
	
	# Stage 2: Violent freeze shatter & explosion particles
	if cryo_particles:
		cryo_particles.amount = 50
		cryo_particles.explosiveness = 0.95
		cryo_particles.speed_scale = 2.0
		cryo_particles.restart()
		
	# Stage 3: Dark disintegration — modulate to shadow color, then fade with particles
	if is_inside_tree():
		var disintegrate_tween := create_tween()
		if disintegrate_tween:
			# Darken to shadow/smoky tone
			disintegrate_tween.tween_property(self, "modulate", Color(0.15, 0.1, 0.25, 0.9), 0.3)
			
			# Shrink slightly as if collapsing
			if anim_sprite:
				disintegrate_tween.parallel().tween_property(anim_sprite, "scale", Vector2(0.8, 0.6), 0.4).set_trans(Tween.TRANS_QUAD)
			
			# Final fade to nothing
			disintegrate_tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.15)
			
			# Spawn secondary disintegration particles during fade
			if hit_particles:
				hit_particles.amount = 35
				hit_particles.lifetime = 0.8
				hit_particles.explosiveness = 0.6
				hit_particles.restart()
				hit_particles.emitting = true
			
			await disintegrate_tween.finished
	queue_free()

func _play_anim(anim_name: String) -> void:
	if anim_sprite and anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		anim_sprite.play(anim_name)
