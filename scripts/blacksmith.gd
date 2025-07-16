extends Area2D

var player_in_range := false
var player : Node2D = null

func _ready() -> void:
	# nothing to do here for the prompt
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("land"):
		print("Shop opened!")
		# clear the prompt on the actual player instance
		player.change_controll_label("")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		player = body   # cache it!
		player.change_controll_label("Press [E] to Open Shop")

func _on_body_exited(body: Node) -> void:
	if body == player:
		player_in_range = false
		player.change_controll_label("")  # clear when they leave
		player = null      # drop the reference
