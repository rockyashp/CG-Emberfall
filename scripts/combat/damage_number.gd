class_name DamageNumber
extends Node3D

@onready var label: Label3D = $Label3D

func setup(amount: float, is_crit: bool = false, is_player_damage: bool = false) -> void:
	if label:
		label.text = str(int(amount))
		if is_player_damage:
			label.modulate = Color(1.0, 0.2, 0.2) # Red for player hurt
		elif is_crit:
			label.modulate = Color(1.0, 0.85, 0.1) # Gold for crit
			label.font_size = 42
		else:
			label.modulate = Color(1.0, 0.95, 0.8) # Cream/white for normal hits
			label.font_size = 32
	
	# Float upward with random slight drift
	var drift_x = randf_range(-0.4, 0.4)
	var target_pos = position + Vector3(drift_x, 1.5, 0)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position", target_pos, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
