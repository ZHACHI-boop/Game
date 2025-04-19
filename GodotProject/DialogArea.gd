extends Area2D

signal dialog_started(player)
signal dialog_ended

export(String, FILE, "*.json") var dialogue_file
export(String) var dialogue_key = "npc1_intro"
export(NodePath) var npc_path = ""

onready var tween = $Tween
onready var dialog_info = $DialogInfo
onready var dialog_box = preload("res://Hud/DialogBox/DialogueBox.tscn")

var player = null
var dialogues = {}

func _ready():
	if npc_path != "":
		connect_to_npc(get_node(npc_path))
	set_process_input(false)
	$DialogInfo.visible = false
	
	# Cargar diálogos desde JSON
	load_dialogues()

func load_dialogues():
	var file = File.new()
	if file.file_exists(dialogue_file):
		file.open(dialogue_file, File.READ)
		dialogues = parse_json(file.get_as_text())
		file.close()
	else:
		push_error("Archivo de diálogo no encontrado: " + dialogue_file)

func connect_to_npc(npc):
	connect("dialog_started", npc, "start_dialog_with")
	connect("dialog_ended", npc, "stop_dialog")

func _on_DialogArea_body_entered(body):
	print("Body entered:", body.name)
	if body.is_in_group("Player"):
		player = body
	show_dialog_info()
	player = body
	set_process_input(true)

func _on_DialogArea_body_exited(body):
	$DialogInfo.visible = false
	set_process_input(false)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		launch_dialog()

func launch_dialog():
	emit_signal("dialog_started", player)
	player.disabled = true
	$DialogInfo.visible = false
	set_process_input(false)
	
	# Crear e instanciar el diálogo
	var db = dialog_box.instance()
	print("DialogueBox instance:", db != null)
	get_tree().get_nodes_in_group("HUD")[0].add_child(db)
	db.start_dialogue(dialogues[dialogue_key])
	db.connect("dialogue_ended", self, "on_dialog_end")

func on_dialog_end():
	emit_signal("dialog_ended")
	if player:
		player.disabled = false
	set_process_input(true)

func show_dialog_info():
	if player:
		player.disabled = false
	$DialogInfo.visible = true
	tween.interpolate_property(dialog_info, "position", Vector2(0, 10), Vector2(0, 0), 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

