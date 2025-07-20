extends Node2D


func _ready() -> void:
	if Globals.did_play_bar_game:
		Globals.did_play_bar_game = false
		$Ysort2/Player.global_position = $TableMarker.global_position
		var money_earned = Globals.bar_game_score * 8
		$UI.change_pickup_indicator(str("You earned $", money_earned, "!"))
		Globals.money += money_earned
