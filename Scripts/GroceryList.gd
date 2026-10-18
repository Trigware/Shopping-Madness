class_name GloceryList
extends CanvasLayer

@onready var grocery_root = $"Grocery Root"
@onready var grocery_label = $"Grocery Root/Groceries"
@onready var grocery_body = $"Grocery Root/Grocery Body"

var groceries_map: Dictionary[Inventory.ItemType, int] = {
	Inventory.ItemType.Lemon: 1
}

const generated_items_count_range: Vector2 = Vector2(1, 2)
const generated_item_count_per_room: Vector2 = Vector2(1, 2)
const generation_limit: int = 500

func generate_grocery_list():
	for current_room: Inventory.RoomType in Inventory.available_foods_in_room_map.keys():
		var available_items: Array = Inventory.available_foods_in_room_map[current_room]
		var items_generated_this_room: int = 0
		var item_count_to_generate: int = randi_range(generated_item_count_per_room.x, generated_item_count_per_room.y)
		
		for i in range(generation_limit):
			var generated_item_type_index: int = randi_range(0, available_items.size() - 1)
			var generated_item: Inventory.ItemType = available_items[generated_item_type_index]
			var item_already_generated: bool = groceries_map.has(generated_item)
			if item_already_generated: continue
			
			var item_count: int = randi_range(generated_items_count_range.x, generated_items_count_range.y)
			groceries_map[generated_item] = item_count
			items_generated_this_room += 1
			if items_generated_this_room >= item_count_to_generate: break

const line_height: float = 40

func _ready():
	generate_grocery_list()
	update_grocery_list()
	Inventory.inv_update.connect(update_grocery_list)

func update_grocery_list():
	var grocery_list_as_text: String = get_as_text()
	grocery_label.text = grocery_list_as_text
	
	var line_count: int = groceries_map.size()
	var grocery_height: float = (line_count + 1) * line_height
	grocery_body.size.y = grocery_height

func is_complete():
	for current_item: Inventory.ItemType in groceries_map.keys():
		var count_in_inventory: int = Inventory.get_item_count(current_item)
		var required_item_count: int = groceries_map[current_item]
		var item_requirement_fulfilled: bool = count_in_inventory >= required_item_count
		if not item_requirement_fulfilled: return false
	
	return true

const grocery_header_size: Vector2 = Vector2(570, 110)
const grocery_list_size_multiplier: float = 0.4

func _process(_delta):
	set_grocery_list_transform()

const grocery_list_offset: float = 1.1

func set_grocery_list_transform():
	var window_size: Vector2 = DisplayServer.window_get_size()
	var grocery_full_size: Vector2 = grocery_header_size
	grocery_full_size.y += grocery_body.size.y
	var fit_to_window_count: float = window_size.y / grocery_full_size.y
	var grocery_scale_multiplier: float = fit_to_window_count * grocery_list_size_multiplier
	grocery_root.scale = Vector2.ONE * grocery_scale_multiplier
	var grocery_size_in_px: Vector2 = grocery_full_size * grocery_scale_multiplier
	
	grocery_root.position = window_size - grocery_size_in_px * grocery_list_offset

func get_as_text() -> String:
	var result = ""
	for grocery_item: Inventory.ItemType in groceries_map.keys():
		var grocery_item_count: int = groceries_map[grocery_item]
		var current_item_as_str: String = Inventory.itemToNameMap.get(grocery_item, "Unknown")
		var current_item_count: int = Inventory.get_item_count(grocery_item)
		var current_line_as_str: String = " - " + current_item_as_str + " (" + str(current_item_count) +\
			 "/" + str(grocery_item_count) + ")\n"
		result += current_line_as_str
	return result
