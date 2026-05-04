extends Node

func build_local_summary(cards: Array[Dictionary], inner_results: Array[Dictionary]) -> Dictionary:
	return {
		"cards": cards.duplicate(true),
		"inner_results": inner_results.duplicate(true),
		"summary": "Bản soi chiếu cuối sẽ được tạo qua AI proxy.",
	}
