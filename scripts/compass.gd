extends CanvasLayer

@export var ship_path             : NodePath     
@export var target_marker_path    : NodePath     
var needle_path           : NodePath     

var ship         : Node2D
var target_marker: Node2D
var needle       : TextureRect

func _ready():
	update_compass()
	ship          = get_node(ship_path) as Node2D
	target_marker = get_node(target_marker_path) as Node2D
	needle        = $Control/CosmicCompass
	Globals.connect("update_compass", update_compass)

	
func _process(delta):
	if ship and target_marker and needle:
		var world_angle = (target_marker.global_position - ship.global_position).angle()
		var relative_angle = world_angle - ship.rotation
		var desired = relative_angle +90
		needle.rotation = lerp(needle.rotation, desired, clamp(delta * 4.0, 0.0, 1.0))

func update_compass():
	if Globals.has_cosmic_compass == false:
		$Control/CosmicCompass.visible = false
	else:
		$Control/CosmicCompass.visible = true
