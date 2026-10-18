extends Node

signal inv_update

enum ItemType {
	None,
	Orange, Pear, Apple, Lemon, Grapes, Melon, Banana,
	Onion, Brocoli, Pepper, Lentils,
	Butter, Milk, Cheese,
	OrangeJuice, MagnesiaRed,
	Salt, Sugar,
	BakedBeans,
	Oatmeal,
	Flour,
	Rice,
	Tuna, Salmon, Meat,
	Spaghetti,
	Doughnut, Bun, Baguette, Croissant, Roll, Bread,
}

enum RoomType {
	None, Vegetables, Pastry, Meat, Fruits, Dairy, Drinks, SmokedMeat, Spice, CashRegister
}

# 1A. PŮVODNÍ SPRITESHEETY (Zelenina a Pečivo zůstávají tak, jak už ti fungují!)
var room_textures_map: Dictionary = {
	RoomType.Vegetables: preload("res://Textures/spritesheet ovoce zelenina.png"),
	RoomType.Pastry: preload("res://Textures/PastrySpritesheet.png"),
	
	# Tady doplníme ty nové složky:
	RoomType.Dairy: preload("res://Textures/mléčné a sypke výrobky/mleko.png"), # Nebo můžeš vytvořit jeden společný obrázek, případně zvolit hlavní sprite
	RoomType.Meat: preload("res://Textures/maso/tunak.png"),
	RoomType.SmokedMeat: preload("res://Textures/maso/sunka.png"),
	RoomType.Drinks: preload("res://Textures/pití/dzusik.png"),
	RoomType.Spice: preload("res://Textures/koreni, konzervy a testoviny/Testoviny.png")
}

# 1B. JEDNOTLIVÉ OBRÁZKY ZE SLOŽEK (pro ostatní místnosti)
var item_textures_map: Dictionary = {
	# Složka: koreni, konzervy a testoviny
	ItemType.Lentils: preload("res://Textures/koreni, konzervy a testoviny/cocka.png"),
	ItemType.BakedBeans: preload("res://Textures/koreni, konzervy a testoviny/fazole.png"),
	ItemType.Pepper: preload("res://Textures/koreni, konzervy a testoviny/pepr.png"),
	ItemType.Spaghetti: preload("res://Textures/koreni, konzervy a testoviny/Testoviny.png"),
	
	# Složka: maso
	ItemType.Salmon: preload("res://Textures/maso/losos.png"),
	ItemType.Meat: preload("res://Textures/maso/sunka.png"),
	ItemType.Tuna: preload("res://Textures/maso/tunak.png"),
	
	# Složka: mléčné a sypke výrobky
	ItemType.Sugar: preload("res://Textures/mléčné a sypke výrobky/cukr.png"),
	ItemType.Butter: preload("res://Textures/mléčné a sypke výrobky/maslo.png"),
	ItemType.Milk: preload("res://Textures/mléčné a sypke výrobky/mleko.png"),
	ItemType.Flour: preload("res://Textures/mléčné a sypke výrobky/mouka.png"),
	ItemType.Oatmeal: preload("res://Textures/mléčné a sypke výrobky/Ovesne_vlocky.png"),
	ItemType.Rice: preload("res://Textures/mléčné a sypke výrobky/ryze.png"),
	ItemType.Salt: preload("res://Textures/mléčné a sypke výrobky/sul.png"),
	
	# Složka: pití
	ItemType.OrangeJuice: preload("res://Textures/pití/dzusik.png"),
	ItemType.MagnesiaRed: preload("res://Textures/pití/mineralka.png"),
}

# 2. SEZNAMY POTRAVIN V MÍSTNOSTECH (přesně podle tvých složek)
var available_foods_in_room_map: Dictionary[RoomType, Array] = {
	RoomType.Vegetables: [
		ItemType.Orange, ItemType.Pear, ItemType.Apple, ItemType.Lemon, 
		ItemType.Grapes, ItemType.Melon, ItemType.Onion, ItemType.Brocoli
	],
	RoomType.Pastry: [
		ItemType.Baguette, ItemType.Roll, ItemType.Bun, ItemType.Doughnut, ItemType.Croissant
	],
	RoomType.Dairy: [
		ItemType.Sugar, ItemType.Butter, ItemType.Milk, 
		ItemType.Flour, ItemType.Oatmeal, ItemType.Rice, ItemType.Salt
	],
	RoomType.Spice: [
		ItemType.Lentils, ItemType.BakedBeans, ItemType.Pepper, ItemType.Spaghetti
	],
	RoomType.Meat: [
		ItemType.Salmon, ItemType.Meat, ItemType.Tuna
	],
	RoomType.SmokedMeat: [
		ItemType.Salmon, ItemType.Meat, ItemType.Tuna
	],
	RoomType.Drinks: [
		ItemType.OrangeJuice, ItemType.MagnesiaRed
	]
}

const itemToNameMap: Dictionary = {
	ItemType.Orange: "Pomeranč",
	ItemType.Pear: "Hruška",
	ItemType.Apple: "Jablko",
	ItemType.Lemon: "Citron",
	ItemType.Grapes: "Hroznové víno",
	ItemType.Melon: "Meloun",
	ItemType.Onion: "Cibule",
	ItemType.Brocoli: "Brokolice",
	ItemType.Baguette: "Bageta",
	ItemType.Roll: "Rohlík",
	ItemType.Bun: "Houska",
	ItemType.Doughnut: "Kobliha",
	ItemType.Croissant: "Croissant",
	ItemType.Butter: "Máslo",
	ItemType.Milk: "Mléko",
	ItemType.Oatmeal: "Ovesné vločky",
	ItemType.Flour: "Mouka",
	ItemType.Rice: "Rýže",
	ItemType.Salt: "Sůl",
	ItemType.Sugar: "Cukr",
	ItemType.Pepper: "Pepř",
	ItemType.Lentils: "Čočka",
	ItemType.BakedBeans: "Fazole v tomatě",
	ItemType.Spaghetti: "Těstoviny",
	ItemType.Tuna: "Tuňák",
	ItemType.Salmon: "Losos",
	ItemType.Meat: "Šunka",
	ItemType.OrangeJuice: "Pomerančový džus",
	ItemType.MagnesiaRed: "Minerálka",
	ItemType.Banana: "Banán",
	ItemType.Bread: "Chléb",
	ItemType.Cheese: "Sýr"
}

var Inventory: Dictionary = {}

func _ready() -> void:
	pass

func add_item(item: ItemType, amount: int = 1) -> void:
	if amount <= 0:
		return
	if Inventory.has(item):
		Inventory[item] += amount
	else:
		Inventory[item] = amount
	inv_update.emit()
	
func remove_item(item: ItemType, amount: int = 1) -> void:
	if amount <= 0 or not Inventory.has(item):
		return
	Inventory[item] -= amount
	if Inventory[item] <= 0:
		Inventory.erase(item)
	inv_update.emit()

func print_inventory() -> void:
	print("--- Inventář ---")
	for item in Inventory:
		var item_name = itemToNameMap.get(item, "Neznámý předmět")
		var amount = Inventory[item]
		print(item_name + ": " + str(amount) + "x")
	print("----------------")
