extends CanvasLayer

func change_scene(path: PackedScene):
	
	$AnimationPlayer.play("fade_to_black")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(path)
	$AnimationPlayer.play_backwards("fade_to_black")
