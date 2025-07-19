extends Area2D

@onready var bartender := $"../Ysort/Mayannaise"
@onready var work_point := $"../MayaWorkPoint"
@onready var greet_point := $"../MayaWalkPoint"

var player_inside := false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if player_inside: return   # already handled
	player_inside = true
	bartender.move_to(greet_point.global_position)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	if not player_inside: return
	player_inside = false
	bartender.move_to(work_point.global_position)
