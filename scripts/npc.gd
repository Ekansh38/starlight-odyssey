extends CharacterBody2D
class_name NPC

@export var ui_path: NodePath
var ui
var player_in_area
var timeline = load("res://Timelines/Druvek.dch")
var timeline_name = "druvek"
@export var prompt = "Press [E] to Talk"

@export var can_interact: bool = true



func _ready():
	print("AAAARG")
	ui = get_node(ui_path)
	Dialogic.signal_event.connect(DialogicSignal)

	ui = get_node_or_null(ui_path)

func _process(delta: float) -> void:
	
	if player_in_area:
		if Input.is_action_just_pressed("land"):
			if can_interact:
				var layer = Dialogic.start(timeline_name)
				layer.register_character(timeline, $TextBoxMarker)
				player_in_area.change_controll_label("")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if can_interact:
			body.change_controll_label(prompt)
			player_in_area = body

	



func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.change_controll_label("")
		player_in_area = null

func DialogicSignal(argument:String):
	if argument == "bar_job_start":
		TransitionLayer.change_scene(preload("res://scenes/bar_minigame.tscn"), "long")
	
	if argument == "hitman_job_start" and timeline_name == "moko":
		if not Globals.player_has_gun:
			if ui : ui.change_pickup_indicator("+20 Money")
			Globals.money += 20
		
		can_interact = false
		Globals.is_in_hitman_game = true
		ui.hitman_photo_visible(true)
		ui.start_hitman_timer()
		
@export var move_speed: float = 100.0
@export var stop_distance: float = 4.0   # how close is “arrived”

var move_target: Vector2
var moving: bool = false

func _finish_movement():
	moving = false
	velocity = Vector2.ZERO

func move_to(pos: Vector2) -> void:
	move_target = pos
	moving = true
	if global_position.distance_to(move_target) <= stop_distance:
		_finish_movement()

func _physics_process(delta: float) -> void:
	if not moving:
		return
	
	var to_target = move_target - global_position
	var dist = to_target.length()
	if dist <= stop_distance:
		_arrive()
		return
	
	var step = min(move_speed * delta, dist)
	var dir  = to_target / dist
	var motion = dir * step
	
	var collision
	collision = move_and_collide(motion)
	if collision:
		_arrive()
		
		
func _arrive():
	moving = false
	velocity = Vector2.ZERO

func take_damage():
	$DamageParticles.emitting = true
