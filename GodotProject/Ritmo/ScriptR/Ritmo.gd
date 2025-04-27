extends Node2D

const END_DELAY = 3.0
const KEY_MAPPING = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]  # Teclas numéricas del 1 al 5
const VOWEL_SPRITES = [
	preload("res://Ritmo/Asets/Sprites/VocalA.png"),  # Tecla 1
	preload("res://Ritmo/Asets/Sprites/VocalE.png"),  # Tecla 2
	preload("res://Ritmo/Asets/Sprites/VocalI.png"),  # Tecla 3
	preload("res://Ritmo/Asets/Sprites/VocalO.png"),  # Tecla 4
	preload("res://Ritmo/Asets/Sprites/VocalU.png")   # Tecla 5
]

export (PackedScene) var KeyObject
var song_length = 0.0
var has_ended = false
var end_timer = 0.0
var last_hit_accuracy = INF
var feedback_cooldown = 0.5
var last_feedback_time = 0.0
var positions: Array = []
var note_map = []
var song_data = {}
var song_position = 0.0
var song_playing = false
var current_note_index = 0
var perfect_count = 0
var bad_count = 0
var score = 0
var combo = 0
var max_combo = 0

onready var score_label = $HUD/ScoreLabel
onready var audio_player = $MusicPlayer
onready var click_sound = $SFXPlayer
onready var mensaje = $FeedbackText
onready var finn = $AnimatedSprite
onready var fondo = $Fondo

func _ready():
	OS.center_window()
	positions = [
		$Objeto/CircleObj.global_position.x,
		$Objeto/CircleObj2.global_position.x,
		$Objeto/CircleObj3.global_position.x,
		$Objeto/CircleObj4.global_position.x,
		$Objeto/CircleObj5.global_position.x
	]
	
	load_song_data("res://notas.json")
	yield(get_tree().create_timer(1.0), "timeout")
	start_game()
	if note_map.size() > 0:
		song_length = note_map.back()["time"] + 5.0  # Margen adicional
		
	yield(get_tree().create_timer(1.0), "timeout")
	start_game()

func load_song_data(path):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var json_data = file.get_as_text()
		file.close()
		
		var parse_result = JSON.parse(json_data)
		if parse_result.error == OK:
			song_data = parse_result.result
			if song_data.has("notes"):
				note_map = []
				var time = 0.0
				var beat_duration = 60.0 / 177.0  # BPM=177
				
				for measure in song_data["notes"]:
					for line in measure:
						for i in range(5):  # 5 columnas
							if line.length() > i and line[i] == '1':
								note_map.append({
									"time": time,
									"dir": i
								})
						time += beat_duration / 4
			else:
				push_error("JSON no contiene datos de notas válidos")
		else:
			push_error("Error parsing JSON: " + parse_result.error_string)
	else:
		push_error("Archivo no encontrado: " + path)

func _process(delta):
	if song_playing:
		song_position = audio_player.get_playback_position()
		check_notes_to_spawn()
		if not has_ended and song_position >= song_length - 0.1:  # Pequeño margen
			on_song_finished()
	if has_ended:
		end_timer += delta
		if end_timer >= END_DELAY:
			complete_minigame()

func _input(event):
	if event is InputEventKey and event.pressed:
		if click_sound and not click_sound.playing:
			click_sound.play()
		check_key_press(event.scancode)
		update_score_display()

func check_key_press(key):
	var best_hit = {"accuracy": INF, "arrow": null}
	
	for arrow in get_children():
		if arrow is Area2D and arrow.inside_area and arrow.selected_key == key:
			var accuracy = abs(arrow.position.y - $Objeto.position.y)
			if accuracy < best_hit["accuracy"]:
				best_hit = {"accuracy": accuracy, "arrow": arrow}
	
	if best_hit["arrow"]:
		var points = calculate_points(best_hit["accuracy"])
		best_hit["arrow"].queue_free()
		add_score(points)
		combo += 1
		show_feedback(best_hit["accuracy"])  # Mostrar feedback visual
	else:
		combo = 0
		show_feedback(INF)  # Mostrar "MISS" cuando falla

