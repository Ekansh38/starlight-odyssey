extends CanvasLayer


func _ready() -> void:
	Globals.connect("update_stats", update_stats)
	update_stats()

func update_stats():
	$VBoxContainer/Energy.value = Globals.player_energy
	$VBoxContainer2/ShipDamage.value = Globals.ship_damage
	$HBoxContainer/Amount.text = str(Globals.food_amount) + "/" + str(Globals.max_food)

func change_info(message):
	$InfoLabel.text = message

func change_minor_info(message):
	$InfoLabel2.text = message
	
func modulate_screen(mod_color):
	$ColorRect.color = mod_color
	
	

func can_bar_visable(the_bool: bool):
	
	$SelfCanniblizeBar.visible = the_bool
	$LandingBar.visible = false

		
func can_bar_update():
	$SelfCanniblizeBar.value += 1
	
func can_bar_value():
	return $SelfCanniblizeBar.value
	
func can_bar_reset():
	$SelfCanniblizeBar.value = 0
	
	

func landing_bar_visable(the_bool: bool):
	$LandingBar.visible = the_bool
	$SelfCanniblizeBar.visible = false
	
func landing_bar_update():
	$LandingBar.value += 1
	
func landing_bar_value():
	return $LandingBar.value
	
func landing_bar_reset():
	$LandingBar.value = 0
