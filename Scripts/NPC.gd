extends CharacterBody2D

@onready var npc_sprite = $Sprite

@onready var interaction_area = $"hitbox_interaction" 

@onready var Collider = $"Collider" 

@export var speed: float = 100.0

@export var is_chaser: bool = false 

@export var character_type: TextSystem.SpeakingCharacter = TextSystem.SpeakingCharacter.None

var npc_dialog = []
var has_triggered_dialog: bool = false 
var is_disabled_during_transition: bool = false

func _ready() -> void:
	await get_tree().process_frame
	
	if DialogRepresentation.available_character_dialogs.has(character_type):
		npc_dialog = DialogRepresentation.available_character_dialogs[character_type].dialog_tree
		
	var char_name = TextSystem.SpeakingCharacter.find_key(character_type)
	if char_name and npc_sprite:
		npc_sprite.animation = char_name

func _physics_process(delta: float) -> void:
	
	if GameManager.is_transitioning:
			velocity = Vector2.ZERO
			return
	
	#pronasledovani
	if is_chaser and not TextSystem.is_interacting:
		var player = get_tree().get_first_node_in_group("Player")
		if player != null:
			var dir = global_position.direction_to(player.global_position)
			velocity = dir * speed
			move_and_slide()
	else:
		#zastaveni rychlosti pri dialogu
		velocity = Vector2.ZERO
	
	if interaction_area == null or not interaction_area.monitoring:
		return
		
		#spusteni iterakce
	var bodies = interaction_area.get_overlapping_bodies()
	var touching_player = false
	
	for b in bodies:
		if b.is_in_group("Player"):
			touching_player = true
			break
			
	if touching_player:
		if not has_triggered_dialog and not TextSystem.is_interacting and not npc_dialog.is_empty():
			has_triggered_dialog = true
			
			is_chaser = false 
			interaction_area.monitoring = false
			Collider = false
			on_touch_player()
	else:
		has_triggered_dialog = false

func on_touch_player():
	await TextSystem.render_dialog_arr(npc_dialog)
	if character_type != TextSystem.SpeakingCharacter.GermanTeacher: return
	#play_german_teacher_questions()

func play_german_teacher_questions():
	Overlay.transition(
		func(): get_tree().change_scene_to_packed(UID.SCN_CLOCK_QUESTION)
	)
