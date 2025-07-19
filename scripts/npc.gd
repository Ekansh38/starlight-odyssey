extends CharacterBody2D
class_name NPC

@export var ui_path: NodePath
var ui
var player_in_area
var timeline = load("res://Timelines/Druvek.dch")
var timeline_name = "druvek"


func _ready():
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)

	
func _process(delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			var layer = Dialogic.start(timeline_name)
			layer.register_character(timeline, $TextBoxMarker)
			player_in_area.change_controll_label("")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.change_controll_label("Press [E] to Talk")
		player_in_area = body

	



func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.change_controll_label("")
		player_in_area = null

func DialogicSignal(argument:String):
	if argument == "bar_job_start":
		TransitionLayer.change_scene(preload("res://scenes/bar_minigame.tscn"), "long")
		
