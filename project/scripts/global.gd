extends Node

@export var debug_enabled : bool

const SETTINGS_FILE_PATH = "user://settings.ini"
const HIGHSCORES_FILE_PATH = "user://highscores.dat"

const HIGHSCORES_SCORE_START = 100
const HIGHSCORES_SCORE_STEP = 10

const HIGHSCORES_NAME_IDX = 0
const HIGHSCORES_SCORE_IDX = 1

const GAMETYPE_ONEPLAYER : String = "OnePlayer"
const GAMETYPE_TWOPLAYERS : String = "TwoPlayers"

const AUDIO_TYPE_SOUNDEFFECT = 0
const AUDIO_TYPE_MUSIC = 1

const available_musics = [
	preload("res://audio/musics/Prologue Theme.ogg"),
]

const sound_effects = {
	"loss": preload("res://audio/effects/ALERT_Error.wav"),
	"effectOne": preload("res://audio/effects/MENU A_Select.wav"),
	"effectTwo": preload("res://audio/effects/MENU A - Back.wav")
}

enum ButtonIDs { BUTTON_1PGAME, BUTTON_2PGAME, BUTTON_DUMMY, BUTTON_HELP, BUTTON_ABOUT, BUTTON_QUIT, BUTTON_SETTINGS, BUTTON_HIGHSCORES, BUTTON_SETTINGS_BACK, BUTTON_SETTINGS_SAVE }
enum LANGUAGE { ENGLISH, FRENCH, OTHER }
enum GAME_EXIT_STATUS { GAME_WON, GAME_LOSS, USER_QUIT }

const TRLP_PAGE_SEPARATOR = "==PS=="
const TRLP_TEXT_SEPARATOR = "==EOT=="
const TRLP_FILE_NAME = "res://Internationalization/long-texts.txt"
const TRANSLATION_ERROR_MESSAGE_BBCODE = "[center]Translation Error ![/center]"
const TRANSLATION_ERROR_MESSAGE_RAW = "Translation Error !"
const TRANSLATION_ABOUT_PAGE = "ABOUT"
const TRANSLATION_ABOUT_PAGECOUNT : int = 1
const TRANSLATION_HELP_PAGE = "HELP"
const TRANSLATION_HELP_PAGECOUNT : int = 7
const AVAILABLE_LANGUAGES : Array = [ "en", "fr", "tt" ]
const TRANSLATION_PANELS_PAGECOUNT : Dictionary = {
	TRANSLATION_ABOUT_PAGE: 1,
	TRANSLATION_HELP_PAGE : 7
}

# Here put all supported locale using the same value as defined for TranslationServer 
const LANGUAGE_SETTING : Dictionary = {
	LANGUAGE.FRENCH : "fr",
	LANGUAGE.ENGLISH : "en",
	LANGUAGE.OTHER : "tt"
}

const LANGUAGE_NAME_TRANSLATION : Array = [ "English", "Français", "test" ]

var dummyNames : Array = [
	"Player One",
	"Player Two",
	"Player Three",
	"Player Four",
	"Player Five",
	"Player Six",
	"Player Seven",
	"Player Eight"
]


var stats : Dictionary = {
	"GamesPlayed": 0,
	"GamesWon": 0,
	"GamesLost": 0,
	"TotalScore": 0
}

var settings : Dictionary = {
	"Audio": { 
		"soundEffects": true,
		"soundVolume": 100,
		"music": true,
		"musicVolume": 75,
		"musicToPlay": 0
	},
	"Display": {
		"screenOrientation": 0,
		"screenResolution": "TODO",
		"fullScreen": false
	},
	"Players": {
		"One": "Player1",
		"Two": "Player2"
	},
	"language": LANGUAGE.ENGLISH,
}

var highScores : Dictionary = {
	#to "translate" better to leave htem as before, add new array/dic gt=key
	"OnePlayer" : [],
	"TwoPlayers" : [],
	"dummy": [],
}

var lp_translations : Dictionary = {
	"HELP" : {
		LANGUAGE_SETTING[LANGUAGE.ENGLISH] : [],
		LANGUAGE_SETTING[LANGUAGE.FRENCH] : [],
		LANGUAGE_SETTING[LANGUAGE.OTHER] : []
	},
	"ABOUT" : {
		LANGUAGE_SETTING[LANGUAGE.ENGLISH] : [],
		LANGUAGE_SETTING[LANGUAGE.FRENCH] : [],
		LANGUAGE_SETTING[LANGUAGE.OTHER] : []
	}
}

