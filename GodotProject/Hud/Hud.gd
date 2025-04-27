extends CanvasLayer

onready var life_bar = $LifeBar


func fade():
	$Fade/Anim.stop()
	$Fade/Anim.play("Fade")


func _on_map_changed():
	fade()

func on_player_hit(damage):
	life_bar.life -= damage

func revive():
	fade()
	life_bar.reset()
	
# En tu script HUD.gd

func show_minigame_results(score, max_combo):
	var results_panel = preload("res://Ritmo/Esenas/MinigameResults.tscn").instance()
	add_child(results_panel)
	
	results_panel.get_node("ScoreLabel").text = "Puntaje: %d" % score
	results_panel.get_node("ComboLabel").text = "Max Combo: %d" % max_combo
	
	# Desaparecer después de 3 segundos
	yield(get_tree().create_timer(3.0), "timeout")
	results_panel.queue_free()
