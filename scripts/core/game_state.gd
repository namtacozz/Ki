extends Node

signal soul_fragments_changed(new_amount: int)

var onboarding_answers: Array[Dictionary] = []
var selected_cards: Array[Dictionary] = []
var current_space_index := 0
var space_answers: Dictionary = {}
var inner_space_results: Array[Dictionary] = []
var minigame_results: Dictionary = {}
var ai_reflections: Dictionary = {}
var soul_fragments := 0
var final_report: Dictionary = {}

func reset_run() -> void:
	onboarding_answers.clear()
	selected_cards.clear()
	current_space_index = 0
	space_answers.clear()
	inner_space_results.clear()
	minigame_results.clear()
	ai_reflections.clear()
	soul_fragments = 0
	soul_fragments_changed.emit(soul_fragments)
	final_report.clear()

func add_onboarding_answer(answer: Dictionary) -> void:
	onboarding_answers.append(answer)

func set_selected_cards(cards: Array[Dictionary]) -> void:
	selected_cards = cards.duplicate(true)

func set_current_space_index(index: int) -> void:
	current_space_index = index

func add_space_answer(position: String, answer: Dictionary) -> void:
	if not space_answers.has(position):
		space_answers[position] = []
	space_answers[position].append(answer)

func add_inner_space_result(result: Dictionary) -> void:
	inner_space_results.append(result)

func set_minigame_result(position: String, result: Dictionary) -> void:
	minigame_results[position] = result.duplicate(true)
	soul_fragments = get_total_soul_fragments()
	soul_fragments_changed.emit(soul_fragments)

func get_total_soul_fragments() -> int:
	var total := 0
	for pos in minigame_results:
		var res = minigame_results[pos]
		total += int(res.get("soul_fragments", res.get("fragments", 0)))
	return total

func get_soul_fragments_by_position() -> Dictionary:
	var map := {}
	for pos in minigame_results:
		var res = minigame_results[pos]
		map[pos] = int(res.get("soul_fragments", res.get("fragments", 0)))
	return map

func get_soul_fragment_events() -> Array:
	var events := []
	for pos in minigame_results:
		var res = minigame_results[pos]
		var sub_events = res.get("soul_fragment_events", [])
		if sub_events is Array:
			events.append_array(sub_events)
	return events

func set_ai_reflection(position: String, reflection: Dictionary) -> void:
	ai_reflections[position] = reflection.duplicate(true)
	for index in inner_space_results.size():
		if String(inner_space_results[index].get("position", "")) == position:
			inner_space_results[index]["ai_reflection"] = reflection.duplicate(true)
			return

func set_final_report(report: Dictionary) -> void:
	final_report = report.duplicate(true)
