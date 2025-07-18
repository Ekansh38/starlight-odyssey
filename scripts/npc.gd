extends CharacterBody2D


@export var ui_path: NodePath
var ui
var player_in_area

func _ready():
	ui = get_node(ui_path)
	
func _process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			print("HOLAA!")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.change_controll_label("Press [E] to Talk")
		player_in_area = body
	



func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		ui.landing_bar_visable(false)
		ui.landing_bar_reset()
		body.change_controll_label("")
		player_in_area = null
		
