extends CharacterBody2D

# Protagonist Rix controller for Echoes of Eternity

signal scanned_anomaly(anomaly_name: String, anomaly_data: String)

@export var walk_speed: float = 175.0
@export var run_speed: float = 290.0

@onready var anim_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var dust_particles: CPUParticles2D = %DustParticles
@onready var interact_label: Label = %InteractPrompt
@onready var weapon_pivot: Node2D = get_node_or_null("%WeaponPivot")
@onready var sword_sprite: Sprite2D = get_node_or_null("%SwordSprite")
@onready var slash_particles: CPUParticles2D = get_node_or_null("%SlashParticles")
@onready var sword_hitbox: Area2D = get_node_or_null("%SwordHitbox")
@onready var sword_hit_shape: CollisionShape2D = get_node_or_null("%SwordHitbox/CollisionShape2D")

var stamina: float = 100.0
var max_stamina: float = 100.0
var oxygen: float = 100.0
var suit_integrity: float = 100.0
var max_suit_integrity: float = 100.0

var _current_interactable: Area2D = null
var _facing: String = "down" # "down", "side", "up"
var _facing_h: float = 1.0 # 1.0 for right, -1.0 for left
var is_locked: bool = false # Lock movement during scripted cutscene/recovery/dialogue
var is_attacking: bool = false
var _attack_cooldown: bool = false
var _is_invulnerable: bool = false
var _hit_enemies_this_swing: Array[Node] = []

const SHEATHED_POS := Vector2(-14, 4)
const SHEATHED_ROT := -0.453786

func _ready() -> void:
	if interact_label:
		interact_label.visible = false
	if anim_sprite:
		anim_sprite.play("idle_down")
	if sword_hitbox:
		sword_hitbox.monitoring = true
		sword_hitbox.monitorable = true
		sword_hitbox.body_entered.connect(_on_sword_hit_target)
		sword_hitbox.area_entered.connect(_on_sword_hit_target)
	if sword_hit_shape:
		sword_hit_shape.disabled = true
		
	# Connect to GameState signals
	var gs: Node = get_node_or_null("/root/GameState")
	var armed: bool = true
	if gs:
		gs.sword_acquired.connect(_on_sword_acquired)
		armed = gs.has_sword or gs.current_region != "crash_site"
		if armed:
			gs.has_sword = true
	update_sword_visibility(armed)

func _on_sword_acquired() -> void:
	update_sword_visibility(true)
	# Play celebratory blade unsheath effect
	play_sword_attack()

func update_sword_visibility(has_blade: bool) -> void:
	if sword_sprite:
		sword_sprite.visible = has_blade
		sword_sprite.position = SHEATHED_POS
		sword_sprite.rotation = SHEATHED_ROT
		sword_sprite.z_index = 0

func _physics_process(delta: float) -> void:
	if is_locked or is_attacking:
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
			_facing_h = -1.0 if (input_vec.x < 0.0) else 1.0
			anim_sprite.flip_h = (input_vec.x < 0.0)
			if weapon_pivot:
				weapon_pivot.scale.x = _facing_h
		elif input_vec.y < 0.0:
			_facing = "up"
			anim_sprite.flip_h = (_facing_h < 0.0)
			if weapon_pivot:
				weapon_pivot.scale.x = _facing_h
		else:
			_facing = "down"
			anim_sprite.flip_h = (_facing_h < 0.0)
			if weapon_pivot:
				weapon_pivot.scale.x = _facing_h
			
		var anim_action := "run_" if is_running else "walk_"
		var target_anim := anim_action + _facing
		if anim_sprite.animation != target_anim:
			anim_sprite.play(target_anim)
			
		if dust_particles:
			dust_particles.emitting = true
	else:
		var target_idle := "idle_" + _facing
		if anim_sprite.animation != target_idle and not anim_sprite.animation.begins_with("interact") and not is_attacking:
			anim_sprite.play(target_idle)
		if dust_particles:
			dust_particles.emitting = false

func _unhandled_input(event: InputEvent) -> void:
	if is_locked:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			var target: Area2D = _current_interactable
			if target == null and is_inside_tree() and get_tree():
				var scene := get_tree().current_scene
				if scene:
					for node in scene.find_children("", "Area2D", true, false):
						if node.has_method("interact") and global_position.distance_to(node.global_position) < 110.0:
							target = node
							break
			if target and target.has_method("interact"):
				anim_sprite.play("interact_down")
				target.interact(self)
		elif event.keycode == KEY_F or event.keycode == KEY_J:
			try_attack()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_attack()

func try_attack() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	var has_blade: bool = (gs != null and (gs.has_sword or gs.current_region != "crash_site")) or (gs == null)
	if not has_blade or is_attacking or is_locked or _attack_cooldown:
		return
	play_sword_attack()

