extends CanvasLayer

@onready var label = $ColorRect/Label
@onready var frame = $ColorRect

const groceries = {
	Inventory.ItemType.Orange: 4,
	Inventory.ItemType.Milk: 1,
	Inventory.ItemType.Bread: 1
}


func _ready() -> void:
	Inventory.inv_update.connect(on_inventory_updated)
	label.size = frame.size
	on_inventory_updated()

func on_inventory_updated():
	var display_text = "Nákupní seznam:\n\n"
	
	for item_type in groceries:
		var required_amount = groceries[item_type]
		var current_amount = Inventory.Inventory.get(item_type, 0)
		var item_name = Inventory.itemToNameMap.get(item_type, "Neznámý")
		
		display_text += item_name + ": " + str(current_amount) + " / " + str(required_amount) + "\n"
		
	label.text = display_text
