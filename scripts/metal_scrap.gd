extends Area2D

var increase = 15

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		if (Globals.ship_damage + increase) >= 100:
			Globals.ship_damage = 100
		else:
			Globals.ship_damage += increase
		
		queue_free()
