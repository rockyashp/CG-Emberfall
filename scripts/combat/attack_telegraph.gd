class_name AttackTelegraph
extends Node3D

@export var duration: float = 0.8
@export var radius: float = 2.0
@export var is_circle: bool = true

@onready var circle_mesh: MeshInstance3D = $CircleMesh
@onready var fill_mesh: MeshInstance3D = $FillMesh

func _ready() -> void:
	if circle_mesh:
		circle_mesh.scale = Vector3(radius, 1.0, radius)
	if fill_mesh:
		fill_mesh.scale = Vector3(0.01, 1.0, 0.01)
		var tween = create_tween()
		tween.tween_property(fill_mesh, "scale", Vector3(radius, 1.0, radius), duration)
		tween.tween_callback(queue_free)
