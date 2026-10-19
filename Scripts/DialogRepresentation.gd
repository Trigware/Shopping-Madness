extends Node

class DialogLine:
	var dialog_text: String = ""
	var dialog_audio: String = ""

class CharacterDialog:
	var ambient_lines: Array[DialogLine] = []
	var dialog_tree: Array[TextSystem.DialogSegment] = []

var available_character_dialogs: Dictionary[TextSystem.SpeakingCharacter, CharacterDialog] = {}
const json_file_path: String = "res://dialogs.json"

func parse_json():
	var json_file: FileAccess = FileAccess.open(json_file_path, FileAccess.READ)
	if json_file == null: return
	
	var json_as_text: String = json_file.get_as_text()
	json_file.close()
	var json_data: Dictionary = JSON.parse_string(json_as_text)
	if json_data == null: return
	
	parse_dictionary(json_data)

func parse_dictionary(json_data: Dictionary):
	for character_name: String in json_data.keys():
		var current_dialog: CharacterDialog = CharacterDialog.new()
		var current_speaker: TextSystem.SpeakingCharacter = TextSystem.SpeakingCharacter[character_name]
		var character_data: Dictionary = json_data[character_name]
		
		var ambient_lines: Array = character_data["ambient"]
		for current_ambient_line: Dictionary in ambient_lines:
			var ambient_as_dialog_line: DialogLine = DialogLine.new()
			ambient_as_dialog_line.dialog_text = current_ambient_line["text"]
			ambient_as_dialog_line.dialog_audio = current_ambient_line["audio"]
			current_dialog.ambient_lines.push_back(ambient_as_dialog_line)
		
		var interact_lines: Dictionary = character_data["interact"]
		var dialog_tree: Array[TextSystem.DialogSegment] = get_dialog_tree_from_interact_text(interact_lines, dialog_entry_point)
		current_dialog.dialog_tree = dialog_tree
		available_character_dialogs[current_speaker] = current_dialog

const dialog_entry_point: String = "start"

func get_dialog_tree_from_interact_text(interact_lines: Dictionary, section_name: String) -> Array[TextSystem.DialogSegment]:
	var result: Array[TextSystem.DialogSegment] = []
	var has_section: bool = section_name in interact_lines.keys()
	if not has_section: return []
	var dialog_value: Dictionary = interact_lines[section_name]
	
	var text_segment: TextSystem.TextSegment = TextSystem.TextSegment.new()
	text_segment.segment_as_text = dialog_value["text"]
	text_segment.segment_audio = dialog_value["audio"]
	result.append(text_segment)
	
	if not dialog_value.has("choices"): return result
	var choices_array: Array = dialog_value["choices"]
	var choice_segment: TextSystem.ChoiceSegment = TextSystem.ChoiceSegment.new()
	result.append(choice_segment)
	
	for choice_data: Dictionary in choices_array:
		var choice_text: String = choice_data["text"]
		var next_section_name: String = choice_data["next"]
		var choice_arr: Array = get_dialog_tree_from_interact_text(interact_lines, next_section_name)
		if choice_data.has("action"):
			var action_value: String = choice_data["action"]
			choice_segment.choices_with_actions[choice_text] = TextSystem.ActionType.GiveMoney
		
		choice_segment.possible_choices[choice_text] = choice_arr
	
	return result

func _ready():
	parse_json()
