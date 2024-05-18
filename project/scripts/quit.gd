extends Control

signal quit_requested

func _on_button_pressed() -> void:
	quit_requested.emit()
