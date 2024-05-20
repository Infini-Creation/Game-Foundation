extends Control

signal language_updated(lang: int)

var language : int

func _on_label_gui_input(event: InputEvent) -> void:
	var displayedLangText = TranslationServer.get_language_name(Global.AVAILABLE_LANGUAGES[Global.settings["language"]])

	#Global.debug("label InEv="+str(event))
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			language += 1
			language %= Global.AVAILABLE_LANGUAGES.size()
			#var labtext = Global.AVAILABLE_LANGUAGES[language]

			#Global.debug("text = "+labtext+"  langn="+TranslationServer.get_language_name(labtext))
			#displayedLangText = TranslationServer.get_language_name(labtext)
			displayedLangText = Global.LANGUAGE_NAME_TRANSLATION[language]
				#here : translate language name natively if possible
			language_updated.emit(language)

			##if labtext == "tt":
			##	displayedLangText = "test"

			$Label.text = displayedLangText
