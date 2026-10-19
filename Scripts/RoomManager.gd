class_name RoomManager
extends Node2D

var current_room: ShopRepresentation.ShopRoom = ShopRepresentation.shop_enterance
var previously_came_from_dir: Player.MovementDir = Player.MovementDir.Up
@onready var room_scene = $Room
@onready var player_node: Player = $Player
@onready var grocery_list = $GroceryList
var room_switching_locked: bool = false

func switch_to_next(destination_room: ShopRepresentation.ShopRoom):
	if room_switching_locked: return
	
	if destination_room.room_type == Inventory.RoomType.CashRegister:
		on_destination_exit()
		return
	
	current_room.shelf_info_arr = room_scene.get_all_shelf_info()
	current_room.has_loaded_before = true
	current_room.room_size = room_scene.generated_room_size
	
	current_room = destination_room
	room_switching_locked = true
	await Overlay.transition(on_switching_to_destination)
	room_switching_locked = false
	player_node.shelf_generator = room_scene.get_node("Shelf Generator")

var on_exit_refusal_dialog: Array = [
	TextSystem.TextSegment.ctor("Zde vede cesta ke kasám. Jelikož jsi ještě nedokončil svůj seznam věcí, jít jsem není dobrý nápad.")
]

func on_destination_exit():
	var allows_exit: bool = grocery_list.is_complete()
	if not allows_exit: TextSystem.render_dialog_arr(on_exit_refusal_dialog); return
	Overlay.transition(
		func(): get_tree().change_scene_to_packed(UID.SCN_EVALUATION_SCREEN)
	)

func on_switching_to_destination():
	room_scene.queue_free()
	room_scene = UID.SCN_ROOM.instantiate()
	room_scene.room_manager = self
	room_scene.player_node = player_node
	add_child(room_scene)
