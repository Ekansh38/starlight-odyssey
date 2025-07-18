extends Area2D

@export_file("*.tscn") var space_scene_path := "res://scenes/space.tscn"  # easy to change in Inspector

var ship_in_area : Node2D = null
var has_launched : bool   = false

@onready var ui = get_node_or_null("../UI")   # cache; safe if missing

func _ready() -> void:
	# If you *didn't* wire the area signals in the editor, uncomment:
	#connect("body_entered", Callable(self, "_on_body_entered"))
	#connect("body_exited",  Callable(self, "_on_body_exited"))
	pass


func _process(delta: float) -> void:
	# Already launched? stop doing anything.
	if has_launched:
		return

	# Not in range? bail.
	if ship_in_area == null:
		return

	# Key pressed? show & fill the hold bar.
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

	# Clean UI
	if ui:
		ui.landing_bar_visable(false)
		ui.landing_bar_reset()

	# Clear prompt on the player before we leave
	if ship_in_area and ship_in_area.has_method("change_controll_label"):
		ship_in_area.change_controll_label("")

	# Defer actual scene swap so we’re not mid-_process on this scene
	call_deferred("_do_launch")


func _do_launch() -> void:
	print("LAUNCHING…")
	# Load PackedScene and hand it to the TransitionLayer helper (as required)
	var ps: PackedScene = load(space_scene_path)
	if ps:
		TransitionLayer.change_scene(ps)
	else:
		push_error("LaunchPad: could not load space scene at %s" % space_scene_path)
	has_launched = false  # optional: TransitionLayer will replace scene anyway


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ship_in_area = body
		if body.has_method("change_controll_label"):
			body.change_controll_label("Press [E] to Launch")
		# ensure clean bar when entering
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
		has_launched = false  # cancel any half-filled attempt
