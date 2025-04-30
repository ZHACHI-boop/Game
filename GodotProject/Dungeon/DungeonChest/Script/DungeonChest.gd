extends Area2D

onready var anim = $AnimationPlayer
onready var state_label = $InteractionLabel
onready var interaction_label = $InteractionLabel

var opened = false
var player_in_range = false

func _ready():
	interaction_label.hide()
	set_process(false)

func _process(delta):
	if Input.is_action_just_pressed("interact") and player_in_range and not opened:
		open_chest()

func open_chest():
	opened = true
	anim.play("open")
	GameState.has_key = true
	GameState.current_item_in_hand = "key"
	interaction_label.text = "¡Llave obtenida!"
	
	# Notificar al jugador para actualizar su sprite de mano
	get_tree().call_group("player", "update_hand_item")
	
	# Mostrar diálogo flotante
	var dialog = preload("res://DialogFloat/FloatingDialog.tscn").instance()
	dialog.set_text("¡Encontraste una llave!")
	get_parent().add_child(dialog)
	dialog.global_position = global_position + Vector2(0, -50)
	
	yield(get_tree().create_timer(2.0), "timeout")
	interaction_label.text = "Cofre vacío"

func show_interaction_label():
	if not opened:
		interaction_label.text = "Presiona E para abrir"
	else:
		interaction_label.text = "Cofre vacío"
	interaction_label.show()
	player_in_range = true
	set_process(true)

func hide_interaction_label():
	interaction_label.hide()
	player_in_range = false
	set_process(false)

func interact(player):
	if not opened:
		open_chest()

func _on_DungeonChest_body_entered(body):
	if body.name == "Character":
		if opened:
			state_label.text = "Cofre vacío"
		else:
			state_label.text = "Presiona E para abrir"
		state_label.show()

func _on_DungeonChest_body_exited(body):
	if body.name == "Character":
		state_label.hide()
