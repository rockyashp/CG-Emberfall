class_name TestEmberfall
extends Node

## Automated test suite for Emberfall: The Three Trials
## Verifies scene loading, node hierarchies, animations, combat math, progression, and saving

var passed_count: int = 0
var failed_count: int = 0
var test_log: Array[String] = []

func _ready() -> void:
	print("\n=======================================================")
	print("   EMBERFALL: THE THREE TRIALS — AUTOMATED TEST SUITE   ")
	print("=======================================================\n")
	
	run_all_tests()
	
	print("\n-------------------------------------------------------")
	print("TEST RESULTS SUMMARY: %d PASSED, %d FAILED" % [passed_count, failed_count])
	print("-------------------------------------------------------\n")
	
	if failed_count == 0:
		print(">> ALL TEST ASSERTIONS COMPLETED SUCCESSFULLY! <<\n")
	else:
		print(">> SOME TESTS FAILED! CHECK LOGS ABOVE. <<\n")

func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		passed_count += 1
		print("[PASS] %s" % test_name)
		test_log.append("[PASS] %s" % test_name)
	else:
		failed_count += 1
		printerr("[FAIL] %s" % test_name)
		test_log.append("[FAIL] %s" % test_name)

func run_all_tests() -> void:
	test_progression_system()
	test_scene_resources()
	test_player_scene()
	test_enemy_scenes()
	test_boss_scene()
	test_level_scenes()
	test_combat_and_progression_math()

func test_progression_system() -> void:
	print(">> Running Progression System Tests...")
	ProgressionManager.reset_progression()
	assert_true(ProgressionManager.shards == 0, "Progression resets with 0 shards")
	assert_true(ProgressionManager.vitality_level == 0, "Base vitality level is 0")
	assert_true(ProgressionManager.damage_level == 0, "Base damage level is 0")
	
	# Test adding shards
	ProgressionManager.add_shards(60)
	assert_true(ProgressionManager.shards == 60, "Adding 60 shards updates balance")
	
	# Test purchasing vitality upgrade
	var v_cost = ProgressionManager.get_upgrade_cost("vitality")
	assert_true(v_cost > 0, "Vitality cost is positive (%d)" % v_cost)
	var bought = ProgressionManager.purchase_upgrade("vitality")
	assert_true(bought, "Successfully purchased vitality upgrade")
	assert_true(ProgressionManager.vitality_level == 1, "Vitality level incremented to 1")
	assert_true(ProgressionManager.get_max_hp_bonus() == 20.0, "Vitality grants +20 Max HP bonus")
	
	# Test purchasing damage upgrade
	var bought_dmg = ProgressionManager.purchase_upgrade("damage")
	assert_true(bought_dmg, "Successfully purchased damage upgrade")
	assert_true(ProgressionManager.damage_level == 1, "Damage level incremented to 1")
	assert_true(is_equal_approx(ProgressionManager.get_damage_multiplier(), 1.15), "Damage multiplier is 1.15x (+15%)")
	
	# Test burst multiplier
	assert_true(is_equal_approx(ProgressionManager.get_burst_multiplier(), 1.0), "Burst multiplier is 1.0 at level 0")
	ProgressionManager.purchase_upgrade("burst")
	assert_true(is_equal_approx(ProgressionManager.get_burst_multiplier(), 1.25), "Burst multiplier is 1.25 at level 1")
	
	# Test save & load
	ProgressionManager.save_progression()
	var cur_shards = ProgressionManager.shards
	var cur_vit = ProgressionManager.vitality_level
	ProgressionManager.load_progression()
	assert_true(ProgressionManager.shards == cur_shards, "Saved shards persist after reload")
	assert_true(ProgressionManager.vitality_level == cur_vit, "Saved vitality level persists after reload")

