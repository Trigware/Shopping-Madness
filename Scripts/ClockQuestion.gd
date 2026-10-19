class_name ClockQuestion
extends Node2D

@onready var background: TiledDiagonals = $Background

func _process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size()
	background.size = window_size
