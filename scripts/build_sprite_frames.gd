@tool
extends SceneTree

# Programmatic builder for Rix's SpriteFrames resource

func _init() -> void:
	print("Building Rix SpriteFrames...")
	var sf := SpriteFrames.new()
	sf.remove_animation("default") # Remove placeholder
	
	var anims := {
		"idle_down": {"dir": "res://assets/images/rix/idle_down", "speed": 6.0, "loop": true},
		"idle_side": {"dir": "res://assets/images/rix/idle_side", "speed": 6.0, "loop": true},
		"idle_up": {"dir": "res://assets/images/rix/idle_up", "speed": 6.0, "loop": true},
		"walk_down": {"dir": "res://assets/images/rix/walk_down", "speed": 8.0, "loop": true},
		"walk_side": {"dir": "res://assets/images/rix/walk_side", "speed": 8.0, "loop": true},
		"walk_up": {"dir": "res://assets/images/rix/walk_up", "speed": 8.0, "loop": true},
		"run_down": {"dir": "res://assets/images/rix/run_down", "speed": 12.0, "loop": true},
		"run_side": {"dir": "res://assets/images/rix/run_side", "speed": 12.0, "loop": true},
		"run_up": {"dir": "res://assets/images/rix/run_up", "speed": 12.0, "loop": true},
		"jump_side": {"dir": "res://assets/images/rix/jump_side", "speed": 8.0, "loop": false},
		"crouch_down": {"dir": "res://assets/images/rix/crouch_down", "speed": 6.0, "loop": false},
		"crouch_side": {"dir": "res://assets/images/rix/crouch_side", "speed": 6.0, "loop": false},
		"crouch_up": {"dir": "res://assets/images/rix/crouch_up", "speed": 6.0, "loop": false},
		"attack_side": {"dir": "res://assets/images/rix/attack_side", "speed": 10.0, "loop": false},
		"interact_down": {"dir": "res://assets/images/rix/interact_down", "speed": 6.0, "loop": false},
		"hurt_down": {"dir": "res://assets/images/rix/hurt_down", "speed": 8.0, "loop": false},
		"death_down": {"dir": "res://assets/images/rix/death_down", "speed": 5.0, "loop": false},
		"crash_recovery": {"dir": "res://assets/images/rix/crash_recovery", "speed": 2.0, "loop": false}
	}
	
	for anim_name in anims.keys():
		var data: Dictionary = anims[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, data["speed"])
		sf.set_animation_loop(anim_name, data["loop"])
		
		var dir_path: String = data["dir"]
		var dir := DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file_names: Array[String] = []
			var f := dir.get_next()
			while f != "":
				if not dir.current_is_dir() and f.ends_with(".png") and not f.ends_with(".import"):
					file_names.append(f)
				f = dir.get_next()
			file_names.sort()
			
			for fn in file_names:
				var tex_path := dir_path + "/" + fn
				var tex: Texture2D = load(tex_path)
				if tex:
					sf.add_frame(anim_name, tex)
			print("  Added animation: %s (%d frames)" % [anim_name, sf.get_frame_count(anim_name)])
		else:
			push_warning("Could not open directory: " + dir_path)
			
	var err := ResourceSaver.save(sf, "res://resources/animations/rix_sprite_frames.tres")
	if err == OK:
		print("Successfully saved rix_sprite_frames.tres!")
	else:
		push_error("Failed to save SpriteFrames: %d" % err)
	quit(0)
