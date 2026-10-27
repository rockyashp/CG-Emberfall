class_name AshenWardenBoss
extends CharacterBody3D

## The Ashen Warden — Final Boss of Emberfall: The Three Trials
## Features 2 distinct phases, 3 attack patterns, telegraphed attacks, and embedded animations

enum State { INTRO, IDLE, CHASE, CLEAVE, CHARGE, HELLFIRE, PHASE_TRANSITION, DEATH }

@export var max_hp: float = 380.0
@export var move_speed: float = 4.2
@export var phase_2_speed_multiplier: float = 1.35

var current_state: State = State.INTRO
var current_hp: float = 380.0
var current_phase: int = 1
var state_timer: float = 0.0

var target_player: Node3D = null
var charge_target_pos: Vector3 = Vector3.ZERO
var charge_dir: Vector3 = Vector3.FORWARD

@onready var visual_root: Node3D = $VisualRoot
@onready var anim_player: AnimationPlayer = $VisualRoot/BossModel/AnimationPlayer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var telegraph_scene = preload("res://scenes/combat/attack_telegraph.tscn")
var hit_scene = preload("res://scenes/combat/hit_effect.tscn")
var burst_scene = preload("res://scenes/combat/ember_burst_effect.tscn")
var dmg_num_scene = preload("res://scenes/combat/damage_number.tscn")
var pickup_scene = preload("res://scenes/pickups/ember_pickup.tscn")
var imp_scene = preload("res://scenes/enemies/imp.tscn")

var _attack_cooldown: float = 0.0
var _last_attack_type: int = 0

func _ready() -> void:
	add_to_group("boss")
	current_hp = max_hp
	GameManager.register_boss(self)
	GameManager.on_boss_hp_changed(current_hp, max_hp, current_phase)
	
	if not anim_player:
		anim_player = find_child("AnimationPlayer", true, false) as AnimationPlayer
	
	_setup_weapon_attachment()
	_find_player()
	
	# Start in Intro
	current_state = State.INTRO
	state_timer = 1.5
	_play_anim("Idle")

func _setup_weapon_attachment() -> void:
	var skeleton = find_child("Skeleton3D", true, false) as Skeleton3D
	if not skeleton:
		return
	
	var bone_name = "Fist.R"
	var bone_idx = skeleton.find_bone(bone_name)
	if bone_idx != -1:
		var bone_attach = skeleton.find_child("BossBoneAttachment", false, false) as BoneAttachment3D
		if not bone_attach:
			bone_attach = BoneAttachment3D.new()
			bone_attach.name = "BossBoneAttachment"
			skeleton.add_child(bone_attach)
		bone_attach.bone_name = bone_name
		bone_attach.bone_idx = bone_idx
		
		var weapon = visual_root.find_child("BossWeapon", true, false)
		if weapon and weapon.get_parent() != bone_attach:
			weapon.get_parent().remove_child(weapon)
			bone_attach.add_child(weapon)
			weapon.position = Vector3(0, 0, 0)
			weapon.rotation_degrees = Vector3(90, 0, 0)

func _find_player() -> void:
	if GameManager.current_player and is_instance_valid(GameManager.current_player):
		target_player = GameManager.current_player
	else:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]

func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		if not is_on_floor():
			velocity.y -= 18.0 * delta
			move_and_slide()
		return
	
	if not target_player or not is_instance_valid(target_player):
		_find_player()
		if not target_player:
			return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
	
	if _attack_cooldown > 0.0:
		_attack_cooldown -= delta
	
	match current_state:
		State.INTRO:
			_process_intro(delta)
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.CLEAVE:
			_process_cleave(delta)
		State.CHARGE:
			_process_charge(delta)
		State.HELLFIRE:
			_process_hellfire(delta)
		State.PHASE_TRANSITION:
			_process_phase_transition(delta)
	
	move_and_slide()

func _face_target(pos: Vector3, weight: float = 0.15) -> void:
	var dir = (pos - global_position)
	dir.y = 0.0
	if dir.length_squared() > 0.01 and visual_root:
		var target_rot = atan2(dir.x, dir.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_rot, weight)

func _process_intro(delta: float) -> void:
	state_timer -= delta
	_face_target(target_player.global_position, 0.1)
	if state_timer <= 0.0:
		current_state = State.CHASE

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	_play_anim("Idle")
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

func _process_chase(delta: float) -> void:
	var dist = global_position.distance_to(target_player.global_position)
	_face_target(target_player.global_position, 0.15)
	
	var cur_speed = move_speed * (phase_2_speed_multiplier if current_phase == 2 else 1.0)
	
	if _attack_cooldown <= 0.0:
		# Decide attack based on distance and phase
		if dist <= 3.2:
			_start_cleave()
			return
		elif dist > 5.0 and randf() < 0.65:
			_start_charge()
			return
		elif current_phase == 2 and randf() < 0.5:
			_start_hellfire()
			return
	
	# Move toward player
	var dir = (target_player.global_position - global_position).normalized()
	dir.y = 0.0
	velocity.x = dir.x * cur_speed
	velocity.z = dir.z * cur_speed
	_play_anim("Run")

# --- ATTACK 1: HEAVY GREATSWORD CLEAVE ---
func _start_cleave() -> void:
	current_state = State.CLEAVE
	state_timer = 0.75 # Wind-up
	velocity.x = 0.0
	velocity.z = 0.0
	_play_anim("Idle")
	
	# Show circular danger zone
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		tel.global_position = global_position + Vector3(0, 0.05, 0)
		tel.duration = 0.75
		tel.radius = 3.4

