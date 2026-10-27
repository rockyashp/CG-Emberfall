class_name HitEffect
extends Node3D

@onready var particles: CPUParticles3D = $CPUParticles3D

func _ready() -> void:
	if particles:
		particles.emitting = true
	var timer = get_tree().create_timer(0.6)
	timer.timeout.connect(queue_free)
