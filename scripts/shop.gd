extends CanvasLayer


func transin():
	$Anim.play("TransIn")
	
func transout():
	$Anim.play("TransOut")

	


func _on_close_button_pressed() -> void:
	transout()
	get_tree().paused = false
