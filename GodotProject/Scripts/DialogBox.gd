extends Panel

onready var dialog_text = $MarginContainer/VBoxContainer/DialogText
onready var options_container = $MarginContainer/VBoxContainer/ResponseOptions

var current_dialog = []
var current_line = 0
var options = []

signal dialog_finished
signal option_selected(index)

func _ready():
	hide()
	for button in options_container.get_children():
		button.connect("pressed", self, "_on_option_selected", [button.get_index()])

func start_dialog(dialog):
	current_dialog = dialog
	current_line = 0
	show()
	show_next_line()

func show_next_line():
	if current_line >= current_dialog.size():
		emit_signal("dialog_finished")
		hide()
		return
	
	var line = current_dialog[current_line]
	
	if line.has("text"):
		dialog_text.bbcode_text = line["text"]
		options_container.hide()
	elif line.has("question"):
		dialog_text.bbcode_text = line["question"]
		options = line["options"]
		show_options()
	
	current_line += 1

func show_options():
	options_container.show()
	for i in range(options_container.get_child_count()):
		var button = options_container.get_child(i)
		if i < options.size():
			button.text = options[i]
			button.show()
		else:
			button.hide()

func _on_option_selected(index):
	emit_signal("option_selected", index)
	show_next_line()
