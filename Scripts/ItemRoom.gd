class_name Room
extends Node2D

const default_room_size: Vector2 = Vector2(10, 6)
const last_texture_coordinate: Vector2i = Vector2i(1, 1)
var current_room_type: Inventory.RoomType = Inventory.RoomType.Pastry

@onready var room_floor = $Floor
@onready var background_diagonals: TiledDiagonals = $Background
@onready var shadow_floor: ColorRect = $"Shadow Floor"
@onready var room_walls: RoomWalls = $RoomWalls
@onready var bounding_area: StaticBody2D = $"Bounding Area"
@export var playerNode: Player

const diagonals_size: int = 10000
const floor_shadow_offset: int = 5

func _ready():
	center_player()
	setup_floor()
	center_background()
	handle_floor_shadow()
	room_walls.create_wall(default_room_size)
	setup_bounding_collision_boxes()

func center_player():
	var room_size_in_px: Vector2 = default_room_size * tile_size
	playerNode.position = room_size_in_px / 2

func setup_floor():
	room_floor.clear()
	for x in range(default_room_size.x): for y in range(default_room_size.y):
		var current_position: Vector2i = Vector2i(x, y)
		var texture_coordinate: Vector2i = Vector2i(
			randi_range(0, last_texture_coordinate.x),
			randi_range(0, last_texture_coordinate.y)
		)
		room_floor.set_cell(current_position, 0, texture_coordinate)

func center_background():
	background_diagonals.size = Vector2.ONE * diagonals_size
	background_diagonals.position_offset = -Vector2.ONE * diagonals_size / 2.0

const tile_size: int = 24

func handle_floor_shadow():
	var shadow_offset: Vector2 = floor_shadow_offset * Vector2.ONE
	shadow_floor.size = default_room_size * tile_size
	shadow_floor.position = shadow_offset

const box_side_count: int = 4
const box_collider_size: int = 20

func setup_bounding_collision_boxes():
	var room_total_size: Vector2 = default_room_size * tile_size
	
	for i in range(box_side_count):
		var current_collision_shape: CollisionShape2D = CollisionShape2D.new()
		var current_shape: RectangleShape2D = RectangleShape2D.new()
		var shape_size: Vector2 = Vector2(room_total_size.x, box_collider_size)
		var shape_position: Vector2 = Vector2.ZERO
		
		var is_horizontal_box: bool = i % 2 == 0
		var is_first_box: bool = i / 2 == 0
		var checked_vec_index: int = 0 if is_horizontal_box else 1
		var inverse_vec_index: int = 1 if is_horizontal_box else 0
		shape_position[checked_vec_index] = room_total_size[checked_vec_index] / 2
		
		if not is_horizontal_box: shape_size = Vector2(box_collider_size, room_total_size.y)
		if not is_first_box: shape_position[inverse_vec_index] = room_total_size[inverse_vec_index]
		var box_offset: float = box_collider_size / 2
		if is_first_box: box_offset = -box_offset
		shape_position[inverse_vec_index] += box_offset
		
		current_shape.size = shape_size
		current_collision_shape.shape = current_shape
		current_collision_shape.position = shape_position
		bounding_area.add_child(current_collision_shape)
