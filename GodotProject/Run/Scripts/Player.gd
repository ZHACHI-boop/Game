extends KinematicBody2D

var speed = 200
var velocity = Vector2()
var follow_speed = 5.0

func _ready():
	add_to_group("Player")  # Para identificación fácil

func _process(delta):
	var target_pos = get_global_mouse_position()
	position = position.linear_interpolate(target_pos, follow_speed * delta)

func continue_running():
	$Player.play("run")

func fall_back():
	position.y += 50
	$Player.play("Morir")
