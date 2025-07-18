extends CanvasLayer
class_name Shop


var curr_item = 0
var select = 0
var item_list = Globals.repairs

func transin():
	$Anim.play("TransIn")
	
func transout():
	$Anim.play("TransOut")

	
func _ready() -> void:
	switch_item(0)


func switch_item(select):
	for i in range(item_list.size()):
		if select == i:
			curr_item = select
			$Control/Name.text = item_list[curr_item]["Name"]
			$Control/Desc.text = item_list[curr_item]["Des"]
			$Control/Icon.texture = item_list[curr_item]["Icon"]
			$Control/Cost.text = "Cost: " + str(item_list[curr_item]["Cost"])

func _on_close_button_pressed() -> void:
	transout()
	get_tree().paused = false


func _on_prev_pressed() -> void:
	switch_item(curr_item - 1)



func _on_next_pressed() -> void:
	switch_item(curr_item + 1)


func _on_buy_pressed() -> void:
	var selected_item = item_list[curr_item]
	if selected_item["Cost"] <= Globals.money:
		Globals.money -= selected_item["Cost"]
	
	if selected_item["Name"] == "Basic Repair":
		Globals.ship_damage += 10
	elif selected_item["Name"] == "Premium Repair":
		Globals.ship_damage += 25
	elif selected_item["Name"] == "Ship Overhaul":
		Globals.ship_damage += 50
