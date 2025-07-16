extends Node2D



	
func _process(delta: float) -> void:
	$ShadowSprite.global_position = $"..".global_position + Vector2(12, 16)
	$ShadowSprite.rotation = 0
	rotation = 0
