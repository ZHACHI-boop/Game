extends Area2D

signal music_changed(music)
export(AudioStream) var music = null

func _ready():
	# Conexión segura al MusicPlayer
	var music_players = get_tree().get_nodes_in_group("MusicPlayer")
	if not music_players.empty():
		connect("music_changed", music_players[0], "_on_music_changed")
	else:
		push_error("No se encontró ningún nodo en el grupo 'MusicPlayer'")

func _on_body_entered(body):
	if body.name == "Character":  # Asegurarme de que sea el jugador
		emit_signal("music_changed", music)
