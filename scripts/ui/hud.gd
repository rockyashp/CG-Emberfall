class_name HUDController
extends Control

## HUD controller handling realtime health bar, ability cooldowns, room indicator, aspects, and announcements

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/HealthContainer/Margin/VBox/HPBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/TopRow/HealthContainer/Margin/VBox/HBoxContainer/HPLabel
@onready var room_label: Label = $MarginContainer/VBoxContainer/TopRow/RoomInfo/Margin/VBox/RoomLabel
@onready var aspect_label: Label = $MarginContainer/VBoxContainer/TopRow/RoomInfo/Margin/VBox/AspectLabel
@onready var enemies_label: Label = $MarginContainer/VBoxContainer/TopRow/RoomInfo/Margin/VBox/EnemiesLabel
@onready var embers_label: Label = $MarginContainer/VBoxContainer/TopRow/Resources/EmbersPill/Margin/EmbersLabel
@onready var shards_label: Label = $MarginContainer/VBoxContainer/TopRow/Resources/ShardsPill/Margin/ShardsLabel

@onready var strike_status: Label = $MarginContainer/BottomRow/Abilities/StrikeCard/Margin/VBox/Status
@onready var dash_cd_bar: ProgressBar = $MarginContainer/BottomRow/Abilities/DashCard/Margin/VBox/DashCD
@onready var dash_status: Label = $MarginContainer/BottomRow/Abilities/DashCard/Margin/VBox/DashStatus
@onready var burst_cd_bar: ProgressBar = $MarginContainer/BottomRow/Abilities/BurstCard/Margin/VBox/BurstCD
@onready var burst_status: Label = $MarginContainer/BottomRow/Abilities/BurstCard/Margin/VBox/BurstStatus
@onready var burst_ready_glow: Panel = $MarginContainer/BottomRow/Abilities/BurstCard/ReadyGlow

@onready var announcement_panel: PanelContainer = $AnnouncementCenter/AnnouncementPanel
@onready var announce_title: Label = $AnnouncementCenter/AnnouncementPanel/VBox/TitleLabel
@onready var announce_subtitle: Label = $AnnouncementCenter/AnnouncementPanel/VBox/SubtitleLabel

var _displayed_hp: float = 100.0
var _target_hp: float = 100.0
var _max_hp: float = 100.0
var _announce_tween: Tween = null

const ASPECT_DESCRIPTIONS: Array[String] = [
	"ASPECT: TRIAL OF STEEL (FUNDAMENTALS)",
	"ASPECT: DASH SURGE (+30% DASH RECOVERY)",
	"ASPECT: INFERNAL RESONANCE (RAPID BURST)"
]

func _ready() -> void:
	GameManager.player_health_updated.connect(_on_player_health_updated)
	GameManager.room_started.connect(_on_room_started)
	GameManager.enemy_spawned.connect(_on_enemy_count_changed)
	GameManager.enemy_defeated.connect(func(_e): _on_enemy_count_changed())
	GameManager.room_cleared.connect(_on_room_cleared)
	GameManager.embers_updated.connect(_on_embers_updated)
	GameManager.announcement_requested.connect(_on_announcement_requested)
	GameManager.wave_updated.connect(_on_wave_updated)
	ProgressionManager.shards_changed.connect(_on_shards_updated)
	
	_on_embers_updated(GameManager.run_embers)
	_on_shards_updated(ProgressionManager.shards)
	_on_room_started(GameManager.current_room_index, GameManager.ROOM_NAMES[GameManager.current_room_index])
	
	if announcement_panel:
		announcement_panel.modulate.a = 0.0
	
	# Initial player health setup
	var player = _get_player()
	if player:
		_max_hp = player.max_hp
		_target_hp = player.current_hp
		_displayed_hp = player.current_hp
		if hp_bar:
			hp_bar.max_value = _max_hp
			hp_bar.value = _displayed_hp
		if hp_label:
			hp_label.text = "%d / %d" % [int(_target_hp), int(_max_hp)]

func _get_player() -> PlayerController:
	if GameManager.current_player and is_instance_valid(GameManager.current_player):
		return GameManager.current_player as PlayerController
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as PlayerController
	return null