func play_sword_attack() -> void:
	is_attacking = true
	_attack_cooldown = true
	_hit_enemies_this_swing.clear()
	
	# Align facing and weapon pivot
	if anim_sprite:
		anim_sprite.flip_h = (_facing_h < 0.0)
		anim_sprite.play("attack_side")
	if weapon_pivot:
		weapon_pivot.scale.x = _facing_h
		
	if sword_sprite:
		sword_sprite.z_index = 1
		var tween := create_tween()
		
		# Wind-up
		sword_sprite.position = Vector2(8, -22)
		sword_sprite.rotation = -1.57
		
		# Downward slash through arc
		tween.tween_property(sword_sprite, "position", Vector2(26, -2), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(sword_sprite, "rotation", 1.35, 0.12)
		
		# Hit frame impact
		tween.tween_callback(func():
			if slash_particles:
				slash_particles.position = Vector2(24, -4)
				slash_particles.restart()
				slash_particles.emitting = true
			if sword_hit_shape:
				sword_hit_shape.disabled = false
			_perform_sword_hit_scan()
			var am: Node = get_node_or_null("/root/AudioManager")
			if am and ResourceLoader.exists("res://assets/audio/reentry.wav"):
				am.play_sfx(load("res://assets/audio/reentry.wav"), -8.0, 2.2)
			elif am:
				am.play_click()
		)
		
		# Active slash linger & multi-frame hit coverage
		tween.tween_interval(0.06)
		tween.tween_callback(_perform_sword_hit_scan)
		tween.tween_interval(0.06)
		tween.tween_callback(_perform_sword_hit_scan)
		
		# Disable hitbox after active frames
		tween.tween_callback(func():
			if sword_hit_shape:
				sword_hit_shape.disabled = true
		)
		
		# Smooth return to sheathed pose on hip
		tween.tween_property(sword_sprite, "position", SHEATHED_POS, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(sword_sprite, "rotation", SHEATHED_ROT, 0.15)
		tween.tween_callback(func():
			if sword_sprite:
				sword_sprite.z_index = 0
		)
		
	await get_tree().create_timer(0.38).timeout
	is_attacking = false
	if anim_sprite:
		anim_sprite.play("idle_" + _facing)
		
	# Short cooldown to prevent animation overlap
	await get_tree().create_timer(0.10).timeout
	_attack_cooldown = false

func _perform_sword_hit_scan() -> void:
	if not is_attacking:
		return
	if sword_hitbox:
		for body in sword_hitbox.get_overlapping_bodies():
			_on_sword_hit_target(body)
		for area in sword_hitbox.get_overlapping_areas():
			_on_sword_hit_target(area)
			
	if not is_inside_tree() or get_tree() == null:
		return
	var scene := get_tree().current_scene
	if scene:
		var strike_pos := global_position + Vector2(_facing_h * 36.0, -38.0)
		if _facing == "up":
			strike_pos = global_position + Vector2(_facing_h * 15.0, -65.0)
		elif _facing == "down":
			strike_pos = global_position + Vector2(_facing_h * 15.0, -12.0)
			
		for target in scene.find_children("", "Node2D", true, false):
			if target != self and is_instance_valid(target):
				var cand: Node = target
				while cand and not cand.has_method("take_damage") and cand != scene:
					cand = cand.get_parent()
				if cand and cand != self and cand.has_method("take_damage"):
					var target_center: Vector2 = target.global_position + Vector2(0, -38.0)
					if strike_pos.distance_to(target_center) <= 88.0:
						_on_sword_hit_target(cand)

func _on_sword_hit_target(target: Node) -> void:
	if not is_attacking or target == self:
		return
	var victim: Node = target
	while victim and not victim.has_method("take_damage") and victim.get_parent() and is_inside_tree() and victim != get_tree().current_scene:
		victim = victim.get_parent()
		
	if victim == null or not victim.has_method("take_damage") or victim == self:
		return
		
	if victim in _hit_enemies_this_swing:
		return
		
	_hit_enemies_this_swing.append(victim)
	victim.take_damage(25.0, global_position)

func take_damage(amount: float, from_pos: Vector2 = Vector2.ZERO) -> void:
	if _is_invulnerable:
		return
	_is_invulnerable = true
	suit_integrity = maxf(0.0, suit_integrity - amount)
	
	# Hurt visual effect
	if anim_sprite:
		anim_sprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
		var tween := create_tween()
		tween.tween_property(anim_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
		am.play_sfx(load("res://assets/audio/impact.wav"), -4.0, 1.2)
		
	# Slight knockback
	if from_pos != Vector2.ZERO:
		var knock_dir := (global_position - from_pos).normalized()
		velocity = knock_dir * 160.0
		move_and_slide()
		
	await get_tree().create_timer(0.45).timeout
	_is_invulnerable = false

func heal(amount: float) -> void:
	suit_integrity = minf(max_suit_integrity, suit_integrity + amount)

func set_nearby_interactable(area: Area2D, prompt_text: String = "[E] SCAN ANOMALY") -> void:
	_current_interactable = area
	if interact_label:
		if area:
			interact_label.text = prompt_text
			interact_label.visible = true
		else:
			interact_label.visible = false
