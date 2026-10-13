extends Control

# Interactive Holographic Map for Echoes of Eternity: 3 Planetary Regions

signal region_selected(region_id: String)
signal map_closed()

@onready var btn_ember: Button = %BtnEmber
@onready var btn_verdant: Button = %BtnVerdant
@onready var btn_frostfall: Button = %BtnFrostfall

@onready var ember_status: Label = %EmberStatus
@onready var verdant_status: Label = %VerdantStatus
@onready var frostfall_status: Label = %FrostfallStatus

# Detail panel
@onready var detail_panel: PanelContainer = %DetailPanel
@onready var detail_title: Label = %DetailTitle
@onready var detail_desc: Label = %DetailDesc
@onready var detail_comp_name: Label = %DetailCompName
@onready var detail_comp_status: Label = %DetailCompStatus
@onready var detail_comp_icon: TextureRect = %DetailCompIcon
@onready var btn_deploy: Button = %BtnDeploy
@onready var btn_return_crash: Button = get_node_or_null("%BtnReturnCrash")
@onready var btn_close: Button = %BtnClose

# Teleport VFX
@onready var teleport_rect: ColorRect = %TeleportRect
@onready var teleport_particles: CPUParticles2D = %TeleportParticles

var _selected_region: String = "ember_wastes"
var _is_deploying: bool = false

const COMPONENT_ICONS := {
	"plasma_regulator": "res://assets/images/plasma_regulator.png",
	"navigation_core": "res://assets/images/navigation_core.png",
	"quantum_power_cell": "res://assets/images/quantum_power_cell.png"
}
const UNKNOWN_ICON := "res://assets/images/component_unknown.png"

func _ready() -> void:
	teleport_rect.visible = false
	teleport_particles.emitting = false
	
	btn_ember.pressed.connect(_select_region.bind("ember_wastes"))
	btn_verdant.pressed.connect(_select_region.bind("verdant_ruins"))
	btn_frostfall.pressed.connect(_select_region.bind("frostfall_expanse"))
	
	btn_deploy.pressed.connect(_on_deploy_pressed)
	if btn_return_crash:
		btn_return_crash.pressed.connect(_on_return_crash_pressed)
	btn_close.pressed.connect(close_map)
	
	var buttons = [btn_ember, btn_verdant, btn_frostfall, btn_deploy, btn_close]
	if btn_return_crash: buttons.append(btn_return_crash)
	for btn in buttons:
		if btn:
			btn.mouse_entered.connect(_on_btn_hover)
			btn.focus_entered.connect(_on_btn_hover)
		
	refresh_map()
	_select_region("ember_wastes")

func open_map() -> void:
	visible = true
	_is_deploying = false
	teleport_rect.visible = false
	btn_deploy.disabled = false
	if btn_return_crash: btn_return_crash.disabled = false
	btn_ember.disabled = false
	btn_verdant.disabled = false
	btn_frostfall.disabled = false
	refresh_map()
	_select_region(_selected_region)
	btn_deploy.grab_focus()

func close_map() -> void:
	if _is_deploying:
		return
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_back()
	visible = false
	map_closed.emit()

func refresh_map() -> void:
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs:
		return
		
	_update_region_badge(ember_status, gs.region_status.get("ember_wastes", "NOT VISITED"), gs.has_component("plasma_regulator"))
	_update_region_badge(verdant_status, gs.region_status.get("verdant_ruins", "NOT VISITED"), gs.has_component("navigation_core"))
	_update_region_badge(frostfall_status, gs.region_status.get("frostfall_expanse", "NOT VISITED"), gs.has_component("quantum_power_cell"))

func _update_region_badge(label: Label, status: String, has_comp: bool) -> void:
	if not label: return
	if has_comp or status == "COMPLETE":
		label.text = "[RECOVERED // COMPLETE]"
		label.modulate = Color(0.2, 1.0, 0.4, 1.0)
	elif status == "IN PROGRESS":
		label.text = "[IN PROGRESS]"
		label.modulate = Color(1.0, 0.85, 0.2, 1.0)
	else:
		label.text = "[UNEXPLORED]"
		label.modulate = Color(0.5, 0.8, 1.0, 0.8)

