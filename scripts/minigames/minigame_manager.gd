extends Node

func create_basic_card_game(card: Dictionary) -> Dictionary:
	return {
		"card": card,
		"goal": "Chọn biểu tượng cộng hưởng với lá bài.",
		"choices": ["Gương", "Nến", "Chìa khóa"],
	}

func resolve_choice(choice: String) -> Dictionary:
	return {
		"won": not choice.is_empty(),
		"reward": "Self Fragment",
	}
