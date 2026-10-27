class_name GameManagerClass
extends Node

## Core Game Manager handling run state, room progression, combat signals, waves, and lifecycle

signal room_started(room_index: int, room_name: String)
signal room_cleared()
signal enemy_spawned()
signal enemy_defeated(enemy_node)
signal player_health_updated(current_hp: float, max_hp: float)
signal player_died()
signal embers_updated(current_embers: int)
signal boss_spawned(boss_node)
signal boss_health_updated(current_hp: float, max_hp: float, phase: int)
signal boss_defeated()
signal victory_achieved()
signal upgrade_requested()
signal announcement_requested(title_text: String, subtitle_text: String)
signal wave_updated(current_wave: int, total_waves: int, enemies_remaining: int)

const ROOM_NAMES: Array[String] = [
	"The Ashen Court",
	"The Obsidian Gallery",
	"The Ember Throne"
]

const ROOM_SCENE_PATHS: Array[String] = [
	"res://scenes/levels/ashen_court.tscn",
	"res://scenes/levels/obsidian_gallery.tscn",
	"res://scenes/levels/ember_throne.tscn"
]

var current_room_index: int = 0
var run_embers: int = 0
var enemies_remaining: int = 0
var is_room_cleared: bool = false
var is_run_active: bool = false
var current_player: Node3D = null
var current_level_node: Node3D = null

# Wave tracking
var current_wave: int = 1
var total_waves: int = 1
var has_more_waves: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_new_run() -> void:
	current_room_index = 0
	run_embers = 0
	is_run_active = true
	is_room_cleared = false
	current_wave = 1
	total_waves = 1
	has_more_waves = false
	embers_updated.emit(run_embers)
	load_room(0)

func load_room(room_idx: int) -> void:
	if room_idx < 0 or room_idx >= ROOM_SCENE_PATHS.size():
		return
	
	current_room_index = room_idx
	is_room_cleared = false
	enemies_remaining = 0
	current_wave = 1
	total_waves = 1
	has_more_waves = false
	
	var path = ROOM_SCENE_PATHS[current_room_index]
	get_tree().change_scene_to_file(path)

func on_level_ready(level_node: Node3D, player_node: Node3D) -> void:
	current_level_node = level_node
	current_player = player_node
	var room_name = ROOM_NAMES[current_room_index]
	room_started.emit(current_room_index, room_name)

func set_wave_info(cur: int, tot: int, more_waves: bool) -> void:
	current_wave = cur
	total_waves = tot
	has_more_waves = more_waves
	wave_updated.emit(current_wave, total_waves, enemies_remaining)

func register_enemy() -> void:
	enemies_remaining += 1
	enemy_spawned.emit()
	wave_updated.emit(current_wave, total_waves, enemies_remaining)

func unregister_enemy(enemy_node: Node3D) -> void:
	enemies_remaining = maxi(0, enemies_remaining - 1)
	enemy_defeated.emit(enemy_node)
	
	# Award run embers
	add_embers(5)
	wave_updated.emit(current_wave, total_waves, enemies_remaining)
	
	if enemies_remaining <= 0 and not is_room_cleared and not has_more_waves:
		on_room_cleared()

func register_boss(boss_node: Node3D) -> void:
	boss_spawned.emit(boss_node)

func on_boss_hp_changed(curr: float, max_v: float, phase: int) -> void:
	boss_health_updated.emit(curr, max_v, phase)

func on_boss_defeated() -> void:
	add_embers(50)
	ProgressionManager.add_shards(30)
	boss_defeated.emit()
	victory_achieved.emit()
	announcement_requested.emit("★ THE ASHEN WARDEN HAS FALLEN ★", "THE THREE TRIALS ARE CONQUERED")
	if AudioManager:
		AudioManager.play_room_clear()
	
	# Automatically transition to Victory screen after delay to show death animation and ember shower
	_delayed_scene_transition("res://scenes/main/victory.tscn", 2.8)

func on_room_cleared() -> void:
	is_room_cleared = true
	room_cleared.emit()
	announcement_requested.emit("★ CHAMBER SECURED ★", "COLLECT YOUR REWARD & PROCEED")
	if AudioManager:
		AudioManager.play_room_clear()
	
	# In room 1 or 2, grant permanent shards and trigger upgrade reward choice
	if current_room_index < 2:
		ProgressionManager.add_shards(10)
		upgrade_requested.emit()

func advance_to_next_room() -> void:
	if current_room_index + 1 < ROOM_SCENE_PATHS.size():
		load_room(current_room_index + 1)
	else:
		on_boss_defeated()

func add_embers(amount: int) -> void:
	if amount > 0:
		run_embers += amount
		embers_updated.emit(run_embers)

func on_player_death() -> void:
	if not is_run_active:
		return
	is_run_active = false
	
	# Convert 50% of run embers to permanent shards on death
	var earned_shards = int(run_embers * 0.5)
	if earned_shards > 0:
		ProgressionManager.add_shards(earned_shards)
	
	player_died.emit()
	announcement_requested.emit("THE EMBER FADES", "YOUR SOUL RETURNS TO THE SANCTUARY")
	
	# Automatically transition to Game Over screen after death collapse
	_delayed_scene_transition("res://scenes/main/game_over.tscn", 2.2)

func _delayed_scene_transition(scene_path: String, delay_sec: float) -> void:
	var tree = get_tree()
	if not tree:
		return
	await tree.create_timer(delay_sec).timeout
	get_tree().change_scene_to_file(scene_path)

func restart_run() -> void:
	start_new_run()

func return_to_main_menu() -> void:
	is_run_active = false
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
