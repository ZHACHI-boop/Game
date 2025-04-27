extends Control

signal play_minigame
signal window_closed

onready var play_button = $TextureRect/VBoxContainer/jugar
onready var return_button = $TextureRect/VBoxContainer/volver

func _ready():
	play_button.connect("pressed", self, "_on_PlayButton_pressed")
	return_button.connect("pressed", self, "_on_ReturnButton_pressed")
	hide()

func _on_PlayButton_pressed():
	emit_signal("play_minigame")
	hide()

func _on_ReturnButton_pressed():
	emit_signal("window_closed")
	queue_free()

func show_window():
	show()
