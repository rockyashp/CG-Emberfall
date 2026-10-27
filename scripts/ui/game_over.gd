class_name GameOverController
extends Control

@onready var restart_btn: Button = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_btn: Button = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/ButtonContainer/MenuButton
@onready var summary_label: Label = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/SummaryPanel/Margin/SummaryLabel

func _ready() -> void:
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)
	
	var earned = int(GameManager.run_embers * 0.5)
	summary_label.text = "Embers Forged: %d\nShards Preserved in Sanctuary: +%d\nTotal Shards: %d" % [
		GameManager.run_embers, earned, ProgressionManager.shards
	]

func _on_restart() -> void:
	GameManager.start_new_run()

func _on_menu() -> void:
	GameManager.return_to_main_menu()
