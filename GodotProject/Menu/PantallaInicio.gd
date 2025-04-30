extends CanvasLayer

onready var logo = $Logo
onready var logo2 = $Logo2
onready var menu = $MenuPanel
onready var anim = $AnimationPlayer
onready var audio = $MenuPanel/Audio

# Variables para control por teclado
onready var buttons = [
	$MenuPanel/VBoxContainer/PlayBtn,
	$MenuPanel/VBoxContainer/MoreGamesBtn,
	$MenuPanel/VBoxContainer/ExitBtn
]
var current_button_index = 0
var can_navigate = true  # Habilitamos navegación desde el principio

func _ready():
	logo.modulate.a = 0
	logo2.modulate.a = 0
	menu.modulate.a = 0
	
	# Configurar el foco inicial
	for button in buttons:
		button.focus_mode = Control.FOCUS_ALL
	
	buttons[current_button_index].grab_focus()
	animar_entrada()

func animar_entrada():
	# Desconectar primero para evitar múltiples conexiones
	if anim.is_connected("animation_finished", self, "_on_anim_finished"):
		anim.disconnect("animation_finished", self, "_on_anim_finished")
	
	# Conectar la señal solo una vez
	anim.connect("animation_finished", self, "_on_anim_finished", [], CONNECT_ONESHOT)
	
	anim.queue("fade_in_background")
	anim.queue("logo_drop")
	anim.queue("logo_dropp_2")
	anim.queue("menu_popup")
	audio.volume_db = -20
	audio.play()
	anim.queue("audio_fade_in")

func _on_anim_finished(_anim_name):
	# Ya no necesitamos cambiar can_navigate aquí porque está activo desde el inicio
	buttons[current_button_index].grab_focus()

func _input(event):
	if !can_navigate:
		return
	
	# Navegación con teclado
	if event.is_action_pressed("ui_up"):
		_change_button(1)
	elif event.is_action_pressed("ui_down"):
		_change_button(-1)
	elif event.is_action_pressed("ui_accept"):
		_press_current_button()

func _change_button(direction):
	# Desactivar foco visual del botón actual
	buttons[current_button_index].focus_mode = Control.FOCUS_NONE
	
	# Cambiar índice
	current_button_index = wrapi(current_button_index + direction, 0, buttons.size())
	
	# Activar foco visual del nuevo botón
	buttons[current_button_index].focus_mode = Control.FOCUS_ALL
	buttons[current_button_index].grab_focus()
	
	# Opcional: Sonido de navegación
	# audio.stream = preload("res://sounds/navigate.wav")
	# audio.play()

func _press_current_button():
	match current_button_index:
		0:
			_on_PlayBtn_pressed()
		1:
			_on_MoreGamesBtn_pressed()
		2:
			_on_ExitBtn_pressed()

func _on_PlayBtn_pressed():
	if !can_navigate:
		return
	can_navigate = false
	animar_salida()
	yield(anim, "animation_finished")
	get_tree().change_scene("res://Main/Main.tscn")

func animar_salida():
	anim.play("fade_out_elements")
	anim.queue("audio_fade_out")

func _on_ExitBtn_pressed():
	if !can_navigate:
		return
	# Cierre seguro para Raspberry Pi/Linux
	if OS.get_name() == "X11":  # Raspberry Pi usa X11
		OS.execute("pkill", ["-f", "nombre_de_tu_juego"], false)
	else:
		get_tree().quit()  # Funciona en Windows/macOS

func _on_MoreGamesBtn_pressed():
	if !can_navigate:
		return
	OS.shell_open("https://arbolabc.com/juegos-para-ninos-6-y-7-anos")
