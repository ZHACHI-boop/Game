extends Area2D

export(String) var url_juego = "https://arbolabcgames.top/M80B/"
var dialogo_web_instance = null
var player_in_area = false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.name == "Character":
		player_in_area = true
		show_dialogo_web()

func _on_body_exited(body):
	if body.name == "Character":
		player_in_area = false
		hide_dialogo_web()

func show_dialogo_web():
	# Verificar si ya existe una instancia válida
	if dialogo_web_instance and is_instance_valid(dialogo_web_instance):
		dialogo_web_instance.mostrar(url_juego)
	else:
		var dialogo_web_scene = preload("res://Hud/DialogoWebCanvas.tscn")
		dialogo_web_instance = dialogo_web_scene.instance()
		get_node("/root/Main").add_child(dialogo_web_instance)
		dialogo_web_instance.mostrar(url_juego)
		
		# Conectar señales para manejo correcto
		dialogo_web_instance.connect("tree_exited", self, "_on_dialogo_web_exited")

func hide_dialogo_web():
	if dialogo_web_instance and is_instance_valid(dialogo_web_instance):
		dialogo_web_instance.ocultar()

func _on_dialogo_web_exited():
	dialogo_web_instance = null
	if player_in_area:
		show_dialogo_web()  # Volver a mostrar si el jugador sigue en el área
