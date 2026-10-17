class_name RoomWalls
extends Node2D

@onready var upper_wall = $UpperWall

@onready var left_edge = $UpperWall/LeftEdge
@onready var right_edge = $UpperWall/RightEdge
@onready var center_wall = $UpperWall/CenterWall
@onready var upper_wall_enterance = $UpperWall/Enterance
@onready var wall_shadow = $UpperWall/WallShadow

var room_size: Vector2 = Vector2.ZERO
const edge_wall_size: Vector2 = Vector2(13, 34)
const tile_size: int = 24
const enterance_offset: int = 5

func create_wall(set_room_size: Vector2):
	room_size = set_room_size
	create_upper_wall()

func create_upper_wall():
	upper_wall.position = -edge_wall_size / 2
	center_wall.clear()
	for x in range(room_size.x):
		var cell_pos: Vector2 = Vector2(x, 0)
		center_wall.set_cell(cell_pos, 0, Vector2.ZERO)
	right_edge.position.x = tile_size * room_size.x + edge_wall_size.x - 1
	upper_wall_enterance.position.x = tile_size * room_size.x / 2 + enterance_offset
	wall_shadow.size.x = tile_size * room_size.x + 1
