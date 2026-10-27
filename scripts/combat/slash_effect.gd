class_name SlashEffect
extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	scale = Vector3(0.5, 0.5, 0.5)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(1.3, 1.3, 1.3), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if mesh_instance and mesh_instance.get_surface_override_material(0):
		var mat = mesh_instance.get_surface_override_material(0).duplicate()
		mesh_instance.set_surface_override_material(0, mat)
		tween.tween_property(mat, "albedo_color:a", 0.0, 0.18)
	tween.chain().tween_callback(queue_free)