func _process(delta: float) -> void:
	# Realtime health bar smooth interpolation
	if absf(_displayed_hp - _target_hp) > 0.1:
		_displayed_hp = lerpf(_displayed_hp, _target_hp, 14.0 * delta)
	else:
		_displayed_hp = _target_hp
	
	if hp_bar:
		hp_bar.max_value = _max_hp
		hp_bar.value = _displayed_hp
	if hp_label:
		hp_label.text = "%d / %d" % [int(ceil(_displayed_hp)), int(_max_hp)]
	
	# Update player realtime cooldowns
	var player = _get_player()
	if player and is_instance_valid(player):
		# Sync health targets if changed outside signal
		if _target_hp != player.current_hp or _max_hp != player.max_hp:
			_target_hp = player.current_hp
			_max_hp = player.max_hp
		
		# Dash Cooldown
		if dash_cd_bar:
			var max_dash_cd = 0.7 * ProgressionManager.get_dash_cooldown_multiplier()
			var dash_rem = player.dash_cooldown_timer
			if dash_rem > 0.0:
				var dash_pct = (1.0 - (dash_rem / max_dash_cd)) * 100.0
				dash_cd_bar.value = clampf(dash_pct, 0.0, 100.0)
				if dash_status:
					dash_status.text = "%.1fs" % dash_rem
			else:
				dash_cd_bar.value = 100.0
				if dash_status:
					dash_status.text = "READY"
		
		# Burst Cooldown
		if burst_cd_bar:
			var max_burst_cd = player.burst_cooldown_max
			var burst_rem = player.burst_cooldown_timer
			if burst_rem > 0.0:
				var burst_pct = (1.0 - (burst_rem / max_burst_cd)) * 100.0
				burst_cd_bar.value = clampf(burst_pct, 0.0, 100.0)
				if burst_status:
					burst_status.text = "%.1fs" % burst_rem
				if burst_ready_glow:
					burst_ready_glow.visible = false
			else:
				burst_cd_bar.value = 100.0
				if burst_status:
					burst_status.text = "READY!"
				if burst_ready_glow:
					burst_ready_glow.visible = true
		
		# Strike Status
		if strike_status:
			if player.current_state == PlayerController.State.ATTACK:
				strike_status.text = "SLASH"
			else:
				strike_status.text = "READY"

func _on_player_health_updated(curr: float, max_v: float) -> void:
	_target_hp = curr
	_max_hp = max_v
	if hp_bar:
		hp_bar.max_value = _max_hp
	if hp_label:
		hp_label.text = "%d / %d" % [int(curr), int(max_v)]

func _on_room_started(room_idx: int, r_name: String) -> void:
	if room_label:
		var roman = ["I", "II", "III"][clampi(room_idx, 0, 2)]
		room_label.text = "TRIAL %s: %s" % [roman, r_name.to_upper()]
	if aspect_label:
		aspect_label.text = ASPECT_DESCRIPTIONS[clampi(room_idx, 0, 2)]
	_on_enemy_count_changed()

func _on_enemy_count_changed() -> void:
	_on_wave_updated(GameManager.current_wave, GameManager.total_waves, GameManager.enemies_remaining)

func _on_wave_updated(cur_w: int, tot_w: int, foes_left: int) -> void:
	if enemies_label:
		if GameManager.current_room_index == 2:
			enemies_label.text = "⚔ THE ASHEN WARDEN"
		elif GameManager.is_room_cleared:
			enemies_label.text = "★ CHAMBER SECURED — GATE UNLOCKED ★"
		elif tot_w > 1:
			enemies_label.text = "⚔ WAVE %d / %d — FOES: %d" % [cur_w, tot_w, foes_left]
		else:
			enemies_label.text = "⚔ FOES REMAINING: %d" % foes_left

func _on_room_cleared() -> void:
	if enemies_label:
		enemies_label.text = "★ CHAMBER SECURED — GATE UNLOCKED ★"

func _on_embers_updated(amt: int) -> void:
	if embers_label:
		embers_label.text = "🔥 %d EMBERS" % amt

func _on_shards_updated(amt: int) -> void:
	if shards_label:
		shards_label.text = "💎 %d SHARDS" % amt

func _on_announcement_requested(title: String, subtitle: String) -> void:
	if not announcement_panel:
		return
	if _announce_tween and _announce_tween.is_valid():
		_announce_tween.kill()
	
	announce_title.text = title
	announce_subtitle.text = subtitle
	
	_announce_tween = create_tween()
	_announce_tween.tween_property(announcement_panel, "modulate:a", 1.0, 0.35)
	_announce_tween.tween_interval(2.0)
	_announce_tween.tween_property(announcement_panel, "modulate:a", 0.0, 0.5)