func show_feedback(accuracy):
	var current_time = OS.get_ticks_msec() / 1000.0
	
	if current_time - last_feedback_time < feedback_cooldown:
		return
	last_feedback_time = current_time
	
	if accuracy < 10: 
		mensaje.text = "PERFECT!"
		mensaje.modulate = Color(0, 1, 0)
		perfect_count += 1
		bad_count = 0
		if perfect_count >= 2:
			finn.play("Perfect")
		
	elif accuracy < 30: 
		mensaje.text = "GOOD"
		mensaje.modulate = Color(0.5, 1, 0.5)
		finn.play("Good")
		perfect_count = 0
		bad_count = 0
		
	elif accuracy < 50: 
		mensaje.text = "BAD"
		mensaje.modulate = Color(1, 1, 0)
		finn.play("Bad")
		perfect_count = 0
		bad_count = 0
		
	else: 
		mensaje.text = "MISS"
		mensaje.modulate = Color(1, 0, 0)
		perfect_count = 0
		bad_count += 1
		
		if bad_count >= 3:
			finn.play("Bad")
	
	$FeedbackAnimator.play("show_feedback")
	
func calculate_points(accuracy):
	if accuracy < 10: return 100
	elif accuracy < 30: return 50
	elif accuracy < 50: return 25
	else: return 0

func add_score(points):
	var multiplier = 1 + (combo * 0.1)
	score += int(points * multiplier)
	max_combo = max(max_combo, combo)
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Puntaje: %d\nCombo: %d\nMax Combo: %d" % [score, combo, max_combo]

func check_notes_to_spawn():
	while current_note_index < note_map.size() and note_map[current_note_index]["time"] <= song_position:
		var note = note_map[current_note_index]
		_spawn(note["dir"])
		current_note_index += 1
		
func _spawn(direction: int):
	if direction >= 0 and direction < 5:  # Asegurar que el índice es válido
		var KeyInstance = KeyObject.instance()
		var pos = $Objeto/Position2D.position
		pos.x = positions[direction]
		KeyInstance.spawn(
			direction, 
			pos, 
			KEY_MAPPING[direction],
			VOWEL_SPRITES[direction]
		)
		add_child(KeyInstance)

func start_game():
	audio_player.play()
	song_playing = true
	song_position = 0.0
	current_note_index = 0
	finn.play("Good")
	fondo.play()

func on_song_finished():
	has_ended = true
	song_playing = false
	
	# Mostrar mensaje de finalización
	mensaje.text = "¡CANCIÓN COMPLETADA!"
	mensaje.modulate = Color(0.5, 0.8, 1.0)
	$FeedbackAnimator.play("show_feedback")
	
	# Detener la música suavemente
	$Tween.interpolate_property(audio_player, "volume_db", 
		audio_player.volume_db, -80.0, 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	
	# Guardar resultados
	Global.minigame_score = score
	Global.minigame_max_combo = max_combo
	Global.minigame_completed = true

func complete_minigame():
	# Limpiar todas las notas restantes
	for child in get_children():
		if child is Area2D:  # Asumiendo que tus notas son Area2D
			child.queue_free()
	
	# Volver al mundo principal
	end_minigame()

func end_minigame():
	# Guardar estado antes de cambiar de escena
	Global.minigame_completed = true
	
	# Volver a la escena anterior
	if Global.player_previous_scene:
		# Detener todos los sonidos
		audio_player.stop()
		click_sound.stop()
		
		# Cambiar de escena
		get_tree().change_scene(Global.player_previous_scene)
		
		# Esperar un frame y reposicionar al jugador
		yield(get_tree(), "idle_frame")
		reposition_player()

func reposition_player():
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0:
		player[0].global_position = Global.player_position
		player[0].disabled = false  # Asegurarse que el jugador no esté deshabilitado
	
	# Opcional: Mostrar resultados en el mundo principal
	var hud = get_tree().get_nodes_in_group("HUD")
	if hud.size() > 0:
		hud[0].show_minigame_results(Global.minigame_score, Global.minigame_max_combo)
