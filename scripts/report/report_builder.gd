extends Node

const REPORT_KEYS := [
	"title",
	"core_self",
	"past_pattern",
	"present_tension",
	"future_invitation",
	"advice",
	"keywords",
]

func build_context() -> Dictionary:
	return {
		"onboarding_answers": GameState.onboarding_answers.duplicate(true),
		"selected_cards": GameState.selected_cards.duplicate(true),
		"spread": _build_spread(),
		"inner_space_results": GameState.inner_space_results.duplicate(true),
		"ai_reflections": GameState.ai_reflections.duplicate(true),
		"minigame_results": GameState.minigame_results.duplicate(true),
		"self_fragments": GameState.self_fragments,
		"final_report": GameState.final_report.duplicate(true),
	}

func normalize_report(data: Dictionary) -> Dictionary:
	var report := {}
	for key in REPORT_KEYS:
		if key == "keywords":
			report[key] = _normalize_keywords(data.get(key, []))
		else:
			report[key] = String(data.get(key, "")).strip_edges()
	return report

func build_local_summary(error_message: String) -> Dictionary:
	var spread := _build_spread()
	var past: Dictionary = spread.get("past", {})
	var present: Dictionary = spread.get("present", {})
	var future: Dictionary = spread.get("future", {})
	return {
		"title": "Bản soi chiếu tạm thời",
		"core_self": "AI chưa khả dụng: %s" % error_message,
		"past_pattern": _card_sentence(past, "Quá khứ đang nhắc lại một mô thức quanh"),
		"present_tension": _card_sentence(present, "Hiện tại đang giữ một lực căng quanh"),
		"future_invitation": _card_sentence(future, "Tương lai đang mời Ngài bước tới"),
		"advice": "Giữ lại điều đã học từ ba không gian, rồi thử lại AI khi proxy sẵn sàng.",
		"keywords": _fallback_keywords(),
	}

func _build_spread() -> Dictionary:
	var spread := {}
	for card in GameState.selected_cards:
		var position := String(card.get("position", "")).to_lower()
		if not position.is_empty():
			spread[position] = card.duplicate(true)
	return spread

func _normalize_keywords(value: Variant) -> Array[String]:
	var keywords: Array[String] = []
	if value is Array:
		for item in value:
			var keyword := String(item).strip_edges()
			if not keyword.is_empty():
				keywords.append(keyword)
	elif value is String:
		for item in String(value).split(",", false):
			var keyword := item.strip_edges()
			if not keyword.is_empty():
				keywords.append(keyword)
	while keywords.size() > 3:
		keywords.pop_back()
	while keywords.size() < 3:
		keywords.append("Soi chiếu")
	return keywords

func _fallback_keywords() -> Array[String]:
	var keywords: Array[String] = []
	for card in GameState.selected_cards:
		var card_keywords: Variant = card.get("keywords", [])
		if card_keywords is Array:
			for keyword in card_keywords:
				var text := String(keyword).strip_edges()
				if not text.is_empty() and not keywords.has(text):
					keywords.append(text)
				if keywords.size() == 3:
					return keywords
	while keywords.size() < 3:
		keywords.append("Soi chiếu")
	return keywords

func _card_sentence(card: Dictionary, prefix: String) -> String:
	if card.is_empty():
		return "%s hành trình chưa hoàn tất." % prefix
	return "%s %s." % [prefix, String(card.get("name", "lá bài chưa rõ"))]
