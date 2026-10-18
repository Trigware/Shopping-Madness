extends Node

# Definice signálu, který se spustí při jakékoliv změně inventáře
signal inv_update

enum ItemType {
	None,
	Orange, Pear, Apple, Lemon, Grapes, Melon, Banana,
	Onion, Brocoli, 	Pepper, 	Lentils,
	Butter, Milk, Cheese,
	OrangeJuice, MagnesiaRed,
	Salt, Sugar,
	BakedBeans,
	Oatmeal,
	Flour,
	Rice,
	Tuna, Salmon, Meat,
	
	Doughnut, Bun, Baguette, Croissant, Roll, Bread,
}

enum RoomType {
	None, Vegetables, Pastry, Meat, Fruits, Dairy, Drinks, SmokedMeat, Spice, CashRegister
}

const available_foods_in_room_map: Dictionary[RoomType, Array] = {
	RoomType.Pastry: [ItemType.Baguette, ItemType.Roll, ItemType.Bun, ItemType.Doughnut, ItemType.Croissant],
	RoomType.Vegetables: []
}

const itemToNameMap: Dictionary = {
	ItemType.Orange: "Pomeranč",
	ItemType.Pear: "Hruška",
	ItemType.Apple: "Jablko",
	ItemType.Lemon: "Citron",
	ItemType.Grapes: "Hroznové víno",
	ItemType.Melon: "Meloun",
	ItemType.Onion: "Cibule",
	ItemType.Butter: "Máslo",
	ItemType.Milk: "Mléko",
	ItemType.OrangeJuice: "Pomerančový džus",
	ItemType.MagnesiaRed: "Magnesia Red",
	ItemType.Salt: "Sůl",
	ItemType.Sugar: "Cukr",
	ItemType.BakedBeans: "Fazole v tomatě",
	ItemType.Oatmeal: "Ovesné vločky",
	ItemType.Flour: "Mouka",
	ItemType.Rice: "Rýže",
	ItemType.Brocoli: "Brokolice",
	ItemType.Pepper: "Pepř",
	ItemType.Lentils: "Čočka",
	ItemType.Tuna: "Tuňák",
	ItemType.Salmon: "Losos",
	ItemType.Doughnut: "Kobliha",
	ItemType.Bun: "Houska",
	ItemType.Baguette: "Bageta",
	ItemType.Croissant: "Croissant",
	ItemType.Roll: "Rohlík",
	ItemType.Bread: "Chléb",
	ItemType.Banana: "Banán",
	ItemType.Meat: "Maso"
}

var Inventory: Dictionary = {}

func _ready() -> void:
	# Příklad použití po spuštění:
	# add_item(ItemType.Apple, 3)
	# add_item(ItemType.Bread, 1)
	pass

# Funkce pro přidání předmětu do inventáře
func add_item(item: ItemType, amount: int = 1) -> void:
	if amount <= 0:
		return
		
	# Pokud předmět už v inventáři je, přičteme množství
	if Inventory.has(item):
		Inventory[item] += amount
	# Jinak ho vytvoříme s daným množstvím
	else:
		Inventory[item] = amount
		
	# Spustíme signál, že se inventář aktualizoval
	inv_update.emit()
	
# (Bonus) Funkce pro odebrání předmětu
func remove_item(item: ItemType, amount: int = 1) -> void:
	if amount <= 0 or not Inventory.has(item):
		return
		
	Inventory[item] -= amount
	
	# Pokud klesne počet na 0 nebo méně, smažeme ho z inventáře úplně
	if Inventory[item] <= 0:
		Inventory.erase(item)
		
	# Spustíme signál, že se inventář aktualizoval
	inv_update.emit()

# Pomocná funkce pro vypsání obsahu inventáře do konzole (pro debug)
func print_inventory() -> void:
	print("--- Inventář ---")
	for item in Inventory:
		var item_name = itemToNameMap.get(item, "Neznámý předmět")
		var amount = Inventory[item]
		print(item_name + ": " + str(amount) + "x")
	print("----------------")
