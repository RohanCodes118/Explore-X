extends Area2D

# Mysterious Stranger / Grandfather NPC for Echoes of Eternity

signal dialogue_requested(grandfather_node: Node2D)

@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("%AnimatedSprite2D")
@onready var sprite: Sprite2D = get_node_or_null("%Sprite2D")
@onready var dust_particles: CPUParticles2D = %DustParticles
@onready var staff_particles: CPUParticles2D = %StaffParticles
@onready var prompt_label: Label = %PromptLabel

var is_moving: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	_update_prompt()
	if anim_sprite:
		anim_sprite.play("idle")

func _update_prompt() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	if gs and gs.grandfather_revealed:
		if prompt_label: prompt_label.text = "[E] SPEAK WITH GRANDFATHER"
	else:
		if prompt_label: prompt_label.text = "[E] APPROACH MYSTERIOUS STRANGER"

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		_update_prompt()
		body.set_nearby_interactable(self, prompt_label.text if prompt_label else "[E] TALK")

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(null)

func _process(_delta: float) -> void:
	if not is_moving:
		var scene: Node = get_tree().current_scene if get_tree() else null
		if scene:
			var dlg: Control = scene.get_node_or_null("%DialogueOverlay")
			if dlg and dlg.visible:
				var player: Node2D = scene.find_child("Player", true, false)
				if player and is_instance_valid(player):
					face_towards(player.global_position.x)

func face_towards(target_x: float) -> void:
	if anim_sprite:
		# If target is to the right, facing right (flip_h = false); if to left, flip_h = true
		anim_sprite.flip_h = (target_x < global_position.x)

func interact(player: CharacterBody2D) -> void:
	if player:
		face_towards(player.global_position.x)
	if anim_sprite and anim_sprite.sprite_frames.has_animation("interact"):
		anim_sprite.play("interact")
		var timer := get_tree().create_timer(1.2)
		timer.timeout.connect(func():
			if not is_moving and anim_sprite:
				anim_sprite.play("idle")
		)
		
	if dialogue_requested.get_connections().size() > 0:
		dialogue_requested.emit(self)
	else:
		var surface: Node = owner if owner != null and owner.has_method("start_grandfather_dialogue") else null
		if surface == null and get_parent() != null and get_parent().has_method("start_grandfather_dialogue"):
			surface = get_parent()
		if surface == null and get_tree() and get_tree().current_scene != null and get_tree().current_scene.has_method("start_grandfather_dialogue"):
			surface = get_tree().current_scene
		if surface:
			surface.start_grandfather_dialogue(self)

func approach_towards(target_position: Vector2, duration: float = 3.5) -> void:
	is_moving = true
	face_towards(target_position.x)
	if anim_sprite:
		anim_sprite.play("walk")
	if dust_particles: dust_particles.emitting = true
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	is_moving = false
	if anim_sprite:
		anim_sprite.play("idle")