func _select_region(region_id: String) -> void:
	_selected_region = region_id
	var gs: Node = get_node_or_null("/root/GameState")
	if not gs or not gs.REGION_DATA.has(region_id):
		return
		
	var data: Dictionary = gs.REGION_DATA[region_id]
	var theme_col: Color = data.get("theme_color", Color(0.3, 0.85, 1.0))
	
	# Update active card highlight
	_update_card_highlights(region_id)
	
	detail_title.text = data["name"].to_upper()
	detail_title.modulate = theme_col
	
	var desc_text: String = data["description"]
	if data.has("terrain"):
		desc_text += "\n\nTERRAIN & ANOMALIES:\n• " + data["terrain"]
	if data.has("quote"):
		desc_text += "\n\n“" + data["quote"] + "”"
	detail_desc.text = desc_text
	
	var comp_id: String = data["component_id"]
	var is_collected: bool = gs.has_component(comp_id)
	
	# Strictly obscure component name, icon, and telemetry until discovered/collected
	if is_collected:
		detail_comp_name.text = "RECOVERED: " + data["component_name"].to_upper()
		detail_comp_name.modulate = Color(0.3, 1.0, 0.5, 1.0)
		detail_comp_status.text = "STATUS: SECURED & ON BOARD [COMPLETE]"
		detail_comp_status.modulate = Color(0.3, 1.0, 0.5, 1.0)
		btn_deploy.text = "REVISIT " + data["name"].to_upper()
		if COMPONENT_ICONS.has(comp_id) and ResourceLoader.exists(COMPONENT_ICONS[comp_id]):
			detail_comp_icon.texture = load(COMPONENT_ICONS[comp_id])
		detail_comp_icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		detail_comp_name.text = "TARGET COMPONENT: ??? [UNDISCOVERED]"
		detail_comp_name.modulate = Color(0.7, 0.85, 1.0, 0.9)
		detail_comp_status.text = "STATUS: SIGNAL OBSCURED — EXPLORATION REQUIRED"
		detail_comp_status.modulate = Color(0.6, 0.8, 1.0, 0.75)
		btn_deploy.text = "DEPLOY TO " + data["name"].to_upper()
		if ResourceLoader.exists(UNKNOWN_ICON):
			detail_comp_icon.texture = load(UNKNOWN_ICON)
		else:
			detail_comp_icon.texture = null
		detail_comp_icon.modulate = Color(0.5, 0.8, 1.0, 0.7)
		
	# Subtle holographic pulse on detail panel
	if detail_panel:
		var p_tween := create_tween()
		p_tween.tween_property(detail_panel, "modulate", Color(1.15, 1.15, 1.2, 1.0), 0.08)
		p_tween.tween_property(detail_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.18)
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()
	region_selected.emit(region_id)

func _update_card_highlights(selected_id: String) -> void:
	var cards := {
		"ember_wastes": btn_ember,
		"verdant_ruins": btn_verdant,
		"frostfall_expanse": btn_frostfall
	}
	for reg_key in cards:
		var btn: Button = cards[reg_key]
		if not btn: continue
		if reg_key == selected_id:
			var t := create_tween()
			t.tween_property(btn, "modulate", Color(1.25, 1.25, 1.25, 1.0), 0.12)
			btn.z_index = 1
		else:
			var t := create_tween()
			t.tween_property(btn, "modulate", Color(0.85, 0.88, 0.92, 0.85), 0.12)
			btn.z_index = 0

func _on_deploy_pressed() -> void:
	if _is_deploying:
		return
	_is_deploying = true
	
	# Lock buttons to prevent duplicate clicks
	btn_deploy.disabled = true
	if btn_return_crash: btn_return_crash.disabled = true
	btn_ember.disabled = true
	btn_verdant.disabled = true
	btn_frostfall.disabled = true
	
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()
		if ResourceLoader.exists("res://assets/audio/reentry.wav"):
			am.play_sfx(load("res://assets/audio/reentry.wav"), -4.0, 1.3)
			
	# Trigger teleport sequence
	teleport_rect.visible = true
	teleport_rect.modulate.a = 0.0
	teleport_particles.emitting = true
	
	var tween := create_tween()
	tween.tween_property(teleport_rect, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.deploy_to_region(_selected_region)

func _on_return_crash_pressed() -> void:
	if _is_deploying:
		return
	_is_deploying = true
	
	# Lock buttons to prevent duplicate clicks
	btn_deploy.disabled = true
	if btn_return_crash: btn_return_crash.disabled = true
	btn_ember.disabled = true
	btn_verdant.disabled = true
	btn_frostfall.disabled = true
	
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()
	
	teleport_rect.visible = true
	teleport_rect.modulate.a = 0.0
	teleport_particles.emitting = true
	
	var tween := create_tween()
	tween.tween_property(teleport_rect, "modulate:a", 1.0, 0.45)
	await tween.finished
	
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.return_to_crash_site()

func _on_btn_hover() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_hover()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or _is_deploying:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		close_map()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_M:
		get_viewport().set_input_as_handled()
		close_map()
	elif event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER):
		get_viewport().set_input_as_handled()
		_on_deploy_pressed()
