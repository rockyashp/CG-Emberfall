class_name ImpEnemy
extends EnemyBase

## Agile goblin skirmisher featuring flanking orbits, lunges, and evasive leap-backs

var strafe_dir: float = 1.0
var strafe_timer: float = 1.4
var is_lunging: bool = false
var hop_back_done: bool = false

func _ready() -> void:
	max_hp = 42.0
	move_speed = 5.6
	attack_range = 2.0
	attack_damage = 12.0
	windup_duration = 0.36
	attack_duration = 0.28
	recovery_duration = 0.75
	ember_reward = 6
	strafe_dir = 1.0 if randf() > 0.5 else -1.0
	strafe_timer = randf_range(1.0, 1.8)
	super._ready()

func _process_chase(delta: float) -> void:
	var dist = global_position.distance_to(target_player.global_position)
	_face_target(target_player.global_position, 0.22)
	
	if dist <= attack_range:
		is_lunging = false
		current_state = State.WINDUP
		state_timer = windup_duration
		velocity.x = 0.0
		velocity.z = 0.0
		_on_windup_start()
		return
	
	var to_player = (target_player.global_position - global_position).normalized()
	to_player.y = 0.0
	var sep = _compute_separation_vector(2.0)
	
	if is_lunging:
		# Lunge forward rapidly into strike
		var lunge_speed = move_speed * 1.4
		velocity.x = to_player.x * lunge_speed
		velocity.z = to_player.z * lunge_speed
		_play_anim("Run")
		return
	
	# Skirmish / Strafe zone (between 3.2m and 6.5m)
	if dist <= 6.5 and dist > 3.2:
		strafe_timer -= delta
		if strafe_timer <= 0.0:
			# Time to lunge!
			is_lunging = true
			return
		
		# Move along tangent circle around player
		var tangent = Vector3(-to_player.z, 0, to_player.x) * strafe_dir
		var move_dir = (tangent * 0.75 + to_player * 0.35 + sep * 1.5).normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		_play_anim("Run")
	else:
		# Direct approach with separation
		var move_dir = (to_player + sep * 1.4).normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		_play_anim("Run")

func _on_windup_start() -> void:
	hop_back_done = false
	_play_anim("Idle")
	if telegraph_scene:
		var tel = telegraph_scene.instantiate()
		get_parent().add_child(tel)
		tel.global_position = global_position + Vector3(0, 0.05, 0)
		tel.duration = windup_duration
		tel.radius = attack_range + 0.4

func _perform_attack() -> void:
	_play_anim("SwordSlash")
	if anim_player and not anim_player.has_animation("SwordSlash"):
		_play_anim("Punch")
	
	if AudioManager:
		AudioManager.play_slash()
	
	if target_player and is_instance_valid(target_player):
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= attack_range + 0.8:
			var push_dir = (target_player.global_position - global_position).normalized()
			push_dir.y = 0.1
			if target_player.has_method("take_damage"):
				target_player.take_damage(attack_damage, push_dir * 8.0)

func _process_recovery(delta: float) -> void:
	# Evasive hop backward right after strike
	if not hop_back_done and visual_root and target_player:
		hop_back_done = true
		var away_dir = (global_position - target_player.global_position).normalized()
		away_dir.y = 0.0
		velocity.x = away_dir.x * 6.0
		velocity.z = away_dir.z * 6.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
	
	_play_anim("Idle")
	
	state_timer -= delta
	if state_timer <= 0.0:
		# Reset skirmish state for next approach
		is_lunging = false
		strafe_dir = -strafe_dir
		strafe_timer = randf_range(1.2, 2.0)
		current_state = State.CHASE
