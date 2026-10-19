class_name ClockQuestion
extends Node2D

@onready var background: TiledDiagonals = $Background
@onready var question_title: Label = $"Question Title"
@onready var question_subtitle: Label = $"Question Title/Subtitle"
@onready var input_message: Control = $"Input Message"
@onready var message_box: NinePatchRect = $"Input Message/Message Box"
@onready var message_line_edit: LineEdit = $"Input Message/LineEdit"

const message_box_relative_pos: Vector2 = Vector2(0.5, 0.9)
const message_box_additional_scale: float = 0.3

func _ready():
	message_line_edit.grab_focus()
	message_line_edit.text_submitted.connect(on_text_submitted)

func _process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size()
	question_title.size.x = window_size.x
	question_subtitle.size.x = window_size.x
	question_title.position.y = question_title.size.y / 2
	background.size = window_size
	
	var message_scale_multiplier: float = min(window_size.x / message_box.size.x, window_size.y / message_box.size.y)
	message_scale_multiplier *= message_box_additional_scale
	input_message.position = (window_size - message_box.position - message_box.size * message_scale_multiplier) *\
		message_box_relative_pos
	input_message.scale = Vector2.ONE * message_scale_multiplier

func on_text_submitted(text_content: String):
	var submission_valid: bool = is_submission_correct(text_content)
	UID.SCN_MAIN_SCENE

func is_submission_correct(text_content: String):
	return true
