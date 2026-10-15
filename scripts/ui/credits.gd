extends Control

# End Credits and Epilogue Sequence for Echoes of Eternity

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var credits_vbox: VBoxContainer = %CreditsVBox
@onready var star_particles: CPUParticles2D = %StarParticles
@onready var action_bar: HBoxContainer = %ActionBar
@onready var btn_continue: Button = %BtnContinue
@onready var btn_menu: Button = %BtnMainMenu
@onready var preview_modal: PanelContainer = %PreviewModal
@onready var btn_close_preview: Button = %BtnClosePreview
@onready var btn_freeroam: Button = %BtnFreeroam
@onready var fade_rect: ColorRect = %FadeRect
@onready var music_player: AudioStreamPlayer = $MusicPlayer

var _scroll_speed: float = 38.0
var _auto_scrolling: bool = true
var _scroll_accum: float = 0.0

const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const CRASH_SITE_SCENE := "res://scenes/gameplay/planet_surface.tscn"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	action_bar.visible = true
	action_bar.modulate.a = 0.0
	preview_modal.visible = false
	
	if star_particles:
		star_particles.emitting = true
		
	# Setup audio
	if ResourceLoader.exists("res://assets/audio/sci_fi_ambient.wav"):
		music_player.stream = load("res://assets/audio/sci_fi_ambient.wav")
		music_player.volume_db = -8.0
		music_player.play()
		
	# Connect buttons
	if not btn_continue.pressed.is_connected(_on_continue_pressed):
		btn_continue.pressed.connect(_on_continue_pressed)
	if not btn_menu.pressed.is_connected(_on_menu_pressed):
		btn_menu.pressed.connect(_on_menu_pressed)
	if not btn_close_preview.pressed.is_connected(_on_close_preview_pressed):
		btn_close_preview.pressed.connect(_on_close_preview_pressed)
	if not btn_freeroam.pressed.is_connected(_on_freeroam_pressed):
		btn_freeroam.pressed.connect(_on_freeroam_pressed)
		
	for btn in [btn_continue, btn_menu, btn_close_preview, btn_freeroam]:
		if btn:
			btn.mouse_entered.connect(_on_btn_hover)
			btn.focus_entered.connect(_on_btn_hover)
			
	# Fade in screen
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.2)
	
	# Reveal action buttons smoothly after a few seconds or when reaching bottom
	var btn_reveal := create_tween()
	btn_reveal.tween_interval(3.5)
	btn_reveal.tween_property(action_bar, "modulate:a", 1.0, 1.0)
	
	# Mark GameState completion
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.complete_game()

func _process(delta: float) -> void:
	if _auto_scrolling and scroll_container:
		_scroll_accum += _scroll_speed * delta
		scroll_container.scroll_vertical = int(_scroll_accum)
		
		# If user reached the very bottom, stop auto scrolling
		var max_scroll = scroll_container.get_v_scroll_bar().max_value - scroll_container.size.y
		if _scroll_accum >= max_scroll and max_scroll > 0:
			_auto_scrolling = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenDrag:
		_auto_scrolling = false # Let player freely scroll if they manually touch/drag

func _on_continue_pressed() -> void:
	_play_click()
	preview_modal.visible = true
	preview_modal.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(preview_modal, "modulate:a", 1.0, 0.25)

func _on_close_preview_pressed() -> void:
	_play_click()
	var tween := create_tween()
	tween.tween_property(preview_modal, "modulate:a", 0.0, 0.2)
	await tween.finished
	preview_modal.visible = false

func _on_freeroam_pressed() -> void:
	_play_click()
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6)
	await tween.finished
	var gs: Node = get_node_or_null("/root/GameState")
	if gs:
		gs.return_to_crash_site()
	else:
		get_tree().change_scene_to_file(CRASH_SITE_SCENE)

func _on_menu_pressed() -> void:
	_play_click()
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6)
	await tween.finished
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_btn_hover() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_hover"):
		am.play_hover()

func _play_click() -> void:
	var am: Node = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_click"):
		am.play_click()
