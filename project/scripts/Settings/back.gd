extends Control

signal settings_back_clicked

func _on_button_pressed() -> void:
	settings_back_clicked.emit()
