class_name IntroCutsceneOverworld
extends Node2D

@onready var background: TiledDiagonals = $Background
@onready var player: Player = $Player

@onready var freezer_root: Node2D = $"Fridge Root"
@onready var freezer_shadow: AnimatedSprite2D = $"Fridge Root/Fridge Shadow"
@onready var freezer_base: AnimatedSprite2D = $"Fridge Root/Fridge"

const starting_tile_x_pos: int = -4
const freezer_width: float = 26

func _ready():
	background.position_offset = -background.size / 2
	player.is_movement_locked = true
	player.position.x = Room.tile_size * starting_tile_x_pos
	move_player_to_freezer()
	await TextSystem.render_dialog_arr([TextSystem.TextSegment.ctor("Příště když tohle uděláš, tak budeš bez těch rob loksů, rozumíš?")])
	open_fridge()

const movement_speed_multiplier: float = 0.6
var is_aligned_with_fridge: bool = false

func move_player_to_freezer():
	var init_x_player_pos: float = player.position.x
	var destination_freezer_x: float = freezer_root.position.x - freezer_width / 2
	
	while player.position.x < destination_freezer_x:
		var player_path_progress: float = inverse_lerp(
			init_x_player_pos, freezer_root.position.x, player.position.x
		)
		player.speed_multiplier = (1 - player_path_progress) * movement_speed_multiplier
		player.simulate_input(Vector2.RIGHT)
		await get_tree().process_frame
	
	is_aligned_with_fridge = true

func open_fridge():
	while true:
		if is_aligned_with_fridge: break
		await get_tree().process_frame
	player.simulate_input(Vector2.UP)
	
	await get_tree().create_timer(0.3).timeout
	freezer_base.frame = 1
	freezer_shadow.frame = 1
	Audio.play(UID.SFX_FRIDGE_OPEN)
	await get_tree().create_timer(0.5).timeout
	
	player.speed_multiplier = 1.5
	handle_after_open_dialog()
	is_after_fridge_running_active = true
	while is_after_fridge_running_active:
		player.simulate_input(Vector2.RIGHT)
		await get_tree().process_frame

var is_after_fridge_running_active: bool = false

func handle_after_open_dialog():
	var after_open_dialog: Array = [
		TextSystem.TextSegment.ctor("Neříkej mi, že už máme zase prázdnou ledničku!"),
		TextSystem.TextSegment.ctor("Upaluj hned do krámu si něco koupit…")
	]
	player.lock_camera()
	
	await TextSystem.render_dialog_arr(after_open_dialog)
	Overlay.transition(func():
		is_after_fridge_running_active = false
		await get_tree().process_frame
		get_tree().change_scene_to_packed(UID.SCN_MAIN_SCENE), 1.0
	)
