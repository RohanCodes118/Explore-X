extends Node

# Global Audio Manager for Echoes of Eternity

const SETTINGS_FILE_PATH := "user://settings.cfg"

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 12

var sfx_hover: AudioStream
var sfx_click: AudioStream
var sfx_back: AudioStream
var ambient_music: AudioStream

var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.85
var fullscreen_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	_load_assets()
	_load_settings()

func _setup_audio_players() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	for i in range(MAX_SFX_PLAYERS):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func _load_assets() -> void:
	if ResourceLoader.exists("res://assets/audio/ui_hover.wav"):
		sfx_hover = load("res://assets/audio/ui_hover.wav")
	if ResourceLoader.exists("res://assets/audio/ui_click.wav"):
		sfx_click = load("res://assets/audio/ui_click.wav")
	if ResourceLoader.exists("res://assets/audio/ui_back.wav"):
		sfx_back = load("res://assets/audio/ui_back.wav")
	if ResourceLoader.exists("res://assets/audio/sci_fi_ambient.wav"):
		ambient_music = load("res://assets/audio/sci_fi_ambient.wav")

func play_music(stream: AudioStream, fade_in_duration: float = 1.0) -> void:
	if not stream:
		return
	if music_player.stream == stream and music_player.playing:
		return
		
	if music_player.playing and fade_in_duration > 0.0:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_in_duration * 0.5)
		await tween.finished
		
	music_player.stream = stream
	music_player.volume_db = -40.0
	music_player.play()
	
	var in_tween := create_tween()
	in_tween.tween_property(music_player, "volume_db", 0.0, fade_in_duration)

func stop_music(fade_out_duration: float = 1.0) -> void:
	if not music_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(music_player, "volume_db", -40.0, fade_out_duration)
	await tween.finished
	music_player.stop()

func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	if not stream:
		return null
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch_scale
			player.play()
			return player
	# If all busy, reuse the first one
	var player: AudioStreamPlayer = sfx_players[0]
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
	return player

func play_hover() -> void:
	if sfx_hover:
		play_sfx(sfx_hover, -4.0, randf_range(0.97, 1.03))

func play_click() -> void:
	if sfx_click:
		play_sfx(sfx_click, -2.0, randf_range(0.98, 1.02))

func play_back() -> void:
	if sfx_back:
		play_sfx(sfx_back, -2.0, 1.0)

# Volume controls (values 0.0 to 1.0)
func set_master_volume(val: float) -> void:
	master_volume = clampf(val, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, master_volume <= 0.01)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(master_volume))
	_save_settings()

func set_music_volume(val: float) -> void:
	music_volume = clampf(val, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, music_volume <= 0.01)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))
	_save_settings()

func set_sfx_volume(val: float) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_mute(bus_idx, sfx_volume <= 0.01)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))
	_save_settings()

func set_fullscreen(val: bool) -> void:
	fullscreen_enabled = val
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master", master_volume)
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("display", "fullscreen", fullscreen_enabled)
	config.save(SETTINGS_FILE_PATH)

func _load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_FILE_PATH)
	if err == OK:
		master_volume = config.get_value("audio", "master", 0.8)
		music_volume = config.get_value("audio", "music", 0.7)
		sfx_volume = config.get_value("audio", "sfx", 0.85)
		fullscreen_enabled = config.get_value("display", "fullscreen", false)
	
	set_master_volume(master_volume)
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
