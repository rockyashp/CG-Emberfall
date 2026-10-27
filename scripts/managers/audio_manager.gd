class_name AudioManagerClass
extends Node

## Handles sound effects and audio feedback for combat, interactions, and UI

var _players: Array[AudioStreamPlayer] = []
var _pool_size: int = 16
var _player_index: int = 0

# Cached audio streams
var _slash_sounds: Array[AudioStream] = []
var _hit_sounds: Array[AudioStream] = []
var _dash_sounds: Array[AudioStream] = []
var _burst_sounds: Array[AudioStream] = []
var _plate_sounds: Array[AudioStream] = []
var _wood_sounds: Array[AudioStream] = []

func _ready() -> void:
	# Create pool of AudioStreamPlayers
	for i in range(_pool_size):
		var p = AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_players.append(p)
	
	_load_sounds()

func _load_sounds() -> void:
	# Load metal sounds for slashes/clashes
	for i in range(5):
		var path = "res://assets/audio/impactMetal_heavy_00%d.ogg" % i
		if ResourceLoader.exists(path):
			_slash_sounds.append(load(path))
	
	# Load plate sounds for armor hits
	for i in range(5):
		var path = "res://assets/audio/impactPlate_heavy_00%d.ogg" % i
		if ResourceLoader.exists(path):
			_plate_sounds.append(load(path))
	
	# Load wood sounds for heavy ground stomps/dashes
	for i in range(5):
		var path = "res://assets/audio/impactWood_heavy_00%d.ogg" % i
		if ResourceLoader.exists(path):
			_wood_sounds.append(load(path))

func _get_player() -> AudioStreamPlayer:
	var p = _players[_player_index]
	_player_index = (_player_index + 1) % _pool_size
	return p

func play_stream(stream: AudioStream, pitch_variance: float = 0.08, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player = _get_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance)
	player.play()

func play_slash() -> void:
	if _slash_sounds.size() > 0:
		var snd = _slash_sounds.pick_random()
		play_stream(snd, 0.12, -2.0)

func play_hit() -> void:
	if _plate_sounds.size() > 0:
		var snd = _plate_sounds.pick_random()
		play_stream(snd, 0.1, 1.0)
	elif _slash_sounds.size() > 0:
		play_stream(_slash_sounds.pick_random(), 0.1, 1.0)

func play_dash() -> void:
	if _wood_sounds.size() > 0:
		play_stream(_wood_sounds[0], 0.15, -4.0)

func play_burst() -> void:
	if _wood_sounds.size() > 1:
		play_stream(_wood_sounds[1], 0.05, 3.0)
	if _plate_sounds.size() > 0:
		play_stream(_plate_sounds[0], 0.08, 0.0)

func play_enemy_death() -> void:
	if _wood_sounds.size() > 2:
		play_stream(_wood_sounds[2], 0.15, -1.0)

func play_room_clear() -> void:
	if _slash_sounds.size() > 0:
		play_stream(_slash_sounds[0], 0.02, 2.0)

func play_boss_stomp() -> void:
	if _wood_sounds.size() > 0:
		play_stream(_wood_sounds.pick_random(), 0.05, 4.0)

func play_pickup() -> void:
	if _slash_sounds.size() > 1:
		var p = _get_player()
		p.stream = _slash_sounds[1]
		p.volume_db = -4.0
		p.pitch_scale = 1.6
		p.play()
