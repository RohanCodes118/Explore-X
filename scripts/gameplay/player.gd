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
		anim_sprite.animation_finished.connect(_on_animation_finished)
	if sword_hitbox:
		sword_hitbox.monitoring = true
		sword_hitbox.monitorable = true
		if not sword_hitbox.body_entered.is_connected(_on_sword_hit_target):
			sword_hitbox.body_entered.connect(_on_sword_hit_target)
		if not sword_hitbox.area_entered.is_connected(_on_sword_hit_target):
			sword_hitbox.area_entered.connect(_on_sword_hit_target)
	if sword_hit_shape:
		sword_hit_shape.set_deferred("disabled", true)
		
	# Connect to GameState signals
	var gs: Node = get_node_or_null("/root/GameState")
	var armed: bool = true
	if gs:
		if not gs.sword_acquired.is_connected(_on_sword_acquired):
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

var is_jumping: bool = false
var is_crouching: bool = false
var _jump_tween: Tween = null
var _attack_tween: Tween = null

const SPRITE_BASE_Y := -70.0
const PIVOT_BASE_Y := -60.0

func _physics_process(delta: float) -> void:
	# Safety auto-unlock if no dialogue, map, recovery, or repair is actively running
	if is_locked and not is_attacking:
		var scene := get_tree().current_scene if get_tree() else null
		if scene:
			var dlg: Control = scene.get_node_or_null("%DialogueOverlay")
			var map: Control = scene.get_node_or_null("%RegionMap")
			var is_rep: bool = scene.get("_is_repairing") if "_is_repairing" in scene else false
			var is_rec: bool = scene.get("_is_recovering") if "_is_recovering" in scene else false
			if (dlg == null or not dlg.visible) and (map == null or not map.visible) and not is_rep and not is_rec:
				is_locked = false

	if is_locked or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	# Robust directional input (WASD, Arrow Keys, UI bindings)
	var raw_x: float = Input.get_axis("ui_left", "ui_right")
	var raw_y: float = Input.get_axis("ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): raw_x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): raw_x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): raw_y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): raw_y += 1.0
	var input_vec := Vector2(clampf(raw_x, -1.0, 1.0), clampf(raw_y, -1.0, 1.0))
	if input_vec.length() > 1.0:
		input_vec = input_vec.normalized()
			
	# Jump input check
	if not is_jumping and not is_crouching and (Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_accept")):
		_start_jump()
		
	# Crouch check
	var wants_crouch: bool = not is_jumping and (Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_C))
	if wants_crouch != is_crouching:
		is_crouching = wants_crouch
		if weapon_pivot and not is_jumping:
			weapon_pivot.position.y = PIVOT_BASE_Y + (12.0 if is_crouching else 0.0)
			
	var is_running := not is_crouching and Input.is_key_pressed(KEY_SHIFT) and stamina > 10.0 and input_vec != Vector2.ZERO
	var current_speed := walk_speed
	if is_crouching:
		current_speed = walk_speed * 0.52
	elif is_running:
		current_speed = run_speed
	
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
			
		if not is_jumping:
			var target_anim: String
			if is_crouching:
				target_anim = "crouch_" + _facing
			elif is_running:
				target_anim = "run_" + _facing
			else:
				target_anim = "walk_" + _facing
				
			if anim_sprite.animation != target_anim:
				anim_sprite.play(target_anim)
			
		if dust_particles and not is_crouching and not is_jumping:
			dust_particles.emitting = true
	else:
		if not is_jumping and not is_attacking:
			var target_idle := ("crouch_" if is_crouching else "idle_") + _facing
			if anim_sprite.animation != target_idle:
				if not anim_sprite.animation.begins_with("interact") or not anim_sprite.is_playing():
					anim_sprite.play(target_idle)
		if dust_particles:
			dust_particles.emitting = false

func _start_jump() -> void:
	if is_jumping or is_locked or is_attacking:
		return
	is_jumping = true
	if anim_sprite:
		anim_sprite.flip_h = (_facing_h < 0.0)
		if anim_sprite.sprite_frames.has_animation("jump_side"):
			anim_sprite.play("jump_side")
		
	if _jump_tween and _jump_tween.is_valid():
		_jump_tween.kill()
		
	_jump_tween = create_tween()
	# Upward arc
	_jump_tween.tween_property(anim_sprite, "position:y", SPRITE_BASE_Y - 26.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if weapon_pivot:
		_jump_tween.parallel().tween_property(weapon_pivot, "position:y", PIVOT_BASE_Y - 26.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Downward fall and landing
	_jump_tween.tween_property(anim_sprite, "position:y", SPRITE_BASE_Y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if weapon_pivot:
		_jump_tween.parallel().tween_property(weapon_pivot, "position:y", PIVOT_BASE_Y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		
	_jump_tween.tween_callback(func():
		is_jumping = false
		if dust_particles:
			dust_particles.restart()
			dust_particles.emitting = true
		if anim_sprite and not is_locked and not is_attacking:
			if velocity != Vector2.ZERO:
				anim_sprite.play(("run_" if Input.is_key_pressed(KEY_SHIFT) else "walk_") + _facing)
			else:
				anim_sprite.play("idle_" + _facing)
	)

func _input(event: InputEvent) -> void:
	if is_locked or not is_inside_tree() or get_tree() == null or get_tree().paused:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var scene := get_tree().current_scene
		if scene:
			var map: Control = scene.get_node_or_null("%RegionMap")
			if map and map.visible:
				return
			var pause: Control = scene.get_node_or_null("%PauseOverlay")
			if pause and pause.visible:
				return
			var dlg: Control = scene.get_node_or_null("%DialogueOverlay")
			if dlg and dlg.visible:
				return
		try_attack()

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
		elif event.keycode == KEY_SPACE:
			if not is_jumping and not is_crouching:
				_start_jump()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_attack()

func try_attack() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	var has_blade: bool = (gs != null and (gs.has_sword or gs.current_region != "crash_site")) or (gs == null)
	if not has_blade or is_attacking or is_locked or _attack_cooldown or is_jumping:
		return
	play_sword_attack()

func play_sword_attack() -> void:
	is_attacking = true
	_attack_cooldown = true
	_hit_enemies_this_swing.clear()
	
	# Facing direction & weapon pivot alignment
	if anim_sprite:
		anim_sprite.flip_h = (_facing_h < 0.0)
		anim_sprite.play("attack_side")
	if weapon_pivot:
		weapon_pivot.scale.x = _facing_h
		weapon_pivot.position = Vector2(0, PIVOT_BASE_Y)
		
	if sword_sprite:
		sword_sprite.visible = true
		sword_sprite.z_index = 2 # Render cleanly in front during slash
		
		if _attack_tween and _attack_tween.is_valid():
			_attack_tween.kill()
		_attack_tween = create_tween()
		
		# Direction-aware attack arc coordinates
		var wind_up_pos := Vector2(4, -26)
		var wind_up_rot := -1.75
		var slash_pos := Vector2(28, 2)
		var slash_rot := 1.45
		
		if _facing == "up":
			wind_up_pos = Vector2(2, -32)
			wind_up_rot = -2.1
			slash_pos = Vector2(22, -12)
			slash_rot = 0.85
		elif _facing == "down":
			wind_up_pos = Vector2(6, -18)
			wind_up_rot = -1.25
			slash_pos = Vector2(26, 10)
			slash_rot = 1.7
			
		# Step 1: Rapid draw from sheath to wind-up position (0.06s)
		_attack_tween.tween_property(sword_sprite, "position", wind_up_pos, 0.06).set_trans(Tween.TRANS_QUAD)
		_attack_tween.parallel().tween_property(sword_sprite, "rotation", wind_up_rot, 0.06)
		
		# Step 2: Powerful slash sweep through the strike arc (0.12s)
		_attack_tween.tween_property(sword_sprite, "position", slash_pos, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_attack_tween.parallel().tween_property(sword_sprite, "rotation", slash_rot, 0.12)
		
		# Step 3: Impact frame — particles and collision activation
		_attack_tween.tween_callback(func():
			if slash_particles:
				slash_particles.position = Vector2(24, -4)
				slash_particles.restart()
				slash_particles.emitting = true
			if sword_hit_shape:
				sword_hit_shape.set_deferred("disabled", false)
			_perform_sword_hit_scan()
			var am: Node = get_node_or_null("/root/AudioManager")
			if am and ResourceLoader.exists("res://assets/audio/reentry.wav"):
				am.play_sfx(load("res://assets/audio/reentry.wav"), -8.0, 2.2)
			elif am:
				am.play_click()
		)
		
		# Step 4: Multi-frame active strike window
		_attack_tween.tween_interval(0.05)
		_attack_tween.tween_callback(_perform_sword_hit_scan)
		_attack_tween.tween_interval(0.05)
		_attack_tween.tween_callback(_perform_sword_hit_scan)
		
		# Step 5: Disable hitbox and smoothly return weapon to resting sheathed position
		_attack_tween.tween_callback(func():
			if sword_hit_shape:
				sword_hit_shape.set_deferred("disabled", true)
		)
		
		# Smooth recovery back to sheath
		_attack_tween.tween_property(sword_sprite, "position", SHEATHED_POS, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		_attack_tween.parallel().tween_property(sword_sprite, "rotation", SHEATHED_ROT, 0.12)
		
		_attack_tween.tween_callback(func():
			sword_sprite.position = SHEATHED_POS
			sword_sprite.rotation = SHEATHED_ROT
			sword_sprite.z_index = 0
			is_attacking = false
			if anim_sprite and not is_locked:
				anim_sprite.play("idle_" + _facing)
		)
		
		_attack_tween.tween_interval(0.08)
		_attack_tween.tween_callback(func():
			_attack_cooldown = false
		)
	else:
		var fallback_tween := create_tween()
		fallback_tween.tween_interval(0.35)
		fallback_tween.tween_callback(func():
			is_attacking = false
			if anim_sprite and not is_locked:
				anim_sprite.play("idle_" + _facing)
		)
		fallback_tween.tween_interval(0.08)
		fallback_tween.tween_callback(func():
			_attack_cooldown = false
		)

func _on_animation_finished() -> void:
	if anim_sprite and anim_sprite.animation.begins_with("interact") and not is_locked and not is_attacking:
		anim_sprite.play("idle_" + _facing)

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
