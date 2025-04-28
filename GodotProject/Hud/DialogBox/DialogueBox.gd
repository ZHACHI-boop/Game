extends Control

signal dialogue_ended
signal minigame_invitation  # Nueva señal

onready var text_label = $TextureRect/RichTextLabel
onready var name_label = $TextureRect/Name
onready var indicator_anim = $TextureRect/Next/AnimationPlayer
onready var next_indicator = $TextureRect/Next
onready var timer = $Timer
onready var face_sprite = $TextureRect/FaceNPC

var current_dialogue = []
var current_line = 0
var is_typing = false
var text_speed = 0.05
var is_active = false
var waiting_for_input = false
var total_characters = 0
var displayed_characters = 0

func _ready():
	hide()
	timer.wait_time = text_speed
	next_indicator.visible = false
	set_process_input(false)
	timer.connect("timeout", self, "_on_Timer_timeout")  # Conexión única

func start_dialogue(dialogue_data):
	if is_active:
		return
		
	is_active = true
	current_dialogue = dialogue_data
	current_line = 0
	show()
	set_process_input(true)
	show_line()

func show_line():
	# Reiniciar estados
	next_indicator.visible = false
	indicator_anim.stop()
	waiting_for_input = false
	
	if current_line >= current_dialogue.size():
		end_dialogue()
		return
	
	var line = current_dialogue[current_line]
	name_label.text = line.get("name", "")
	text_label.text = line["text"]  # Establecer texto completo
	text_label.visible_characters = 0  # Ocultar inicialmente
	total_characters = line["text"].length()
	displayed_characters = 0
	
	if line.has("face"):
		var face_texture = load(line["face"])
		if face_texture:
			face_sprite.texture = face_texture
	
	is_typing = true
	timer.start()  # Iniciar el timer

func _on_Timer_timeout():
	if !is_typing:
		return
	
	displayed_characters += 1
	text_label.visible_characters = displayed_characters
	
	if displayed_characters >= total_characters:
		finish_typing()
	else:
		timer.start()  # Continuar el timer

func finish_typing():
	timer.stop()
	is_typing = false
	waiting_for_input = true
	show_next_indicator()

func show_next_indicator():
	next_indicator.visible = true
	indicator_anim.play("Circulo")

func hide_next_indicator():
	next_indicator.visible = false
	indicator_anim.stop()
	
func end_dialogue():
	timer.stop()
	set_process_input(false)
	hide_next_indicator()
	is_active = false
	waiting_for_input = false
	hide()
	
	# Verificar si este diálogo debe invitar al minijuego
	var current_line_data = current_dialogue[current_line - 1] if current_line > 0 else null
	if current_line_data and current_line_data.get("invite_minigame", false):
		emit_signal("minigame_invitation")
	else:
		emit_signal("dialogue_ended")
	
	queue_free()

func _input(event):
	if event.is_action_pressed("ui_accept") and is_active:
		if is_typing:
			# Mostrar todo el texto inmediatamente
			text_label.visible_characters = -1  # Mostrar todos los caracteres
			finish_typing()
		elif waiting_for_input:
			hide_next_indicator()
			current_line += 1
			show_line()
