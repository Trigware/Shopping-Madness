class_name ShelfItem
extends Area2D

@onready var texture: Sprite2D = $Texture
@onready var collider: CollisionShape2D = $Collider

# TADY TY PROMĚNNÉ CHYBĚLY:
var available_items_in_shelf: Array = []
var room_type: Inventory.RoomType = Inventory.RoomType.None
var is_horizontal_shelf: bool = false
var item_index: int = 0
var item_type: Inventory.ItemType = Inventory.ItemType.None

const collider_scale_multiplier: float = 3
const smaller_axis_collider_multiplier: float = 0.75

func _ready():
	if available_items_in_shelf.is_empty():
		return
		
	# 1. Vybereme konkrétní předmět pro toto políčko poličky:
	var current_tile_x: int = item_index % available_items_in_shelf.size()
	item_type = available_items_in_shelf[current_tile_x]
	
	# 2. Nastavení textury podle toho, jestli jde o samostatný soubor, nebo starý spritesheet:
	if Inventory.item_textures_map.has(item_type):
		# Samostatný obrázek ze složky (mléko, maso, sůl atd.)
		texture.texture = Inventory.item_textures_map[item_type]
		texture.hframes = 1  # Nerozřezávat!
		texture.vframes = 1
		texture.frame = 0
	elif Inventory.room_textures_map.has(room_type):
		# Starý spojený spritesheet (Zelenina nebo Pečivo)
		texture.texture = Inventory.room_textures_map[room_type]
		texture.hframes = available_items_in_shelf.size()
		texture.vframes = 1
		texture.frame_coords.x = current_tile_x
	
	# 3. Úprava kolizí, ať to odpovídá velikosti spritu
	var shape_axis_index: int = 1 if is_horizontal_shelf else 0
	var opposite_axis_index: int = 0 if is_horizontal_shelf else 1
	collider.scale[shape_axis_index] *= collider_scale_multiplier
	collider.scale[opposite_axis_index] *= smaller_axis_collider_multiplier

func _process(_delta):
	var is_picking_up: bool = Input.is_action_just_pressed("item_pickup")
	if not is_picking_up: return
	handle_pickup()

func handle_pickup():
	if item_type == Inventory.ItemType.None or Inventory.item_pick_up_disabled: return
	var bodies_in_area: Array = get_overlapping_bodies()
	var does_player_overlap: bool = false
	for body: Node in bodies_in_area:
		var is_player: bool = body.is_in_group("Player")
		if is_player: does_player_overlap = true; break
	if not does_player_overlap: return
	
	var item_value: int = Inventory.item_prices[item_type]
	var total_money_count: int = GameManager.money
	var can_buy: bool = total_money_count >= item_value
	if not can_buy or TextSystem.is_interacting: return
	
	GameManager.remove_money(item_value)
	Inventory.add_item(item_type, 1)
	item_type = Inventory.ItemType.None
	hide()
	Inventory.item_pick_up_disabled = true
	await get_tree().process_frame
	Inventory.item_pick_up_disabled = false
