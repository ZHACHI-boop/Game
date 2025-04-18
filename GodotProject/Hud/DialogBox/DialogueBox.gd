extends Control


var dialogos = []
var dialog_index = 0

func _ready():
	cargar_dialogos()
	mostrar_dialogo()

func cargar_dialogos():
	var file = File.new()
	if file.file_exists("res:/Dialogs/dialogstest.json"):
		file.open("res:/Dialogs/dialogstest.json", File.READ)
		var contenido = file.get_as_text()
		var data = JSON.parse(contenido)
		if data.error == OK:
			dialogos = data.result["dialogs"]
		file.close()

func mostrar_dialogo():
	if dialog_index < dialogos.size():
		var dialogo_actual = dialogos[dialog_index]
		$Label.text = dialogo_actual["personaje"]
		$DialogoLabel.text = dialogo_actual["texto"]
	else:
		$Label.text = ""
		$DialogoLabel.text = "Fin del diálogo."

func _on_NextButton_pressed():
	dialog_index += 1
	mostrar_dialogo()
