class_name EvaluationScreen
extends Node2D

@onready var background = $Background
@onready var evaluation_title: Label = $"Evaluation Title"
@onready var evaluation_factors: RichTextLabel = $"Evaluation Title/Evaluation Factors"
@onready var title_screen_button: Node2D = $"Evaluation Title/Title Screen Button"

var expected_window_size = Vector2(1152, 648)
const font_size: int = 34
const time_for_another_statistic: float = 0.6
var current_statistic: EvaluationStatistic = EvaluationStatistic.None

const title_screen_button_multiplier: float = 1.5
const title_screen_button_size: Vector2 = Vector2(176, 52)

func _ready():
	title_screen_button.hide()
	uncover_next_factor()

func _process(_delta):
	var window_size: Vector2 = DisplayServer.window_get_size()
	var size_multiplier: float = window_size.x / expected_window_size.x
	
	background.size = window_size
	evaluation_title.size.x = window_size.x / size_multiplier
	evaluation_title.scale = Vector2.ONE * size_multiplier
	evaluation_title.position.y = font_size * size_multiplier
	
	handle_title_screen_button()
	hover_over_button()

const button_relative_pos: Vector2 = Vector2(0.5, 0.75)

func handle_title_screen_button():
	var window_size: Vector2 = DisplayServer.window_get_size()
	title_screen_button.scale = Vector2.ONE * title_screen_button_multiplier
	var button_size_in_px: Vector2 = title_screen_button_size * title_screen_button_multiplier
	title_screen_button.position = (window_size - button_size_in_px) * button_relative_pos

enum EvaluationStatistic {
	None,
	Timing,
	Money,
	InteractionCount
}

const timer_clock_asset_path: String = "res://Textures/Timer Clock.png"
const money_asset_path: String = "res://Textures/penizky.webp"

func uncover_next_factor():
	await get_tree().create_timer(time_for_another_statistic).timeout
	current_statistic = (current_statistic as int + 1) as EvaluationStatistic
	if current_statistic >= EvaluationStatistic.size():
		show_main_menu_button()
		return
	
	Audio.play(UID.SFX_UNCOVER_NEW_STAT)
	var appended_text: String = ""
	match current_statistic:
		EvaluationStatistic.Timing: appended_text = "[img=48]" + str(timer_clock_asset_path) + "[/img] Čas: " + EvaluationData.get_time_as_str()
		EvaluationStatistic.Money: appended_text = "[img=48]" + str(money_asset_path) + "[/img] " + str(GameManager.money) + " Kč"
		EvaluationStatistic.InteractionCount: appended_text = "Počet interakcí: " + str(EvaluationData.interaction_count)
	
	evaluation_factors.text += appended_text + '\n'
	uncover_next_factor()

func show_main_menu_button():
	await get_tree().create_timer(time_for_another_statistic).timeout
	Audio.play(UID.SFX_UNCOVER_NEW_STAT)
	title_screen_button.show()
	
func hover_over_button():
	if not title_screen_button.visible: return
	var button_size_in_px: Vector2 = title_screen_button_size * title_screen_button.scale
	var local_mouse: Vector2 = title_screen_button.get_local_mouse_position()
	var is_hovering: bool = local_mouse.x >= 0 and local_mouse.y >= 0 and\
		 local_mouse.x <= button_size_in_px.x and local_mouse.y <= button_size_in_px.y
	var is_clicking: bool = Input.is_action_just_pressed("mouse_click")
	if not is_clicking or not is_hovering: return
	
	Overlay.transition(
		func(): get_tree().change_scene_to_packed(UID.SCN_TITLE_SCREEN)
	)
	
