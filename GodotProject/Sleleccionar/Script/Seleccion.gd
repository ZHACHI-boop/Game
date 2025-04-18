extends Control

var dialogs = [
	"Hola, bienvenido al juego.",
	"Hoy comienza tu aventura.",
	"Prepárate para lo que viene."
]
var dialog_index = 0

onready var vidas = $CanvasLayer/CenterContainer
onready var opciones = $HBoxContainer
onready var tween = $Tween
onready var instruccion = $Instruccion
onready var audio = $Audio
onready var sprite = $Sprite
onready var fondo = $AnimatedSprite

func _ready():
	fondo.play("Fondo")
	$Label.text = dialogs[dialog_index]

func _on_NextButton_pressed():
	dialog_index += 1
	if dialog_index < dialogs.size():
		$Label.text = dialogs[dialog_index]
	else:
		$Label.text = "Fin del diálogo."
