extends Control

signal panel_closed

var helpText : String = Global.TRANSLATION_ERROR_MESSAGE_BBCODE

func _ready():
	$CenterContainer/VBoxContainer/TextureRect/RichTextLabel.text = helpText

func _on_close_button_pressed() -> void:
	hide()
	panel_closed.emit()
	
func _on_visibility_changed():
	helpText = Global.lp_translations[Global.TRANSLATION_ABOUT_PAGE][TranslationServer.get_locale()][0]
