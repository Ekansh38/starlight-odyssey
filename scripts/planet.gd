extends Area2D

var ship_in_area: Node2D = null
@onready var cam := get_node("../Ship/Camera2D")
@onready var tween := get_tree().create_tween()

func _process(delta: float) -> void:
	if ship_in_area and Input.is_action_pressed("land"):
		$"../UI".landing_bar_visable(true)
		$"../UI".landing_bar_update()
	if $"../UI".landing_bar_value() >= 100:
		
		land()
		
	if Input.is_action_just_released("land"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()
		
func land():
	Globals.last_ship_position = $"../Ship".global_position
	Globals.has_saved_ship_pos = true
	TransitionLayer.change_scene("res://scenes/on_planet.tscn")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		body.change_controll_label("Press 'E' to Land")
		ship_in_area = body
		body.override_zoom(Vector2(0.15, 0.15))
	if body.is_in_group("Enemy"):
		if "start_disapear" in body:
			body.start_disapear()
	


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		$"../UI".landing_bar_visable(false)
		$"../UI".landing_bar_reset()
		body.change_controll_label("")
		ship_in_area = null
		body.clear_zoom_override()
		
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Asteroid"):
		area.inside_planet = true
		if area.has_method("start_disappear"):
			area.start_disappear()

	
