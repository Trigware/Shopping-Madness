class_name ShopRepresentation
extends Resource

class ShopRoom:
	var linked_rooms: Dictionary[Player.MovementDir, ShopRoom] = {}
	var room_type: Inventory.RoomType = Inventory.RoomType.None
	
	static func from_tree(rooms_tree: Dictionary) -> ShopRoom:
		var result_room: ShopRoom = ShopRoom.new()
		if rooms_tree.size() != 1: return result_room
		
		result_room.room_type = rooms_tree.keys()[0]
		var linked_rooms_dict: Dictionary = rooms_tree.values()[0]
		for movement_dir: Player.MovementDir in linked_rooms_dict:
			var linked_room_value = linked_rooms_dict[movement_dir]
			if linked_room_value is Dictionary:
				result_room.linked_rooms[movement_dir] = from_tree(linked_room_value)
				continue
			
			var current_linked_room: ShopRoom = ShopRoom.new()
			current_linked_room.room_type = linked_room_value
			result_room.linked_rooms[movement_dir] = current_linked_room
		
		return result_room

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
