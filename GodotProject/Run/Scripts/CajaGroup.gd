extends Node2D

# Asegúrate de que estos nombres coincidan con los de tu escena
export(NodePath) var caja_izquierda_path
export(NodePath) var caja_centro_path
export(NodePath) var caja_derecha_path

onready var cajas = [
	get_node_or_null(caja_izquierda_path),
	get_node_or_null(caja_centro_path),
	get_node_or_null(caja_derecha_path)
]

var caja_correcta_index : int

func _ready():
	print("¡Grupo de cajas listo!")
	update()
	randomize()
	caja_correcta_index = randi() % 3  # 0, 1, o 2
	for i in range(3):
		if cajas[i] != null:  # Verifica que el nodo exista
			cajas[i].is_correct = (i == caja_correcta_index)
		else:
			print("¡Error: Caja ", i, " no encontrada!")
			
func _draw():
	draw_rect(Rect2(-50, -50, 100, 100), Color.red, false)
