extends Node2D

# Base exploration controller for Ember Wastes, Verdant Ruins, and Frostfall Expanse
# Enhanced with health regeneration, professional HUD, treasure chest mechanics

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

# Enhanced HUD labels (created dynamically if not in scene)
var health_value_label: Label = null
var oxygen_value_label: Label = null
var enemy_counter_label: Label = null
var chest_status_label: Label = null
var regen_indicator_label: Label = null

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
@onready var forcefield_barrier: StaticBody2D = get_node_or_null("%ForcefieldBarrier")

var _is_paused: bool = false
var _sentinels: Array[Node] = []
var _initial_sentinel_count: int = 0
var _all_sentinels_defeated: bool = false

# Health regeneration
var _regen_timer: float = 0.0
var _regen_active: bool = false
const REGEN_AMOUNT: float = 10.0
const REGEN_INTERVAL: float = 3.0

# Treasure chest state
var _chest_unlocked: bool = false
var _chest_ice_broken: bool = false
var _component_pickup_node: Node = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if pause_overlay: pause_overlay.visible = false
	if obtained_banner: obtained_banner.visible = false
	if region_map:
		region_map.visible = false
		region_map.map_closed.connect(_on_map_closed)
		
	if region_tag: region_tag.text = "SECTOR // " + region_display_name
	_init_combat_guardians()
	_setup_enhanced_hud()
	_setup_treasure_chest()
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

func _setup_enhanced_hud() -> void:
	# Create dynamic HUD enhancement labels alongside existing bars
	# health_bar is inside BarSuit (HBox) -> VBox -> HBox -> Margin -> TopLeftBox
	# We need the VBox that contains BarSuit, BarO2, BarStamina
	var hud_vbox: Node = null
	if health_bar and health_bar.get_parent():
		hud_vbox = health_bar.get_parent().get_parent()  # BarSuit -> VBox
	
	# Health value label (shows HP/MaxHP numerically)
	health_value_label = _create_hud_label("100 / 100", Color(0.3, 1.0, 0.5, 0.9))
	if health_bar and health_bar.get_parent():
		health_bar.get_parent().add_child(health_value_label)
	
	# Oxygen value label
	oxygen_value_label = _create_hud_label("100%", Color(0.4, 0.85, 1.0, 0.9))
	if oxygen_bar and oxygen_bar.get_parent():
		oxygen_bar.get_parent().add_child(oxygen_value_label)
	
	# Enemy counter label — add as new row in the VBox
	enemy_counter_label = _create_hud_label("", Color(1.0, 0.4, 0.4, 1.0))
	if hud_vbox and hud_vbox is VBoxContainer:
		var enemy_hbox := HBoxContainer.new()
		enemy_hbox.name = "EnemyInfo"
		var enemy_icon_lbl := Label.new()
		enemy_icon_lbl.text = "⚔ HOSTILES"
		enemy_icon_lbl.custom_minimum_size = Vector2(65, 0)
		enemy_icon_lbl.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3, 0.85))
		enemy_icon_lbl.add_theme_font_size_override("font_size", 11)
		enemy_hbox.add_child(enemy_icon_lbl)
		enemy_hbox.add_child(enemy_counter_label)
		hud_vbox.add_child(enemy_hbox)
		
		# Add chest status below enemy counter
		var chest_hbox := HBoxContainer.new()
		chest_hbox.name = "ChestInfo"
		var chest_icon_lbl := Label.new()
		chest_icon_lbl.text = "❄ CACHE"
		chest_icon_lbl.custom_minimum_size = Vector2(65, 0)
		chest_icon_lbl.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0, 0.85))
		chest_icon_lbl.add_theme_font_size_override("font_size", 11)
		chest_hbox.add_child(chest_icon_lbl)
		chest_status_label = _create_hud_label("FROZEN — DEFEAT HOSTILES", Color(0.6, 0.85, 1.0, 0.85))
		chest_hbox.add_child(chest_status_label)
		hud_vbox.add_child(chest_hbox)
	
	# Regen indicator
	regen_indicator_label = _create_hud_label("", Color(0.3, 1.0, 0.5, 0.0))
	if hud_vbox and hud_vbox is VBoxContainer:
		hud_vbox.add_child(regen_indicator_label)

