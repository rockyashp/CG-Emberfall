class_name PlayerController
extends CharacterBody3D

## Player controller handling keyboard-driven movement & facing, mouse-only attacks, dash, ember burst, and health

enum State { IDLE, MOVE, ATTACK, DASH, HIT, DEATH }

@export var move_speed: float = 7.0
@export var dash_speed: float = 17.0
@export var dash_duration: float = 0.22
@export var base_damage: float = 28.0
@export var burst_cooldown_max: float = 6.0

var current_state: State = State.IDLE
var current_hp: float = 100.0
var max_hp: float = 100.0

var is_invulnerable: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_dir: Vector3 = Vector3.FORWARD
var last_facing_angle: float = 0.0

var burst_cooldown_timer: float = 0.0
var attack_timer: float = 0.0

# References
@onready var visual_root: Node3D = $VisualRoot
@onready var hitbox: Area3D = $PlayerHitbox
@onready var weapon_node: Node3D = $VisualRoot/PlayerWeapon
@onready var camera_mount: Node3D = $CameraMount

var anim_player: AnimationPlayer = null
var skeleton: Skeleton3D = null
var fist_bone_idx: int = -1

var slash_scene = preload("res://scenes/combat/slash_effect.tscn")
var burst_scene = preload("res://scenes/combat/ember_burst_effect.tscn")
var hit_scene = preload("res://scenes/combat/hit_effect.tscn")
var dmg_num_scene = preload("res://scenes/combat/damage_number.tscn")

var _hit_enemies_this_swing: Array[Node3D] = []

func _ready() -> void:
	add_to_group("player")
	
	# Apply permanent vitality upgrade
	max_hp = 100.0 + ProgressionManager.get_max_hp_bonus()
	current_hp = max_hp
	GameManager.player_health_updated.emit(current_hp, max_hp)
	
	# Discover AnimationPlayer recursively in children
	anim_player = _find_anim_player(self)
	
	# Discover Skeleton and mount weapon to right hand
	skeleton = _find_skeleton(self)
	_setup_weapon_attachment()
	
	# Connect hitbox
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.monitoring = false
	
	_play_anim("Idle")

func _setup_weapon_attachment() -> void:
	if not weapon_node:
		return
	
	var skel = _find_skeleton(self)
	if skel:
		var bone_name = "Fist.R"
		var bone_idx = skel.find_bone(bone_name)
		if bone_idx != -1:
			var bone_attach = skel.find_child("PlayerBoneAttachment", false, false) as BoneAttachment3D
			if not bone_attach:
				bone_attach = BoneAttachment3D.new()
				bone_attach.name = "PlayerBoneAttachment"
				skel.add_child(bone_attach)
			bone_attach.bone_name = bone_name
			bone_attach.bone_idx = bone_idx
			
			if weapon_node.get_parent() != bone_attach:
				weapon_node.get_parent().remove_child(weapon_node)
				bone_attach.add_child(weapon_node)
				weapon_node.position = Vector3(0.0, 0.05, 0.05)
				weapon_node.rotation_degrees = Vector3(90, 0, 0)
				weapon_node.scale = Vector3(0.9, 0.9, 0.9)

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found = _find_anim_player(child)
		if found:
			return found
	return null

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found = _find_skeleton(child)
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

func _physics_process(delta: float) -> void:
	# Update cooldown timers
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = maxf(0.0, dash_cooldown_timer - delta)
	if burst_cooldown_timer > 0.0:
		burst_cooldown_timer = maxf(0.0, burst_cooldown_timer - delta)
	
	if current_state == State.DEATH:
		if not is_on_floor():
			velocity.y -= 18.0 * delta
			move_and_slide()
		return
	
	match current_state:
		State.IDLE, State.MOVE:
			_process_keyboard_movement_and_facing(delta)
			_process_inputs()
		State.DASH:
			_process_dash(delta)
		State.ATTACK:
			_process_attack(delta)
		State.HIT:
			_process_hit(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0
	
	move_and_slide()

## Keyboard controls ALL movement and direction facing
func _process_keyboard_movement_and_facing(delta: float) -> void:
	var input_x = Input.get_axis("move_left", "move_right")
	var input_z = Input.get_axis("move_forward", "move_backward")
	var move_vec = Vector3(input_x, 0.0, input_z).normalized()
	
	if move_vec.length_squared() > 0.01:
		current_state = State.MOVE
		velocity.x = move_vec.x * move_speed
		velocity.z = move_vec.z * move_speed
		
		# Rotate visual root to face movement direction
		var target_rot = atan2(move_vec.x, move_vec.z)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_rot, 0.28)
		last_facing_angle = visual_root.rotation.y
		_play_anim("Run")
	else:
		current_state = State.IDLE
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, move_speed * 12.0 * delta)
		visual_root.rotation.y = last_facing_angle
		_play_anim("Idle")

func _process_inputs() -> void:
	# Mouse only controls attacking
	if Input.is_action_just_pressed("attack"):
		_start_attack()
	elif Input.is_action_just_pressed("dash"):
		if dash_cooldown_timer <= 0.0:
			_start_dash()
	elif Input.is_action_just_pressed("special"):
		if burst_cooldown_timer <= 0.0:
			_start_burst()

