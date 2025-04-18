extends Node2D

signal map_changed
onready var npc = $Npc


func _ready():
	for teleporter in get_tree().get_nodes_in_group("Teleporter"):
		teleporter.connect("teleported",self,"change_map")

func change_map():
	emit_signal("map_changed")

func _on_player_entered_npc_area():
	pass

func _on_player_exited_npc_area():
	pass