func _create_hud_label(initial_text: String, color: Color) -> Label:
	var lbl := Label.new()
	lbl.text = initial_text
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.size_flags_horizontal = Control.SIZE_SHRINK_END
	return lbl

func _setup_treasure_chest() -> void:
	# Find the ComponentPickup node in the scene
	_component_pickup_node = find_child("ComponentPickup", true, false)
	
	var gs: Node = get_node_or_null("/root/GameState")
	var target_comp: String = gs.REGION_DATA[region_id]["component_id"] if (gs and gs.REGION_DATA.has(region_id)) else ""
	var already_cleared: bool = gs and gs.has_component(target_comp)
	
	if already_cleared:
		_chest_unlocked = true
		_chest_ice_broken = true
		return
	
	# If sentinels exist, lock the chest
	if not _sentinels.is_empty() and _component_pickup_node:
		_lock_chest()
	else:
		_chest_unlocked = true
		_chest_ice_broken = true

func _lock_chest() -> void:
	if _component_pickup_node:
		# Disable interaction until sentinels are defeated
		_component_pickup_node.set_deferred("monitoring", false)
		_component_pickup_node.set_deferred("monitorable", false)
		# Dim the sprite to show it's frozen/locked
		var chest_sprite: Node = _component_pickup_node.get_node_or_null("Sprite2D")
		if chest_sprite:
			chest_sprite.modulate = Color(0.4, 0.6, 0.9, 0.5)
		var chest_aura: Node = _component_pickup_node.get_node_or_null("AuraParticles")
		if chest_aura:
			chest_aura.emitting = false
		_chest_unlocked = false

func _unlock_chest() -> void:
	if _component_pickup_node and not _chest_unlocked:
		_chest_unlocked = true
		
		# Ice breaking visual effect
		await _play_ice_break_effect()
		
		if not _component_pickup_node.visible:
			if _component_pickup_node.has_method("reveal"):
				_component_pickup_node.reveal(_component_pickup_node.global_position)
			else:
				_component_pickup_node.visible = true
		# Re-enable interaction
		_component_pickup_node.set_deferred("monitoring", true)
		_component_pickup_node.set_deferred("monitorable", true)
		if player and is_instance_valid(player) and player.has_method("set_nearby_interactable"):
			var d: float = _component_pickup_node.global_position.distance_to(player.global_position)
			if d <= 120.0:
				player.set_nearby_interactable(_component_pickup_node, _component_pickup_node.prompt_message)
		
		# Restore visual
		var chest_sprite: Node = _component_pickup_node.get_node_or_null("Sprite2D")
		if chest_sprite:
			var reveal_tween := create_tween()
			if reveal_tween:
				reveal_tween.tween_property(chest_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)
			else:
				chest_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		var chest_aura: Node = _component_pickup_node.get_node_or_null("AuraParticles")
		if chest_aura:
			chest_aura.emitting = true

		if chest_status_label:
			chest_status_label.text = "UNLOCKED — RECOVER COMPONENT"
			chest_status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))

