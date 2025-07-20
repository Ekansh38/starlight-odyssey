extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		Globals.reset()
		TransitionLayer.change_scene(load("res://scenes/space.tscn"))
		
