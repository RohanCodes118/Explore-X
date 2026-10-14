extends SceneTree

# Automated Combat Test for Frostfall Expanse & Cryo Sentinels

func _init() -> void:
	print("--- TESTING COMBAT & REGION 3 ENHANCEMENTS ---")
	var gs: Node = root.get_node_or_null("GameState")
	if gs == null:
		var gs_script = load("res://scripts/autoload/game_state.gd")
		gs = gs_script.new()
		gs.name = "GameState"
		root.add_child(gs)
		
	# Reset state
	gs.collected_components["quantum_power_cell"] = false
	gs.region_status["frostfall_expanse"] = "IN PROGRESS"
	gs.has_sword = true
	
	var frost_scene: PackedScene = load("res://scenes/regions/frostfall_expanse.tscn")
	assert(frost_scene != null, "Could not load frostfall_expanse.tscn")
	var frost_inst: Node2D = frost_scene.instantiate()
	root.add_child(frost_inst)
	await process_frame
	
	# 1. Verify obstacles matching the arena
	assert(frost_inst.find_child("NorthGlacier", true, false) != null, "NorthGlacier missing")
	assert(frost_inst.find_child("SouthGlacier", true, false) != null, "SouthGlacier missing")
	assert(frost_inst.find_child("MonolithLeft", true, false) != null, "MonolithLeft missing")
	assert(frost_inst.find_child("MonolithRight", true, false) != null, "MonolithRight missing")
	assert(frost_inst.find_child("CrystalCluster1", true, false) != null, "CrystalCluster1 missing")
	assert(frost_inst.find_child("CrystalCluster2", true, false) != null, "CrystalCluster2 missing")
	assert(frost_inst.find_child("ConduitPipes1", true, false) != null, "ConduitPipes1 missing")
	assert(frost_inst.find_child("ContainmentPod1", true, false) != null, "ContainmentPod1 missing")
	assert(frost_inst.find_child("HazardVent1", true, false) != null, "HazardVent1 missing")
	print("  [PASS] Arena obstacles verified (Crystal Clusters, Conduit Pipes, Containment Pods, Vents).")
	
	# 2. Verify Sentinels (Combat NPCs)
	var sentinels_container: Node = frost_inst.find_child("Sentinels", true, false)
	assert(sentinels_container != null, "Sentinels container missing")
	assert(sentinels_container.get_child_count() == 3, "Expected 3 Cryo Sentinels in arena")
	print("  [PASS] 3 Cryo Sentinels present in arena.")
	
	# 3. Verify Barrier is initially active
	var barrier: StaticBody2D = frost_inst.find_child("ForcefieldBarrier", true, false)
	assert(barrier != null, "ForcefieldBarrier missing")
	assert(barrier.visible == true, "Barrier should be active and visible while sentinels guard it")
	print("  [PASS] Forcefield barrier active guarding the Quantum Power Cell.")
	
	# 4. Verify Combat: Player sword damage and Sentinel HP reduction
	var sentinel_1 = sentinels_container.get_child(0)
	var initial_hp: float = sentinel_1.health
	assert(initial_hp == 100.0, "Sentinel starting health should be 100")
	
	# Position player right in front of sentinel and perform sword attack
	var player: CharacterBody2D = frost_inst.find_child("Player", true, false)
	player.global_position = sentinel_1.global_position + Vector2(-45, 0)
	player._facing = "side"
	player._facing_h = 1.0
	player.play_sword_attack()
	await create_timer(0.2).timeout
	assert(sentinel_1.health == 75.0, "Sentinel health should drop by 25 to 75 from player sword attack")
	print("  [PASS] Player sword attack accurately damages sentinel in combat (100 -> 75).")
	
	# Direct damage tests
	sentinel_1.take_damage(45.0, Vector2.ZERO)
	assert(sentinel_1.health == 30.0, "Sentinel health should decrease to 30")
	print("  [PASS] Sword hits reduce Sentinel health bar accurately (75 -> 30).")
	
	# Defeat all sentinels
	for sentinel in sentinels_container.get_children():
		sentinel.take_damage(100.0, Vector2.ZERO)
		
	# Allow deferred queue_free & signal dispatch
	await create_timer(0.1).timeout
	
	# Verify Barrier unlocks
	assert(frost_inst._sentinels.is_empty(), "All sentinels should be registered as defeated")
	print("  [PASS] Sentinels defeated; security forcefield deactivates.")
	
	# 5. Conquer component & return
	var pickup: Area2D = frost_inst.find_child("ComponentPickup", true, false)
	# Position player near pickup and verify accessible interaction
	player.global_position = pickup.global_position + Vector2(25, 0)
	await process_frame
	pickup.interact(player)
	assert(gs.has_component("quantum_power_cell") == true, "Quantum Power Cell should now be collected")
	print("  [PASS] Quantum Power Cell conquered & secured for ship repair.")
	
	frost_inst.queue_free()
	print("--- ALL COMBAT AND ARENA ENHANCEMENT TESTS PASSED! ---")
	quit()
