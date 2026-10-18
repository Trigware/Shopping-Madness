class_name TitleScreen
extends Node2D

@onready var logo_root = $"Logo Root"
@onready var background = $Background
@onready var play_button: Node2D = $"Logo Root/Play Button"
@onready var button_texture: NinePatchRect = $"Logo Root/Play Button/Button Texture"

const logo_size: Vector2 = Vector2(252, 111)
const logo_additional_multiplier: float = 0.9
var logo_offset_multiplier: Vector2 = Vector2(0.5, 1)
var logo_additional_y_offset: float = 1
const final_logo_offset_y: float = 0.3

func _ready():
	tween_logo()

func _process(_delta):
	position_logo()
	handle_mouse_hover()

const logo_tween_duration: float = 0.85

func position_logo():
	var window_size: Vector2 = DisplayServer.window_get_size()
	var min_window_dimen_size: float = min(window_size.x, window_size.y)
	var max_logo_dimen_size: float = max(logo_size.x, logo_size.y)
	var logo_scale_multiplier: float = min_window_dimen_size / max_logo_dimen_size * logo_additional_multiplier
	
	var logo_size_in_px: Vector2 = logo_scale_multiplier * logo_size
	var logo_offset: Vector2 = (window_size - logo_size_in_px) * logo_offset_multiplier
	logo_offset.y += logo_size_in_px.y * logo_additional_y_offset
	logo_root.scale = Vector2.ONE * logo_scale_multiplier
	logo_root.position = logo_offset
	background.scale = Vector2.ONE * logo_scale_multiplier

func tween_logo():
	create_tween().tween_property(self, "logo_additional_y_offset", 0, logo_tween_duration).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	create_tween().tween_property(self, "logo_offset_multiplier:y", final_logo_offset_y, logo_tween_duration).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)

func handle_mouse_hover():
	var mouse_position: Vector2 = play_button.get_local_mouse_position()
	var button_size_in_px: Vector2 = button_texture.size * button_texture.scale
	var is_hovering: bool = mouse_position.x > 0 and mouse_position.y > 0 and\
		mouse_position.x <= button_size_in_px.x and mouse_position.y <= button_size_in_px.y
	var is_clicking = Input.is_action_just_pressed("mouse_click")
	if not is_clicking or not is_hovering: return
	
	click_on_play_button()

func click_on_play_button():
	Overlay.transition(func():
		get_tree().change_scene_to_packed(UID.SCN_INTRO_CUTSCENE), 0.4, 0.3
	)
