extends Node

const QUESTIONS_DATA_PATH := "res://data/questions.generated.json"

var _data: Dictionary = {}

func _ready() -> void:
	load_questions()

func load_questions() -> void:
	var loaded: Variant = JsonLoader.load_json(QUESTIONS_DATA_PATH, {})
	_data = loaded if loaded is Dictionary else {}

func get_onboarding_intro() -> String:
	_ensure_loaded()
	return String(_data.get("onboarding_intro", ""))

func get_onboarding_questions() -> Array[Dictionary]:
	_ensure_loaded()
	return _to_dictionary_array(_data.get("onboarding", []))



func get_questions_for_card_position(card_slug: String, position: String) -> Array[Dictionary]:
	_ensure_loaded()
	var section := get_card_position_section(card_slug, position)
	return _to_dictionary_array(section.get("questions", []))

func get_story_for_card_position(card_slug: String, position: String) -> String:
	return String(get_card_position_section(card_slug, position).get("story", ""))

func get_card_position_section(card_slug: String, position: String) -> Dictionary:
	_ensure_loaded()
	var cards: Variant = _data.get("cards", {})
	if not cards is Dictionary:
		return {}
	var card_data: Variant = cards.get(card_slug, {})
	if not card_data is Dictionary:
		return {}
	var position_key := get_set_id_for_position(position)
	var section: Variant = card_data.get(position_key, {})
	return section.duplicate(true) if section is Dictionary else {}

func get_set_id_for_position(position: String) -> String:
	match position.to_lower():
		"quá khứ", "past":
			return "past"
		"hiện tại", "present":
			return "present"
		"tương lai", "future":
			return "future"
		_:
			return "inner_space"



func is_free_text_question(question: Dictionary) -> bool:
	return bool(question.get("free_text", false))

func is_valid_choice(question: Dictionary, choice: String) -> bool:
	if is_free_text_question(question):
		return not choice.strip_edges().is_empty()
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for item in choices:
			if get_choice_text(item) == choice:
				return true
	return false

func build_answer(question: Dictionary, value: String) -> Dictionary:
	var key := "text" if is_free_text_question(question) else "choice"
	var answer := {
		"question_id": String(question.get("id", "")),
		key: value,
	}
	if not is_free_text_question(question):
		answer["tags"] = get_choice_tags(question, value)
	return answer

func get_choice_text(choice: Variant) -> String:
	if choice is Dictionary:
		return String(choice.get("text", ""))
	return String(choice)

func get_choice_label(choice: Variant) -> String:
	if choice is Dictionary:
		return String(choice.get("label", ""))
	return ""

func get_choice_tags(question: Dictionary, value: String) -> Array[String]:
	var result: Array[String] = []
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		for item in choices:
			if item is Dictionary and String(item.get("text", "")) == value:
				var tags: Variant = item.get("tags", [])
				if tags is Array:
					for tag in tags:
						result.append(String(tag))
	return result

func _ensure_loaded() -> void:
	if _data.is_empty():
		load_questions()

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item.duplicate(true))
	return result
