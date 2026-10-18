class_name RoomManager
extends Node2D

var current_room: ShopRepresentation.ShopRoom = ShopRepresentation.shop_enterance
@onready var room_scene: Room = $Room
@onready var player_node: Player = $Player
var room_switching_locked: bool = false

func switch_to_next(destination_room: ShopRepresentation.ShopRoom):
	if room_switching_locked: return
	
	current_room.shelf_info_arr = room_scene.get_all_shelf_info()
	current_room.has_loaded_before = true
	current_room.room_size = room_scene.generated_room_size
	
	current_room = destination_room
	room_switching_locked = true
	await Overlay.transition(on_switching_to_destination)
	room_switching_locked = false

func on_switching_to_destination():
	room_scene.queue_free()
	room_scene = UID.SCN_ROOM.instantiate()
	room_scene.room_manager = self
	room_scene.player_node = player_node
	add_child(room_scene)
