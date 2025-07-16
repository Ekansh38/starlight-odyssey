extends Area2D

class_name Asteroid

@export var speed: float = 200.0
@export var rotation_speed: float = 1.0
@export var dir: Vector2 = Vector2.LEFT

var inside_planet := false

func _ready():
	$CollisionShape2D.disabled = false
	dir = dir.normalized()
	set_physics_process(true)

func _physics_process(delta):
	position += dir * speed * delta
	rotation += rotation_speed * delta

func explode():
	$AnimationPlayer.play("explode")
	$CPUParticles2D.emitting = true
	$ExplosionSoundEffect.play()
	await $AnimationPlayer.animation_finished
	queue_free()

func set_direction(direction):
	dir = direction


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Ship"):
		if not inside_planet:
			body.take_damage("medium")
			explode()
		
func start_disappear():
	await get_tree().create_timer(0.2).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "queue_free"))
