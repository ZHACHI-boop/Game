extends Node2D

export var speed = 100
onready var bg1 = $Sprite1
onready var bg2 = $Sprite2
onready var bg3 = $Sprite3

var sprite_height = 0

func _ready():
	sprite_height = bg1.texture.get_size().y

	# Posicionamos los 3 en orden vertical
	bg1.position = Vector2(0, 0)
	bg2.position = Vector2(0, -sprite_height)
	bg3.position = Vector2(0, -sprite_height * 2)

func _process(delta):
	# Mover todos
	bg1.position.y += speed * delta
	bg2.position.y += speed * delta
	bg3.position.y += speed * delta

	# Cuando uno se sale abajo, lo mandamos arriba del que está más arriba
	if bg1.position.y >= sprite_height * 2:
		bg1.position.y = min(bg2.position.y, bg3.position.y) - sprite_height
	if bg2.position.y >= sprite_height * 2:
		bg2.position.y = min(bg1.position.y, bg3.position.y) - sprite_height
	if bg3.position.y >= sprite_height * 2:
		bg3.position.y = min(bg1.position.y, bg2.position.y) - sprite_height