func test_scene_resources() -> void:
	print(">> Running Scene Resource Loading Tests...")
	var scenes_to_check = [
		"res://scenes/main/main.tscn",
		"res://scenes/main/main_menu.tscn",
		"res://scenes/main/game_over.tscn",
		"res://scenes/main/victory.tscn",
		"res://scenes/player/player.tscn",
		"res://scenes/player/player_weapon.tscn",
		"res://scenes/player/player_hitbox.tscn",
		"res://scenes/enemies/imp.tscn",
		"res://scenes/enemies/puglin.tscn",
		"res://scenes/boss/boss.tscn",
		"res://scenes/boss/boss_weapon.tscn",
		"res://scenes/levels/ashen_court.tscn",
		"res://scenes/levels/obsidian_gallery.tscn",
		"res://scenes/levels/ember_throne.tscn",
		"res://scenes/levels/exit_gate.tscn",
		"res://scenes/pickups/upgrade_reward.tscn",
		"res://scenes/pickups/ember_pickup.tscn",
		"res://scenes/combat/hit_effect.tscn",
		"res://scenes/combat/slash_effect.tscn",
		"res://scenes/combat/ember_burst_effect.tscn",
		"res://scenes/combat/attack_telegraph.tscn",
		"res://scenes/combat/damage_number.tscn",
		"res://scenes/ui/hud.tscn",
		"res://scenes/ui/boss_health_bar.tscn",
		"res://scenes/ui/upgrade_selection.tscn",
		"res://scenes/ui/pause_menu.tscn"
	]
	
	for path in scenes_to_check:
		var res = ResourceLoader.load(path)
		assert_true(res != null, "Scene resource loads: %s" % path)

func test_player_scene() -> void:
	print(">> Running Player Scene Tests...")
	var p_scene = load("res://scenes/player/player.tscn") as PackedScene
	var player = p_scene.instantiate() as PlayerController
	add_child(player)
	
	assert_true(player != null, "Player instantiates successfully")
	assert_true(player.is_in_group("player"), "Player is in 'player' group")
	
	var col = player.get_node_or_null("CollisionShape3D")
	assert_true(col != null, "Player has CollisionShape3D")
	
	var hitbox = player.get_node_or_null("PlayerHitbox")
	assert_true(hitbox != null, "Player has PlayerHitbox Area3D")
	
	var cam_mount = player.get_node_or_null("CameraMount")
	assert_true(cam_mount != null, "Player has CameraMount")
	var cam = cam_mount.get_node_or_null("Camera3D")
	assert_true(cam != null, "CameraMount contains Camera3D")
	
	var anim = player.find_child("AnimationPlayer", true, false) as AnimationPlayer
	assert_true(anim != null, "Player contains AnimationPlayer")
	if anim:
		assert_true(anim.has_animation("Idle"), "Player AnimationPlayer has 'Idle'")
		assert_true(anim.has_animation("Run"), "Player AnimationPlayer has 'Run'")
		assert_true(anim.has_animation("SwordSlash"), "Player AnimationPlayer has 'SwordSlash'")
		assert_true(anim.has_animation("Death"), "Player AnimationPlayer has 'Death'")
	
	player.queue_free()

func test_enemy_scenes() -> void:
	print(">> Running Enemy Scene Tests...")
	# Imp
	var imp_scn = load("res://scenes/enemies/imp.tscn") as PackedScene
	var imp = imp_scn.instantiate() as ImpEnemy
	add_child(imp)
	assert_true(imp != null, "Imp instantiates successfully")
	assert_true(imp.is_in_group("enemies"), "Imp is in 'enemies' group")
	assert_true(imp.max_hp > 0.0, "Imp has valid max_hp (%f)" % imp.max_hp)
	assert_true(imp.move_speed > 4.0, "Imp has fast move speed (%f)" % imp.move_speed)
	imp.queue_free()
	
	# Puglin
	var pug_scn = load("res://scenes/enemies/puglin.tscn") as PackedScene
	var pug = pug_scn.instantiate() as PuglinEnemy
	add_child(pug)
	assert_true(pug != null, "Puglin instantiates successfully")
	assert_true(pug.is_in_group("enemies"), "Puglin is in 'enemies' group")
	assert_true(pug.max_hp > 60.0, "Puglin has high tanky max_hp (%f)" % pug.max_hp)
	assert_true(pug.attack_damage > 18.0, "Puglin has heavy slam damage (%f)" % pug.attack_damage)
	pug.queue_free()

