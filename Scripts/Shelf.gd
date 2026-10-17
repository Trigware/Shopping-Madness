class_name Shelf
extends Node2D

@onready var shelf_texture: NinePatchRect = $Texture
@onready var bounding_area: CollisionShape2D = $"Bounding Area/Collider"
@onready var items_root: Node2D = $Items

var shelf_size: Vector2 = Vector2.ZERO
var shelf_position: Vector2 = Vector2.ZERO
var shelf_room_type: Inventory.RoomType = Inventory.RoomType.None
var items_count_on_shelves: int = 0
var is_horizonzal: bool = false

const shelf_item_scale: float = 0.45

func _ready():
	shelf_texture.size = shelf_size
	var collider_shape: Shape2D = RectangleShape2D.new()
	collider_shape.size = shelf_size
	bounding_area.shape = collider_shape
	bounding_area.position = shelf_size / 2
	position = shelf_position
	add_shelf_items()

func add_shelf_items():
	var current_position: Vector2 = Vector2.ZERO
	var available_items: Array = Inventory.available_foods_in_room_map[shelf_room_type]
	var index_offset: int = randi_range(0, available_items.size() - 1)
	
	for i in range(items_count_on_shelves):
		var shelf_item: ShelfItem = UID.SCN_SHELF_ITEM.instantiate()
		shelf_item.scale = Vector2.ONE * shelf_item_scale
		shelf_item.position = current_position
		shelf_item.available_items_in_shelf = available_items
		shelf_item.item_index = i
		shelf_item.index_offset = index_offset
		shelf_item.is_horizontal_shelf = is_horizonzal
		
		var current_direction: Vector2 = Vector2.RIGHT if is_horizonzal else Vector2.DOWN
		var true_food_tile_size: float = ShelfGenerator.food_tile_size * shelf_item_scale
		current_position += true_food_tile_size * current_direction
		items_root.add_child(shelf_item)
