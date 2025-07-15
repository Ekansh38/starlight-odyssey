extends Area2D

@export var speed: float = 500.0
var vel: Vector2 = Vector2.ZERO

func _ready():
	rotation = vel.angle()
	await get_tree().create_timer(8.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += vel * delta

#func _on_body_entered(body: Node2D) -> void:
#	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("explode"):
		area.explode()
	queue_free()
