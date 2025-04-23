extends CanvasLayer

onready var music_ventana = $AudioStreamPlayer
onready var panel = $Panel
onready var vbox = $Panel/VBoxContainer
onready var label = $Panel/Label
onready var boton_jugar = $Panel/VBoxContainer/jugar
onready var boton_volver = $Panel/VBoxContainer/volver
onready var tween = Tween.new()
onready var music_player = get_node("/root/Main/MusicPlayer")
var juegos = {
	"https://arbolabcgames.top/M82B/": "LISTOS? YA!",
	"https://arbolabcgames.top/F37A/": "ZOO DE SILABAS",
	"https://arbolabcgames.top/M80B/": "DE COMPRAS",
	"https://arbolabcgames.top/M91AB/": "VOLCAN DE FORMAS",
	"https://arbolabcgames.top/L32A/": "RUTA MAYA",
	"https://arbolabcgames.top/L8A/": "BURBUJAS ALFABETICAS",
	"https://arbolabcgames.top/L5A/": "MEMORIA",
	"https://arbolabcgames.top/Patos-locos/Build/index.html": "PATOS LOCOS"
}

var url_actual = ""

func _ready():
	tween = Tween.new()
	add_child(tween)
	panel.visible = false
	music_ventana.stop()
	vbox.modulate.a = 0
	boton_jugar.connect("pressed", self, "_on_jugar_pressed")
	boton_volver.connect("pressed", self, "_on_volver_pressed")

func mostrar(url):
	url_actual = url
	var nombre_juego = juegos.get(url, url)
	label.text = "¿Quieres jugar '%s'?" % nombre_juego
	panel.visible = true
	music_ventana.play()
	music_player.stream_paused = true
	tween.interpolate_property(vbox, "modulate:a", 0, 1, 0.3)
	tween.interpolate_property(music_ventana, "volume_db", -80, -10, 0.5, Tween.TRANS_SINE)
	tween.start()

func ocultar():
	music_ventana.stop()
	tween.interpolate_property(vbox, "modulate:a", 1, 0, 0.2)
	tween.start()
	yield(tween, "tween_completed")
	panel.visible = false
	music_player.stream_paused = false
	get_node("/root/Main/MusicPlayer").stream_paused = false

func _on_jugar_pressed():
	OS.shell_open(url_actual)
	ocultar()

func _on_volver_pressed():
	ocultar()
