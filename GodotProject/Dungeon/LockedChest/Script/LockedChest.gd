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
	if Input.is_action_just_pressed("interact") and player_in_range:
		try_open_chest()

func try_open_chest():
	if not opened:
		if GameState.current_item_in_hand == "key":
			opened = true
			anim.play("open")
			GameState.has_potion = true
			GameState.current_item_in_hand = "potion"
			interaction_label.text = "¡Poción obtenida!"
			
			# Notificar al jugador
			get_tree().call_group("player", "update_hand_item")
			
			# Diálogo flotante
			var dialog = preload("res://DialogFloat/FloatingDialog.tscn").instance()
			dialog.set_text("¡Una poción mágica!")
			get_parent().add_child(dialog)
			dialog.global_position = global_position + Vector2(0, -50)
			
			yield(get_tree().create_timer(2.0), "timeout")
			interaction_label.text = "Cofre vacío"
		else:
			interaction_label.text = "Necesitas una llave"
			$ErrorSound.play()
			yield(get_tree().create_timer(2.0), "timeout")
			if not opened:
				interaction_label.text = "Presiona E para usar llave"

func show_interaction_label():
	if not opened:
		interaction_label.text = "Presiona E para usar llave"
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
	try_open_chest()

func _on_LockedChest_body_entered(body):
	if body.name == "Character":
		if opened:
			state_label.text = "Cofre vacío"
		else:
			state_label.text = "Presiona E para usar llave"
		state_label.show()

func _on_LockedChest_body_exited(body):
	if body.name == "Character":
		state_label.hide()
