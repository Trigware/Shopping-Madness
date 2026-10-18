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

var item_pick_up_disabled: bool = false

# Textury pro celé místnosti (zelenina a pečivo jedou ze spritesheetů, zbytek ze slozek protoze se mi nechteli delat sprite sheety)
var room_textures_map: Dictionary = {
	RoomType.Vegetables: preload("res://Textures/spritesheet ovoce zelenina.png"),
	RoomType.Pastry: preload("res://Textures/PastrySpritesheet.png"),
	RoomType.Dairy: preload("res://Textures/mléčné a sypke výrobky/mleko.png"),
	RoomType.Meat: preload("res://Textures/maso/tunak.png"),
	RoomType.SmokedMeat: preload("res://Textures/maso/sunka.png"),
	RoomType.Drinks: preload("res://Textures/pití/dzusik.png"),
	RoomType.Spice: preload("res://Textures/koreni, konzervy a testoviny/Testoviny.png")
}

# Jednotlivé ikonky pro předměty, co se točí ve složkách
var item_textures_map: Dictionary = {
	# Koření, konzervy, těstoviny
	ItemType.Lentils: preload("res://Textures/koreni, konzervy a testoviny/cocka.png"),
	ItemType.BakedBeans: preload("res://Textures/koreni, konzervy a testoviny/fazole.png"),
	ItemType.Pepper: preload("res://Textures/koreni, konzervy a testoviny/pepr.png"),
	ItemType.Spaghetti: preload("res://Textures/koreni, konzervy a testoviny/Testoviny.png"),
	
	# Maso
	ItemType.Salmon: preload("res://Textures/maso/losos.png"),
	ItemType.Meat: preload("res://Textures/maso/sunka.png"),
	ItemType.Tuna: preload("res://Textures/maso/tunak.png"),
	
	# Mléčné a sypké výrobky
	ItemType.Sugar: preload("res://Textures/mléčné a sypke výrobky/cukr.png"),
	ItemType.Butter: preload("res://Textures/mléčné a sypke výrobky/maslo.png"),
	ItemType.Milk: preload("res://Textures/mléčné a sypke výrobky/mleko.png"),
	ItemType.Flour: preload("res://Textures/mléčné a sypke výrobky/mouka.png"),
	ItemType.Oatmeal: preload("res://Textures/mléčné a sypke výrobky/Ovesne_vlocky.png"),
	ItemType.Rice: preload("res://Textures/mléčné a sypke výrobky/ryze.png"),
	ItemType.Salt: preload("res://Textures/mléčné a sypke výrobky/sul.png"),
	
	# Pití
	ItemType.OrangeJuice: preload("res://Textures/pití/dzusik.png"),
	ItemType.MagnesiaRed: preload("res://Textures/pití/mineralka.png"),
}

# rozdeleni na mistnosti
var available_foods_in_room_map: Dictionary[RoomType, Array] = {
	RoomType.Vegetables: [
		ItemType.Orange, ItemType.Brocoli, ItemType.Onion, ItemType.Lemon, 
		ItemType.Grapes, ItemType.Pear, ItemType.Apple, ItemType.Melon
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

# Lokalizované názvy pro výpisy do konzole nebo UI
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
		
	Inventory[item] = Inventory.get(item, 0) + amount
	print(ItemType.find_key(item))
	inv_update.emit()

func get_item_count(item_type: ItemType) -> int:
	if not Inventory.has(item_type): return 0
	return Inventory[item_type]
	
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
		print("%s: %dx" % [item_name, Inventory[item]])
	print("----------------")
