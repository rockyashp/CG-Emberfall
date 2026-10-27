extends Node

func _ready() -> void:
	# Start at Main Menu
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
