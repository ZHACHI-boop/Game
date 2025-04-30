extends CanvasLayer

onready var pause := $Pause
onready var pause_button := $PauseButton
onready var resume_option := $Pause/HBoxOptions/Resume
onready var main_menu_option := $Pause/HBoxOptions/MainMenu
onready var label := $PressESCToOpenMenu

# Variables para control por teclado (sistema similar al menú principal)
onready var pause_buttons = [
	resume_option,
	main_menu_option
]
var current_button_index = 0
var can_navigate = false

func _ready():
	if OS.has_touchscreen_ui_hint():
		label.visible = false
	
	# Configurar el foco inicial (igual que en el menú principal)
	for button in pause_buttons:
		button.focus_mode = Control.FOCUS_NONE
	
	# Solo activar foco para el botón actual
	pause_buttons[current_button_index].focus_mode = Control.FOCUS_ALL

func _exit_tree() -> void:
	get_tree().paused = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_tree().set_input_as_handled()
	
	# Navegación con teclado (sistema idéntico al menú principal)
	if get_tree().paused and can_navigate:
		if event.is_action_pressed("ui_down"):
			_change_pause_button(1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_up"):
			_change_pause_button(-1)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_accept"):
			_press_current_pause_button()
			get_tree().set_input_as_handled()

# Funciones de navegación idénticas al menú principal
func _change_pause_button(direction):
	# Desactivar foco visual del botón actual
	pause_buttons[current_button_index].focus_mode = Control.FOCUS_NONE
	
	# Cambiar índice
	current_button_index = wrapi(current_button_index + direction, 0, pause_buttons.size())
	
	# Activar foco visual del nuevo botón
	pause_buttons[current_button_index].focus_mode = Control.FOCUS_ALL
	pause_buttons[current_button_index].grab_focus()
	
	# Opcional: Reproducir sonido de navegación
	# $Audio.stream = preload("res://sounds/navigate.ogg")
	# $Audio.play()

func _press_current_pause_button():
	match current_button_index:
		0:
			_on_Resume_pressed()
		1:
			_on_MainMenu_pressed()

func resume():
	get_tree().paused = false
	$PauseButton.show()
	pause.hide()
	can_navigate = false

func pause_game():
	current_button_index = 0  # Resetear al botón de Resume
	pause_buttons[current_button_index].focus_mode = Control.FOCUS_ALL
	pause_buttons[current_button_index].grab_focus()
	
	get_tree().paused = true
	$PauseButton.hide()
	pause.show()
	can_navigate = true

# Funciones originales de los botones
func _on_Resume_pressed():
	resume()

func _on_PauseButton_pressed():
	pause_game()
	
func _on_MainMenu_pressed():
	get_tree().change_scene("res://Menu/PantallaInicio.tscn")
