extends Area2D

var player_in_range := false
var player : Node2D = null

@export var shop_path: NodePath
var shop

func _ready() -> void:
	if shop_path:
		shop = get_node(shop_path)
	else:
		push_error("Shop path not assigned!")

	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited",  Callable(self, "_on_body_exited"))
	shop.visible = false


func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("land"):
		print("Shop opened!")
		get_tree().paused = true
		shop.transin()
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
