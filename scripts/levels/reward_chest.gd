class_name RewardChest
extends Area3D

var is_active: bool = false
var is_opened: bool = false
var player_in_range: bool = false

@onready var light: OmniLight3D = $OmniLight3D
@onready var label: Label3D = $Label3D
@onready var chest_model: Node3D = $ChestModel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameManager.room_cleared.connect(activate_chest)
	_update_state()

func activate_chest() -> void:
	if not is_opened:
		is_active = true
		_update_state()

func _update_state() -> void:
	if is_opened:
		if label:
			label.visible = false
		if light:
			light.light_energy = 0.5
	elif is_active:
		if label:
			label.visible = true
			label.text = "[E] OPEN RELIC CHEST"
			label.modulate = Color(1.0, 0.85, 0.2)
		if light:
			light.light_color = Color(1.0, 0.8, 0.2)
			light.light_energy = 2.5
	else:
		if label:
			label.visible = false
		if light:
			light.light_energy = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if is_active and not is_opened and player_in_range:
		if event.is_action_pressed("interact"):
			_open_chest()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if is_active and not is_opened:
			# Auto open or prompt
			_open_chest()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _open_chest() -> void:
	if not is_active or is_opened:
		return
	is_opened = true
	is_active = false
	if AudioManager:
		AudioManager.play_pickup()
	
	# Animate chest opening (scale/tilt)
	var tween = create_tween()
	tween.tween_property(chest_model, "scale", Vector3(1.1, 1.3, 1.1), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(chest_model, "scale", Vector3(1.0, 1.0, 1.0), 0.2)
	
	_update_state()
	GameManager.upgrade_requested.emit()
