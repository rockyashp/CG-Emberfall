class_name ExitGate
extends Area3D

@export var is_unlocked: bool = false
@onready var light: OmniLight3D = $OmniLight3D
@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var label: Label3D = $Label3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameManager.room_cleared.connect(unlock_gate)
	_update_visuals()

func unlock_gate() -> void:
	is_unlocked = true
	_update_visuals()

func _update_visuals() -> void:
	if is_unlocked:
		if light:
			light.light_color = Color(1.0, 0.75, 0.2)
			light.light_energy = 3.0
		if particles:
			particles.emitting = true
		if label:
			label.text = "[ EXIT UNLOCKED - STEP THROUGH ]"
			label.modulate = Color(1.0, 0.85, 0.3)
	else:
		if light:
			light.light_color = Color(0.8, 0.1, 0.1)
			light.light_energy = 1.0
		if particles:
			particles.emitting = false
		if label:
			label.text = "[ SEALED - DEFEAT ALL FOES ]"
			label.modulate = Color(0.8, 0.2, 0.2)

func _on_body_entered(body: Node3D) -> void:
	if is_unlocked and body.is_in_group("player"):
		GameManager.advance_to_next_room()
