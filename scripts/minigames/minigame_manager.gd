extends Node

const CardModelScript := preload("res://scripts/minigames/card_model.gd")

const POSITION_MODES := {
	"past": "blackjack",
	"present": "poker",
	"future": "symbol_match",
}

func create_game(card: Dictionary) -> Dictionary:
	var position := String(card.get("position", "")).to_lower()
	var mode := String(POSITION_MODES.get(position, "symbol_match"))
	match mode:
		"blackjack":
			return _create_blackjack(card)
		"poker":
			return _create_poker(card)
		_:
			return _create_symbol_match(card)

func resolve_action(game: Dictionary, action: String) -> Dictionary:
	match String(game.get("mode", "")):
		"blackjack":
			return _resolve_blackjack(game, action)
		"poker":
			return _resolve_poker(game, action)
		_:
			return _resolve_symbol_match(game, action)

func create_basic_card_game(card: Dictionary) -> Dictionary:
	return create_game(card)

func resolve_choice(choice: String) -> Dictionary:
	return {
		"won": not choice.is_empty(),
		"fragments": 1 if not choice.is_empty() else 0,
		"reward": "Self Fragment",
	}

func _create_deck() -> RefCounted:
	var deck: RefCounted = CardModelScript.new()
	deck.shuffle()
	return deck

func _create_blackjack(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var player_hand: Array[Dictionary] = deck.draw(2)
	var dealer_hand: Array[Dictionary] = deck.draw(2)
	return {
		"mode": "blackjack",
		"title": "Blackjack Nhẹ: Quá khứ",
		"goal": "Dừng gần 21 hơn KÌ, không vượt 21.",
		"card": card.duplicate(true),
		"deck": deck.cards.duplicate(true),
		"player_hand": player_hand,
		"dealer_hand": dealer_hand,
		"actions": ["Rút thêm", "Dừng"],
		"state": "playing",
	}

func _resolve_blackjack(game: Dictionary, action: String) -> Dictionary:
	var player_hand: Array = game.get("player_hand", [])
	var dealer_hand: Array = game.get("dealer_hand", [])
	var deck_cards: Array = game.get("deck", [])
	
	if action == "Rút thêm" and not deck_cards.is_empty():
		_apply_blackjack_hit(game, player_hand, deck_cards)
		if CardModelScript.calculate_blackjack_total(player_hand) <= 21:
			return game
			
	_play_dealer_turn(dealer_hand, deck_cards)
	
	var player_total := CardModelScript.calculate_blackjack_total(player_hand)
	var dealer_total := CardModelScript.calculate_blackjack_total(dealer_hand)
	var won := _is_blackjack_win(player_total, dealer_total)
	
	return _build_result(game, won, 2 if won else 1, "Ngài: %d | KÌ: %d" % [player_total, dealer_total], {
		"player_hand": player_hand,
		"dealer_hand": dealer_hand,
	})

func _apply_blackjack_hit(game: Dictionary, player_hand: Array, deck_cards: Array) -> void:
	player_hand.append(deck_cards.pop_front())
	game["player_hand"] = player_hand
	game["deck"] = deck_cards
	game["detail"] = "Tổng hiện tại: %d. Có thể rút hoặc dừng." % CardModelScript.calculate_blackjack_total(player_hand)
	game["state"] = "playing"

func _play_dealer_turn(dealer_hand: Array, deck_cards: Array) -> void:
	while CardModelScript.calculate_blackjack_total(dealer_hand) < 17 and not deck_cards.is_empty():
		dealer_hand.append(deck_cards.pop_front())

func _is_blackjack_win(player_total: int, dealer_total: int) -> bool:
	return player_total <= 21 and (dealer_total > 21 or player_total >= dealer_total)

func _create_poker(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var player_hand: Array[Dictionary] = deck.draw(5)
	return {
		"mode": "poker",
		"title": "Poker Nhẹ: Hiện tại",
		"goal": "Đoán chất bài xuất hiện nhiều nhất trong tay 5 lá.",
		"card": card.duplicate(true),
		"player_hand": player_hand,
		"actions": ["Chuồn", "Rô", "Cơ", "Bích"],
		"state": "playing",
	}

func _resolve_poker(game: Dictionary, action: String) -> Dictionary:
	var hand: Array = game.get("player_hand", [])
	var suit_counts := {}
	for card in hand:
		var suit := String(card.get("suit", ""))
		suit_counts[suit] = int(suit_counts.get(suit, 0)) + 1
	var best_suit := ""
	var best_count := -1
	for suit in suit_counts.keys():
		var count := int(suit_counts[suit])
		if count > best_count:
			best_suit = String(suit)
			best_count = count
	var best_label: String = _suit_label(best_suit)
	var won: bool = action == best_label
	return _build_result(game, won, 2 if won else 1, "Tay bài: %s. Chất mạnh nhất: %s." % [CardModelScript.labels(hand), best_label])

func _create_symbol_match(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var hand: Array[Dictionary] = deck.draw(4)
	var target_symbol := _target_symbol(card)
	return {
		"mode": "symbol_match",
		"title": "Ghép Biểu Tượng: Tương lai",
		"goal": "Chọn biểu tượng cộng hưởng với lá bài tương lai.",
		"card": card.duplicate(true),
		"player_hand": hand,
		"target_symbol": target_symbol,
		"actions": CardModelScript.SYMBOLS.duplicate(),
		"state": "playing",
	}

func _resolve_symbol_match(game: Dictionary, action: String) -> Dictionary:
	var target_symbol := String(game.get("target_symbol", ""))
	var won := action == target_symbol
	return _build_result(game, won, 2 if won else 1, "Biểu tượng đúng: %s." % target_symbol)

func _target_symbol(card: Dictionary) -> String:
	var symbols: Variant = card.get("symbols", [])
	if symbols is Array and not symbols.is_empty():
		var index: int = abs(String(symbols[0]).hash()) % CardModelScript.SYMBOLS.size()
		return CardModelScript.SYMBOLS[index]
	return CardModelScript.SYMBOLS[0]

func _suit_label(suit: String) -> String:
	match suit:
		"clubs":
			return "Chuồn"
		"diamonds":
			return "Rô"
		"hearts":
			return "Cơ"
		"spades":
			return "Bích"
		_:
			return suit



func _build_result(game: Dictionary, won: bool, fragments: int, detail: String, extra: Dictionary = {}) -> Dictionary:
	var result := game.duplicate(true)
	for key in extra.keys():
		result[key] = extra[key]
	result["won"] = won
	result["fragments"] = fragments
	result["reward"] = "Self Fragment x%d" % fragments
	result["detail"] = detail
	result["state"] = "complete"
	return result
