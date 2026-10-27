class_name MainMenuController
extends Control

@onready var start_btn: Button = $MarginContainer/CardPanel/InnerMargin/VBoxContainer/MenuButtons/StartButton
@onready var upgrades_btn: Button = $MarginContainer/CardPanel/InnerMargin/VBoxContainer/MenuButtons/UpgradesButton
@onready var controls_btn: Button = $MarginContainer/CardPanel/InnerMargin/VBoxContainer/MenuButtons/ControlsButton
@onready var quit_btn: Button = $MarginContainer/CardPanel/InnerMargin/VBoxContainer/MenuButtons/QuitButton
@onready var upgrade_modal: UpgradeSelectionController = $UpgradeSelection
@onready var controls_panel: PanelContainer = $ControlsPanel
@onready var close_controls_btn: Button = $ControlsPanel/Margin/VBoxContainer/CloseControlsButton
@onready var shards_label: Label = $MarginContainer/CardPanel/InnerMargin/VBoxContainer/ShardsPill/Margin/ShardsLabel

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	upgrades_btn.pressed.connect(_on_upgrades_pressed)
	controls_btn.pressed.connect(_on_controls_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	close_controls_btn.pressed.connect(func(): controls_panel.visible = false)
	controls_panel.visible = false
	
	ProgressionManager.shards_changed.connect(_update_shards)
	_update_shards(ProgressionManager.shards)

func _update_shards(amt: int) -> void:
	if shards_label:
		shards_label.text = "💎 SANCTUARY SHARDS: %d" % amt

func _on_start_pressed() -> void:
	if AudioManager:
		AudioManager.play_slash()
	GameManager.start_new_run()

func _on_upgrades_pressed() -> void:
	if upgrade_modal:
		upgrade_modal.open_selection()

func _on_controls_pressed() -> void:
	controls_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()
