extends Node

const TAROT_DATA_PATH := "res://data/tarot_major_arcana.json"
const SPREAD_POSITIONS := ["Quá khứ", "Hiện tại", "Tương lai"]

var _cards: Array[Dictionary] = []

func _ready() -> void:
	load_cards()

func load_cards() -> void:
	_cards = _to_dictionary_array(JsonLoader.load_json(TAROT_DATA_PATH, []))

func get_all_cards() -> Array[Dictionary]:
	return _cards.duplicate(true)

func get_card_by_id(card_id: int) -> Dictionary:
	_ensure_cards_loaded()
	for card in _cards:
		if int(card.get("id", -1)) == card_id:
			return card.duplicate(true)
	return {}

func draw_three_cards(seed_text: String = "") -> Array[Dictionary]:
	_ensure_cards_loaded()
	var deck := _cards.duplicate(true)
	if deck.size() < SPREAD_POSITIONS.size():
		return []
	_shuffle_deck(deck, seed_text)
	return _build_spread(deck)

func draw_for_answers(answers: Array[Dictionary]) -> Array[Dictionary]:
	_ensure_cards_loaded()
	var deck := _cards.duplicate(true)
	if deck.size() < SPREAD_POSITIONS.size():
		return []
	var seed_text: String = _answers_seed(answers)
	_shuffle_deck(deck, seed_text)
	var offset: int = abs(hash(seed_text)) % deck.size() if not seed_text.is_empty() else 0
	deck = deck.slice(offset) + deck.slice(0, offset)
	return _build_spread(deck)

func get_theme_for_card(card: Dictionary) -> String:
	return String(card.get("theme", ""))

func get_keywords_for_card(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var keywords: Variant = card.get("keywords", [])
	if keywords is Array:
		for keyword in keywords:
			result.append(String(keyword))
	return result

func _ensure_cards_loaded() -> void:
	if _cards.is_empty():
		load_cards()

func _build_spread(deck: Array[Dictionary]) -> Array[Dictionary]:
	var spread: Array[Dictionary] = []
	for index in SPREAD_POSITIONS.size():
		spread.append(_make_position_card(deck[index], SPREAD_POSITIONS[index]))
	return spread

func _shuffle_deck(deck: Array[Dictionary], seed_text: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(seed_text) if not seed_text.is_empty() else Time.get_unix_time_from_system()
	for index in range(deck.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var card := deck[index]
		deck[index] = deck[swap_index]
		deck[swap_index] = card

func _answers_seed(answers: Array[Dictionary]) -> String:
	var parts: Array[String] = []
	for answer in answers:
		parts.append(String(answer.get("question_id", "")))
		parts.append(String(answer.get("choice", answer.get("text", ""))))
	return "|".join(parts)

func _make_position_card(card: Dictionary, position: String) -> Dictionary:
	var result := card.duplicate(true)
	result["position"] = position
	return result

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result
