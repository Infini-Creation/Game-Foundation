extends Control

signal button_clicked(buttonID : int)

func _ready():
	Global.debug("MM buttons _ready called")

func _on_visibility_changed():
	Global.debug("MM buttons vis changed called: "+str(visible))

func hide_quit_button():
	$ButtonGroup/ButtonsRow4/Quit.hide()

func _on_one_player_oneplayer_game_requested():
	Global.debug("1P game button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_1PGAME)

func _on_settings_settings_requested():
	Global.debug("Settings button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_SETTINGS)
	
func _on_two_player_twoplayer_game_requested():
	Global.debug("2P game button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_2PGAME)

func _on_high_scores_item_highscores_requested():
	Global.debug("HighSCores button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_HIGHSCORES)
	
func _on_help_help_requested():
	Global.debug("help button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_HELP)

func _on_about_about_requested() -> void:
	Global.debug("About button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_ABOUT)

func _on_quit_quit_requested():
	Global.debug("Quit button clicked")
	button_clicked.emit(Global.ButtonIDs.BUTTON_QUIT)
