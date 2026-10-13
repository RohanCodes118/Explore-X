extends Area2D

# Spaceship Propulsion Core Console for Component Inspection and Repairs

@export var prompt_message: String = "[E] ACCESS SHIP PROPULSION CORE"

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		var gs: Node = get_node_or_null("/root/GameState")
		var prompt := prompt_message
		if gs and gs.all_components_collected() and not gs.ship_repaired:
			prompt = "[E] COMMENCE SHIP REPAIR SEQUENCE"
		body.set_nearby_interactable(self, prompt)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(null)

func interact(player: CharacterBody2D) -> void:
	var surface: Node = owner if owner != null and owner.has_method("interact_ship_console") else null
	if surface == null and get_parent() != null and get_parent().has_method("interact_ship_console"):
		surface = get_parent()
	if surface == null and get_tree() and get_tree().current_scene != null and get_tree().current_scene.has_method("interact_ship_console"):
		surface = get_tree().current_scene
	if surface:
		surface.interact_ship_console()
