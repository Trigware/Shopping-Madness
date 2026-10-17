extends Node

# Signál, který zakřičí do celé hry: "Hele, změnily se peníze!"
signal money_changed(new_amount: int)

var money: int = 0

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money) # Vyšle signál s novou částkou

func remove_money(amount: int) -> void:
	money = max(0, money - amount) # Odečte, ale nepustí pod 0
	money_changed.emit(money);
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P: # Klávesa P přidá 100 peněz
			GameManager.add_money(100)
			print("Přidáno! Aktuální peníze: ", GameManager.money)
			
		elif event.keycode == KEY_O: # Klávesa O ubere 25 peněz
			GameManager.remove_money(25)
			print("Odebráno! Aktuální peníze: ", GameManager.money)
