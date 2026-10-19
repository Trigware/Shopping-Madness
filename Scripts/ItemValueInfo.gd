extends CanvasLayer

@onready var item_label: Label = $"Item Label"
@onready var value_label: Label = $"Value Label"

var hovered_item_type: Inventory.ItemType = Inventory.ItemType.None

func _process(_delta):
	pass
