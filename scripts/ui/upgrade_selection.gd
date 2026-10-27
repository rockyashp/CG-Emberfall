class_name UpgradeSelectionController
extends Control

## Upgrade Selection modal offering roguelike perks between chambers and sanctuary meta-progression

@onready var card_1_btn: Button = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card1/Margin/VBox/Button
@onready var card_1_level: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card1/Margin/VBox/Badge/Margin/LevelLabel
@onready var card_1_cost: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card1/Margin/VBox/Cost

@onready var card_2_btn: Button = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card2/Margin/VBox/Button
@onready var card_2_level: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card2/Margin/VBox/Badge/Margin/LevelLabel
@onready var card_2_cost: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card2/Margin/VBox/Cost

@onready var card_3_btn: Button = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card3/Margin/VBox/Button
@onready var card_3_level: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card3/Margin/VBox/Badge/Margin/LevelLabel
@onready var card_3_cost: Label = $PanelContainer/Margin/VBoxContainer/CardsContainer/Card3/Margin/VBox/Cost

@onready var close_btn: Button = $PanelContainer/Margin/VBoxContainer/CloseButton
@onready var shards_label: Label = $PanelContainer/Margin/VBoxContainer/Header/ShardsPill/Margin/ShardsLabel

func _ready() -> void:
	visible = false
	GameManager.upgrade_requested.connect(open_selection)
	card_1_btn.pressed.connect(func(): _choose_upgrade("vitality"))
	card_2_btn.pressed.connect(func(): _choose_upgrade("damage"))
	card_3_btn.pressed.connect(func(): _choose_upgrade("burst"))
	close_btn.pressed.connect(close_selection)

func open_selection() -> void:
	visible = true
	_update_ui()

func close_selection() -> void:
	visible = false

func _update_ui() -> void:
	if shards_label:
		shards_label.text = "💎 AVAILABLE SHARDS: %d" % ProgressionManager.shards
	
	_update_card_elements("vitality", card_1_level, card_1_cost, card_1_btn)
	_update_card_elements("damage", card_2_level, card_2_cost, card_2_btn)
	_update_card_elements("burst", card_3_level, card_3_cost, card_3_btn)

func _update_card_elements(upgrade_id: String, level_lbl: Label, cost_lbl: Label, btn: Button) -> void:
	var lvl = ProgressionManager.get_upgrade_level(upgrade_id)
	var cost = ProgressionManager.get_upgrade_cost(upgrade_id)
	var can_afford = ProgressionManager.can_afford(upgrade_id)
	
	if cost < 0:
		if level_lbl:
			level_lbl.text = "★ MAX LEVEL ★"
		if cost_lbl:
			cost_lbl.text = "MAXED OUT"
		btn.text = "MAX RANK"
		btn.disabled = true
	else:
		if level_lbl:
			level_lbl.text = "LEVEL %d ➔ %d" % [lvl, lvl + 1]
		if cost_lbl:
			cost_lbl.text = "💎 %d SHARDS" % cost
		btn.text = "ACQUIRE UPGRADE"
		btn.disabled = not can_afford

func _choose_upgrade(upgrade_id: String) -> void:
	if ProgressionManager.purchase_upgrade(upgrade_id):
		if AudioManager:
			AudioManager.play_pickup()
		
		# If vitality upgraded, heal player immediately
		if upgrade_id == "vitality" and GameManager.current_player:
			var p = GameManager.current_player as PlayerController
			if p:
				p.max_hp += 20.0
				p.current_hp = minf(p.max_hp, p.current_hp + 30.0)
				GameManager.player_health_updated.emit(p.current_hp, p.max_hp)
		
		_update_ui()
		# Close after choice if in run chamber
		if GameManager.is_run_active:
			close_selection()
