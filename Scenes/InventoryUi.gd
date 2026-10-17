extends Node2D

@onready var panel: TextureRect = $CanvasLayer/PanelContainer
@onready var item_list: ItemList = $CanvasLayer/PanelContainer/MarginContainer/ItemList

var displayed_items: Array = []

func _ready() -> void:
	# Na začátku hry inventář schováme
	panel.visible = false
	
	# Napojíme se na globální Autoload "Inventory" a jeho signál "inv_update"
	Inventory.inv_update.connect(refresh_ui)
	
	# Dvojklik na položku v inventáři
	item_list.item_activated.connect(_on_item_activated)
	
	refresh_ui()

func _input(event: InputEvent) -> void:
	# Otevírání a zavírání klávesou I nebo Tab
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I or event.keycode == KEY_TAB:
			panel.visible = not panel.visible
			get_viewport().set_input_as_handled() # Zabrání tomu, aby Tab dělal bílý rámeček
		
		# TESTOVÁNÍ: Zmáčkni K pro přidání jablka a Magnesie
		elif event.keycode == KEY_K:
			Inventory.add_item(Inventory.ItemType.Apple, 1)
			Inventory.add_item(Inventory.ItemType.MagnesiaRed, 2)
			Inventory.print_inventory()

# Překreslí ItemList podle dat v Inventory.gd
func refresh_ui() -> void:
	item_list.clear()
	displayed_items.clear()
	
	for item_type in Inventory.Inventory:
		var item_name: String = Inventory.itemToNameMap.get(item_type, "Neznámý předmět")
		var amount: int = Inventory.Inventory[item_type]
		
		var display_text: String = item_name + " (" + str(amount) + "x)"
		
		item_list.add_item(display_text)
		displayed_items.append(item_type)

# Dvojklik na položku v UI odebere 1 kus
func _on_item_activated(index: int) -> void:
	var item_type = displayed_items[index]
	var item_name = Inventory.itemToNameMap.get(item_type, "")
	
	print("Odebráno/použito 1x: ", item_name)
	Inventory.remove_item(item_type, 1)
