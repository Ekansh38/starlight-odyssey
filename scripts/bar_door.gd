extends Area2D

@export_file("*.tscn") var bar_scene_path  # easy to change in Inspector

@export var is_leaving: bool

var ship_in_area : Node2D = null
var has_launched : bool   = false

@onready var ui = get_node_or_null("../UI")


func _process(delta: float) -> void:
	if has_launched:
		return

	if ship_in_area == null:
		return

	if Input.is_action_just_pressed("land"):
		if ui:
			ui.landing_bar_visable(true)

	if Input.is_action_pressed("land"):
		if ui:
			ui.landing_bar_update()
			if ui.landing_bar_value() >= 100:
				_start_launch()
				return  # important: don't continue touching UI this frame

	# Released early -> cancel
	if Input.is_action_just_released("land"):
		if ui:
			ui.landing_bar_visable(false)
			ui.landing_bar_reset()


func _start_launch() -> void:
	if has_launched:
		return
	has_launched = true

	if ui:
		ui.landing_bar_visable(false)
		ui.landing_bar_reset()

	if ship_in_area and ship_in_area.has_method("change_controll_label"):
		ship_in_area.change_controll_label("")

	call_deferred("_do_launch")


func _do_launch() -> void:
	print("entering…")
	var ps: PackedScene = load(bar_scene_path)
	if ps:
		if is_leaving:
			Globals.did_player_exit_bar = true
		TransitionLayer.change_scene(ps)
	else:
		push_error("LaunchPad: could not load space scene at %s" % bar_scene_path)
	has_launched = false 


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ship_in_area = body
		if body.has_method("change_controll_label"):
			if is_leaving:
				body.change_controll_label("Press E to leave")
			else:
				body.change_controll_label("Press E to enter")

		if ui:
			ui.landing_bar_visable(false)
			ui.landing_bar_reset()


func _on_body_exited(body: Node2D) -> void:
	if body == ship_in_area:
		if ui:
			ui.landing_bar_visable(false)
			ui.landing_bar_reset()
		if body.has_method("change_controll_label"):
			body.change_controll_label("")
		ship_in_area = null
		has_launched = false 
