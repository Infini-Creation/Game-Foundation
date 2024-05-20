extends Control

signal settings_accept_clicked

func _on_button_pressed() -> void:
	settings_accept_clicked.emit()
