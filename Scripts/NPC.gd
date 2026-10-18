extends Area2D

var npc_dialog: Array = []

func _ready():
	await get_tree().process_frame
	npc_dialog = DialogRepresentation.available_character_dialogs[TextSystem.SpeakingCharacter.Drobasek].dialog_tree
	print(npc_dialog)

func _process(_delta):
	var can_interact: bool = check_if_can_interact()
	if can_interact: TextSystem.render_dialog_arr(npc_dialog)

func check_if_can_interact() -> bool:
	var interaction_button_pressed: bool = Input.is_action_just_pressed("item_pickup")
	if TextSystem.is_interacting or not interaction_button_pressed: return false
	
	var overlapping_bodies: Array = get_overlapping_bodies()
	for body: Node2D in overlapping_bodies:
		var is_player: bool = body.is_in_group("Player")
		if is_player: return true
	return false
