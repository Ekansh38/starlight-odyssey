extends StaticBody2D

@export var can_see: bool = true

func _ready() -> void:
	if can_see:
		$ColorRect.visible = true
	else:
		$ColorRect.visible = false
