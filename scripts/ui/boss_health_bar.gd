class_name BossHealthBar
extends Control

@onready var hp_bar: ProgressBar = $PanelContainer/Margin/VBoxContainer/ProgressBar
@onready var phase_label: Label = $PanelContainer/Margin/VBoxContainer/TitleContainer/PhaseLabel
@onready var title_label: Label = $PanelContainer/Margin/VBoxContainer/TitleContainer/TitleLabel

var _displayed_hp: float = 380.0
var _target_hp: float = 380.0

func _ready() -> void:
	visible = false
	GameManager.boss_spawned.connect(_on_boss_spawned)
	GameManager.boss_health_updated.connect(_on_boss_hp_updated)
	GameManager.boss_defeated.connect(_on_boss_defeated)

func _process(delta: float) -> void:
	if visible and hp_bar:
		_displayed_hp = lerpf(_displayed_hp, _target_hp, 8.0 * delta)
		hp_bar.value = _displayed_hp

func _on_boss_spawned(_boss: Node3D) -> void:
	visible = true
	_displayed_hp = 380.0
	_target_hp = 380.0
	if hp_bar:
		hp_bar.max_value = 380.0
		hp_bar.value = 380.0
	if phase_label:
		phase_label.text = "PHASE I"
		phase_label.modulate = Color(1.0, 0.82, 0.25)

func _on_boss_hp_updated(curr: float, max_v: float, phase: int) -> void:
	visible = true
	_target_hp = curr
	if hp_bar:
		hp_bar.max_value = max_v
	if phase_label:
		if phase == 2:
			phase_label.text = "PHASE II — ENRAGED"
			phase_label.modulate = Color(1.0, 0.3, 0.15)
		else:
			phase_label.text = "PHASE I"
			phase_label.modulate = Color(1.0, 0.82, 0.25)

func _on_boss_defeated() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): visible = false)
