extends NPC

func take_damage():
	$DamageParticles.emitting = true
	
	if Globals.is_in_hitman_game:
	
		modulate.a = 1.0
	
		var tw = create_tween()
		tw.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tw.tween_callback(Callable(self, "queue_free"))
		ui.cancel_hitman_timer()
		ui.change_info("ASSASINATION SUCSESSFUL!")
		ui.hitman_photo_visible(false)
		ui.change_pickup_indicator("+ $40 ")
		Globals.money += 40