func _play_ice_break_effect() -> void:
	_chest_ice_broken = true
	if not _component_pickup_node:
		return
		
	# Create ice shatter particles at the chest location
	var ice_shatter := CPUParticles2D.new()
	ice_shatter.global_position = _component_pickup_node.global_position
	ice_shatter.amount = 45
	ice_shatter.lifetime = 1.2
	ice_shatter.one_shot = true
	ice_shatter.explosiveness = 0.9
	ice_shatter.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	ice_shatter.emission_sphere_radius = 35.0
	ice_shatter.gravity = Vector2(0, 80)
	ice_shatter.initial_velocity_min = 80.0
	ice_shatter.initial_velocity_max = 200.0
	ice_shatter.scale_amount_min = 3.0
	ice_shatter.scale_amount_max = 9.0
	
	var ice_gradient := Gradient.new()
	ice_gradient.offsets = PackedFloat32Array([0, 0.3, 0.7, 1])
	ice_gradient.colors = PackedColorArray([
		0.8, 0.95, 1.0, 1.0,
		0.4, 0.85, 1.0, 0.8,
		0.2, 0.6, 0.9, 0.4,
		0.0, 0.2, 0.5, 0.0
	])
	ice_shatter.color_ramp = ice_gradient
	
	add_child(ice_shatter)
	ice_shatter.emitting = true
	
	# Camera shake
	var orig_pos := camera.position
	var shake_tween := create_tween()
	for i in range(8):
		shake_tween.tween_property(camera, "offset", Vector2(randf_range(-4, 4), randf_range(-3, 3)), 0.04)
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.06)
	
	# Play audio
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and ResourceLoader.exists("res://assets/audio/impact.wav"):
		am.play_sfx(load("res://assets/audio/impact.wav"), -2.0, 0.8)
	
	await get_tree().create_timer(1.5).timeout
	ice_shatter.queue_free()

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
		
		# Enhanced HUD updates
		if health_value_label:
			health_value_label.text = "%d / %d" % [int(player.suit_integrity), int(player.max_suit_integrity)]
			# Color based on health level
			if player.suit_integrity <= 25.0:
				health_value_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
			elif player.suit_integrity <= 50.0:
				health_value_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.2, 1.0))
			else:
				health_value_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 0.9))
		
		if oxygen_value_label:
			oxygen_value_label.text = "%d%%" % int(player.oxygen)
			if player.oxygen <= 30.0:
				oxygen_value_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3, 1.0))
			else:
				oxygen_value_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 0.9))
		
		if enemy_counter_label:
			var remaining := _sentinels.size()
			enemy_counter_label.text = "%d / %d" % [_initial_sentinel_count - remaining, _initial_sentinel_count]
			if remaining == 0:
				enemy_counter_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
				enemy_counter_label.text = "ALL NEUTRALIZED"
		
		# Atmospheric grid telemetry without spoiling collectible coordinates
		var lat := base_lat + (player.position.y * 0.0005)
		var lon := base_lon + (player.position.x * 0.0005)
		coords_label.text = "%s // LAT: %0.3f  LON: %0.3f" % [region_display_name, lat, lon]
		
		camera.position = camera.position.lerp(player.position, delta * 6.0)
		
		# Health regeneration logic
		if _regen_active and player.suit_integrity < player.max_suit_integrity:
			_regen_timer += delta
			if _regen_timer >= REGEN_INTERVAL:
				_regen_timer -= REGEN_INTERVAL
				player.heal(REGEN_AMOUNT)
				
				# Regen visual feedback
				if regen_indicator_label:
					regen_indicator_label.text = "♥ +%d HP" % int(REGEN_AMOUNT)
					regen_indicator_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
					var flash_tween := create_tween()
					flash_tween.tween_property(regen_indicator_label, "modulate:a", 1.0, 0.1)
					flash_tween.tween_interval(0.8)
					flash_tween.tween_property(regen_indicator_label, "modulate:a", 0.0, 0.5)
				
				# Update health bar with smooth animation
				var bar_tween := create_tween()
				bar_tween.tween_property(health_bar, "value", player.suit_integrity, 0.3).set_trans(Tween.TRANS_QUAD)
		elif _regen_active and player.suit_integrity >= player.max_suit_integrity:
			# Regen complete
			_regen_active = false
			_regen_timer = 0.0
			if regen_indicator_label:
				regen_indicator_label.text = "♥ FULLY RESTORED"
				var done_tween := create_tween()
				done_tween.tween_property(regen_indicator_label, "modulate:a", 1.0, 0.1)
				done_tween.tween_interval(2.0)
				done_tween.tween_property(regen_indicator_label, "modulate:a", 0.0, 0.8)

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
	
	if chest_status_label:
		chest_status_label.text = "COMPONENT SECURED ✔"
		chest_status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
	
	var tween := create_tween()
	tween.tween_property(obtained_banner, "modulate:a", 1.0, 0.4)
	tween.tween_interval(3.5)
	tween.tween_property(obtained_banner, "modulate:a", 0.0, 0.6)
	await tween.finished
	obtained_banner.visible = false
	_update_objective_label()

