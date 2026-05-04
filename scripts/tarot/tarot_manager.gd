extends Node

const TAROT_DATA_PATH := "res://data/tarot_major_arcana.json"
const SPREAD_POSITIONS := ["past", "present", "future"]
const AFFINITY_WEIGHT := 0.64
const RANDOM_WEIGHT := 0.36
const MAX_AFFINITY_DIVISOR := 3.0

var _cards: Array[Dictionary] = []

func _ready() -> void:
	load_cards()

func load_cards() -> void:
	_cards = _to_dictionary_array(JsonLoader.load_json(TAROT_DATA_PATH, []))
	for index in _cards.size():
		if String(_cards[index].get("slug", "")).is_empty():
			_cards[index]["slug"] = _slugify(String(_cards[index].get("name", "")))

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
	var tag_profile := _tag_profile(answers)
	if tag_profile.is_empty():
		_shuffle_deck(deck, _answers_seed(answers))
		return _build_spread(deck)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_answers_seed(answers) + "|" + str(Time.get_unix_time_from_system()))
	var scored_cards: Array[Dictionary] = []
	for card in deck:
		var card_with_score: Dictionary = card.duplicate(true)
		card_with_score["_score"] = _hybrid_score(card, tag_profile, rng)
		scored_cards.append(card_with_score)
	scored_cards.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("_score", 0.0)) > float(b.get("_score", 0.0))
	)
	for card in scored_cards:
		card.erase("_score")
	return _build_spread(scored_cards)

func get_theme_for_card(card: Dictionary) -> String:
	return String(card.get("theme", ""))

func get_keywords_for_card(card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var keywords: Variant = card.get("keywords", [])
	if keywords is Array:
		for keyword in keywords:
			result.append(String(keyword))
	return result

func get_art_path_for_card(card: Dictionary) -> String:
	var art_path := String(card.get("art_path", card.get("image_path", "")))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return ""
	return art_path

func get_slug_for_card(card: Dictionary) -> String:
	var slug := String(card.get("slug", ""))
	return slug if not slug.is_empty() else _slugify(String(card.get("name", "")))

func get_display_name_for_card(card: Dictionary) -> String:
	var display_name := String(card.get("display_name_vi", ""))
	return display_name if not display_name.is_empty() else String(card.get("name", ""))

func get_subtitle_for_card(card: Dictionary) -> String:
	return String(card.get("subtitle", card.get("name", "")))

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
	var seed_value := hash(seed_text)
	if seed_text.is_empty():
		seed_value = int(Time.get_unix_time_from_system())
	rng.seed = seed_value
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
		var tags: Variant = answer.get("tags", [])
		if tags is Array:
			for tag in tags:
				parts.append(String(tag))
	return "|".join(parts)

func _make_position_card(card: Dictionary, position: String) -> Dictionary:
	var result := card.duplicate(true)
	result["position"] = position
	return result

func _tag_profile(answers: Array[Dictionary]) -> Dictionary:
	var profile: Dictionary = {}
	for answer in answers:
		var tags: Variant = answer.get("tags", [])
		if tags is Array:
			for tag in tags:
				var key := String(tag)
				profile[key] = int(profile.get(key, 0)) + 1
	return profile

func _hybrid_score(card: Dictionary, tag_profile: Dictionary, rng: RandomNumberGenerator) -> float:
	var affinity := 0.0
	var tags: Variant = card.get("affinity_tags", [])
	if tags is Array:
		for tag in tags:
			affinity += float(tag_profile.get(String(tag), 0))
	var normalized_affinity: float = min(1.0, affinity / MAX_AFFINITY_DIVISOR)
	return normalized_affinity * AFFINITY_WEIGHT + rng.randf() * RANDOM_WEIGHT

func _slugify(value: String) -> String:
	return value.to_lower().replace(" ", "_").replace("-", "_")

func _to_dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item)
	return result
