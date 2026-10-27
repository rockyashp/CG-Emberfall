class_name PuglinEnemy
extends EnemyBase

## Heavy brute enemy featuring Seismic Ground Slams and directional Bull Rush Charges

enum AttackType { SLAM, CHARGE }

var current_attack_type: AttackType = AttackType.SLAM
var charge_dir: Vector3 = Vector3.FORWARD
var charge_timer: float = 0.0
var charge_cooldown: float = 3.0

func _ready() -> void:
	max_hp = 85.0
	move_speed = 3.2
	attack_range = 2.6
	attack_damage = 22.0
	windup_duration = 0.8
	attack_duration = 0.4
	recovery_duration = 1.1
	ember_reward = 12
	charge_cooldown = randf_range(2.0, 4.0)
	super._ready()

func _physics_process(delta: float) -> void:
	if charge_cooldown > 0.0:
		charge_cooldown -= delta
	super._physics_process(delta)

func _process_chase(delta: float) -> void:
	var dist = global_position.distance_to(target_player.global_position)
	_face_target(target_player.global_position, 0.16)
	
	# Decide between Close Slam or Medium-Range Bull Rush
	if dist <= attack_range:
		current_attack_type = AttackType.SLAM
		current_state = State.WINDUP
		state_timer = windup_duration
		velocity.x = 0.0
		velocity.z = 0.0
		_on_windup_start()
		return
	elif dist >= 4.5 and dist <= 9.0 and charge_cooldown <= 0.0:
		# Initiate Bull Rush Charge!
		current_attack_type = AttackType.CHARGE
		charge_cooldown = randf_range(5.0, 7.0)
		current_state = State.WINDUP
		state_timer = 0.7
		charge_dir = (target_player.global_position - global_position).normalized()
		charge_dir.y = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		_on_windup_start()
		return
	
	# Normal heavy advance with flocking separation
	var to_player = (target_player.global_position - global_position).normalized()
	to_player.y = 0.0
	var sep = _compute_separation_vector(2.4)
	var move_dir = (to_player + sep * 1.5).normalized()
	velocity.x = move_dir.x * move_speed
	velocity.z = move_dir.z * move_speed
	_play_anim("Run")

func _on_windup_start() -> void:
	_play_anim("Idle")
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		if current_attack_type == AttackType.SLAM:
			tel.global_position = global_position + Vector3(0, 0.05, 0)
			tel.duration = windup_duration
			tel.radius = 3.2
		else:
			# Directional Charge telegraph at target
			tel.global_position = global_position + charge_dir * 3.0 + Vector3(0, 0.05, 0)
			tel.duration = 0.7
			tel.radius = 2.4

func _process_windup(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	
	if current_attack_type == AttackType.SLAM:
		_face_target(target_player.global_position, 0.08)
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.ATTACK
		if current_attack_type == AttackType.SLAM:
			state_timer = attack_duration
			_perform_slam_attack()
		else:
			state_timer = 0.85 # Charge duration
			_play_anim("Run")

func _perform_slam_attack() -> void:
	_play_anim("Punch")
	if anim_player and not anim_player.has_animation("Punch"):
		_play_anim("SwordSlash")
	
	if AudioManager:
		AudioManager.play_boss_stomp()
	
	# Ground slam area damage within 3.4m radius
	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= 3.4:
			var push_dir = (target_player.global_position - global_position).normalized()
			push_dir.y = 0.25
			if target_player.has_method("take_damage"):
				target_player.take_damage(attack_damage, push_dir * 11.0)
	
	# Impact sparks at ground
	if hit_scene:
		var fx = hit_scene.instantiate()
		get_parent().add_child(fx)
		fx.global_position = global_position + Vector3(0, 0.2, 0)

func _process_attack(delta: float) -> void:
	if current_attack_type == AttackType.CHARGE:
		# Rapid bull rush along charge direction
		var charge_speed = 11.5
		velocity.x = charge_dir.x * charge_speed
		velocity.z = charge_dir.z * charge_speed
		
		# Check collision with player during charge
		if target_player and is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position)
			if dist <= 1.8:
				# Impact!
				var push = charge_dir + Vector3(0, 0.2, 0)
				if target_player.has_method("take_damage"):
					target_player.take_damage(26.0, push * 12.0)
				if AudioManager:
					AudioManager.play_boss_stomp()
				state_timer = 0.0 # Stop charge on hit
	else:
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	
	state_timer -= delta
	if state_timer <= 0.0:
		current_state = State.RECOVERY
		state_timer = recovery_duration if current_attack_type == AttackType.SLAM else 1.2
