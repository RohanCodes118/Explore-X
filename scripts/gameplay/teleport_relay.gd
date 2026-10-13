extends Area2D

# Teleport Relay / Extraction Beacon allowing Rix to return to crash site or open map

@export var prompt_message: String = "[E] ACTIVATE EXTRACTION RELAY"

@onready var aura_particles: CPUParticles2D = get_node_or_null("AuraParticles")
@onready var beam_particles: CPUParticles2D = get_node_or_null("BeamParticles")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self, prompt_message)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(null)

func interact(player: CharacterBody2D) -> void:
	var scene: Node = get_tree().current_scene
	if scene and scene.has_method("open_region_map"):
		scene.open_region_map()
	else:
		var gs: Node = get_node_or_null("/root/GameState")
		if gs:
			gs.return_to_crash_site()
