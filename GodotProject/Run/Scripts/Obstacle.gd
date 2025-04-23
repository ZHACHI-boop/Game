extends Area2D

# Configuración de movimiento
export var move_speed := 100.0
export var target_y := 350.0
var is_correct := false
var should_move := true

func _process(delta):
	if should_move and position.y > target_y:
		position.y -= move_speed * delta
		print("Movimiento - Pos Y: ", position.y)
	elif not should_move and position.y <= target_y:
		position.y = target_y

func _on_Obstacle_body_entered(body):
	if body.name == "Player":
		should_move = is_correct  # Solo se mueve si es correcta
		if not is_correct:
			$AnimatedSprite.play("incorrecto")
			$CollisionShape2D.set_deferred("disabled", true)

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "incorrecto":
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = $AnimatedSprite.frames.get_frame_count("incorrecto") - 1
