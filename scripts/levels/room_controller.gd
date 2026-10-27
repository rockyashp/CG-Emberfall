class_name RoomController
extends Node3D

## Manages room lifecycle, player spawn, multi-wave enemy encounters, and chamber aspects

@export var room_name: String = "The Ashen Court"
@export var is_boss_room: bool = false
@export var imp_spawn_count: int = 4
@export var puglin_spawn_count: int = 2

@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var spawn_points: Node3D = $SpawnPoints
@onready var exit_gate: ExitGate = $ExitGate
@onready var reward_chest: RewardChest = get_node_or_null("RewardChest")

var player_scene = preload("res://scenes/player/player.tscn")
var imp_scene = preload("res://scenes/enemies/imp.tscn")
var puglin_scene = preload("res://scenes/enemies/puglin.tscn")
var boss_scene = preload("res://scenes/boss/boss.tscn")
var hud_scene = preload("res://scenes/ui/hud.tscn")
var telegraph_scene = preload("res://scenes/combat/attack_telegraph.tscn")
var hit_scene = preload("res://scenes/combat/hit_effect.tscn")

var _spawned_player: PlayerController = null
var current_wave_idx: int = 0
var room_waves: Array[Dictionary] = []
var _is_transitioning_wave: bool = false

func _ready() -> void:
	# Instantiate HUD
	var hud = hud_scene.instantiate()
	add_child(hud)
	
	# Spawn player
	_spawn_player()
	
	# Apply chamber-specific aspect / modifiers
	_apply_level_aspect()
	
	# Notify GameManager
	GameManager.on_level_ready(self, _spawned_player)
	GameManager.enemy_defeated.connect(_on_enemy_defeated)
	
	# Configure room waves
	_setup_wave_configurations()
	
	# Spawn encounter after brief intro delay
	var spawn_timer = get_tree().create_timer(0.5)
	spawn_timer.timeout.connect(_start_initial_encounter)

func _spawn_player() -> void:
	_spawned_player = player_scene.instantiate()
	add_child(_spawned_player)
	if player_spawn:
		_spawned_player.global_position = player_spawn.global_position
	else:
		_spawned_player.global_position = Vector3(0, 0.2, 7)

## Configure distinct wave compositions per chamber
func _setup_wave_configurations() -> void:
	if is_boss_room:
		return
	
	match GameManager.current_room_index:
		0:
			# Trial I: The Ashen Court (2 Waves)
			# Wave 1: 3 Imps (Skirmisher intro)
			# Wave 2: 2 Imps + 2 Puglin Brutes (Frontline reinforcement)
			room_waves = [
				{ "imps": 3, "puglins": 0 },
				{ "imps": 2, "puglins": 2 }
			]
		1:
			# Trial II: The Obsidian Gallery (3 Waves)
			# Wave 1: 3 Imps
			# Wave 2: 2 Puglins + 1 Imp
			# Wave 3: 3 Imps + 2 Puglins (Climax)
			room_waves = [
				{ "imps": 3, "puglins": 0 },
				{ "imps": 1, "puglins": 2 },
				{ "imps": 3, "puglins": 2 }
			]
		_:
			room_waves = [
				{ "imps": imp_spawn_count, "puglins": puglin_spawn_count }
			]

## Apply chamber-specific modifiers for each trial
func _apply_level_aspect() -> void:
	match GameManager.current_room_index:
		0:
			# Level 1: Trial of Steel (Standard baseline)
			pass
		1:
			# Level 2: Trial of Resilience & Corrupted Crystals
			# Player receives accelerated dash recovery from crystal resonance
			if _spawned_player:
				_spawned_player.dash_speed *= 1.15
		2:
			# Level 3: Trial of Flame (Volcanic Boss Chamber)
			# Ember burst power is enhanced by the ambient volcanic heat
			if _spawned_player:
				_spawned_player.burst_cooldown_max = 4.5

func _start_initial_encounter() -> void:
	if is_boss_room:
		_spawn_boss()
	else:
		_start_wave(0)

