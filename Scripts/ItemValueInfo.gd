class_name ItemValidInfo
extends CanvasLayer

@onready var ui_root: Control = $"UI Root"
@onready var item_label: Label = $"UI Root/Item Label"
@onready var value_label: Label = $"UI Root/Value Label"
@export var player: Player

var hovered_item_type: Inventory.ItemType = Inventory.ItemType.None

func _process(_delta):
	hovered_item_type = player.latest_touching_food
	update_label_contents()
	handle_control_transform()

func update_label_contents():
	var item_name: String = Inventory.itemToNameMap.get(hovered_item_type, "----")
	var item_text: String = "Koupil bys (ENTER): " + item_name
	var item_value: int = Inventory.item_prices.get(hovered_item_type, 0)
	var value_as_text: String = ("--" if item_value == 0 else str(item_value)) + " Kč"
	
	item_label.text = item_text
	value_label.text = value_as_text

const additional_scale_multiplier: float = 0.375
const position_offset: float = 0.2

func handle_control_transform():
	var minimum_item_label_size: Vector2 = item_label.get_minimum_size()
	var minimum_value_label_size: Vector2 = item_label.get_minimum_size()
	
	var ui_full_size_px: Vector2 = Vector2(
		max(minimum_item_label_size.x, minimum_value_label_size.x),
		minimum_item_label_size.y + minimum_value_label_size.y
	)
	
	var window_size = DisplayServer.window_get_size()
	var scale_multiplier: float = window_size.x / ui_full_size_px.x * additional_scale_multiplier
	ui_root.scale = Vector2.ONE * scale_multiplier
	var scaled_size_px: Vector2 = ui_full_size_px * scale_multiplier
	ui_root.position.y = window_size.y - scaled_size_px.y * 2
