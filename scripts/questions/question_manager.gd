extends Node

const QUESTIONS_DATA_PATH := "res://data/questions.json"

var _question_sets: Dictionary = {}

func _ready() -> void:
	load_questions()

func load_questions() -> void:
	var data: Variant = JsonLoader.load_json(QUESTIONS_DATA_PATH, {})
	_question_sets = data if data is Dictionary else {}

func get_onboarding_questions() -> Array[Dictionary]:
	return get_questions("onboarding")

func get_inner_space_questions() -> Array[Dictionary]:
	return get_questions("inner_space")

func get_questions(set_id: String) -> Array[Dictionary]:
	if _question_sets.is_empty():
		load_questions()
	return _to_dictionary_array(_question_sets.get(set_id, []))

func get_question(set_id: String, question_id: String) -> Dictionary:
	for question in get_questions(set_id):
		if String(question.get("id", "")) == question_id:
			return question.duplicate(true)
	return {}

func get_question_count(set_id: String) -> int:
	return get_questions(set_id).size()

func get_question_at(set_id: String, index: int) -> Dictionary:
	var questions := get_questions(set_id)
	if index < 0 or index >= questions.size():
		return {}
	return questions[index].duplicate(true)

func get_next_question(set_id: String, answered_count: int) -> Dictionary:
	return get_question_at(set_id, answered_count)

func has_next_question(set_id: String, answered_count: int) -> bool:
	return answered_count < get_question_count(set_id)

func is_free_text_question(question: Dictionary) -> bool:
	return bool(question.get("free_text", false))

func is_valid_choice(question: Dictionary, choice: String) -> bool:
	if is_free_text_question(question):
		return not choice.strip_edges().is_empty()
	var choices: Variant = question.get("choices", [])
	if choices is Array:
		return choices.has(choice)
	return false

func build_answer(question: Dictionary, value: String) -> Dictionary:
	var key := "text" if is_free_text_question(question) else "choice"
	return {
		"question_id": String(question.get("id", "")),
		key: value,
	}

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result
