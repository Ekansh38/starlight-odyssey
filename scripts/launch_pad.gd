extends Area2D

var ship_in_area: Node2D = null
@onready var tween := get_tree().create_tween()


func _process(delta: float) -> void:
	if ship_in_area and Input.is_action_pressed("land"):
		$"../UI".landing_bar_visable(true)
		$"../UI".landing_bar_update()
	if $"../UI".landing_bar_value() >= 100:
		
		launch()
		
	if Input.is_action_just_released("land"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()
		
func launch():
	TransitionLayer.change_scene("res://scenes/space.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("PPw")
		body.change_controll_label("Press 'E' to Launch")
		ship_in_area = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()
		body.change_controll_label("")
		ship_in_area = null
		
	
