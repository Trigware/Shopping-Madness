class_name IntroCutscene
extends Node2D

@onready var background: ColorRect = $Background
@onready var phone_root: Node2D = $"Phone Root"
@onready var ringtone: AudioStreamPlayer = $"Phone Root/Ringtone"

@onready var answer_icon: Sprite2D = $"Phone Root/Answer Icon"
@onready var decline_icon: Sprite2D = $"Phone Root/Decline Icon"

const phone_size: Vector2 = Vector2(180, 380)
const phone_additional_multiplier: float = 0.8
var relative_phone_position: Vector2 = Vector2(0.5, 1)
var phone_additional_offset: float = 1

const wait_for_phone_duration: float = 0.7

func _ready():
	phone_root.hide()
	ringtone.finished.connect(play_ringtone_again)
	await get_tree().create_timer(wait_for_phone_duration).timeout
	handle_phone_tweens()

func _process(_delta):
	set_phone_transform()
	handle_mouse_interaction()

func set_phone_transform():
	var window_size: Vector2 = DisplayServer.window_get_size()
	var minimum_window_dimen: float = min(window_size.x, window_size.y)
	
	background.size = window_size
	var phone_scale_multiplier: float = minimum_window_dimen / phone_size.y * phone_additional_multiplier
	var phone_size_in_px: Vector2 = phone_size * phone_scale_multiplier
	var phone_position: Vector2 = (window_size - phone_size_in_px) * relative_phone_position
	phone_position.y += phone_additional_offset * phone_size_in_px.y
	phone_root.position = phone_position
	phone_root.scale = Vector2.ONE * phone_scale_multiplier

const phone_tween_duration: float = 0.6
var is_ringing: bool = false

func handle_tweening(relative_final: float, offset_final: float):
	create_tween().tween_property(self, "relative_phone_position:y", relative_final, phone_tween_duration).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await create_tween().tween_property(self, "phone_additional_offset", offset_final, phone_tween_duration).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD).finished

func handle_phone_tweens():
	phone_root.show()
	await handle_tweening(0.5, 0)
	ringtone.play()
	is_ringing = true

const wait_between_ringtones: float = 0.85

func play_ringtone_again():
	if not is_ringing:
		ringtone.stop()
		return
	await get_tree().create_timer(wait_between_ringtones).timeout
	ringtone.play()

const icon_radius: float = 40

func handle_mouse_interaction():
	var is_clicking: bool = Input.is_action_just_pressed("mouse_click")
	if not is_clicking: return
	
	var icon_radius_scaled: float = icon_radius / phone_root.scale.x
	var dist_to_answer: float = answer_icon.get_local_mouse_position().length()
	var dist_to_decline: float = decline_icon.get_local_mouse_position().length()
	
	var hover_over_answer: bool = dist_to_answer <= icon_radius_scaled
	var hover_over_decline: bool = dist_to_decline <= icon_radius_scaled
	if hover_over_answer:
		handle_phone_answer()
		return
	if hover_over_decline: handle_phone_decline()

func handle_phone_decline():
	ringtone.stop()
	await handle_tweening(1, 1)
	await get_tree().create_timer(0.5).timeout
	handle_phone_tweens()

var phone_dialog: Array = [
	TextSystem.TextSegment.ctor("Konečně jsi mi to zvedl! Pokouším se tě dovolat od už od půl pátý!", "intro_01"),
	TextSystem.TextSegment.ctor("Ty jsi si nepřipravil tu zatracenou svačinu…", "intro_02"),
	TextSystem.TextSegment.ctor("Já ti to říkám celej večer a ty to stejně neuděláš!", "intro_03"),
	TextSystem.ChoiceSegment.ctor({
		"Promiň mami, jdu si to hned připravit.": [
			TextSystem.TextSegment.ctor("No tak to doufám - udělej to dřív než řeknu tátovi ať se o tebe postárá!", "intro_04_A")
		],
		"Kašlu ti na to!": [
			TextSystem.TextSegment.ctor("No co si to dovoluješ, mě takhle oslovovat - ještě jednou mi něco takovýho řekneš přísahám…", "intro_04_B"),
			TextSystem.TextSegment.ctor("PŘÍSAHÁM! ŽE TY TVOJE MINECRAFTY UŽ NIKDY NEUVIDÍŠ!", "intro_04_B2")
		]
	}),
	TextSystem.TextSegment.ctor("Dělej než my vyčerpáš všechny moje kredity…")
]

const transition_fade_out_duration: float = 0.8

func handle_phone_answer():
	await handle_tweening(1, 1)
	ringtone.stop()
	is_ringing = false
	await get_tree().create_timer(0.5).timeout
	await TextSystem.render_dialog_arr(phone_dialog)
	Overlay.transition(
		func(): get_tree().change_scene_to_packed(UID.SCN_INTRO_CUTSCENE_OVERWORLD), 0.5, 0.35
	)
