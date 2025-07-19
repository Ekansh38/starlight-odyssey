extends CanvasLayer

func change_scene(path: PackedScene, length = "short"):
	
	if length == "short":
		$AnimationPlayer.play("fade_to_black")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_packed(path)
		$AnimationPlayer.play_backwards("fade_to_black")
	else:
		$AnimationPlayer.play("fade_to_black_long")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_packed(path)
		$AnimationPlayer.play_backwards("fade_to_black_long")
		
