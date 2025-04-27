extends Node

var scene_world_main = null  # Variable global
var score = 0               # Ejemplo adicional
var lives = 3               # Puedes añadir más variables

var player_position = Vector2.ZERO
var player_previous_scene = ""
var minigame_completed = false
var minigame_score = 0
var minigame_max_combo = 0
