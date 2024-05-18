extends Control

signal settings_requested

func _on_button_pressed() -> void:
	settings_requested.emit()
