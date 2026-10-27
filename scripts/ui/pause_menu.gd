class_name PauseMenuController
extends Control

@onready var resume_btn: Button = $PanelContainer/Margin/VBoxContainer/ResumeButton
@onready var upgrades_btn: Button = $PanelContainer/Margin/VBoxContainer/UpgradesButton
@onready var restart_btn: Button = $PanelContainer/Margin/VBoxContainer/RestartButton
@onready var quit_btn: Button = $PanelContainer/Margin/VBoxContainer/QuitButton
@onready var shards_label: Label = $PanelContainer/Margin/VBoxContainer/ShardsPill/Margin/ShardsLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(toggle_pause)
	upgrades_btn.pressed.connect(_on_upgrades_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	var new_paused = not get_tree().paused
	get_tree().paused = new_paused
	visible = new_paused
	if visible and shards_label:
		shards_label.text = "💎 SANCTUARY SHARDS: %d" % ProgressionManager.shards

func _on_upgrades_pressed() -> void:
	GameManager.upgrade_requested.emit()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameManager.restart_run()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	visible = false
	GameManager.return_to_main_menu()
