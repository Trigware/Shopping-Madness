class_name Player
extends CharacterBody2D

@onready var sprite = $Sprite
@onready var camera = $Camera

const movement_speed: float = 100
var current_movement_dir: MovementDir = MovementDir.None
var is_movement_locked: bool = false
var speed_multiplier: float = 1

enum MovementDir {
	None, Left, Right, Up, Down
}

const possible_horizontal_directions: Array[MovementDir] = [MovementDir.Left, MovementDir.Right]
const possible_vertical_directions: Array[MovementDir] = [MovementDir.Up, MovementDir.Down]

const movement_dir_to_spawn_multiplier: Dictionary[MovementDir, Vector2] = {
	MovementDir.Left: Vector2(0, 0.5), MovementDir.Right: Vector2(1, 0.5),
	MovementDir.Up: Vector2(0.5, 0), MovementDir.Down: Vector2(0.5, 1)
}

const movement_to_animation_map: Dictionary[MovementDir, String] = {
	MovementDir.Left: "walk_left", MovementDir.Right: "walk_right",
	MovementDir.Up: "walk_up", MovementDir.Down: "walk_down"
}

const standard_resolution: Vector2 = Vector2(1152, 648)
const standard_zoom_level: float = 3

func _process(delta: float):
	handle_movement(delta)
	update_camera_zoom()

func update_camera_zoom():
	var window_size: Vector2 = DisplayServer.window_get_size()
	var window_size_change: Vector2 = window_size / standard_resolution
	var minimum_change: float = min(window_size_change.x, window_size_change.y)
	var used_zoom_level: float = standard_zoom_level * minimum_change
	camera.zoom = Vector2.ONE * used_zoom_level
	if is_camera_locked: camera.global_position = locked_position

func handle_movement(delta: float):
	var movement_vec: Vector2 = get_movement_vector()
	if is_movement_locked: return
	simulate_input(movement_vec)

const vec_to_movement_dir_map: Dictionary[Vector2, MovementDir] = {
	Vector2.LEFT: MovementDir.Left, Vector2.RIGHT: MovementDir.Right,
	Vector2.UP: MovementDir.Up, Vector2.DOWN: MovementDir.Down
}

var is_camera_locked: bool = false
var locked_position: Vector2 = Vector2.ZERO

func lock_camera():
	is_camera_locked = true
	locked_position = camera.global_position

func simulate_input(movement_vec: Vector2):
	velocity = movement_vec * movement_speed * speed_multiplier
	current_movement_dir = get_movement_direction(movement_vec)
	move_and_slide()
	if current_movement_dir == MovementDir.None:
		sprite.stop()
		return
	
	var current_animation_name: String = movement_to_animation_map[current_movement_dir]
	sprite.play(current_animation_name)

func get_movement_vector() -> Vector2:
	var movement_vec: Vector2 = Vector2.ZERO
	if TextSystem.is_interacting: return Vector2.ZERO
	
	if Input.is_action_pressed("walk_left"): movement_vec.x -= 1
	if Input.is_action_pressed("walk_right"): movement_vec.x += 1
	if Input.is_action_pressed("walk_up"): movement_vec.y -= 1
	if Input.is_action_pressed("walk_down"): movement_vec.y += 1
	
	return movement_vec

func get_movement_direction(movement_vec: Vector2) -> MovementDir:
	if movement_vec == Vector2.ZERO: return MovementDir.None
	var horizontal_dir_index: int = 0 if movement_vec.x == -1 else 1
	if movement_vec.x != 0: return possible_horizontal_directions[horizontal_dir_index]
	
	var vertical_dir_index: int = 0 if movement_vec.y == -1 else 1
	return possible_vertical_directions[vertical_dir_index]
