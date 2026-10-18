class_name ShelfGenerator
extends Node2D

@export var current_room: Room

const shelf_smaller_size: float = 25
const shelf_length_range: Vector2 = Vector2(3, 4)
var placed_shelves_rect_arr: Array[Rect2] = []

func _ready():
	var loaded_room: ShopRepresentation.ShopRoom = current_room.room_manager.current_room
	var loaded_previously: bool = loaded_room.has_loaded_before
	if loaded_previously:
		recover_shelves()
		return
	generate_shelves()

func add_shelf(shelf_size: Vector2, shelf_pos: Vector2, items_in_shelf: int, is_horizontal: bool) -> Shelf:
	var added_shelf: Shelf = UID.SCN_SHELF.instantiate()
	added_shelf.shelf_position = shelf_pos
	added_shelf.shelf_size = shelf_size
	added_shelf.shelf_room_type = current_room.current_room_type
	added_shelf.items_count_on_shelves = items_in_shelf
	added_shelf.is_horizonzal = is_horizontal
	add_child(added_shelf)
	added_shelf.items_root.position = Vector2.ONE * shelf_smaller_size / 2.0
	
	var shelf_as_rect: Rect2
	shelf_as_rect.size = shelf_size
	shelf_as_rect.position = shelf_pos
	placed_shelves_rect_arr.push_back(shelf_as_rect)
	return added_shelf

const generation_padding_size: float = 0.2
const max_generation_count: int = 300
const maximum_generated_shelves: int = 8
const food_tile_size: int = 45

func generate_shelves():
	var room_size_pixels: Vector2 = current_room.default_room_size * current_room.tile_size
	var smaller_room_size_px: float = min(room_size_pixels.x, room_size_pixels.y)
	var top_left_min = Vector2.ONE * smaller_room_size_px * generation_padding_size
	var generated_shelf_count: int = 0
	
	for i in range(max_generation_count):
		var items_in_shelf_count: int = randi_range(shelf_length_range.x, shelf_length_range.y)
		var shelf_length: float = food_tile_size * Shelf.shelf_item_scale * items_in_shelf_count
		var is_shelf_horizontal: bool = randf_range(0, 1) < 0.5
		var shelf_size: Vector2 = Vector2(shelf_smaller_size, shelf_length)
		if is_shelf_horizontal: shelf_size = Vector2(shelf_size.y, shelf_size.x)
		
		var bottom_right_max: Vector2 = room_size_pixels - top_left_min - shelf_size
		var generated_position: Vector2 = Vector2(
			randf_range(top_left_min.x, bottom_right_max.x),
			randf_range(top_left_min.y, bottom_right_max.y)
		)
		var is_valid: bool = is_generated_shelf_valid(generated_position, shelf_size)
		if not is_valid: continue
		
		add_shelf(shelf_size, generated_position, items_in_shelf_count, is_shelf_horizontal)
		generated_shelf_count += 1
		if generated_shelf_count >= maximum_generated_shelves: break

const shelf_rect_offset: float = current_room.tile_size * 2.5

func is_generated_shelf_valid(shelf_position: Vector2, shelf_size: Vector2) -> bool:
	var generated_shelf_as_rect: Rect2
	shelf_size += Vector2.ONE * shelf_rect_offset
	shelf_position -= Vector2.ONE * shelf_rect_offset / 2
	generated_shelf_as_rect.size = shelf_size
	generated_shelf_as_rect.position = shelf_position
	
	for i in range(placed_shelves_rect_arr.size()):
		var shelf_rect: Rect2 = placed_shelves_rect_arr[i]
		var is_intersecting: bool = shelf_rect.intersects(generated_shelf_as_rect)
		if is_intersecting: return false
	
	return true

func recover_shelves():
	var loaded_room: ShopRepresentation.ShopRoom = current_room.room_manager.current_room
	for current_shelf: Shelf.ShelfInfo in loaded_room.shelf_info_arr:
		add_shelf(
			current_shelf.shelf_rect.size, current_shelf.shelf_rect.position,
			current_shelf.shelf_items.size(), current_shelf.is_horizontal
		)