func _start_dash() -> void:
	current_state = State.DASH
	is_invulnerable = true
	dash_timer = dash_duration
	dash_cooldown_timer = 0.7 * ProgressionManager.get_dash_cooldown_multiplier()
	
	var input_x = Input.get_axis("move_left", "move_right")
	var input_z = Input.get_axis("move_forward", "move_backward")
	var move_vec = Vector3(input_x, 0.0, input_z).normalized()
	
	if move_vec.length_squared() > 0.01:
		dash_dir = move_vec
	else:
		dash_dir = Vector3(sin(visual_root.rotation.y), 0, cos(visual_root.rotation.y)).normalized()
	
	velocity.x = dash_dir.x * dash_speed
	velocity.z = dash_dir.z * dash_speed
	
	if AudioManager:
		AudioManager.play_dash()
	
	_play_anim("Roll")
	if anim_player and not anim_player.has_animation("Roll"):
		_play_anim("Jump")

func _process_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.x = dash_dir.x * dash_speed
	velocity.z = dash_dir.z * dash_speed
	
	if dash_timer <= 0.0:
		is_invulnerable = false
		current_state = State.IDLE
		_play_anim("Idle")

func _start_attack() -> void:
	current_state = State.ATTACK
	attack_timer = 0.42
	_hit_enemies_this_swing.clear()
	
	# Slight forward attack step in facing direction
	var facing = Vector3(sin(visual_root.rotation.y), 0, cos(visual_root.rotation.y)).normalized()
	velocity.x = facing.x * 4.0
	velocity.z = facing.z * 4.0
	
	if AudioManager:
		AudioManager.play_slash()
	
	_play_anim("SwordSlash")
	
	# Visual glowing slash arc effect
	if slash_scene:
		var slash = slash_scene.instantiate()
		add_child(slash)
		slash.global_position = global_position + Vector3(0, 0.9, 0) + facing * 1.0
		slash.rotation.y = visual_root.rotation.y

func _process_attack(delta: float) -> void:
	attack_timer -= delta
	velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	
	var is_active_window = attack_timer <= 0.35 and attack_timer >= 0.1
	if hitbox:
		hitbox.monitoring = is_active_window
	
	if attack_timer <= 0.0:
		if hitbox:
			hitbox.monitoring = false
		current_state = State.IDLE
		_play_anim("Idle")

func _start_burst() -> void:
	burst_cooldown_timer = burst_cooldown_max
	if burst_scene:
		var burst = burst_scene.instantiate()
		get_parent().add_child(burst)
		burst.global_position = global_position

func _on_hitbox_body_entered(body: Node3D) -> void:
	if not hitbox.monitoring or body == self:
		return
	if body.is_in_group("enemies") or body.is_in_group("boss"):
		_apply_damage_to_target(body)

func _on_hitbox_area_entered(area: Area3D) -> void:
	if not hitbox.monitoring:
		return
	var body = area.get_parent()
	if body and (body.is_in_group("enemies") or body.is_in_group("boss")):
		_apply_damage_to_target(body)

func _apply_damage_to_target(target: Node3D) -> void:
	if target in _hit_enemies_this_swing:
		return
	_hit_enemies_this_swing.append(target)
	
	var dmg = base_damage * ProgressionManager.get_damage_multiplier()
	var is_crit = randf() < 0.20
	if is_crit:
		dmg *= 1.6
	
	var push_dir = (target.global_position - global_position).normalized()
	push_dir.y = 0.1
	var knockback = push_dir * 8.5
	
	if target.has_method("take_damage"):
		target.take_damage(dmg, knockback)
	
	# Spawn impact sparks
	if hit_scene:
		var fx = hit_scene.instantiate()
		get_parent().add_child(fx)
		fx.global_position = (global_position + target.global_position) * 0.5 + Vector3(0, 1.0, 0)
	
	# Spawn damage number
	if dmg_num_scene:
		var num = dmg_num_scene.instantiate()
		get_parent().add_child(num)
		num.global_position = target.global_position + Vector3(0, 1.6, 0)
		num.setup(dmg, is_crit, false)
	
	if AudioManager:
		AudioManager.play_hit()

func take_damage(amount: float, knockback: Vector3 = Vector3.ZERO) -> void:
	if is_invulnerable or current_state == State.DEATH:
		return
	
	current_hp = maxf(0.0, current_hp - amount)
	GameManager.player_health_updated.emit(current_hp, max_hp)
	
	if dmg_num_scene:
		var num = dmg_num_scene.instantiate()
		get_parent().add_child(num)
		num.global_position = global_position + Vector3(0, 1.8, 0)
		num.setup(amount, false, true)
	
	if AudioManager:
		AudioManager.play_hit()
	
	if current_hp <= 0.0:
		_die()
	else:
		current_state = State.HIT
		is_invulnerable = true
		velocity = knockback * 0.5
		_play_anim("RecieveHit")
		
		var iframe_timer = get_tree().create_timer(0.35)
		iframe_timer.timeout.connect(func():
			is_invulnerable = false
			if current_state == State.HIT:
				current_state = State.IDLE
				_play_anim("Idle")
		)

func _process_hit(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)

func _die() -> void:
	current_state = State.DEATH
	velocity = Vector3.ZERO
	_play_anim("Death")
	GameManager.on_player_death()
