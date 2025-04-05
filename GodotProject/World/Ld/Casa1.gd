extends Area2D

export(String) var url_juego = "https://arbolabcgames.top/M82B/"  # Cambia esto por cada casa

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.name == "Character":
		get_node("/root/Main/DialogoWebCanvas").mostrar(url_juego)

func _on_body_exited(body):
	if body.name == "Character":
		get_node("/root/Main/DialogoWebCanvas").ocultar()
