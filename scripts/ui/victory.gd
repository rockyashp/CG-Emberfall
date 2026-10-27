class_name VictoryController
extends Control

@onready var restart_btn: Button = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/ButtonContainer/RestartButton
@onready var menu_btn: Button = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/ButtonContainer/MenuButton
@onready var stats_label: Label = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/StatsLabel
@onready var thank_you_label: Label = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/ThankYouLabel
@onready var epilogue_label: Label = $MarginContainer/CardPanel/MarginContainer/VBoxContainer/EpilogueLabel

func _ready() -> void:
	restart_btn.pressed.connect(_on_restart)
	menu_btn.pressed.connect(_on_menu)
	
	thank_you_label.text = "THANK YOU FOR PLAYING EMBERFALL: THE THREE TRIALS!"
	epilogue_label.text = "You ventured into the Ashen Court, conquered the crystal hazard trials of the Obsidian Gallery, and weathered the roaring inferno of the Ember Throne to vanquish the Ashen Warden.\n\nYour mastery of blade and flame has rekindled the sacred Hearthfire."
	
	var vit_lv = ProgressionManager.upgrades.get("max_health", 0)
	var dmg_lv = ProgressionManager.upgrades.get("attack_damage", 0)
	var brst_lv = ProgressionManager.upgrades.get("burst_cooldown", 0)
	var dash_lv = ProgressionManager.upgrades.get("dash_cooldown", 0)
	
	stats_label.text = "TRIALS CONQUERED: 3 / 3  (COMPLETE)\nRun Embers Forged: %d   |   Sanctuary Shards: %d\nMastered Upgrades: Vitality Lv.%d  •  Blade Lv.%d  •  Burst Lv.%d  •  Dash Lv.%d" % [
		GameManager.run_embers,
		ProgressionManager.shards,
		vit_lv,
		dmg_lv,
		brst_lv,
		dash_lv
	]

func _on_restart() -> void:
	GameManager.start_new_run()

func _on_menu() -> void:
	GameManager.return_to_main_menu()
