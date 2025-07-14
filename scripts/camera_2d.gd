extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 5.0
var max_offset: float = 50.0

func _process(delta):
	if shake_amount > 0.01:
		offset = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_amount * max_offset
		shake_amount = lerp(shake_amount, 0.0, delta * shake_decay)
	else:
		offset = Vector2.ZERO

func start_shake(amount: float = 1.0):
	shake_amount = clamp(shake_amount + amount, 0.0, 1.0)
