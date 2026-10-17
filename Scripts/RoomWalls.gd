class_name RoomWalls
extends Node2D

@onready var upper_wall = $UpperWall

@onready var left_edge = $UpperWall/LeftEdge
@onready var right_edge = $UpperWall/RightEdge
@onready var center_wall = $UpperWall/CenterWall
@onready var upper_wall_enterance = $UpperWall/Enterance
@onready var wall_shadow = $UpperWall/WallShadow
@onready var enterance_area: Area2D = $"UpperWall/Enterance/Enterance Area"
@onready var exit_arrows_root: Node2D = $"Exit Arrows Root"

var room_size: Vector2 = Vector2.ZERO
const edge_wall_size: Vector2 = Vector2(13, 34)
const tile_size: int = 24
const enterance_offset: int = 5

const exit_arrows_directions: Array[Player.MovementDir] = [
	Player.MovementDir.Left, Player.MovementDir.Right, Player.MovementDir.Down
]

func _ready():
	enterance_area.body_entered.connect(body_entered_to_enterance)

func create_wall(set_room_size: Vector2):
	room_size = set_room_size
	create_upper_wall()
	create_exit_arrows()

func create_upper_wall():
	upper_wall.position = -edge_wall_size / 2
	center_wall.clear()
	for x in range(room_size.x):
		var cell_pos: Vector2 = Vector2(x, 0)
		center_wall.set_cell(cell_pos, 0, Vector2.ZERO)
	right_edge.position.x = tile_size * room_size.x + edge_wall_size.x - 1
	upper_wall_enterance.position.x = tile_size * room_size.x / 2 + enterance_offset
	wall_shadow.size.x = tile_size * room_size.x + 1

func body_entered_to_enterance(body: Node2D):
	if not body.is_in_group("Player"): return
	print("ENTER ROOM")

const exit_arrow_offset: float = 18

func create_exit_arrows():
	var room_size_in_px: Vector2 = room_size * tile_size
	
	for movement_dir: Player.MovementDir in exit_arrows_directions:
		var exit_arrow: EnteranceArrow = UID.SCN_ENTERANCE_ARROW.instantiate()
		match movement_dir:
			Player.MovementDir.Left:
				exit_arrow.scale.x = -exit_arrow.scale.x
				exit_arrow.position = Vector2(-exit_arrow_offset, room_size_in_px.y / 2)
			Player.MovementDir.Right:
				exit_arrow.position = Vector2(room_size_in_px.x + exit_arrow_offset, room_size_in_px.y / 2)
			Player.MovementDir.Down:
				exit_arrow.rotation_degrees = 90
				exit_arrow.position = Vector2(room_size_in_px.x / 2, room_size_in_px.y + exit_arrow_offset)
		exit_arrow.body_entered.connect(body_entered_to_enterance)
		exit_arrows_root.add_child(exit_arrow)
