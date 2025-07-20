extends Node2D

var maya: PackedScene = load("res://scenes/mayannaise.tscn")

func _ready() -> void:
	var new_maya = maya.instantiate()
	new_maya.global_position = $"../MayaPos".global_position
	add_child(new_maya)
