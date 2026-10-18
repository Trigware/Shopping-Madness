class_name TransitionOverlay
extends CanvasLayer

@onready var overlay_rect: ColorRect = $"Overlay Rect"

const transition_in_out_duration: float = 0.35
const transition_wait_duration: float = 0.15

func tween_alpha(final_alpha: float, in_out_duration: float = transition_in_out_duration):
	var tween = create_tween().\
		tween_property(overlay_rect, "color:a", final_alpha, in_out_duration).\
		set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	return tween

func transition(on_hidden: Callable,
	in_out_duration: float = transition_in_out_duration, wait_duration: float = transition_wait_duration
):
	await tween_alpha(1, in_out_duration).finished
	await get_tree().create_timer(wait_duration).timeout
	on_hidden.call()
	await tween_alpha(0, in_out_duration).finished
