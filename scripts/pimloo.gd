extends NPC

func _process(delta: float) -> void:
	
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			$FoodShop.transin()
