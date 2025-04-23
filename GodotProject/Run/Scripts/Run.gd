extends Node2D

const Caja = preload("res://Run/Scenes/Obstacle.tscn")
export var spawn_interval = 3.0
export var start_y = 700  # Posición Y inicial (fuera de pantalla)
export var horizontal_spacing = 150  # Espacio entre cajas

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.start()

func _on_Timer_timeout():
	spawn_three_boxes()

func spawn_three_boxes():
	var viewport_width = get_viewport_rect().size.x
	var start_x = viewport_width / 2  # Centro horizontal
	
	for i in range(3):  # 0, 1, 2
		var caja = Caja.instance()
		add_child(caja)
		
		# Posición X: Centro + desplazamiento (-1, 0, 1)
		caja.position = Vector2(
			start_x + (i - 1) * horizontal_spacing,
			start_y
		)
		
		# Opcional: Aleatoriedad visual
		caja.rotation_degrees = rand_range(-10, 10)
		caja.scale = Vector2(rand_range(0.9, 1.1), rand_range(0.9, 1.1))
