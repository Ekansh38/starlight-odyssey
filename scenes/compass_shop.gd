extends Shop
	

func _ready():
	$".".visible = false
	$".".transout()

	item_list = Globals.compass_items
	switch_item(0)



func _on_buy_pressed() -> void:
	var selected_item = item_list[curr_item]
	
	if selected_item["Cost"] > Globals.money:
		return

	
	if selected_item["Name"] == "Cosmic Compass":
		if Globals.has_cosmic_compass == true:
			return
		Globals.has_cosmic_compass = true
		$"..".change_pickup_indicator("Cosmic Compass Aquired.")
		$"..".change_info("Launch into space to use.")
		$"..".can_interact = false

		
	if selected_item["Cost"] <= Globals.money:
		Globals.money -= selected_item["Cost"]
	
	transout()
