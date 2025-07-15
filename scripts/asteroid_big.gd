extends Asteroid

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		if not inside_planet:
			body.take_damage("big")
			explode()