func _process_cleave(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	
	if state_timer > 0.2:
		_face_target(target_player.global_position, 0.1)
	
	state_timer -= delta
	if state_timer <= 0.0:
		_perform_cleave_strike()

func _perform_cleave_strike() -> void:
	_play_anim("SwordSlash")
	if AudioManager:
		AudioManager.play_slash()
	
	# Check if player hit
	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= 3.6:
			var push_dir = (target_player.global_position - global_position).normalized()
			push_dir.y = 0.2
			target_player.take_damage(28.0, push_dir * 12.0)
	
	_finish_attack(0.8)

# --- ATTACK 2: DIRECTIONAL CHARGE & SLAM ---
func _start_charge() -> void:
	current_state = State.CHARGE
	state_timer = 0.7 # Telegraph
	charge_target_pos = target_player.global_position
	charge_dir = (charge_target_pos - global_position).normalized()
	charge_dir.y = 0.0
	velocity.x = 0.0
	velocity.z = 0.0
	_play_anim("Idle")
	
	# Show danger lane telegraph
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		tel.global_position = charge_target_pos + Vector3(0, 0.05, 0)
		tel.duration = 0.7
		tel.radius = 2.8

func _process_charge(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		# Rapid dash toward target
		var dist = global_position.distance_to(charge_target_pos)
		if dist > 0.8:
			var dash_speed = 15.0
			velocity.x = charge_dir.x * dash_speed
			velocity.z = charge_dir.z * dash_speed
			_play_anim("Run")
		else:
			# Reached target: slam ground!
			_perform_charge_slam()

func _perform_charge_slam() -> void:
	velocity = Vector3.ZERO
	_play_anim("SwordSlash")
	if AudioManager:
		AudioManager.play_boss_stomp()
	
	if burst_scene:
		var burst = burst_scene.instantiate()
		get_parent().add_child(burst)
		burst.global_position = global_position
		burst.damage = 32.0
		burst.radius = 3.6
	
	_finish_attack(1.0)

# --- ATTACK 3: MOLTEN HELLFIRE AREA BURST (Phase 2) ---
func _start_hellfire() -> void:
	current_state = State.HELLFIRE
	state_timer = 0.9
	velocity = Vector3.ZERO
	_play_anim("Victory")
	
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		tel.global_position = global_position + Vector3(0, 0.05, 0)
		tel.duration = 0.9
		tel.radius = 6.2

func _process_hellfire(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		_perform_hellfire_eruption()

func _perform_hellfire_eruption() -> void:
	if AudioManager:
		AudioManager.play_burst()
		AudioManager.play_boss_stomp()
	
	if burst_scene:
		var burst = burst_scene.instantiate()
		get_parent().add_child(burst)
		burst.global_position = global_position
		burst.damage = 40.0
		burst.radius = 6.0
	
	_finish_attack(1.2)

func _finish_attack(cooldown_time: float) -> void:
	_attack_cooldown = cooldown_time
	current_state = State.IDLE
	state_timer = 0.4

func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO) -> void:
	if current_state in [State.DEATH, State.PHASE_TRANSITION]:
		return
	
	current_hp = maxf(0.0, current_hp - amount)
	GameManager.on_boss_hp_changed(current_hp, max_hp, current_phase)
	
	# Phase transition check at 50% HP
	if current_hp <= max_hp * 0.5 and current_phase == 1:
		_start_phase_transition()
		return
	
	if current_hp <= 0.0:
		_die()

func _start_phase_transition() -> void:
	current_phase = 2
	current_state = State.PHASE_TRANSITION
	state_timer = 1.6
	velocity = Vector3.ZERO
	_play_anim("Victory")
	
	GameManager.announcement_requested.emit(
		"★ PHASE II: ENRAGED WARDEN ★",
		"THE ASHEN WARDEN CALLS FLAMING MINIONS"
	)
	
	if AudioManager:
		AudioManager.play_burst()
	
	# Blast enemies and emit shockwave
	if burst_scene:
		var burst = burst_scene.instantiate()
		get_parent().add_child(burst)
		burst.global_position = global_position
		burst.damage = 15.0
		burst.radius = 5.0
	
	# Summon 2 minion imps
	for i in range(2):
		var offset = Vector3(-4.0 if i == 0 else 4.0, 0, 2.0)
		var spawn_pos = global_position + offset
		if telegraph_scene:
			var tel = telegraph_scene.instantiate()
			get_parent().add_child(tel)
			tel.global_position = spawn_pos + Vector3(0, 0.05, 0)
			tel.duration = 0.6
			tel.radius = 1.5
		if imp_scene:
			var minion = imp_scene.instantiate()
			get_parent().add_child(minion)
			minion.global_position = spawn_pos
	
	GameManager.on_boss_hp_changed(current_hp, max_hp, current_phase)

func _process_phase_transition(delta: float) -> void:
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

func _die() -> void:
	current_state = State.DEATH
	velocity = Vector3.ZERO
	if collision_shape:
		collision_shape.disabled = true
	
	_play_anim("Death")
	GameManager.on_boss_defeated()
	
	# Spawn large ember cluster
	for i in range(5):
		if pickup_scene:
			var pickup = pickup_scene.instantiate()
			get_parent().add_child(pickup)
			var offset = Vector3(randf_range(-1.5, 1.5), 0.5, randf_range(-1.5, 1.5))
			pickup.global_position = global_position + offset
			pickup.value = 10

func _play_anim(anim_name: String) -> void:
	if not anim_player:
		return
	if anim_player.has_animation(anim_name):
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name)
