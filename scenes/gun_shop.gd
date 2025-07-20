extends Shop
	

func _ready():
	$".".visible = false
	$".".transout()

	item_list = Globals.gun_items
	switch_item(0)



func _on_buy_pressed() -> void:
	var selected_item = item_list[curr_item]
	
	if selected_item["Cost"] > Globals.money:
		return

	
	if selected_item["Name"] == "Pistol":
		if Globals.player_has_gun == true:
			return
		Globals.player_has_gun = true
		Globals.player_ammo += 5
		$"..".change_pickup_indicator("+1 Pistol, +5 Ammo")
	
	elif selected_item["Name"] == "Ammo Mag":

		Globals.player_ammo += 10
		$"..".change_pickup_indicator("+10 Ammo")
		
	if selected_item["Cost"] <= Globals.money:
		Globals.money -= selected_item["Cost"]
