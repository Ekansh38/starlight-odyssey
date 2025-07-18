extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Globals.has_cosmic_compass = true
		queue_free()
