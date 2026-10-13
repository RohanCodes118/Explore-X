extends Area2D

@export var prompt_message: String = "[E] SCAN ANOMALY"
@export var scan_title: String = "CRYSTALLINE RESONATOR"
@export var scan_description: String = "High-energy mineral cluster exhibiting anomalous electromagnetic pulsing. Native to Kepler-884b."

@onready var glow_sprite: Sprite2D = get_node_or_null("GlowSprite")

var _is_player_inside: bool = false
var _time_passed: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	_time_passed += delta
	if glow_sprite:
		glow_sprite.modulate.a = 0.5 + 0.3 * sin(_time_passed * 3.0)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		_is_player_inside = true
		body.set_nearby_interactable(self, prompt_message)

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("set_nearby_interactable"):
		_is_player_inside = false
		body.set_nearby_interactable(null)

func interact(player: CharacterBody2D) -> void:
	var surface: Node = get_tree().current_scene
	if not surface or not surface.has_method("show_scan_result"):
		surface = owner
	if not surface or not surface.has_method("show_scan_result"):
		surface = get_parent()
	if surface and surface.has_method("show_scan_result"):
		surface.show_scan_result(scan_title, scan_description, 5.0)
