extends Node2D

@onready var sprite = $Sprite

const movement_speed: float = 100
var current_movement_dir: MovementDir = MovementDir.None

enum MovementDir {
	None, Left, Right, Up, Down
}

const possible_horizontal_directions: Array[MovementDir] = [MovementDir.Left, MovementDir.Right]
const possible_vertical_directions: Array[MovementDir] = [MovementDir.Up, MovementDir.Down]

const movement_to_animation_map: Dictionary[MovementDir, String] = {
	MovementDir.Left: "walk_left", MovementDir.Right: "walk_right",
	MovementDir.Up: "walk_up", MovementDir.Down: "walk_down"
}

func _process(delta: float):
	handle_movement(delta)

func handle_movement(delta: float):
	var movement_vec: Vector2 = get_movement_vector()
	position += movement_vec * movement_speed * delta
	if current_movement_dir == MovementDir.None:
		sprite.stop()
		return
	
	print(MovementDir.find_key(current_movement_dir))
	var current_animation_name: String = movement_to_animation_map[current_movement_dir]
	sprite.play(current_animation_name)

func get_movement_vector() -> Vector2:
	var movement_vec: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("walk_left"): movement_vec.x -= 1
	if Input.is_action_pressed("walk_right"): movement_vec.x += 1
	if Input.is_action_pressed("walk_up"): movement_vec.y -= 1
	if Input.is_action_pressed("walk_down"): movement_vec.y += 1
	
	current_movement_dir = get_movement_direction(movement_vec)
	return movement_vec

func get_movement_direction(movement_vec: Vector2) -> MovementDir:
	if movement_vec == Vector2.ZERO: return MovementDir.None
	var horizontal_dir_index: int = 0 if movement_vec.x == -1 else 1
	if movement_vec.x != 0: return possible_horizontal_directions[horizontal_dir_index]
	
	var vertical_dir_index: int = 0 if movement_vec.y == -1 else 1
	return possible_vertical_directions[vertical_dir_index]
