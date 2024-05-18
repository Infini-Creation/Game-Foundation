extends Node2D

signal game_end(status : int, score: int)
signal playsound(String)

var quit : bool = false
var score : int = 0

func _ready():
	Global.debug("game is ready")
	OS.set_low_processor_usage_mode(true)


func setup(number_of_players : int, game_type: String) -> void:
	#TODO
	pass


func _input(event):
	if event.is_action_pressed("Quit"):
		quit = true


func _process(_delta):
	if quit:
		game_over(Global.GAME_EXIT_STATUS.USER_QUIT)
		return


func _on_button_pressed() -> void:
	Global.debug("Game quit button pressed")
	#go back to menu
	game_end.emit(Global.GAME_EXIT_STATUS.USER_QUIT, score)

func _on_noise_pressed() -> void:
	playsound.emit("effectOne")
	score += randi_range(1, 1000)
	$CenterContainer/VBoxContainer/Score.text = str(score)


func game_over(status : int):
	pass
