extends CanvasLayer

@onready var money_label: Label = $MarginContainer/HBoxContainer/Label

func _ready() -> void:
	# Propojíme globální signál s naší funkcí update_ui
	GameManager.money_changed.connect(update_ui)
	update_ui(GameManager.money)

func update_ui(new_amount: int) -> void:
	money_label.text = str(new_amount)