func test_boss_scene() -> void:
	print(">> Running Boss Scene Tests...")
	var boss_scn = load("res://scenes/boss/boss.tscn") as PackedScene
	var boss = boss_scn.instantiate() as AshenWardenBoss
	add_child(boss)
	assert_true(boss != null, "The Ashen Warden boss instantiates successfully")
	assert_true(boss.is_in_group("boss"), "Boss is in 'boss' group")
	assert_true(boss.max_hp >= 300.0, "Boss has monumental max_hp (%f)" % boss.max_hp)
	assert_true(boss.current_phase == 1, "Boss starts in Phase 1")
	
	var col = boss.get_node_or_null("CollisionShape3D")
	assert_true(col != null, "Boss has CollisionShape3D")
	
	var anim = boss.find_child("AnimationPlayer", true, false) as AnimationPlayer
	assert_true(anim != null, "Boss has AnimationPlayer")
	if anim:
		assert_true(anim.has_animation("Idle"), "Boss has 'Idle' animation")
		assert_true(anim.has_animation("SwordSlash"), "Boss has 'SwordSlash' animation")
		assert_true(anim.has_animation("Death"), "Boss has 'Death' animation")
	
	boss.queue_free()

func test_level_scenes() -> void:
	print(">> Running Level Scene Structure Tests...")
	var levels = [
		{"name": "Level 1: Ashen Court", "path": "res://scenes/levels/ashen_court.tscn", "is_boss": false},
		{"name": "Level 2: Obsidian Gallery", "path": "res://scenes/levels/obsidian_gallery.tscn", "is_boss": false},
		{"name": "Level 3: Ember Throne", "path": "res://scenes/levels/ember_throne.tscn", "is_boss": true}
	]
	
	for lvl in levels:
		var scn = load(lvl["path"]) as PackedScene
		assert_true(scn != null, "Level scene loads: %s" % lvl["name"])
		var node = scn.instantiate() as RoomController
		add_child(node)
		
		assert_true(node.player_spawn != null, "%s has valid PlayerSpawn marker" % lvl["name"])
		assert_true(node.spawn_points != null, "%s has SpawnPoints node" % lvl["name"])
		assert_true(node.spawn_points.get_child_count() > 0, "%s has at least 1 spawn marker (%d)" % [lvl["name"], node.spawn_points.get_child_count()])
		assert_true(node.exit_gate != null, "%s has ExitGate" % lvl["name"])
		assert_true(node.is_boss_room == lvl["is_boss"], "%s boss room flag matches (%s)" % [lvl["name"], str(lvl["is_boss"])])
		
		node.queue_free()

func test_combat_and_progression_math() -> void:
	print(">> Running Combat & Roguelike Math Tests...")
	# Verify that damage bonuses scale cleanly
	var base_dmg = 28.0
	var upgraded_dmg = base_dmg * ProgressionManager.get_damage_multiplier()
	assert_true(upgraded_dmg >= base_dmg, "Upgraded damage (%f) >= base damage (%f)" % [upgraded_dmg, base_dmg])
	
	# Verify dash cooldown scaling
	var base_dash_cd = 0.7
	var upgraded_dash_cd = base_dash_cd * ProgressionManager.get_dash_cooldown_multiplier()
	assert_true(upgraded_dash_cd <= base_dash_cd, "Upgraded dash cooldown (%f) <= base (%f)" % [upgraded_dash_cd, base_dash_cd])
	
	# Verify room names and count
	assert_true(GameManager.ROOM_NAMES.size() == 3, "Exactly THREE combat trials configured")
	assert_true(GameManager.ROOM_SCENE_PATHS.size() == 3, "Exactly THREE room scene paths configured")
