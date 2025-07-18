extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false

var button_pressed = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	$AudioStreamPlayer2D.play()


	if not button_pressed:
		button_pressed = true
		await $AudioStreamPlayer2D.finished
		get_tree().change_scene_to_file("res://scenes/opening_cutscene.tscn")

func _on_button_2_pressed() -> void:
	pass # Replace with function body.
