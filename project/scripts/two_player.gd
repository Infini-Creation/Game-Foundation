extends Control

signal twoplayer_game_requested

func _on_button_pressed():
	twoplayer_game_requested.emit()
