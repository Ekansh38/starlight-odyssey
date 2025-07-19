extends CanvasLayer
@onready var sprite: Sprite2D = $GameOverViaEnergy
const DURATION := 2.5
const BG_FADE_DURATION := 2.0


func _ready() -> void:
	$Label.visible = false
	$RedoButton.visible = false
	$QuitButton.visible = false
	var mat := $SpaceBackground.material as ShaderMaterial
	mat.set("shader_parameter/modulate_color", Color(1, 0.8, 0.8, 1))
	mat.set("shader_parameter/fade", 0.0)

	play_sheet_once()


func play_sheet_once():
	var total_frames = sprite.hframes * sprite.vframes
	var tween = create_tween()
	tween.tween_method(_set_frame, 0.0, total_frames - 1.0, DURATION).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	$Label.visible = true
	$RedoButton.visible = true
	$QuitButton.visible = true
	_fade_space_bg_in()
	
func _set_frame(val: float) -> void:
	sprite.frame = int(val)

func _fade_space_bg_in():
	var mat := $SpaceBackground.material as ShaderMaterial
	mat.set("shader_parameter/modulate_color", Color(1, 0.8, 0.8, 1))
	mat.set("shader_parameter/fade", 0.0)
	var tw = create_tween()
	tw.tween_property(mat, "shader_parameter/fade", 1.0, 1.5) 


func _on_redo_button_pressed() -> void:
	get_tree().paused = false
	
	Globals.reset() 

	TransitionLayer.change_scene(preload("res://scenes/space.tscn"))
	
func _on_quit_button_pressed() -> void:
	if OS.has_feature("web"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		get_tree().quit()
