extends Node2D

onready var label = $Label
onready var tween = $Tween

func set_text(text):
	label.text = text
	tween.interpolate_property(self, "position", 
		position, position + Vector2(0, -30), 1.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "modulate:a", 
		1.0, 0.0, 1.5, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tween.start()
	yield(tween, "tween_completed")
	queue_free()