func _init_combat_guardians() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	var target_comp: String = gs.REGION_DATA[region_id]["component_id"] if (gs and gs.REGION_DATA.has(region_id)) else ""
	var already_cleared: bool = gs and gs.has_component(target_comp)
	
	_sentinels.clear()
	var sentinel_container: Node = find_child("Sentinels", true, false)
	if sentinel_container == null:
		sentinel_container = find_child("EnemySpawns", true, false)
	if sentinel_container:
		for child in sentinel_container.get_children():
			if child.has_signal("defeated"):
				if already_cleared:
					child.queue_free()
				else:
					_sentinels.append(child)
					child.defeated.connect(_on_sentinel_defeated)
	
	_initial_sentinel_count = _sentinels.size()
	_all_sentinels_defeated = _sentinels.is_empty()
					
	if forcefield_barrier:
		if already_cleared or _sentinels.is_empty():
			forcefield_barrier.visible = false
			var col: CollisionShape2D = forcefield_barrier.get_node_or_null("CollisionShape2D")
			if col:
				col.set_deferred("disabled", true)
		else:
			forcefield_barrier.visible = true
			var col: CollisionShape2D = forcefield_barrier.get_node_or_null("CollisionShape2D")
			if col:
				col.set_deferred("disabled", false)

func _on_sentinel_defeated(sentinel: Node) -> void:
	if sentinel in _sentinels:
		_sentinels.erase(sentinel)
		
	if _sentinels.is_empty():
		_all_sentinels_defeated = true
		_on_all_sentinels_cleared()
	else:
		_update_objective_label()

func _on_all_sentinels_cleared() -> void:
	_unlock_containment_barrier()
	_start_health_regeneration()
	if is_inside_tree() and get_tree() != null:
		await get_tree().create_timer(1.5).timeout
	_unlock_chest()

func _start_health_regeneration() -> void:
	if _regen_active:
		return
	if player.suit_integrity >= player.max_suit_integrity:
		return
	
	_regen_active = true
	_regen_timer = 0.0
	
	# Show regen starting banner
	if obtained_banner:
		obtained_title.text = "SUIT AUTO-REPAIR INITIATED"
		obtained_desc.text = "Regenerating +%d HP every %d seconds." % [int(REGEN_AMOUNT), int(REGEN_INTERVAL)]
		obtained_banner.visible = true
		obtained_banner.modulate.a = 0.0
		var tb := create_tween()
		tb.tween_property(obtained_banner, "modulate:a", 1.0, 0.3)
		tb.tween_interval(2.0)
		tb.tween_property(obtained_banner, "modulate:a", 0.0, 0.5)
		await tb.finished
		obtained_banner.visible = false

func _unlock_containment_barrier() -> void:
	if forcefield_barrier and forcefield_barrier.visible:
		var am: Node = get_node_or_null("/root/AudioManager")
		if am and ResourceLoader.exists("res://assets/audio/glitch.wav"):
			am.play_sfx(load("res://assets/audio/glitch.wav"), -4.0, 1.0)
			
		var col: CollisionShape2D = forcefield_barrier.get_node_or_null("CollisionShape2D")
		if col:
			col.set_deferred("disabled", true)
			
		var tween := create_tween()
		if tween:
			tween.tween_property(forcefield_barrier, "modulate:a", 0.0, 0.6)
			tween.tween_callback(func():
				forcefield_barrier.visible = false
			)
		else:
			forcefield_barrier.visible = false
		
	if obtained_banner:
		obtained_title.text = "DEFENSE GRID OVERRIDDEN!"
		obtained_desc.text = "CRYO SENTINELS NEUTRALIZED. CONTAINMENT VAULT ACCESSIBLE."
		obtained_banner.visible = true
		obtained_banner.modulate.a = 0.0
		var tb := create_tween()
		tb.tween_property(obtained_banner, "modulate:a", 1.0, 0.4)
		tb.tween_interval(3.2)
		tb.tween_property(obtained_banner, "modulate:a", 0.0, 0.5)
		await tb.finished
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
	elif not _sentinels.is_empty():
		objective_label.text = "OBJECTIVE: Defeat Cryo Sentinels (%d remaining) to unlock containment vault." % _sentinels.size()
		objective_label.modulate = Color(1.0, 0.4, 0.4, 1.0)
	elif not _chest_unlocked:
		objective_label.text = "OBJECTIVE: Containment ice breaking — cache emerging..."
		objective_label.modulate = Color(0.4, 0.85, 1.0, 1.0)
	else:
		objective_label.text = "OBJECTIVE: Containment vault open — recover the component!"
		objective_label.modulate = Color(0.3, 0.9, 1.0, 1.0)
