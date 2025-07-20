extends Area2D


is_tab_pressed = false
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		
