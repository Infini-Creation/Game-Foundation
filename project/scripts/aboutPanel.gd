extends Control

signal panel_closed

var aboutText : String = Global.TRANSLATION_ERROR_MESSAGE_BBCODE

func _ready():
	$CenterContainer/VBoxContainer/TextureRect/RichTextLabel.text = aboutText
	
func _on_close_button_pressed() -> void:
	#send signal to caller to do whatever needed after closing
	hide()
	panel_closed.emit()
	
func _on_visibility_changed():
	aboutText = Global.lp_translations[Global.TRANSLATION_ABOUT_PAGE][TranslationServer.get_locale()][0]

