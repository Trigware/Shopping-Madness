extends CanvasLayer

@onready var money_label: Label = $MarginContainer/HBoxContainer/Label

func update_money(amount: int) -> void:
	money_label.text = str(amount)
