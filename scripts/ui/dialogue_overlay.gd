extends Control

# Cinematic Sci-Fi Dialogue System for Echoes of Eternity

signal dialogue_finished()
signal sword_gifted()
signal map_opened_request()

@onready var panel: PanelContainer = %DialogPanel
@onready var portrait_rect: TextureRect = %Portrait
@onready var speaker_label: Label = %SpeakerLabel
@onready var dialog_text: Label = %DialogText
@onready var prompt_advance: Label = %PromptAdvance

# Item gift popup overlay
@onready var gift_popup: PanelContainer = %GiftPopup
@onready var gift_icon: TextureRect = %GiftIcon
@onready var gift_title: Label = %GiftTitle
@onready var gift_desc: Label = %GiftDesc

var _dialogue_lines: Array[Dictionary] = []
var _current_index: int = 0
var _is_typing: bool = false
var _type_tween: Tween = null
var _is_showing_gift: bool = false

const PORTRAIT_RIX := "res://assets/images/rix_portrait.png"
const PORTRAIT_GRANDFATHER := "res://assets/images/grandfather_portrait.png"

func _ready() -> void:
	visible = false
	if gift_popup: gift_popup.visible = false

func start_dialogue(lines: Array[Dictionary]) -> void:
	_dialogue_lines = lines
	_current_index = 0
	visible = true
	if gift_popup: gift_popup.visible = false
	_is_showing_gift = false
	var scene: Node = get_tree().current_scene if get_tree() else null
	if scene:
		var p: Node = scene.find_child("Player", true, false)
		if p and "is_locked" in p:
			p.is_locked = true
	_show_current_line()

func _show_current_line() -> void:
	if _current_index >= _dialogue_lines.size():
		_finish_dialogue()
		return
		
	var entry: Dictionary = _dialogue_lines[_current_index]
	
	# Check for special gift event in dialogue line
	if entry.get("event") == "give_sword" and not _is_showing_gift:
		_show_sword_gift()
		return
		
	var speaker: String = entry.get("speaker", "UNKNOWN")
	var text: String = entry.get("text", "")
	var portrait_path: String = entry.get("portrait", PORTRAIT_RIX)
	
	speaker_label.text = speaker
	if speaker.to_lower().contains("rix"):
		speaker_label.modulate = Color(0.3, 0.85, 1.0, 1.0)
	elif speaker.to_lower().contains("grandfather") or speaker.to_lower().contains("stranger"):
		speaker_label.modulate = Color(1.0, 0.75, 0.35, 1.0)
	else:
		speaker_label.modulate = Color(0.9, 0.95, 1.0, 1.0)
		
	if ResourceLoader.exists(portrait_path):
		portrait_rect.texture = load(portrait_path)
		
	_type_text(text)

func _type_text(full_text: String) -> void:
	if _type_tween and _type_tween.is_valid():
		_type_tween.kill()
		
	dialog_text.text = full_text
	dialog_text.visible_ratio = 0.0
	_is_typing = true
	prompt_advance.visible = false
	
	var duration: float = clampf(full_text.length() * 0.022, 0.6, 1.8)
	_type_tween = create_tween()
	_type_tween.tween_property(dialog_text, "visible_ratio", 1.0, duration).set_ease(Tween.EASE_OUT)
	_type_tween.finished.connect(func():
		_is_typing = false
		prompt_advance.visible = true
	)

func _show_sword_gift() -> void:
	_is_showing_gift = true
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.acquire_sword()
	sword_gifted.emit()
	
	if gift_popup:
		gift_popup.visible = true
		gift_popup.modulate.a = 0.0
		gift_title.text = "WEAPON ACQUIRED // ANCIENT PLASMA BLADE"
		gift_desc.text = "Gifted by your grandfather. Press [F] or [J] or [LEFT CLICK] to wield."
		if ResourceLoader.exists("res://assets/images/ancient_sword.png"):
			gift_icon.texture = load("res://assets/images/ancient_sword.png")
		var tween := create_tween()
		tween.tween_property(gift_popup, "modulate:a", 1.0, 0.4)
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_click()

func advance_dialogue() -> void:
	if _is_showing_gift:
		# Close gift popup and resume
		var tween := create_tween()
		tween.tween_property(gift_popup, "modulate:a", 0.0, 0.3)
		await tween.finished
		if gift_popup: gift_popup.visible = false
		_is_showing_gift = false
		_current_index += 1
		_show_current_line()
		return
		
	if _is_typing:
		# Skip typewriter
		if _type_tween and _type_tween.is_valid():
			_type_tween.kill()
		dialog_text.visible_ratio = 1.0
		_is_typing = false
		prompt_advance.visible = true
		return
		
	var am: Node = get_node_or_null("/root/AudioManager")
	if am: am.play_click()
	
	_current_index += 1
	_show_current_line()

func _finish_dialogue() -> void:
	visible = false
	var scene: Node = get_tree().current_scene if get_tree() else null
	if scene:
		var p: Node = scene.find_child("Player", true, false)
		if p and "is_locked" in p:
			p.is_locked = false
	dialogue_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			advance_dialogue()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		advance_dialogue()
