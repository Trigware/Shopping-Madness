class_name TextSystemClass
extends CanvasLayer

enum SpeakingCharacter {
	None,
	Drobasek,
	Mrazek,
	GermanTeacher,
	Grznar
}

enum ActionType {
	Unknown,
	GiveMoney
}

var is_interacting: bool = false

@onready var text_box: TextureRect = $TextBox
@onready var text_box_contents: Label = $TextBox/Contents
@onready var progress_indicator: TextureRect = $"TextBox/Progress Indicator"
@onready var choicer_root: Control = $TextBox/Choicer

const wait_between_glyphs: float = 0.035

@abstract class DialogSegment: pass

class TextSegment extends DialogSegment:
	var segment_as_text: String = ""
	var segment_audio: String = ""
	
	static func ctor(segment_content: String, audio_path: String = "") -> TextSegment:
		var result: TextSegment = TextSegment.new()
		result.segment_as_text = segment_content
		result.segment_audio = audio_path
		return result

class ChoiceSegment extends DialogSegment:
	var possible_choices: Dictionary = {}
	
	static func ctor(choices: Dictionary) -> ChoiceSegment:
		var result: ChoiceSegment = ChoiceSegment.new()
		result.possible_choices = choices
		return result

class ActionSegment extends DialogSegment:
	var action_type: ActionType = ActionType.Unknown

func render_dialog_arr(dialog_arr: Array):
	TextSystem.is_interacting = true
	text_box.show()
	
	for i in range(dialog_arr.size()):
		var current_segment: DialogSegment = dialog_arr[i]
		await render_segment(current_segment)
	
	TextSystem.is_interacting = false
	text_box.hide()

func render_segment(current_segment: DialogSegment):
	if current_segment is TextSegment: await render_text_segment(current_segment as TextSegment)
	if current_segment is ChoiceSegment: await render_choice_segment(current_segment as ChoiceSegment)
	await get_tree().process_frame

var initial_textbox_size: Vector2 = Vector2.ZERO
const textbox_scale_multiplier: float = 0.8
const textbox_y_offset_multiplier: float = 1.15

func _ready():
	initial_textbox_size = text_box.size
	text_box.hide()

var will_skip_next_time: bool = false

func _process(_delta):
	position_textbox()
	if Input.is_action_pressed("skip_text"): will_skip_next_time = true

func position_textbox():
	var window_size: Vector2 = DisplayServer.window_get_size()
	var scale_multiplier: float = window_size.x / initial_textbox_size.x * textbox_scale_multiplier
	text_box.scale = Vector2.ONE * scale_multiplier
	
	var current_size_px: Vector2 = initial_textbox_size * scale_multiplier
	var textbox_offset: float = (window_size.x - current_size_px.x) / 2
	text_box.position.x = textbox_offset
	text_box.position.y = window_size.y - current_size_px.y * textbox_y_offset_multiplier

const interpunction_symbols = ["!", ".", "-", ",", ":", "…"]
const interpunction_delay: float = 0.5

const voice_clips_path: String = "res://Audio/Voiceclips/"
const default_voice_clip_extension: String = ".mp3"

func render_text_segment(current_segment: TextSegment):
	var segment_as_text: String = current_segment.segment_as_text
	text_box_contents.text = segment_as_text
	var segment_text_length: float = segment_as_text.length()
	choicer_root.hide()
	if current_segment.segment_audio != "":
		var voice_clip_path: String = voice_clips_path + current_segment.segment_audio + default_voice_clip_extension
		var loaded_voiceclip: AudioStream = load(voice_clip_path)
		Audio.play(loaded_voiceclip)
	
	for i in range(segment_text_length):
		will_skip_next_time = false
		var visible_ratio: float = (i + 1) / segment_text_length
		var ch: String = segment_as_text[i]
		text_box_contents.visible_ratio = visible_ratio
		var is_last_ch: bool = i == segment_text_length - 1
		
		var is_interpunction_symbol: bool = interpunction_symbols.has(ch)
		var glyph_wait_duration: float = wait_between_glyphs
		if is_interpunction_symbol and not is_last_ch: glyph_wait_duration += interpunction_delay
		await get_tree().create_timer(glyph_wait_duration).timeout
		if will_skip_next_time:
			text_box_contents.visible_ratio = 1
			break
		
		var play_default_audio: bool = current_segment.segment_audio == ""
		if play_default_audio: Audio.play(UID.SFX_DEFAULT_TALK)
	
	progress_indicator.show()
	await wait_until_progress()
	progress_indicator.hide()

func wait_until_progress():
	while true:
		var is_progress_pressed: bool = Input.is_action_just_pressed("item_pickup")
		if is_progress_pressed: break
		await get_tree().process_frame

var current_chosen_option: Player.MovementDir = Player.MovementDir.None

func render_choice_segment(choice_segment: ChoiceSegment):
	choicer_root.show()
	var choicer_max_options_count: int = choicer_root.get_children().size()
	var ammount_of_used_options: int = choice_segment.possible_choices.size()
	text_box_contents.text = ""
	current_chosen_option = Player.MovementDir.None
	
	for i in range(choicer_max_options_count):
		var is_choice_hidden: bool = i > ammount_of_used_options - 1
		var choice_label: Label = choicer_root.get_child(i)
		choice_label.visible = not is_choice_hidden
		if is_choice_hidden: continue
		choice_label.label_settings.font_color = Color.WHITE
		choice_label.text = choice_segment.possible_choices.keys()[i]
	
	await wait_until_choicer_progress(ammount_of_used_options)
	var current_option_index: int = choice_directions_in_order.find(current_chosen_option)
	var option_as_key: String = choice_segment.possible_choices.keys()[current_option_index]
	var response_segments: Array = choice_segment.possible_choices[option_as_key]
	
	for current_segment: DialogSegment in response_segments:
		await render_segment(current_segment)

const choice_directions_in_order: Array[Player.MovementDir] = [
	Player.MovementDir.Up, Player.MovementDir.Down, Player.MovementDir.Left, Player.MovementDir.Right
]

func wait_until_choicer_progress(possible_choices_count: int):
	while true:
		await get_tree().process_frame
		var selected_option: Player.MovementDir = Player.MovementDir.None
		var can_progress: bool = Input.is_action_just_pressed("item_pickup") and current_chosen_option != Player.MovementDir.None
		if can_progress: return
		
		if Input.is_action_just_pressed("walk_left"): selected_option = Player.MovementDir.Left
		if Input.is_action_just_pressed("walk_right"): selected_option = Player.MovementDir.Right
		if Input.is_action_just_pressed("walk_up"): selected_option = Player.MovementDir.Up
		if Input.is_action_just_pressed("walk_down"): selected_option = Player.MovementDir.Down
		
		var choice_dir_index: int = choice_directions_in_order.find(selected_option)
		var cannot_be_selected: bool = choice_dir_index >= possible_choices_count or selected_option == Player.MovementDir.None
		if cannot_be_selected: continue
		
		var previous_selected_option: Player.MovementDir = current_chosen_option
		current_chosen_option = selected_option
		var current_choice_label: Label = choicer_root.get_child(choice_dir_index)
		current_choice_label.label_settings.font_color = Color.LIME_GREEN
		if previous_selected_option == current_chosen_option: continue
		
		var previous_choice_label_index: int = choice_directions_in_order.find(previous_selected_option)
		var previous_choice_label: Label = choicer_root.get_child(previous_choice_label_index)
		previous_choice_label.label_settings.font_color = Color.WHITE
		
