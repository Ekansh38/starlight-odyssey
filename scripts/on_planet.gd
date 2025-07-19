extends Node2D

func _ready():
	print(Globals.did_player_exit_bar)
	if Globals.did_player_exit_bar == true:
		Globals.did_player_exit_bar = false
		$Ysort/Player.global_position = $BarMarker.global_position
