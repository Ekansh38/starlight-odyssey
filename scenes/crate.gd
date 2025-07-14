extends Area2D

@export var speed_cap: float = 600.0
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	if velocity.length() > speed_cap:
		velocity = velocity.normalized() * speed_cap

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):	
		Globals.player_energy += Globals.energy_per_food
		if Globals.player_energy > Globals.max_energy:
			Globals.player_energy = Globals.max_energy
		queue_free()
		
func set_velocity(value):
	velocity = value
