extends Node

# base scene where all takes place
# init settings, HS

@onready var musicPlayer = $MusicPlayer
@onready var soundEffectPlayer = $SoundEffectPlayer

@export var currentMusic : int = 0

var mainMenuScene = preload("res://Scenes/main_menu.tscn")
var gameScene = preload("res://Scenes/game.tscn")

var menu
var game
var current_game_type : String = ""


func _init():
	Global.debug_enabled = true #tmp
	
	Global.debug("origin: init called")
	#
	#also called again after qitting a game !
	
	if !Global.initialised:
		Global.debug("origin: init config & stuff")
		Global.load_config()
		Global.debug("settings="+str(Global.settings))
		
		if FileAccess.file_exists(Global.HIGHSCORES_FILE_PATH):
			Global.debug("load HS file")
			Global.load_high_scores()
		else:
			Global.debug("init HS file")
			Global.initialize_high_scores()
			Global.save_high_scores()
			
		var load_tr_status = Global.load_long_texts()
		Global.debug("load translation file="+str(load_tr_status))
		
		Global.initialised = true


#this may be in _init func, this one is called every time player quit and play again !
func _ready():
	Global.debug("origin: ready")
	currentMusic = randi_range(0, Global.available_musics.size()-1)
	musicPlayer.stream = Global.available_musics[currentMusic]

	Global.debug("setting="+str( Global.settings["Audio"]["music"] ))

	if Global.settings["Audio"]["music"] == true:
		musicPlayer.volume_db = linear_to_db(Global.settings["Audio"]["musicVolume"] / 100.0)
		musicPlayer.play()
	else:
		musicPlayer.stop()

	if Global.settings["Audio"]["soundEffects"] == true:
		soundEffectPlayer.volume_db = linear_to_db(Global.settings["Audio"]["soundVolume"] / 100.0)
	else:
		soundEffectPlayer.stop()

	Global.debug("origin: inst. game & menu")
	menu = mainMenuScene.instantiate()
	game = gameScene.instantiate()

	Global.debug("origin: add menu")
	add_child(menu)

	menu.connect("launch_game", _on_game_launched)
	menu.connect("audio_volume_updated", _on_audio_settings_updated)


func _on_audio_settings_updated(audio_type : int, new_volume: int) -> void:
	Global.debug("audio change T="+str(audio_type)+" vol="+str(new_volume))
	if audio_type == Global.AUDIO_TYPE_MUSIC:
		musicPlayer.volume_db = linear_to_db(new_volume / 100.0)
	elif audio_type == Global.AUDIO_TYPE_SOUNDEFFECT:
		soundEffectPlayer.volume_db = linear_to_db(new_volume / 100.0)


func _on_game_launched(gameType : String):
	Global.debug("origin: launch game="+gameType)
	current_game_type = gameType
	Global.previous_scene = get_tree().current_scene.scene_file_path
	Global.debug("origin: prev scene=" + Global.previous_scene)

	# here maybe check GT 1P/2P, set nb players accordingly
	game.setup(0, gameType)

	Global.debug("origin: remove menu & add game")
	remove_child(menu)
	add_child(game)
	Global.debug("origin: game added to tree")
	
	game.connect("game_end", _on_game_is_over)

	if Global.settings["Audio"]["soundEffects"] == true:
		game.connect("playsound", _on_game_play_soundeffect)
		
	#add gametype, as param,  global or to game
	#	current_session_data


func _on_game_play_soundeffect(effect : String):
	Global.debug("_on_game_play_soundeffect called with effect: "+effect)
	
	if Global.settings["Audio"]["soundEffects"] == true:
		if Global.sound_effects.has(effect):
			soundEffectPlayer.stream = Global.sound_effects[effect]
			soundEffectPlayer.play()
		else:
			Global.debug("unkown sound effect: "+effect)


func _on_game_is_over(status : int, score : int):
	var update_hs : bool = false
	Global.debug("origin: _on_game_is_over called, status =" + str(status))
	if status == Global.GAME_EXIT_STATUS.GAME_WON:
		Global.debug("origin/_ogio: Game won")
		update_hs = true

	elif status == Global.GAME_EXIT_STATUS.GAME_LOSS:
		Global.debug("origin/_ogio: Game loss")
		update_hs = true

	elif status == Global.GAME_EXIT_STATUS.USER_QUIT:
		Global.debug("origin/_ogio: quit")
	
	# that should be done only after GOP button clicked (as well as add menu below)
	Global.debug("origin: game child will be removed")
	remove_child(game)
	
	if update_hs == true:
		Global.debug("update HS")
		update_highscores(current_game_type, score)
		
	current_game_type = ""
	add_child(menu)
	get_tree().change_scene_to_file(Global.previous_scene)


func update_highscores(gameType : String, score: int) -> void:
	#need to convert player idx in string for access settings/or change settings
	Global.debug("saveHS type="+gameType+" s="+str(score))
	# later : play highscore update animation
		#tween ?
		# put below row one row down
		# add new row
		# wait for user to click to go back to main menu
	if gameType == Global.GAMETYPE_ONEPLAYER:
		Global.add_high_score(gameType, Global.settings["Players"]["One"], score)
	elif gameType == Global.GAMETYPE_TWOPLAYERS:
		Global.add_high_score(gameType, Global.settings["Players"]["One"], score)
		Global.add_high_score(gameType, Global.settings["Players"]["Two"], score)

	Global.save_high_scores()
