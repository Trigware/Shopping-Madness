class_name EvaluationScreen
extends Node2D

@onready var background = $Background

func _process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size()
	background.size = window_size
	
