class_name EnemyBase
extends CharacterBody3D

## Base class for enemies with finite state machine, AI steering, separation flocking, and damage handling

enum State { IDLE, CHASE, WINDUP, ATTACK, RECOVERY, HIT, DEATH }

@export var max_hp: float = 45.0
@export var move_speed: float = 4.8
@export var attack_range: float = 2.0
@export var attack_damage: float = 14.0
@export var windup_duration: float = 0.45
@export var attack_duration: float = 0.35
@export var recovery_duration: float = 0.7
@export var ember_reward: int = 6

var current_state: State = State.IDLE
var current_hp: float = 45.0
var state_timer: float = 0.0

var target_player: Node3D = null
var anim_player: AnimationPlayer = null

@onready var visual_root: Node3D = $VisualRoot
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var pickup_scene = preload("res://scenes/pickups/ember_pickup.tscn")
var hit_scene = preload("res://scenes/combat/hit_effect.tscn")
var dmg_num_scene = preload("res://scenes/combat/damage_number.tscn")
var telegraph_scene = preload("res://scenes/combat/attack_telegraph.tscn")

func _ready() -> void:
	add_to_group("enemies")
	current_hp = max_hp
	GameManager.register_enemy()
	
	# Find AnimationPlayer recursively in children
	anim_player = _find_anim_player(self)
	_play_anim("Idle")
	_find_player()

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found = _find_anim_player(child)
		if found:
			return found
	return null

func _play_anim(anim_name: String) -> void:
	if not anim_player:
		return
	var anim_list = anim_player.get_animation_list()
	var target = ""
	for a in anim_list:
		if a == anim_name or a.ends_with("/" + anim_name) or a.to_lower().ends_with("/" + anim_name.to_lower()):
			target = a
			break
	if target != "" and anim_player.current_animation != target:
		anim_player.play(target)

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
	
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.WINDUP:
			_process_windup(delta)
		State.ATTACK:
			_process_attack(delta)
		State.RECOVERY:
			_process_recovery(delta)
		State.HIT:
			_process_hit(delta)
	
	move_and_slide()

func _face_target(target_pos: Vector3, weight: float = 0.2) -> void:
	var dir = (target_pos - global_position)
	dir.y = 0.0
	if dir.length_squared() > 0.01 and visual_root:
		var target_rot = atan2(dir.x, dir.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_rot, weight)

func _compute_separation_vector(desired_dist: float = 2.2) -> Vector3:
	var sep = Vector3.ZERO
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e == self or not is_instance_valid(e):
			continue
		var to_self = global_position - e.global_position
		to_self.y = 0.0
		var dist = to_self.length()
		if dist > 0.01 and dist < desired_dist:
			sep += to_self.normalized() * (1.0 - (dist / desired_dist))
	return sep

func _process_idle(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	_play_anim("Idle")
	
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 25.0:
			current_state = State.CHASE

func _process_chase(delta: float) -> void:
	var dist = global_position.distance_to(target_player.global_position)
	_face_target(target_player.global_position, 0.2)
	
	if dist <= attack_range:
		current_state = State.WINDUP
		state_timer = windup_duration
		velocity.x = 0.0
		velocity.z = 0.0
		_on_windup_start()
	else:
		var to_player = (target_player.global_position - global_position).normalized()
		to_player.y = 0.0
		var sep = _compute_separation_vector(2.2)
		var move_dir = (to_player + sep * 1.5).normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		_play_anim("Run")

func _on_windup_start() -> void:
	_play_anim("Idle")
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		tel.global_position = global_position + Vector3(0, 0.05, 0)
		tel.duration = windup_duration
		tel.radius = attack_range

func _process_windup(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
	_face_target(target_player.global_position, 0.1)
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.ATTACK
		state_timer = attack_duration
		_perform_attack()

func _perform_attack() -> void:
	_play_anim("Punch")
	if anim_player and not anim_player.has_animation("Punch"):
		_play_anim("SwordSlash")
	
	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= attack_range + 0.6:
			var push_dir = (target_player.global_position - global_position).normalized()
			push_dir.y = 0.1
			if target_player.has_method("take_damage"):
				target_player.take_damage(attack_damage, push_dir * 7.0)

func _process_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.RECOVERY
		state_timer = recovery_duration

func _process_recovery(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	_play_anim("Idle")
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

func _process_hit(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.CHASE

func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO) -> void:
	if current_state == State.DEATH:
		return
	
	current_hp = maxf(0.0, current_hp - amount)
	
	if current_hp <= 0.0:
		_die()
	else:
		current_state = State.HIT
		state_timer = 0.28
		velocity = knockback
		_play_anim("RecieveHit")

func _die() -> void:
	current_state = State.DEATH
	velocity = Vector3.ZERO
	if collision_shape:
		collision_shape.disabled = true
	
	_play_anim("Death")
	
	if pickup_scene:
		var pickup = pickup_scene.instantiate()
		get_parent().add_child(pickup)
		pickup.global_position = global_position
		pickup.value = ember_reward
	
	if AudioManager:
		AudioManager.play_enemy_death()
	
	GameManager.unregister_enemy(self)
	
	# Fade out after death animation completes
	var timer = get_tree().create_timer(1.2)
	timer.timeout.connect(func():
		var tween = create_tween()
		tween.tween_property(visual_root, "scale", Vector3.ZERO, 0.3)
		tween.tween_callback(queue_free)
	)
