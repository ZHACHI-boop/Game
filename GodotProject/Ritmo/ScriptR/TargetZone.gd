extends Area2D

const GRAVITY = 190
var inside_area = false
var selected_key = 0
var is_being_destroyed = false  # Nueva variable de control

func _process(delta):
	if is_being_destroyed:
		return  # Si ya estamos destruyendo el objeto, ignorar
	
	position.y += GRAVITY * delta
	
	if inside_area and Input.is_key_pressed(selected_key):
		hit_effect()

func hit_effect():
	is_being_destroyed = true  # Marcamos para destrucción
	$Sprite.scale *= 2
	
	# Creamos un timer independiente
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.start()
	
	yield(timer, "timeout")
	
	if is_instance_valid(self):  # Verificamos si aún existe
		queue_free()
	timer.queue_free()  # Limpiamos el timer

func spawn(key_index: int, pos: Vector2, key: int, texture: Texture) -> void:
	position = pos
	selected_key = key
	$Sprite.texture = texture
	var scale_factor = 0.7
	$Sprite.scale = Vector2(scale_factor, scale_factor)
	$Sprite.offset = -$Sprite.texture.get_size() * scale_factor / 2

func _on_TargetZone_area_entered(area):
	inside_area = true

func _on_TargetZone_area_exited(area):
	inside_area = false
	if not is_being_destroyed:  # Solo destruir si no está en proceso
		queue_free()
