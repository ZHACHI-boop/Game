extends CanvasLayer


onready var logo = $Logo
onready var logo2 = $Logo2
onready var menu = $MenuPanel
onready var anim = $AnimationPlayer
onready var audio = $MenuPanel/Audio

func _ready():
	logo.modulate.a = 0
	logo2.modulate.a = 0
	menu.modulate.a = 0
	animar_entrada()

func animar_entrada():

	anim.queue("fade_in_background")
	anim.queue("logo_drop")
	anim.queue("logo_dropp_2")
	anim.queue("menu_popup")
	audio.volume_db = -20
	audio.play()
	anim.queue("audio_fade_in")

func _on_PlayBtn_pressed():
	animar_salida()
	yield(anim, "animation_finished")
	get_tree().change_scene("res://Main/Main.tscn")
	

	
func animar_salida():
	anim.play("fade_out_elements")
	anim.queue("audio_fade_out")


func _on_ExitBtn_pressed():
	# Cierre seguro para Raspberry Pi/Linux
	if OS.get_name() == "X11":  # Raspberry Pi usa X11
		OS.execute("pkill", ["-f", "nombre_de_tu_juego"], false)
	else:
		get_tree().quit()  # Funciona en Windows/macOS
	
func _on_MoreGamesBtn_pressed():
	OS.shell_open("https://arbolabc.com/juegos-para-ninos-6-y-7-anos")
