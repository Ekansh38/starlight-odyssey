extends Area2D

var increase = 15

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		if (Globals.player_energy + increase) >= 100:
			Globals.player_energy = 100
		else:
			Globals.player_energy += increase
		
		queue_free()
