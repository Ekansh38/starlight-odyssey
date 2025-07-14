extends Area2D

var ship_in_area: Node2D = null

func _process(delta: float) -> void:
	if ship_in_area and Input.is_action_pressed("land"):
		$"../UI".landing_bar_visable(true)
		$"../UI".landing_bar_update()
	if $"../UI".landing_bar_value() >= 100:
		get_tree().change_scene_to_file("res://scenes/on_planet.tscn")
	if Input.is_action_just_released("land"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()

func _on_body_entered(body: Node2D) -> void:
	

	if body.is_in_group("Ship"):
		body.change_controll_label("Press 'E' to Land")
		ship_in_area = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()
		body.change_controll_label("")
		ship_in_area = null


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Asteroid"):
		area.inside_planet = true
		if area.has_method("start_disappear"):
			area.start_disappear()

	
