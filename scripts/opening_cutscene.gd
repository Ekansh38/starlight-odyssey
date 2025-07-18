extends Node2D


func _ready() -> void:
	$Explosion.play()
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.modulate.a = 1
	$AnimatedSprite2D.play("explode")
	await $AnimatedSprite2D.animation_finished
	
	$AnimationPlayer.play("main")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/space.tscn")
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):# Space to skip
		$CanvasLayer/SkipBar.value += 100 * delta
	
	if Input.is_action_just_released("boost"):# Space to skip
		$CanvasLayer/SkipBar.value = 0
	
	if $CanvasLayer/SkipBar.value >= 100:
		get_tree().change_scene_to_file("res://scenes/space.tscn")


		
