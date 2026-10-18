class_name ShopRepresentation
extends Resource

const reversed_directions_map: Dictionary[Player.MovementDir, Player.MovementDir] = {
	Player.MovementDir.Left: Player.MovementDir.Right,
	Player.MovementDir.Right: Player.MovementDir.Left,
	Player.MovementDir.Up: Player.MovementDir.Down,
	Player.MovementDir.Down: Player.MovementDir.Up
}

class ShopRoom:
	var linked_rooms: Dictionary[Player.MovementDir, ShopRoom] = {}
	var room_type: Inventory.RoomType = Inventory.RoomType.None
	var shelf_info_arr: Array[Shelf.ShelfInfo] = []
	var room_size: Vector2 = Vector2.ZERO
	var has_loaded_before: bool = false
	
	static func from_tree(rooms_tree: Dictionary) -> ShopRoom:
		var result_room: ShopRoom = ShopRoom.new()
		if rooms_tree.size() != 1: return result_room
		
		result_room.room_type = rooms_tree.keys()[0]
		var linked_rooms_dict: Dictionary = rooms_tree.values()[0]
		for movement_dir: Player.MovementDir in linked_rooms_dict:
			var linked_room_value = linked_rooms_dict[movement_dir]
			var current_linked_room: ShopRoom = ShopRoom.new()
			if linked_room_value is Dictionary: current_linked_room = from_tree(linked_room_value)
			else: current_linked_room.room_type = linked_room_value
			
			current_linked_room.setup_reversed_path(movement_dir, result_room)
			result_room.linked_rooms[movement_dir] = current_linked_room
		
		return result_room
	
	func setup_reversed_path(dir_to_room: Player.MovementDir, source_room: ShopRoom):
		var reversed_dir: Player.MovementDir = reversed_directions_map[dir_to_room]
		linked_rooms[reversed_dir] = source_room

static var shop_enterance: ShopRoom = ShopRoom.from_tree({
	Inventory.RoomType.Vegetables: {
		Player.MovementDir.Up: Inventory.RoomType.Meat,
		Player.MovementDir.Right: {Inventory.RoomType.Pastry: {
			Player.MovementDir.Right: Inventory.RoomType.SmokedMeat,
			Player.MovementDir.Up: {Inventory.RoomType.Dairy: {
				Player.MovementDir.Up: {Inventory.RoomType.Drinks: {
					Player.MovementDir.Left: Inventory.RoomType.CashRegister,
					Player.MovementDir.Right: Inventory.RoomType.Spice
				}}
			}}
		}}
	}}
)
