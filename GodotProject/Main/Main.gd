extends Node

onready var hud = $Hud
onready var life_bar = $Hud/LifeBar

func _ready():
	print(get_node("/root/Main").get_children())  # Ver si aparece DialogoWebCanvas
	var player = $World/YSort/Character
	player.connect("hit",hud,"on_player_hit")
	life_bar.connect("dead",player,"death")


