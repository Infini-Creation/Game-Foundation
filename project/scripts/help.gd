extends Control

signal help_requested

func _on_button_pressed() -> void:
	help_requested.emit()