var initialised : bool = false
var previous_scene : String
var configLoaded : bool = false



func save_config() -> bool:
	var config = ConfigFile.new()
	var ok : bool = true

	for item in settings:
		Global.debug("sav item=["+item+"]")
		if settings[item] is Dictionary:
			for subItem in settings[item]:
				Global.debug("sav subItem=["+subItem+"]="+str(settings[item][subItem]))
				config.set_value(item, subItem, settings[item][subItem])
		else:
			Global.debug("misc val=["+str(settings[item])+"]")
			config.set_value("misc", item, settings[item])
	
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("sav error=["+str(error)+"]") #TODO: deal with eror
			#or log to file
		ok = false

	return ok


func load_config():
	if configLoaded == true:
		Global.debug("cfg already loaded, skip")
		return

	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		Global.debug("load error=["+str(error)+"]") #TODO: deal with eror
	else:
	
		for item in settings:
			Global.debug("item=["+item+"]")
			if settings[item] is Dictionary:
				for subItem in settings[item]:
					Global.debug("subItem=["+subItem+"]")
					if config.has_section(item):
						if config.has_section_key(item, subItem):
							settings[item][subItem] = config.get_value(item, subItem, settings[item][subItem])
							Global.debug("cfgloaded ("+item+"/"+subItem+")=["+str(settings[item][subItem])+"]")
			else:
				settings[item] = config.get_value("misc", item, settings[item])
				Global.debug("cfgloaded ("+item+")=["+str(settings[item])+"]")
	Global.debug("LoadConf: settings="+str(settings))
	
	if LANGUAGE_SETTING.has(settings["language"]):
		Global.debug("set locale to: " + LANGUAGE_SETTING[settings["language"]])
		TranslationServer.set_locale(LANGUAGE_SETTING[settings["language"]])
	else:
		Global.debug("locale not supported, fall back to default (en)")
		TranslationServer.set_locale(LANGUAGE_SETTING[LANGUAGE.ENGLISH])
	configLoaded = true


func initialize_high_scores():
	var score : int
	var random_name : String

	for gameType in highScores:
		highScores[gameType] = []
		highScores[gameType].resize(10)
		
		score = HIGHSCORES_SCORE_START

		for idx in range(0, 10):
			random_name = dummyNames[randi_range(0,dummyNames.size() - 1)]
			
			highScores[gameType][idx] = [random_name, score]

func load_high_scores():
	if highScores[GAMETYPE_ONEPLAYER].size() == 0:
		var highscores = FileAccess.open(HIGHSCORES_FILE_PATH, FileAccess.READ)
		var error = FileAccess.get_open_error()
		if error == ERR_FILE_NOT_FOUND:
			Global.debug("HS file does not exists, initialize HS")
			initialize_high_scores()
			save_high_scores()
		elif error != OK:
			Global.debug("load_high_scores: error=["+str(error)+"]") #TODO: deal with eror
			#deal with filenotfound => init hs
		else:
			var gameType : String

			for gtidx in range(0, highScores.size()):
				gameType = highscores.get_pascal_string()
				highScores[gameType] = []
				highScores[gameType].resize(10)
				Global.debug("lHS gt="+gameType)

				for idx in range(0, 10):
					Global.debug("gt["+gameType+"] file array idx="+str(idx))
					highScores[gameType][idx] = []
					highScores[gameType][idx].resize(4)
					Global.debug("gt["+gameType+"] array ="+str(highScores[gameType][idx]))
					
					highScores[gameType][idx][HIGHSCORES_NAME_IDX] = highscores.get_pascal_string()
					Global.debug("gt["+gameType+"] loaded array ="+str(highScores[gameType][idx]))
					#highscores.get_error()
			highscores.close()


func save_high_scores():
	var highscores = FileAccess.open(HIGHSCORES_FILE_PATH, FileAccess.WRITE)
	var error = FileAccess.get_open_error()
	if error != Error.OK:
		Global.debug("save_high_scores: error=["+error+"]") #TODO: deal with eror

	for gameType in highScores:
		Global.debug("sHS gt="+gameType)
		highscores.store_pascal_string(gameType)

		for idx in range(0, 10):
			#highscores.store_pascal_string(highScores[gameType][idx][HIGHSCORES_NAME_IDX])
			#highscores.get_error()
			pass

	highscores.close()


