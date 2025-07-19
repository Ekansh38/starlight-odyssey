extends Area2D


@export var drink_image: Texture2D = load("res://assets/drinks-removebg-preview.png")
@export var frame = 3
@export var drink_held = "wine"

var ship_in_area : Node2D = null

@onready var ui = get_node_or_null("../UI")


func _process(delta: float) -> void:


	if ship_in_area == null:
		return

	if Input.is_action_just_pressed("land"):
		_start_launch()
		return 

	if Input.is_action_just_released("land"):
		if ui:
			ui.landing_bar_visable(false)
			ui.landing_bar_reset()


func _start_launch() -> void:
	if ship_in_area and ship_in_area.has_method("change_controll_label"):
		ship_in_area.change_controll_label("")

	call_deferred("_do_launch")


func _do_launch() -> void:
	ship_in_area.change_holdable_visible(true)
	print("entering…")
	ship_in_area.change_holdable_frame(frame)
	ship_in_area.change_holdable_visible(true)
	ship_in_area.change_holdable(drink_image)
	ship_in_area.drink_held = drink_held


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ship_in_area = body
		if body.has_method("change_controll_label"):
			body.change_controll_label("Press E to pickup")


func _on_body_exited(body: Node2D) -> void:
	if body == ship_in_area:
		if body.has_method("change_controll_label"):
			body.change_controll_label("")
		ship_in_area = null
