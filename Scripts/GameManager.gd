extends Node

signal money_changed(new_amount: int)
var money: int = 500

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func remove_money(amount: int) -> void:
	money = max(0, money - amount)
	money_changed.emit(money)

# Test
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			add_money(100)
		elif event.keycode == KEY_O:
			remove_money(25)
