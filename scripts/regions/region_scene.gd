extends Node2D

# Base exploration controller for Ember Wastes, Verdant Ruins, and Frostfall Expanse

@export var region_id: String = "ember_wastes"
@export var region_display_name: String = "EMBER WASTES"
@export var base_lat: float = -12.408
@export var base_lon: float = 148.912

@onready var player: CharacterBody2D = %Player
@onready var camera: Camera2D = %Camera2D

# HUD elements
@onready var health_bar: ProgressBar = %HealthBar
@onready var oxygen_bar: ProgressBar = %OxygenBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var coords_label: Label = %CoordsLabel
@onready var region_tag: Label = %RegionTag
@onready var objective_label: Label = %ObjectiveLabel

# Banner
@onready var obtained_banner: PanelContainer = %ObtainedBanner
@onready var obtained_title: Label = %ObtainedTitle
@onready var obtained_desc: Label = %ObtainedDesc

# Map and Pause
@onready var region_map: Control = %RegionMap
@onready var pause_overlay: Control = %PauseOverlay
@onready var btn_resume: Button = %BtnResume
@onready var btn_return_crash: Button = %BtnReturnCrash
@onready var btn_open_map: Button = %BtnOpenMap
@onready var fade_rect: ColorRect = %FadeRect

var _is_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if pause_overlay: pause_overlay.visible = false
	if obtained_banner: obtained_banner.visible = false
	if region_map:
		region_map.visible = false
		region_map.map_closed.connect(_on_map_closed)
		
	if region_tag: region_tag.text = "SECTOR // " + region_display_name
	_update_objective_label()
	
	# Initial fade in
	if fade_rect:
		fade_rect.visible = true
		fade_rect.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
		await tween.finished
		fade_rect.visible = false
		
	_connect_pause_buttons()
	_show_region_arrival_banner()

func _show_region_arrival_banner() -> void:
	if not obtained_banner:
		return
	var gs: Node = get_node_or_null("/root/GameState")
	var desc := ""
	if gs and gs.REGION_DATA.has(region_id):
		desc = gs.REGION_DATA[region_id]["description"]
	obtained_title.text = "ZONE RECONNAISSANCE // " + region_display_name
	obtained_desc.text = desc
	obtained_banner.visible = true
	obtained_banner.modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(obtained_banner, "modulate:a", 1.0, 0.5)
	tween.tween_interval(3.5)
	tween.tween_property(obtained_banner, "modulate:a", 0.0, 0.6)
	await tween.finished
	obtained_banner.visible = false

func _connect_pause_buttons() -> void:
	if btn_resume: btn_resume.pressed.connect(toggle_pause)
	if btn_open_map: btn_open_map.pressed.connect(open_region_map)
	if btn_return_crash: btn_return_crash.pressed.connect(return_to_crash_site)

func _process(delta: float) -> void:
	if not _is_paused:
		health_bar.value = player.suit_integrity
		oxygen_bar.value = player.oxygen
		stamina_bar.value = player.stamina
		
		# Atmospheric grid telemetry without spoiling collectible coordinates
		var lat := base_lat + (player.position.y * 0.0005)
		var lon := base_lon + (player.position.x * 0.0005)
		coords_label.text = "%s // LAT: %0.3f  LON: %0.3f" % [region_display_name, lat, lon]
		
		camera.position = camera.position.lerp(player.position, delta * 6.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		if region_map and region_map.visible:
			region_map.close_map()
		else:
			toggle_pause()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_M:
		get_viewport().set_input_as_handled()
		if region_map and region_map.visible:
			region_map.close_map()
		else:
			open_region_map()

func toggle_pause() -> void:
	_is_paused = !_is_paused
	get_tree().paused = _is_paused
	if pause_overlay: pause_overlay.visible = _is_paused
	if _is_paused and btn_resume: btn_resume.grab_focus()

func open_region_map() -> void:
	if _is_paused:
		toggle_pause()
	if region_map:
		if player:
			player.is_locked = true
		region_map.open_map()

func _on_map_closed() -> void:
	if player:
		player.is_locked = false
		player.grab_focus()

func return_to_crash_site() -> void:
	if _is_paused:
		toggle_pause()
	fade_rect.visible = true
	fade_rect.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	await tween.finished
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.return_to_crash_site()

func show_component_obtained_banner(comp_name: String) -> void:
	if not obtained_banner:
		return
	obtained_title.text = "CRITICAL COMPONENT RECOVERED!"
	obtained_desc.text = comp_name.to_upper() + " SECURED. RETURN TO SHIP OR CONTINUE EXPLORATION."
	obtained_banner.visible = true
	obtained_banner.modulate.a = 0.0
	
	var tween := create_tween()
	tween.tween_property(obtained_banner, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.5)
	tween.tween_property(obtained_banner, "modulate:a", 0.0, 0.6)
	await tween.finished
	obtained_banner.visible = false
	_update_objective_label()

func _update_objective_label() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs or not objective_label:
		return
	var target_comp: String = gs.REGION_DATA[region_id]["component_id"]
	if gs.has_component(target_comp):
		objective_label.text = "OBJECTIVE: " + gs.REGION_DATA[region_id]["component_name"].to_upper() + " SECURED! Use extraction relay or press [M] to depart."
		objective_label.modulate = Color(0.3, 1.0, 0.5, 1.0)
	else:
		objective_label.text = "OBJECTIVE: Explore terrain — scan for missing propulsion component."
		objective_label.modulate = Color(1.0, 0.8, 0.3, 1.0)
