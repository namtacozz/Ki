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

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result
