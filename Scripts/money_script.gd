extends CanvasLayer

@onready var money_root: Control = $"Money Root"
@onready var money_label: Label = $"Money Root/Label"

func _ready() -> void:
	GameManager.money_changed.connect(update_ui)
	update_ui(GameManager.money)

func update_ui(new_amount: int) -> void:
	money_label.text = str(new_amount)

const default_window_size: Vector2 = Vector2(1152, 648)

func _process(_delta: float):
	var window_size: Vector2 = DisplayServer.window_get_size()
	var size_increase: float = window_size.x / default_window_size.x
	money_root.scale = Vector2.ONE * size_increase
