class_name Shelf
extends Node2D

class ShelfInfo:
	var shelf_rect: Rect2
	var shelf_items: Array[Inventory.ItemType] = []
	var is_horizontal: bool = false
	var index_offset: int = 0

@onready var shelf_texture: NinePatchRect = $Texture
@onready var bounding_area: CollisionShape2D = $"Bounding Area/Collider"
@onready var items_root: Node2D = $Items

var shelf_size: Vector2 = Vector2.ZERO
var shelf_position: Vector2 = Vector2.ZERO
var shelf_room_type: Inventory.RoomType = Inventory.RoomType.None
var items_count_on_shelves: int = 0
var is_horizonzal: bool = false

const shelf_item_scale: float = 0.45
var mandatory_items: Array = []

func _ready():
	shelf_texture.size = shelf_size
	var collider_shape: Shape2D = RectangleShape2D.new()
	collider_shape.size = shelf_size
	bounding_area.shape = collider_shape
	bounding_area.position = shelf_size / 2
	position = shelf_position
	mandatory_items = get_mandatory_items_list()
	add_shelf_items()

@onready var room_manager = get_parent().get_parent().get_parent()
@onready var grocery_list = room_manager.grocery_list

func get_mandatory_items_list():
	var result: Array = []
	var items_in_room: Array = Inventory.available_foods_in_room_map[shelf_room_type]
	for current_item: Inventory.ItemType in items_in_room:
		var is_in_groceries: bool = grocery_list.groceries_map.has(current_item)
		if is_in_groceries: result.push_back(current_item)
	
	return result

func add_shelf_items(items_arr: Array = []):
	var current_position: Vector2 = Vector2.ZERO
	var available_items: Array = []
	if Inventory.available_foods_in_room_map.has(shelf_room_type):
		available_items = Inventory.available_foods_in_room_map[shelf_room_type]
	else: push_error("ROOM IS WITHOUT ITEMS!")
	
	for i in range(items_count_on_shelves):
		var shelf_item: ShelfItem = UID.SCN_SHELF_ITEM.instantiate()
		shelf_item.scale = Vector2.ONE * shelf_item_scale
		shelf_item.position = current_position
		shelf_item.available_items_in_shelf = available_items
		shelf_item.room_type = shelf_room_type
		shelf_item.item_index = randi_range(0, available_items.size() - 1)
		shelf_item.is_horizontal_shelf = is_horizonzal
		if i < mandatory_items.size():
			shelf_item.item_type = mandatory_items[i]
		
		var current_direction: Vector2 = Vector2.RIGHT if is_horizonzal else Vector2.DOWN
		var true_food_tile_size: float = ShelfGenerator.food_tile_size * shelf_item_scale
		current_position += true_food_tile_size * current_direction
		items_root.add_child(shelf_item)
		
		if items_arr.size() > 0: shelf_item.item_type = items_arr[i]

func get_shelf_info() -> ShelfInfo:
	var result: ShelfInfo = ShelfInfo.new()
	
	result.shelf_rect.position = shelf_position
	result.shelf_rect.size = shelf_size
	result.is_horizontal = is_horizonzal
	
	for shelf_item: ShelfItem in items_root.get_children():
		result.shelf_items.push_back(shelf_item.item_type)
	return result

func delete_shelf_items():
	for shelf_item: ShelfItem in items_root.get_children():
		shelf_item.queue_free()
