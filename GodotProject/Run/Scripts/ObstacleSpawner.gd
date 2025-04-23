extends Node2D

export(PackedScene) var caja_group_scene  # Asigna CajaGroup.tscn en el inspector

func _ready():
	print("ObstacleSpawner inicializado")
	if caja_group_scene == null:
		print("¡Error: caja_group_scene no está asignado!")
	$Timer.start()

func _on_Timer_timeout():
	var grupo = caja_group_scene.instance()
	add_child(grupo)
	grupo.position = Vector2(0, get_viewport_rect().size.y + 100)  # Aparece abajo
	print("Grupo creado en: ", grupo.position)
