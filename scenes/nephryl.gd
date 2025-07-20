extends NPC



func _process(delta: float) -> void:
	
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			$GunShop.transin()
				

func change_pickup_indicator(message):
	if ui: ui.change_pickup_indicator(message)