func _start_wave(wave_idx: int) -> void:
	if wave_idx >= room_waves.size():
		return
	
	current_wave_idx = wave_idx
	_is_transitioning_wave = false
	var wave_data = room_waves[wave_idx]
	var total_w = room_waves.size()
	var has_subsequent_waves = (wave_idx < total_w - 1)
	
	# Broadcast announcement
	if wave_idx == 0:
		GameManager.announcement_requested.emit(
			"★ WAVE 1 / %d ★" % total_w,
			"THE TRIAL COMMENCES — SURVIVE THE PACK"
		)
	else:
		GameManager.announcement_requested.emit(
			"★ WAVE %d / %d: REINFORCEMENTS! ★" % [wave_idx + 1, total_w],
			"NEW FOES EMERGE INTO THE CHAMBER"
		)
		if AudioManager:
			AudioManager.play_burst()
	
	# Update GameManager with wave metadata
	GameManager.set_wave_info(wave_idx + 1, total_w, has_subsequent_waves)
	
	# Spawn wave enemies with telegraph markers
	_spawn_wave_enemies(wave_data["imps"], wave_data["puglins"])

func _spawn_wave_enemies(imp_count: int, pug_count: int) -> void:
	var markers = _get_spawn_markers()
	var marker_idx = 0
	var spawn_queue: Array[Dictionary] = []
	
	for i in range(imp_count):
		var m = markers[marker_idx % markers.size()] as Node3D
		marker_idx += 1
		var spawn_pos = m.global_position + Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))
		spawn_queue.append({ "scene": imp_scene, "pos": spawn_pos, "is_imp": true })
	
	for i in range(pug_count):
		var m = markers[marker_idx % markers.size()] as Node3D
		marker_idx += 1
		var spawn_pos = m.global_position + Vector3(randf_range(-0.6, 0.6), 0, randf_range(-0.6, 0.6))
		spawn_queue.append({ "scene": puglin_scene, "pos": spawn_pos, "is_imp": false })
	
	# Visual danger/summoning rings at all spawn locations
	for item in spawn_queue:
		if telegraph_scene:
			var tel = telegraph_scene.instantiate()
			add_child(tel)
			tel.global_position = item["pos"] + Vector3(0, 0.05, 0)
			tel.duration = 0.55
			tel.radius = 1.4 if item["is_imp"] else 2.2
	
	# Delay actual spawn slightly so telegraph plays first
	await get_tree().create_timer(0.55).timeout
	if not is_instance_valid(self):
		return
	
	for item in spawn_queue:
		var enemy = item["scene"].instantiate() as EnemyBase
		add_child(enemy)
		enemy.global_position = item["pos"]
		
		# Chamber 2 aspect: armored enemies
		if GameManager.current_room_index == 1:
			enemy.max_hp *= 1.15
			enemy.current_hp = enemy.max_hp
		
		# Spawn impact effect
		if hit_scene:
			var fx = hit_scene.instantiate()
			add_child(fx)
			fx.global_position = item["pos"] + Vector3(0, 0.3, 0)

func _on_enemy_defeated(_enemy) -> void:
	if is_boss_room or _is_transitioning_wave:
		return
	
	# If current wave is wiped out and more waves remain, spawn next wave!
	if GameManager.enemies_remaining <= 0 and current_wave_idx < room_waves.size() - 1:
		_is_transitioning_wave = true
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(self):
			_start_wave(current_wave_idx + 1)

func _get_spawn_markers() -> Array[Node]:
	var markers: Array[Node] = []
	if spawn_points and spawn_points.get_child_count() > 0:
		markers = spawn_points.get_children()
	else:
		var pos_list = [
			Vector3(-6, 0.2, -5),
			Vector3(6, 0.2, -5),
			Vector3(-6, 0.2, 3),
			Vector3(6, 0.2, 3),
			Vector3(0, 0.2, -8),
			Vector3(0, 0.2, 0)
		]
		for p in pos_list:
			var m = Marker3D.new()
			m.position = p
			add_child(m)
			markers.append(m)
	return markers

func _spawn_boss() -> void:
	var boss = boss_scene.instantiate()
	add_child(boss)
	if spawn_points and spawn_points.get_child_count() > 0:
		boss.global_position = (spawn_points.get_child(0) as Node3D).global_position
	else:
		boss.global_position = Vector3(0, 0.2, -5)
