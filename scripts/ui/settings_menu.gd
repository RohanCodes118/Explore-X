extends Control

signal closed

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton

@onready var master_val_label: Label = %MasterValLabel
@onready var music_val_label: Label = %MusicValLabel
@onready var sfx_val_label: Label = %SFXValLabel

var _updating_ui: bool = false

func _ready() -> void:
	_connect_signals()
	sync_with_settings()

func _connect_signals() -> void:
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	back_button.pressed.connect(_on_back_pressed)
	
	back_button.mouse_entered.connect(_on_button_hover)
	fullscreen_check.mouse_entered.connect(_on_button_hover)

func sync_with_settings() -> void:
	_updating_ui = true
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		master_slider.value = am.master_volume * 100.0
		music_slider.value = am.music_volume * 100.0
		sfx_slider.value = am.sfx_volume * 100.0
		fullscreen_check.button_pressed = am.fullscreen_enabled
		
		master_val_label.text = "%d%%" % int(master_slider.value)
		music_val_label.text = "%d%%" % int(music_slider.value)
		sfx_val_label.text = "%d%%" % int(sfx_slider.value)
	_updating_ui = false

func _on_master_slider_changed(value: float) -> void:
	if _updating_ui:
		return
	master_val_label.text = "%d%%" % int(value)
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.set_master_volume(value / 100.0)

func _on_music_slider_changed(value: float) -> void:
	if _updating_ui:
		return
	music_val_label.text = "%d%%" % int(value)
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.set_music_volume(value / 100.0)

func _on_sfx_slider_changed(value: float) -> void:
	if _updating_ui:
		return
	sfx_val_label.text = "%d%%" % int(value)
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.set_sfx_volume(value / 100.0)
		am.play_click()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if _updating_ui:
		return
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.set_fullscreen(toggled_on)
		am.play_click()

func _on_back_pressed() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_back()
	close_settings()

func _on_button_hover() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am:
		am.play_hover()

func open_settings() -> void:
	sync_with_settings()
	visible = true
	back_button.grab_focus()
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func close_settings() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	visible = false
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_settings()
