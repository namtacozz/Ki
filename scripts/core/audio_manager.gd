extends Node


signal music_changed(track_name: String)

const POOL_SIZE = 8
var sfx_players: Array[AudioStreamPlayer] = []
var typewriter_player: AudioStreamPlayer

var card_music_paths: Array[String] = [
	"res://assets/audio/music/TheFool.mp3",
	"res://assets/audio/music/TheMagician.mp3",
	"res://assets/audio/music/TheHighPriestess.mp3",
	"res://assets/audio/music/TheEmpress.mp3",
	"res://assets/audio/music/TheEmperor.mp3",
	"res://assets/audio/music/TheHierophant.mp3",
	"res://assets/audio/music/TheLovers.mp3",
	"res://assets/audio/music/TheChariot.mp3",
	"res://assets/audio/music/Strength.mp3",
	"res://assets/audio/music/TheHermit.mp3",
	"res://assets/audio/music/WheelofFortune.mp3",
	"res://assets/audio/music/Justice.mp3",
	"res://assets/audio/music/TheHangedMan.mp3",
	"res://assets/audio/music/Death.mp3",
	"res://assets/audio/music/Temperance.mp3",
	"res://assets/audio/music/TheDevil.mp3",
	"res://assets/audio/music/TheTower.mp3",
	"res://assets/audio/music/TheStar.mp3",
	"res://assets/audio/music/TheMoon.mp3",
	"res://assets/audio/music/TheSun.mp3",
	"res://assets/audio/music/Judgement.mp3",
	"res://assets/audio/music/TheWorld.mp3"
]

const MAIN_THEME_PATH = "res://assets/audio/music/TarotVeil.mp3"

var _bgm_player1: AudioStreamPlayer
var _bgm_player2: AudioStreamPlayer
var _active_bgm: AudioStreamPlayer
var _fading_out_bgm: AudioStreamPlayer
var _music_tween: Tween

var sfx_paths = {
	"hover": "res://assets/audio/sfx_hover.ogg",
	"click": "res://assets/audio/sfx_click.ogg",
	"typewriter": "res://assets/audio/sfx_typewriter.ogg",
	"card_draw": "res://assets/audio/sfx_card_draw.ogg",
	"card_place": "res://assets/audio/sfx_card_place.ogg",
	"soul_fragment": "res://assets/audio/sfx_soul_fragment.ogg",
	"transition": "res://assets/audio/sfx_transition.ogg"
}
var sfx_cache = {}

func _ready() -> void:
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
		
	typewriter_player = AudioStreamPlayer.new()
	# Pre-cache typewriter if it exists
	if FileAccess.file_exists(sfx_paths["typewriter"]):
		typewriter_player.stream = load(sfx_paths["typewriter"])
	add_child(typewriter_player)
	
	_bgm_player1 = AudioStreamPlayer.new()
	add_child(_bgm_player1)
	
	_bgm_player2 = AudioStreamPlayer.new()
	add_child(_bgm_player2)
	
	_active_bgm = _bgm_player1

func play_sfx(stream_name: String) -> void:
	if not sfx_paths.has(stream_name):
		push_warning("AudioManager: Stream '%s' not found in paths." % stream_name)
		return
		
	var stream = _get_sfx_stream(stream_name)
	if not stream:
		return
		
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
			
	var oldest_player = sfx_players[0]
	oldest_player.stream = stream
	oldest_player.play()

func _get_sfx_stream(stream_name: String) -> AudioStream:
	if sfx_cache.has(stream_name):
		return sfx_cache[stream_name]
	
	var path = sfx_paths[stream_name]
	if FileAccess.file_exists(path):
		var stream = load(path)
		sfx_cache[stream_name] = stream
		return stream
	
	return null

func play_typewriter() -> void:
	if not typewriter_player.playing:
		typewriter_player.play()

func stop_typewriter() -> void:
	if typewriter_player.playing:
		typewriter_player.stop()

func play_main_theme() -> void:
	if not FileAccess.file_exists(MAIN_THEME_PATH): return
	var stream = load(MAIN_THEME_PATH)
	_transition_music(stream)
	music_changed.emit("Tarot Veil")

func play_card_music(card_id: int) -> void:
	if card_id < 0 or card_id >= card_music_paths.size():
		return
	var path = card_music_paths[card_id]
	if not FileAccess.file_exists(path): return
	var stream = load(path)
	_transition_music(stream)
	
	var track_name := path.get_file().get_basename()
	var tarot_manager = get_node_or_null("/root/TarotManager")
	if tarot_manager and tarot_manager.has_method("get_card_by_id"):
		var card = tarot_manager.get_card_by_id(card_id)
		if not card.is_empty():
			track_name = card.get("name", track_name)
	music_changed.emit(track_name)

func stop_music() -> void:
	if is_instance_valid(_music_tween):
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_active_bgm, "volume_db", -80.0, 1.0)
	_music_tween.tween_callback(func(): _active_bgm.stop())

func _transition_music(new_track: AudioStream) -> void:
	if _active_bgm.stream == new_track and _active_bgm.playing:
		return
		
	if is_instance_valid(_music_tween):
		_music_tween.kill()
		
	_music_tween = create_tween()
	
	_fading_out_bgm = _active_bgm
	_active_bgm = _bgm_player2 if _active_bgm == _bgm_player1 else _bgm_player1
	
	_active_bgm.stream = new_track
	_active_bgm.volume_db = -80.0
	_active_bgm.play()
	
	_music_tween.set_parallel(true)
	if _fading_out_bgm.playing:
		_music_tween.tween_property(_fading_out_bgm, "volume_db", -80.0, 1.0)
	_music_tween.tween_property(_active_bgm, "volume_db", 0.0, 1.0)
	
	_music_tween.set_parallel(false)
	_music_tween.tween_callback(func(): _fading_out_bgm.stop())
