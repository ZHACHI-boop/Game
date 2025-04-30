extends KinematicBody2D

signal change_direction(direction)
signal velocity_changed(velocity)
signal action_pressed()
signal hit(damage)
signal interact_pressed()
signal position_changed(position)
signal item_changed(item)  # Nueva señal para cambios de item

var left:bool = false
var right:bool = false
var up:bool = false
var down:bool = false
var move_axis:Vector2 = Vector2() setget set_move_axis
var speed:float = 90
var velocity:Vector2 = Vector2() setget set_velocity
var push_velocity:Vector2 = Vector2()
var bloc_move = false
var disabled = false setget set_disabled
var can_interact = false
var current_interactable = null
onready var start_pos = global_position
var original_scale = Vector2(0.7, 0.7)

# Nuevas variables para el sistema de items e interacción
onready var hand_item = $HandPosition/ItemSprite
onready var interaction_label = $InteractionArea/InteractionLabel
var near_interactable = null

func _ready():
	sprite.scale = original_scale
	interaction_label.hide()
	update_hand_item()

onready var tween:Tween = $Sprite/Tween
onready var sprite:AnimatedSprite = $Sprite

func _process(delta):
	if bloc_move:
		return
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	up = Input.is_action_pressed("move_up")
	down = Input.is_action_pressed("move_down")
	self.move_axis = Vector2(-int(left)+int(right),-int(up)+int(down))
	
	# Sistema de interacción mejorado
	if Input.is_action_just_pressed("action"):
		emit_signal("action_pressed")
		if near_interactable:
			interact_with(near_interactable)
		else:
			bloc_move = true
			self.move_axis = Vector2.ZERO
			self.velocity = Vector2.ZERO

func _physics_process(delta):
	push_velocity = push_velocity.linear_interpolate(Vector2.ZERO,0.1)
	velocity = move_and_slide((velocity+push_velocity).floor())
	emit_signal("position_changed",global_position)

# Función para actualizar el item en la mano
func update_hand_item():
	match GameState.current_item_in_hand:
		"key":
			hand_item.texture = preload("res://Dungeon/Sprites/Key.png")
			hand_item.show()
		"potion":
			hand_item.texture = preload("res://Dungeon/Sprites/Potion.png")
			hand_item.show()
		"gem":
			hand_item.texture = preload("res://Dungeon/Sprites/Gem.png")
			hand_item.show()
		_:
			hand_item.hide()
	emit_signal("item_changed", GameState.current_item_in_hand)

# Función para interactuar con objetos
func interact_with(target):
	if target.has_method("interact"):
		target.interact(self)
	elif target.is_in_group("chest"):
		if target.opened:
			interaction_label.text = "Cofre vacío"
		else:
			if GameState.current_item_in_hand == "key" and target.name == "LockedChest":
				target.interact(self)
			elif target.name == "DungeonChest":
				target.interact(self)

# Señales de área de interacción
func _on_InteractionArea_area_entered(area):
	if area.is_in_group("interactable"):
		near_interactable = area.get_parent()
		if near_interactable.is_in_group("chest"):
			if near_interactable.opened:
				interaction_label.text = "Cofre abierto"
			else:
				interaction_label.text = "Presiona E para interactuar"
			interaction_label.show()

func _on_InteractionArea_area_exited(area):
	if area.is_in_group("interactable") and near_interactable == area.get_parent():
		near_interactable = null
		interaction_label.hide()

# Resto de tus funciones existentes...
func set_direction(direction):
	emit_signal("change_direction",direction)

func set_move_axis(v):
	if disabled:
		return
	if move_axis != v:
		if v.length():
			emit_signal("change_direction",v)
	self.velocity = move_axis*speed
	move_axis = v

func set_velocity(v):
	velocity = v
	emit_signal("velocity_changed",velocity)

func _on_ActionTime_timeout():
	bloc_move = false

func hit(damage = 1):
	emit_signal("hit",damage)
	hit_fx()

func death():
	self.disabled = true
	sprite.animation = "Death"
	yield(get_tree().create_timer(0.5,false),"timeout")
	get_tree().call_group("Hud","revive")
	reset()

func reset():
	global_position = start_pos
	self.disabled = false

func push(from,force):
	push_velocity = (global_position-from).normalized()*force

func hit_fx():
	tween.interpolate_property(sprite, "scale", Vector2(2,2), original_scale, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.interpolate_property(sprite, "modulate", Color(50,50,50), Color.white, 0.2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$SndHit.play()
	tween.start()

func set_disabled(v):
	disabled = v
	set_process(!v)
	set_physics_process(!v)

func _input(event):
	if event.is_action_pressed("action") and can_interact and current_interactable:
		emit_signal("interact_pressed")
		current_interactable.interact(self)

func _on_InteractionArea_body_entered(body):
	if body.is_in_group("interactable"):
		can_interact = true
		current_interactable = body
		if body.has_method("show_interaction_label"):
			body.show_interaction_label()

func _on_InteractionArea_body_exited(body):
	if body == current_interactable:
		can_interact = false
		if body.has_method("hide_interaction_label"):
			body.hide_interaction_label()
		current_interactable = null
