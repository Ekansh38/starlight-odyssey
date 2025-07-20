extends Node2D

var astriux = ["Astriux", load("res://Astriux.dch"), NodePath("../AstriuxPos")]
var druvek  = ["Druvek",  load("res://Timelines/Druvek.dch"),  NodePath("../DruvekPos")]
var nephryl = ["Nephryl", load("res://Timelines/Nephryl.dch"), NodePath("../NephrylPos")]

var cocktails = ["Plum Wine", "Cosmopolitan", "M&M", "Plum Mocktail"]
var characters = [astriux, druvek, nephryl]

var cocktails_orderd = []

var score = 0

func _ready() -> void:
	$"../AstriuxRect".visible = false
	$"../AstriuxText".visible = false
	
	$"../DruvekRect".visible = false
	$"../DruvekText".visible = false
	
	$"../NephrylRect".visible = false
	$"../NephrylText".visible = false
	
	
	if characters.is_empty():
		push_warning("No characters defined for cocktail orders.")
		return
	
	refule()

func refule():
	for character in characters:
		var rect: ColorRect = get_node(str("../" + character[0] + "Rect"))
		var text: Label = get_node(str("../" + character[0] + "Text"))
		
		rect.visible = true
		text.visible = true
		var idx = int(randi() % cocktails.size())
		var cocktail = cocktails[idx]
		text.text = cocktail
		cocktails_orderd.append(cocktail)


func _on_glass_drink_served(drink: Variant) -> void:
	if drink == "Magical & Milky (M&M)":
		drink = "M&M"
	
	if drink in cocktails_orderd:
		score += 1
		$"../UI".change_pickup_indicator(str("Served a ", drink))
		remove_drink(drink)
		cocktails_orderd.erase(drink)
				
		if cocktails_orderd.is_empty():
			refule()
	else:
		if score > 0:
			score -= 1
		$"../UI".change_pickup_indicator(str("No one ordered a ", drink, "!"))
	$"../Score".text = str(score)



	# if the list is empty then call refule
	
func remove_drink(drink):
	for character in characters:
		var rect: ColorRect = get_node(str("../" + character[0] + "Rect"))
		var text: Label = get_node(str("../" + character[0] + "Text"))
		
		if text.text == drink:
			text.text = ""
			rect.visible = false
			return
