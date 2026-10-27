class_name EmberBurstEffect
extends Area3D

@export var damage: float = 55.0
@export var knockback_force: float = 14.0
@export var radius: float = 4.5

@onready var particles: CPUParticles3D = $CPUParticles3D
@onready var shockwave: MeshInstance3D = $ShockwaveMesh

func _ready() -> void:
	# Calculate damage scaled by permanent progression
	damage = 50.0 * ProgressionManager.get_burst_multiplier()
	
	if AudioManager:
		AudioManager.play_burst()
	
	if particles:
		particles.emitting = true
	
	# Animate expanding shockwave ring
	if shockwave:
		shockwave.scale = Vector3(0.2, 0.2, 0.2)
		var tween = create_tween().set_parallel(true)
		tween.tween_property(shockwave, "scale", Vector3(radius, 0.1, radius), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if shockwave.get_surface_override_material(0):
			var mat = shockwave.get_surface_override_material(0).duplicate()
			shockwave.set_surface_override_material(0, mat)
			tween.tween_property(mat, "albedo_color:a", 0.0, 0.35)
	
	# Apply damage to all overlapping enemies
	var timer = get_tree().create_timer(0.05)
	timer.timeout.connect(_deal_burst_damage)
	
	# Self cleanup
	var cleanup_timer = get_tree().create_timer(0.7)
	cleanup_timer.timeout.connect(queue_free)

func _deal_burst_damage() -> void:
	var bodies = get_overlapping_bodies()
	for b in bodies:
		if b.is_in_group("enemies") or b.is_in_group("boss"):
			if b.has_method("take_damage"):
				var push_dir = (b.global_position - global_position).normalized()
				push_dir.y = 0.2
				b.take_damage(damage, push_dir * knockback_force)
