extends CanvasLayer


func _ready() -> void:
	Globals.connect("update_stats", update_stats)
	update_stats()

func update_stats():
	$VBoxContainer/Energy.value = Globals.player_energy
	$VBoxContainer2/ShipDamage.value = Globals.ship_damage
	$HBoxContainer/Amount.text = str(Globals.food_amount) + "/" + str(Globals.max_food)
	$Money/Money.text = str(Globals.money)
	$Ammo/Ammo.text = str(Globals.player_ammo)

func change_info(message):
	$InfoLabel.text = message

func change_minor_info(message):
	$InfoLabel2.text = message
	
func modulate_screen(mod_color):
	$ColorRect.color = mod_color
	
	

func can_bar_visable(the_bool: bool):
	
	$SelfCanniblizeBar.visible = the_bool
	$LandingBar.visible = false
	$ZoomOutBar.visible = false
		
func can_bar_update():
	$SelfCanniblizeBar.value += 1
	
func can_bar_value():
	return $SelfCanniblizeBar.value
	
func can_bar_reset():
	$SelfCanniblizeBar.value = 0
	
	

func landing_bar_visable(the_bool: bool):
	$LandingBar.visible = the_bool
	$SelfCanniblizeBar.visible = false
	$ZoomOutBar.visible = false

	
func landing_bar_update():
	$LandingBar.value += 1
	
func landing_bar_value():
	return $LandingBar.value
	
func landing_bar_reset():
	$LandingBar.value = 0
	
func speed_lines_visablity(value: bool):
	$SpeedLines.visible = value
	
func minor_info_shown():
	if $InfoLabel2.text != "":
		return true
	else:
		return false
		
func zoom_bar_visable(the_bool: bool):
	$ZoomOutBar.visible = the_bool
	$LandingBar.visible = false
	$SelfCanniblizeBar.visible = false

	
func zoom_bar_update():
	$ZoomOutBar.value += 1
	
func zoom_bar_value():
	return $ZoomOutBar.value
	
func zoom_bar_reset():
	$ZoomOutBar.value = 0
	
