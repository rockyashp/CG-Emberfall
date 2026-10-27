class_name EmberPickup
extends Area3D

@export var value: int = 5
var _player: Node3D = null
var _magnet_speed: float = 0.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var light: OmniLight3D = $OmniLight3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Random float offset
	var tween = create_tween().set_loops()
	tween.tween_property(mesh, "position:y", 0.6, 0.7).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh, "position:y", 0.3, 0.7).set_trans(Tween.TRANS_SINE)

func _physics_process(delta: float) -> void:
	mesh.rotate_y(delta * 2.5)
	
	# Magnet toward player if nearby
	if _player and is_instance_valid(_player):
		_magnet_speed += delta * 25.0
		global_position = global_position.move_toward(_player.global_position + Vector3(0, 0.8, 0), _magnet_speed * delta)
		if global_position.distance_to(_player.global_position + Vector3(0, 0.8, 0)) < 0.6:
			_collect()
	else:
		# Search for player within 4.5m
		if GameManager.current_player and is_instance_valid(GameManager.current_player):
			var dist = global_position.distance_to(GameManager.current_player.global_position)
			if dist < 4.5:
				_player = GameManager.current_player

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	GameManager.add_embers(value)
	if AudioManager:
		AudioManager.play_pickup()
	queue_free()
