class_name ShelfItem
extends Area2D

@onready var texture: Sprite2D = $Texture
@onready var collider: CollisionShape2D = $Collider

var available_items_in_shelf: Array = []
var is_horizontal_shelf: bool = false
var item_index: int = 0
var index_offset: int = 0
var item_type: Inventory.ItemType = Inventory.ItemType.None

const collider_scale_multiplier: float = 3
const smaller_axis_collider_multiplier: float = 0.75

func _ready():
	var current_tile_x: int = (item_index + index_offset) % (available_items_in_shelf.size() - 1)
	texture.frame_coords.x = current_tile_x
	item_type = available_items_in_shelf[current_tile_x]
	
	var shape_axis_index: int = 1 if is_horizontal_shelf else 0
	var opposite_axis_index: int = 0 if is_horizontal_shelf else 1
	collider.scale[shape_axis_index] *= collider_scale_multiplier
	collider.scale[opposite_axis_index] *= smaller_axis_collider_multiplier

func _process(delta: float):
	var is_picking_up: bool = Input.is_action_just_pressed("item_pickup")
	if not is_picking_up: return
	handle_pickup()

func handle_pickup():
	if item_type == Inventory.ItemType.None: return
	var bodies_in_area: Array = get_overlapping_bodies()
	var does_player_overlap: bool = false
	for body: Node in bodies_in_area:
		var is_player: bool = body.is_in_group("Player")
		if is_player: does_player_overlap = true; break
	if not does_player_overlap: return
	
	Inventory.add_item(item_type, 1)
	item_type = Inventory.ItemType.None
	hide()