func add_high_score(gameType, playerName : String, score : int)  -> void:
	for scoreIdx in range(0, highScores[gameType].size()):
		debug("score="+str(score)+" vs hs="+str(highScores[gameType][scoreIdx][HIGHSCORES_SCORE_IDX]))
		if score >= highScores[gameType][scoreIdx][HIGHSCORES_SCORE_IDX]:
			highScores[gameType].insert(scoreIdx, [playerName, score])
			highScores[gameType].pop_back()
			break


func load_long_texts() -> bool:
	var status : bool = false
	
	#~be sure all pages & langs are filled here so no check needed in about/help/other
	# add always "trans error" for missing page/lang
	var translationFile = FileAccess.open(TRLP_FILE_NAME, FileAccess.READ)
	var error = FileAccess.get_open_error()

	if error == ERR_FILE_NOT_FOUND:
		Global.debug("load_long_texts: translation file does not exists !")
	elif error != OK:
		Global.debug("load_long_texts: error=["+str(error)+"]") #TODO: deal with eror
	else:
		var data : String
		var totalpages : int = -1
		var page : String = ""
		var pageCount : int = 0
		var currLang : String = ""
		var currPage : int = 0

		while (translationFile.get_position() < translationFile.get_length()):
			data = translationFile.get_line()
			Global.debug("TrFile data=["+data+"]")
			Global.debug("l="+str(data.length()))

			if (totalpages == -1 and page == ""):
				# check format 1st
				totalpages = data.right(1).to_int()
				page = data.erase(data.length()-2, 2)
				pageCount += 1
				Global.debug("tp="+str(totalpages)+" page="+page)
				
				if lp_translations.has(page):
					Global.debug("page["+page+"] exists in dic")
				else:
					Global.debug("(warn?)page["+page+"] DOES NOT exist in dic")
			else:
				
				#kind of automata could be done using accumulator var step=1, 2, 3
				#then if ... and step=[expected step]
				# 		else: error break, report file is wrong
				# does this even matter ? file are not made by users anyway !!
				
				
				if data == TRLP_PAGE_SEPARATOR:
					pageCount += 1
					Global.debug("==> new page pC="+ str(pageCount))
				elif data == TRLP_TEXT_SEPARATOR:
					Global.debug("==> new language")
					Global.debug("pC="+ str(pageCount) +"  tp="+ str(totalpages))
					
					if pageCount != totalpages:
						Global.debug("WARNING: get "+ str(pageCount) +" pages over "+ str(totalpages) +" expected !")
						#error ? status=false
					else:
						Global.debug("all pages read")
						pageCount = 0
						totalpages = -1
						page = ""
						currLang = ""

				elif data.length() == 2 and !data.is_valid_int() and currLang.is_empty():
					Global.debug("lang?="+data)
					currLang = data
					#here allocate array for tp size
					#set array size here
					lp_translations[page][currLang].resize(totalpages)
					
				elif data.length() == 1 and data.is_valid_int():
					currPage = data.to_int()
					Global.debug("page="+data+" / tp="+str(totalpages))
				else:
					Global.debug("store data")
					if lp_translations[page][currLang][currPage - 1] == null:
						lp_translations[page][currLang][currPage - 1] = ""
					lp_translations[page][currLang][currPage - 1] += data + "\n"

		translationFile.close()
	
	#check all loaded trans, if all supported lang there + all pages
	#no need to check maybe, when filling, no lang... tr error def msg
	# BUT missing tr won't be known when reading the file
	for page in [TRANSLATION_ABOUT_PAGE, TRANSLATION_HELP_PAGE]:
		for language in AVAILABLE_LANGUAGES:
			Global.debug("check pg[" + page + "] lang[" + language + "]")
			if lp_translations[page].has(language) and lp_translations[page][language].size() > 0:
				Global.debug("LPT="+str(lp_translations[page][language].size()))
			else:
				Global.debug("add default error into pg[" + page + "] lg[" + language + "]")
				lp_translations[page][language].resize(TRANSLATION_PANELS_PAGECOUNT[page])
				for count in range(0,TRANSLATION_PANELS_PAGECOUNT[page]):
					if page == "HELP":
						lp_translations[page][language][count] = TRANSLATION_ERROR_MESSAGE_RAW
					else:
						lp_translations[page][language][count] = TRANSLATION_ERROR_MESSAGE_BBCODE
		
	#status = true

	return status


func debug(msg : String) -> void:
	if (debug_enabled == true):
		print(msg)
