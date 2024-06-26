extends Control

@export var music_enabled_icon : Texture
@export var music_disabled_icon : Texture

@onready var VolumeValue = $HBoxContainer/VolumeValue

var music_volume : int
var music_enabled : bool

signal settings_updated(audio_type, music_volume, music_enabled)


func _ready():
	$HBoxContainer/TextureButton.texture_normal = music_enabled_icon
	$HBoxContainer/TextureButton.texture_pressed = music_disabled_icon
	
	$HBoxContainer/HSlider.value = music_volume
	$HBoxContainer/TextureButton.button_pressed = !music_enabled
	
	VolumeValue.text = str($HBoxContainer/HSlider.value)


func load_settings(updated_music_volume : int, updated_music_enabled : bool) -> void:
	if updated_music_volume >= 0 and updated_music_volume <= 100:
		music_volume = updated_music_volume
	music_enabled = updated_music_enabled
	Global.debug("umv="+str(updated_music_volume)+" ume="+str(updated_music_enabled))
	Global.debug("mv="+str(music_volume)+" me="+str(music_enabled))
	
	$HBoxContainer/HSlider.value = music_volume
	$HBoxContainer/TextureButton.button_pressed = !music_enabled


func _on_texture_button_toggled(button_pressed):
	Global.debug("av butt press="+str(button_pressed))
	$HBoxContainer/HSlider.editable = !button_pressed
	music_enabled = !button_pressed
	#bp=true = audio disabled, false = enabled
	Global.debug("av settings signal="+str(button_pressed))
	settings_updated.emit(music_volume, !button_pressed)


func _on_h_slider_value_changed(value):
	Global.debug("slider="+str(value))
	VolumeValue.text = str(value)
	settings_updated.emit(value, music_enabled)
