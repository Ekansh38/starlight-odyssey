# DoorArea.gd
extends Area2D

@export var target_pos : Marker2D      # drag the destination Marker2D here
@export var fade_time  : float = 0.4   # seconds for each fade half

# OPTIONAL – if your player script uses a different property / method
const CONTROL_PROP := "controls_enabled"   # bool that turns movement on/off
const CONTROL_FUNC := "set_controls_enabled"

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	
	_disable_player_input(body, true)

	# make the player fade out, teleport, then fade back in
	var tw := body.create_tween()
	tw.tween_property(body, "modulate:a", 0.0, 0.4)
	tw.tween_property(body, "global_position", target_pos.global_position, 0.4)
	
	
	tw.tween_callback(Callable(body, "set_controls_enabled").bind(true))
	tw.tween_callback(Callable(self, "_reappear").bind(body))
	tw.tween_property(body, "modulate:a", 1.0, fade_time)

# ----- helpers --------------------------------------------------------------

func _teleport_player(body: Node2D) -> void:
	if target_pos:
		body.global_position = target_pos.global_position

func _disable_player_input(body: Node, disable: bool) -> void:
	if CONTROL_PROP in body:
		body.set(CONTROL_PROP, !disable)
		return
	
	if CONTROL_FUNC in body:
		body.call(CONTROL_FUNC, !disable)
		return
	
	body.set_physics_process(!disable)
