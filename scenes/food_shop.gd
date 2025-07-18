extends Shop

	

func _ready():
	item_list = Globals.food_items
	switch_item(0)



func _on_buy_pressed() -> void:
	var selected_item = item_list[curr_item]
	
	if selected_item["Cost"] > Globals.money:
		return

	
	if selected_item["Name"] == "Snack":
		if (Globals.food_amount + 1) > Globals.max_food:
			return
		Globals.food_amount += 1
	elif selected_item["Name"] == "Meal":
		if (Globals.food_amount + 3) > Globals.max_food:
			return
		Globals.food_amount += 3
	elif selected_item["Name"] == "Bundle":
		Globals.max_food += 2

	if selected_item["Cost"] <= Globals.money:
		Globals.money -= selected_item["Cost"]
