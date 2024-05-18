extends Control

@onready var MainMenuButtons : PackedScene = preload("res://Scenes/Main Menu/Buttons.tscn")
#@onready var SettingsButtons : PackedScene = preload("res://Scenes/SettingsMenu/Controls.tscn")
#@onready var highScoresPage : PackedScene = preload("res://Scenes/high_scores.tscn")
@onready var gameScene : PackedScene = preload("res://Scenes/game.tscn")

var mainMenuButtons
var settingsMenu
var highScores
var game
var mainMenuSave : Node

signal launch_game(game_type : String)
signal audio_volume_updated(type: int, volume: int)


func _ready():
	game = gameScene.instantiate()

	$CenterContainer/DummyLabel.hide()
	mainMenuButtons = MainMenuButtons.instantiate()
	Global.debug("add MM buttons")
	$CenterContainer.add_child(mainMenuButtons)
	mainMenuButtons.connect("button_clicked", _on_button_click_received)
	
	# Quit button is useless for Web export (does nothing) so hide it in such case
	if OS.get_name() == "Web":
		MainMenuButtons.hide_quit_button()


func _on_button_click_received(buttonID : int):
	Global.debug("id="+str(buttonID))
	match buttonID:
	# Main menu buttons
		Global.ButtonIDs.BUTTON_1PGAME:
			launch_game.emit(Global.GAMETYPE_ONEPLAYER)

		Global.ButtonIDs.BUTTON_2PGAME:
			launch_game.emit(Global.GAMETYPE_TWOPLAYERS)

		Global.ButtonIDs.BUTTON_ABOUT:
			# maybe
			mainMenuButtons.hide()
			$AboutPanel.show()

		Global.ButtonIDs.BUTTON_HELP:
			mainMenuButtons.hide()
			$HelpPanel.show()

		Global.ButtonIDs.BUTTON_QUIT:
			get_tree().quit()

		Global.ButtonIDs.BUTTON_SETTINGS:
			if mainMenuButtons != null: #or is in tree
				Global.debug("remove MM buttons")
				$CenterContainer.remove_child(mainMenuButtons)
				##mainMenuButtons.queue_free() #may cause issue

			##settingsMenu = SettingsButtons.instantiate()
			##$CenterContainer.add_child(settingsMenu)
			#settingsMenu.connect("button_clicked", _on_button_click_received)
			#settingsMenu.connect("sound_volume_updated", _on_sound_volume_updated)
			#settingsMenu.connect("language_updated", _on_language_updated)

		Global.ButtonIDs.BUTTON_HIGHSCORES:
			$HallOfFamePanel.show()

		Global.ButtonIDs.BUTTON_SETTINGS_BACK:
			$CenterContainer.remove_child(settingsMenu)
			##settingsMenu.queue_free()
			Global.debug("settings back to MM, add MM buttons")
			$CenterContainer.add_child(mainMenuButtons)

		Global.ButtonIDs.BUTTON_SETTINGS_SAVE:
			Global.debug("call save settings HERE")
			
			# ==> + update sound volume and on/off status
			# gather settings (signal ?) or save in settings script directly
			#  would be better no need to transfert data here, global is global !
			# as above, go back to main menu ?

		_: 
			Global.debug("unhandled action : " + str(buttonID))


func _on_about_panel_panel_closed() -> void:
	mainMenuButtons.show()

func _on_help_panel_panel_closed() -> void:
	mainMenuButtons.show()
