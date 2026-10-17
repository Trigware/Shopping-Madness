class_name Shelf
extends Node2D

@onready var shelf_texture: NinePatchRect = $Texture
@onready var bounding_area: CollisionShape2D = $"Bounding Area/Collider"

var shelf_size: Vector2 = Vector2.ZERO
var shelf_position: Vector2 = Vector2.ZERO

func _ready():
	shelf_texture.size = shelf_size
	var collider_shape: Shape2D = RectangleShape2D.new()
	collider_shape.size = shelf_size
	bounding_area.shape = collider_shape
	bounding_area.position = shelf_size / 2
	position = shelf_position
