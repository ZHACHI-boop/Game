extends CanvasLayer
class_name DialogueManager

# Configuración de escala para compensar la cámara
export(Vector2) var camera_scale = Vector2(0.31, 0.27)

# Referencia al diálogo box
onready var dialogue_box = preload("res://Hud/DialogBox/DialogueBox.tscn")
var current_dialogue: DialogueBox = null

func _ready():
	# Configuración del CanvasLayer
	layer = 100  # Capa alta
	follow_viewport_enable = true  # Seguir la cámara
	offset = Vector2(0, 0)
	scale = Vector2(1.0/camera_scale.x, 1.0/camera_scale.y)  # Compensar escala
	set_process_input(false)

func show_dialogue(dialogue_data: Array) -> void:
	# Limpiar diálogo anterior
	if is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
	
	# Crear nueva instancia
	current_dialogue = dialogue_box.instance()
	add_child(current_dialogue)
	
	# Configurar y conectar señales
	current_dialogue.start_dialogue(dialogue_data)
	current_dialogue.connect("dialogue_ended", self, "_on_dialogue_ended")
	current_dialogue.connect("show_game_option", self, "_on_show_game_option")
	set_process_input(true)

func _on_dialogue_ended():
	set_process_input(false)
	if is_instance_valid(current_dialogue):
		current_dialogue.queue_free()
	current_dialogue = null

func _on_show_game_option(ruta: String, tipo: String):
	# Manejar la opción de juego
	match tipo:
		"URL":
			OS.shell_open(ruta)
		"escena":
			get_tree().change_scene(ruta)

func _input(event):
	# Redirigir input al diálogo actual
	if current_dialogue and current_dialogue.is_active:
		current_dialogue._input(event)
