extends Node2D

const default_room_size: Vector2 = Vector2(10, 6)
const last_texture_coordinate: Vector2i = Vector2i(1, 1)

@onready var room_floor = $Floor
@onready var background_diagonals: TiledDiagonals = $Background
@onready var shadow_floor: ColorRect = $"Shadow Floor"
@onready var room_walls: RoomWalls = $RoomWalls

const diagonals_size: int = 10000
const floor_shadow_offset: int = 5

func _ready():
	setup_floor()
	center_background()
	handle_floor_shadow()
	room_walls.create_wall(default_room_size)

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
