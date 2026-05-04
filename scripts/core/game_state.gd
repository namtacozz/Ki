extends Node

var onboarding_answers: Array[Dictionary] = []
var selected_cards: Array[Dictionary] = []
var inner_space_results: Array[Dictionary] = []
var final_report: Dictionary = {}

func reset_run() -> void:
	onboarding_answers.clear()
	selected_cards.clear()
	inner_space_results.clear()
	final_report.clear()

func add_onboarding_answer(answer: Dictionary) -> void:
	onboarding_answers.append(answer)

func set_selected_cards(cards: Array[Dictionary]) -> void:
	selected_cards = cards.duplicate(true)

func add_inner_space_result(result: Dictionary) -> void:
	inner_space_results.append(result)

func set_final_report(report: Dictionary) -> void:
	final_report = report.duplicate(true)
