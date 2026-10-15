extends Area2D

# Spaceship Propulsion Core Console for Component Inspection and Repairs

@export var prompt_message: String = "[E] ACCESS SHIP PROPULSION CORE"

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func get_prompt() -> String:
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs:
		return prompt_message
	if gs.ship_repaired or gs.all_components_installed():
		return "[E] INITIATE LAUNCH // DEPART KEPLER-884B"
	var next_comp: String = gs.get_next_installable_component()
	if next_comp == "plasma_regulator":
		return "[E] INSTALL PLASMA REGULATOR [PROPULSION]"
	elif next_comp == "navigation_core":
		return "[E] INSTALL NAVIGATION CORE [AVIONICS]"
	elif next_comp == "quantum_power_cell":
		return "[E] INSTALL QUANTUM POWER CELL [REACTOR]"
	else:
		var count: int = 0
		for k in gs.collected_components:
			if gs.collected_components[k]: count += 1
		return "[E] SHIP CONSOLE // %d/3 RECOVERED [DIAGNOSTIC]" % count

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self, get_prompt())

func update_prompt_for_player(body: Node2D) -> void:
	if body and body.has_method("set_nearby_interactable"):
		body.set_nearby_interactable(self, get_prompt())

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
