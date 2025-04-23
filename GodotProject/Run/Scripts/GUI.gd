extends CanvasLayer

onready var lives_bar = $LivesBar
var lives = 5

func reduce_life():
	lives -= 1
	lives_bar.value = lives
	if lives <= 0:
		get_tree().change_scene("res://Run/Assets/Sprite/Life_Line.png")
