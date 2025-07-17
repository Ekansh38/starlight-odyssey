extends Control

var ship_path             : NodePath     
var target_marker_path    : NodePath     
@export var needle_path           : NodePath     

var ship         : Node2D
var target_marker: Node2D
var needle       : TextureRect

func _ready():
	ship          = get_node(ship_path) as Node2D
	target_marker = get_node(target_marker_path) as Node2D
	needle        = get_node(needle_path)    as TextureRect
	

	
func _process(delta):
	if ship and target_marker and needle:
		var dir = (target_marker.global_position - ship.global_position).normalized()
		print(dir)
		needle.rotation = deg_to_rad(dir.angle())
