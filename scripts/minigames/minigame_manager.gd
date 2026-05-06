extends Node

const CardModelScript := preload("res://scripts/minigames/card_model.gd")

const POSITION_MODES := {
	"past": "twenty_one_confession",
	"present": "present_poker",
	"future": "higher_lower",
}

func create_game(card: Dictionary) -> Dictionary:
	var position := String(card.get("position", "")).to_lower()
	var mode := String(POSITION_MODES.get(position, "higher_lower"))
	match mode:
		"twenty_one_confession":
			return _create_twenty_one_confession(card)
		"present_poker":
			return _create_present_poker(card)
		"poker": # Fallback
			return _create_present_poker(card)
		_:
			return _create_higher_lower(card)

func resolve_action(game: Dictionary, action: String) -> Dictionary:
	match String(game.get("mode", "")):
		"twenty_one_confession":
			return _resolve_twenty_one_confession(game, action)
		"present_poker":
			return _resolve_present_poker(game, action)
		"poker": # Fallback
			return _resolve_present_poker(game, action)
		_:
			return _resolve_higher_lower(game, action)

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

func _create_twenty_one_confession(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var player_hand: Array[Dictionary] = deck.draw(2)
	return {
		"mode": "twenty_one_confession",
		"title": "Hai Mươi Mốt Lời Thú Nhận",
		"goal": "Mỗi lá rút thêm là một ký ức được đào sâu. Đến gần 21 để hiểu nó, nhưng vượt quá 21 nghĩa là bị quá khứ nhấn chìm.",
		"card": card.duplicate(true),
		"deck": deck.cards.duplicate(true),
		"player_hand": player_hand,
		"burn_count": 3,
		"burn_used": false,
		"ended": false,
		"ended_by": "",
		"busted": false,
		"soul_fragments": 0,
		"soul_fragment_events": [],
		"cards_drawn": 2,
		"final_total": CardModelScript.calculate_blackjack_total(player_hand),
		"actions": ["Rút thêm", "Dừng lại", "Đốt lá cao nhất (3)"],
		"status": "playing",
	}

func _resolve_twenty_one_confession(game: Dictionary, action: String) -> Dictionary:
	if game.get("ended", false):
		return game
		
	var player_hand: Array = game.get("player_hand", [])
	var deck_cards: Array = game.get("deck", [])
	
	match action:
		"Rút thêm":
			if not deck_cards.is_empty():
				player_hand.append(deck_cards.pop_front())
				game["player_hand"] = player_hand
				game["deck"] = deck_cards
				game["cards_drawn"] = int(game.get("cards_drawn", 0)) + 1
				var total := CardModelScript.calculate_blackjack_total(player_hand)
				game["final_total"] = total
				if total > 21:
					game["ended"] = true
					game["ended_by"] = "bust"
					return _calculate_twenty_one_confession_result(game)
				elif player_hand.size() >= 5 and total <= 21:
					game["ended"] = true
					game["ended_by"] = "ngu_linh"
					return _calculate_twenty_one_confession_result(game)
			else:
				game["ended"] = true
				game["ended_by"] = "deck_empty"
				return _calculate_twenty_one_confession_result(game)
				
		"Dừng lại":
			game["ended"] = true
			game["ended_by"] = "stand"
			return _calculate_twenty_one_confession_result(game)
			
		"Đốt lá cao nhất (3)", "Đốt lá cao nhất (2)", "Đốt lá cao nhất (1)":
			var burn_count: int = game.get("burn_count", 0)
			if burn_count > 0 and player_hand.size() >= 2:
				var highest_idx := -1
				var highest_val := -1
				for i in player_hand.size():
					var card_val := int(player_hand[i].get("value", 0))
					if card_val > highest_val:
						highest_val = card_val
						highest_idx = i
				if highest_idx != -1:
					player_hand.remove_at(highest_idx)
					game["player_hand"] = player_hand
					game["burn_count"] = burn_count - 1
					game["burn_used"] = true
					game["final_total"] = CardModelScript.calculate_blackjack_total(player_hand)
					
					var next_burn_count = burn_count - 1
					if next_burn_count > 0:
						game["actions"] = ["Rút thêm", "Dừng lại", "Đốt lá cao nhất (%d)" % next_burn_count]
					else:
						game["actions"] = ["Rút thêm", "Dừng lại"]
			
	game["detail"] = "Tổng hiện tại: %d. Chuỗi ký ức đang dần hiện rõ..." % game["final_total"]
	game["status"] = "playing"
	return game

func _calculate_twenty_one_confession_result(game: Dictionary) -> Dictionary:
	var total := int(game.get("final_total", 0))
	var ended_by := String(game.get("ended_by", ""))
	var burn_used := bool(game.get("burn_used", false))
	var fragments := 0
	var detail := ""
	var events := []
	
	if ended_by == "stand" or ended_by == "deck_empty":
		if total == 21: fragments = 10
		elif total >= 18: fragments = 7
		elif total >= 15: fragments = 4
		elif total >= 11: fragments = 2
		else: fragments = 1
		detail = "Ngài chọn giữ phần ký ức đã hiểu (%d)." % total
		events.append({"amount": fragments, "reason": "stand_score", "label": "Thấu hiểu ký ức (%d)" % total, "tags": ["performance"]})
	elif ended_by == "bust":
		if total <= 24: fragments = 3
		elif total <= 27: fragments = 2
		else: fragments = 1
		detail = "Ký ức vượt quá sức chứa (%d)." % total
		game["busted"] = true
		events.append({"amount": fragments, "reason": "bust_score", "label": "Ký ức quá tải (%d)" % total, "tags": ["risk"]})
	elif ended_by == "ngu_linh":
		fragments = 15
		detail = "Ngũ Linh! Ngài đã chứa trọn 5 mảnh ký ức mà không bị quá tải."
		events.append({"amount": fragments, "reason": "ngu_linh", "label": "Ngũ Linh (%d)" % total, "tags": ["performance", "ngu_linh"]})
	
	if burn_used and not game.get("busted", false):
		fragments += 2
		detail += " Sự buông bỏ mang lại thanh thản."
		events.append({"amount": 2, "reason": "burn_bonus", "label": "Buông bỏ thành công", "tags": ["bonus", "release"]})
		
	game["soul_fragments"] = fragments
	game["soul_fragment_events"] = events
	
	var risk = game.get("risk_profile", "cautious")
	var cards_drawn = int(game.get("cards_drawn", 0))
	var busted = bool(game.get("busted", false))
	
	var metrics = {
		"final_total": total,
		"burn_used": burn_used,
		"cards_drawn": cards_drawn,
		"busted": busted
	}
	
	return _build_standard_result(game, "past", fragments, events, risk, [risk], detail, metrics)

func _create_blackjack(card: Dictionary) -> Dictionary:
	# Keep as internal helper if needed, but not exposed to Past position
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

func _create_present_poker(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var hole_cards: Array[Dictionary] = deck.draw(2)
	return {
		"mode": "present_poker",
		"title": "Poker của Hiện Tại",
		"goal": "Hai lá trên tay là phần Ngài đang giữ. Ngài có thể đổi một phần của mình khi hoàn cảnh mới mở ra.",
		"card": card.duplicate(true),
		"deck": deck.cards.duplicate(true),
		"hole_cards": hole_cards,
		"community_cards": [],
		"stage": "pre_flop",
		"decision_index": 0,
		"swap_history": [],
		"swaps_used": 0,
		"ended": false,
		"actions": ["Đổi lá trái", "Đổi lá phải", "Không đổi"],
		"status": "playing",
	}

func _resolve_present_poker(game: Dictionary, action: String) -> Dictionary:
	if game.get("ended", false):
		return game
		
	var deck_cards: Array = game.get("deck", [])
	var hole_cards: Array = game.get("hole_cards", [])
	var community_cards: Array = game.get("community_cards", [])
	var stage: String = game.get("stage", "pre_flop")
	var decision_index: int = game.get("decision_index", 0)
	var swaps_used: int = game.get("swaps_used", 0)
	var swap_history: Array = game.get("swap_history", [])
	
	var action_key := ""
	match action:
		"Đổi lá trái": action_key = "swap_left"
		"Đổi lá phải": action_key = "swap_right"
		"Không đổi": action_key = "keep"
		_: action_key = action # Handle direct keys if any
		
	var discarded: Dictionary = {}
	var new_card: Dictionary = {}
	
	if (action_key == "swap_left" or action_key == "swap_right") and stage != "river":
		var idx := 0 if action_key == "swap_left" else 1
		if not deck_cards.is_empty():
			discarded = hole_cards[idx].duplicate(true)
			new_card = deck_cards.pop_front()
			hole_cards[idx] = new_card
			swaps_used += 1
			
	swap_history.append({
		"decision": decision_index,
		"stage": stage,
		"action": action_key,
		"discarded_card": discarded,
		"new_card": new_card
	})
	
	# Advance stage
	match stage:
		"pre_flop":
			for i in 3:
				if not deck_cards.is_empty():
					community_cards.append(deck_cards.pop_front())
			game["stage"] = "flop"
			game["actions"] = ["Đổi lá trái", "Đổi lá phải", "Không đổi"]
		"flop":
			if not deck_cards.is_empty():
				community_cards.append(deck_cards.pop_front())
			game["stage"] = "turn"
			game["actions"] = ["Đổi lá trái", "Đổi lá phải", "Không đổi"]
		"turn":
			if not deck_cards.is_empty():
				community_cards.append(deck_cards.pop_front())
			game["stage"] = "river"
			game["actions"] = ["Xem kết quả"]
		"river":
			game["ended"] = true
			
	game["deck"] = deck_cards
	game["hole_cards"] = hole_cards
	game["community_cards"] = community_cards
	game["decision_index"] = decision_index + 1
	game["swaps_used"] = swaps_used
	game["swap_history"] = swap_history
	
	if game["ended"]:
		return _calculate_present_poker_result(game)
		
	if game["stage"] == "river":
		game["detail"] = "Giai đoạn: River. 5 lá bài chung đã mở. Hãy xem kết quả!"
	else:
		game["detail"] = "Giai đoạn: %s. Ngài muốn đổi một lá hay giữ nguyên?" % _poker_stage_label(game["stage"])
	return game

func _poker_stage_label(stage: String) -> String:
	match stage:
		"pre_flop": return "Trước Flop"
		"flop": return "Flop (3 lá chung)"
		"turn": return "Turn (4 lá chung)"
		"river": return "River (5 lá chung)"
	return stage

func _calculate_present_poker_result(game: Dictionary) -> Dictionary:
	var hole_cards: Array = game.get("hole_cards", [])
	var community_cards: Array = game.get("community_cards", [])
	var all_cards = hole_cards + community_cards
	
	var eval := _evaluate_poker_7_cards(all_cards)
	var rank_val: int = eval["rank"]
	var rank_key: String = eval["rank_key"]
	var rank_label: String = eval["label"]
	
	var fragments := 0
	match rank_key:
		"royal_flush": fragments = 30
		"straight_flush": fragments = 24
		"four_kind": fragments = 20
		"full_house": fragments = 16
		"flush": fragments = 12
		"straight": fragments = 10
		"three_kind": fragments = 8
		"two_pair": fragments = 6
		"one_pair": fragments = 4
		_: fragments = 2
		
	var swaps_used: int = game.get("swaps_used", 0)
	var bonus = 0
	if swaps_used == 0 and rank_val >= 5: # straight or better
		bonus = 2
		fragments += bonus
		
	var events := [{
		"amount": fragments - bonus,
		"reason": "poker_hand",
		"label": "Tay bài %s" % rank_label,
		"tags": [rank_key]
	}]
	if bonus > 0:
		events.append({"amount": bonus, "reason": "no_swap_bonus", "label": "Kiên định (+2)", "tags": ["bonus", "stable"]})
		
	game["soul_fragments"] = fragments
	game["soul_fragment_events"] = events
	
	var profile = game.get("present_profile", "adaptive")
	var metrics = {
		"hand_rank": rank_key,
		"hand_rank_label": rank_label,
		"swaps_used": swaps_used
	}
	
	return _build_standard_result(game, "present", fragments, events, profile, [profile, rank_key], "Kết quả: %s." % rank_label, metrics)

func _poker_profile_label(profile: String) -> String:
	match profile:
		"fortunate": return "gặp được một vận may lớn"
		"stable": return "giữ vững bản tâm trong hiện tại"
		"restless": return "không ngừng thay đổi lựa chọn"
		"scattered": return "thấy hiện tại thật rời rạc"
		"adaptive": return "thích nghi với hoàn cảnh"
	return "đi qua hiện tại"

func _evaluate_poker_7_cards(cards: Array) -> Dictionary:
	var best_rank := -1
	var best_label := ""
	var best_hand: Array = []
	
	# 7 choose 5 combinations (21 total)
	for i in range(0, 3):
		for j in range(i + 1, 4):
			for k in range(j + 1, 5):
				for l in range(k + 1, 6):
					for m in range(l + 1, 7):
						var combo = [cards[i], cards[j], cards[k], cards[l], cards[m]]
						var eval := _evaluate_poker_5_cards(combo)
						if eval["rank"] > best_rank:
							best_rank = eval["rank"]
							best_label = eval["label"]
							best_hand = combo
							
	return {
		"rank": best_rank,
		"rank_key": _poker_rank_key(best_rank),
		"label": best_label,
		"hand": best_hand
	}

func _evaluate_poker_5_cards(hand: Array) -> Dictionary:
	var ranks: Array[int] = []
	var suits: Array[String] = []
	for card in hand:
		var val = int(card.get("value", 0))
		if val == 1: val = 14 # Ace high
		ranks.append(val)
		suits.append(String(card.get("suit", "")))
	
	ranks.sort()
	
	var is_flush := true
	var first_suit := suits[0]
	for s in suits:
		if s != first_suit:
			is_flush = false
			break
			
	var is_straight := false
	if ranks[4] - ranks[0] == 4 and _count_unique(ranks) == 5:
		is_straight = true
	elif ranks == [2, 3, 4, 5, 14]: # Low Ace
		is_straight = true
		
	var counts := {}
	for r in ranks:
		counts[r] = int(counts.get(r, 0)) + 1
	var c_vals := counts.values()
	c_vals.sort()
	
	if is_flush and is_straight:
		if ranks[0] == 10: return {"rank": 10, "label": "Royal Flush"}
		return {"rank": 9, "label": "Straight Flush"}
	
	if c_vals == [1, 4]: return {"rank": 8, "label": "Four of a Kind"}
	if c_vals == [2, 3]: return {"rank": 7, "label": "Full House"}
	if is_flush: return {"rank": 6, "label": "Flush"}
	if is_straight: return {"rank": 5, "label": "Straight"}
	if c_vals == [1, 1, 3]: return {"rank": 4, "label": "Three of a Kind"}
	if c_vals == [1, 2, 2]: return {"rank": 3, "label": "Two Pair"}
	if c_vals == [1, 1, 1, 2]: return {"rank": 2, "label": "One Pair"}
	return {"rank": 1, "label": "High Card"}

func _count_unique(arr: Array) -> int:
	var unique := {}
	for x in arr:
		unique[x] = true
	return unique.size()

func _poker_rank_key(val: int) -> String:
	match val:
		10: return "royal_flush"
		9: return "straight_flush"
		8: return "four_kind"
		7: return "full_house"
		6: return "flush"
		5: return "straight"
		4: return "three_kind"
		3: return "two_pair"
		2: return "one_pair"
		_: return "high_card"

func _create_poker(card: Dictionary) -> Dictionary:
	# Legacy fallback
	return _create_present_poker(card)

func _resolve_poker(game: Dictionary, action: String) -> Dictionary:
	# Legacy fallback
	return _resolve_present_poker(game, action)

func _create_higher_lower(card: Dictionary) -> Dictionary:
	var deck := _create_deck()
	var current_card: Dictionary = deck.draw(1)[0]
	return {
		"mode": "higher_lower",
		"title": "Dự đoán lá kế",
		"goal": "Lá tiếp theo sẽ cao hay thấp hơn lá hiện tại?",
		"card": card.duplicate(true),
		"deck": deck.cards.duplicate(true),
		"current_card": current_card,
		"last_drawn_card": {},
		"last_choice": "",
		"last_result": "",
		"correct_guesses": 0,
		"wrong_guesses": 0,
		"ties": 0,
		"current_streak": 0,
		"best_streak": 0,
		"cards_seen": 1,
		"soul_fragments": 0,
		"soul_fragment_events": [],
		"ended": false,
		"ended_by": "",
		"perfect_run": false,
		"actions": ["Cao hơn", "Thấp hơn", "Dừng và giữ mảnh hồn"],
		"status": "playing",
	}

func _get_higher_lower_rank(card: Dictionary) -> int:
	if not card or not card.has("value"): return 0
	var value := int(card.get("value", 0))
	if value == 1: return 14 # Ace high
	return value

func _resolve_higher_lower(game: Dictionary, action: String) -> Dictionary:
	var deck_cards: Array = game.get("deck", [])
	var current_card: Dictionary = game.get("current_card", {})
	var current_rank := _get_higher_lower_rank(current_card)
	
	if action == "Dừng và giữ mảnh hồn":
		game["ended"] = true
		game["ended_by"] = "stopped"
		return _build_higher_lower_result(game)
		
	if deck_cards.is_empty():
		game["ended"] = true
		game["ended_by"] = "deck_complete"
		game["perfect_run"] = true
		return _build_higher_lower_result(game)
		
	var next_card: Dictionary = deck_cards.pop_front()
	var next_rank := _get_higher_lower_rank(next_card)
	
	game["cards_seen"] += 1
	game["last_drawn_card"] = game["current_card"].duplicate(true)
	game["last_choice"] = "higher" if action == "Cao hơn" else "lower"
	
	var is_higher = next_rank > current_rank
	var is_lower = next_rank < current_rank
	var is_tie = next_rank == current_rank
	
	if is_tie:
		game["ties"] += 1
		game["last_result"] = "tie"
	elif (action == "Cao hơn" and is_higher) or (action == "Thấp hơn" and is_lower):
		game["correct_guesses"] += 1
		game["current_streak"] += 1
		if game["current_streak"] > game["best_streak"]:
			game["best_streak"] = game["current_streak"]
		game["last_result"] = "correct"
		
		var fragments_gained = 1
		if game["current_streak"] % 10 == 0:
			fragments_gained += 5
		elif game["current_streak"] % 5 == 0:
			fragments_gained += 2
		game["soul_fragments"] += fragments_gained
		game["soul_fragment_events"].append({"amount": fragments_gained, "reason": "correct_guess", "label": "Đoán đúng (+%d)" % fragments_gained, "tags": ["future"]})
	else:
		game["wrong_guesses"] += 1
		game["current_streak"] = 0
		game["last_result"] = "wrong"
		game["ended"] = true
		game["ended_by"] = "wrong_guess"
		
	game["current_card"] = next_card
	game["deck"] = deck_cards
	
	if not game["ended"] and deck_cards.is_empty():
		game["ended"] = true
		game["ended_by"] = "deck_complete"
		game["perfect_run"] = true
		game["soul_fragments"] += 22
		game["soul_fragment_events"].append({"amount": 22, "reason": "perfect_run", "label": "Hoàn hảo (+22)", "tags": ["bonus", "perfect"]})
		
	if game["ended"]:
		return _build_higher_lower_result(game)
		
	game["detail"] = "Đoán đúng: %d | Chuỗi: %d | Còn lại: %d | Thưởng: %d" % [game["correct_guesses"], game["current_streak"], deck_cards.size(), game.get("soul_fragments", 0)]
	return game

func _build_higher_lower_result(game: Dictionary) -> Dictionary:
	var fragments := int(game.get("soul_fragments", 0))
	var events: Array = game.get("soul_fragment_events", [])
	var ended_by := String(game.get("ended_by", ""))
	var detail := ""
	match ended_by:
		"stopped": detail = "Dừng an toàn."
		"wrong_guess": detail = "Đoán sai!"
		"deck_complete": detail = "Hoàn thành bộ bài!"
	detail += " Nhận %d Mảnh Hồn." % fragments
	
	var perfect = bool(game.get("perfect_run", false))
	var profile = "perfect" if perfect else "standard"
	var metrics = {
		"correct_guesses": game.get("correct_guesses", 0),
		"best_streak": game.get("best_streak", 0),
		"perfect_run": perfect
	}
	
	return _build_standard_result(game, "future", fragments, events, profile, [profile], detail, metrics)

func _build_standard_result(game_state: Dictionary, position: String, fragments: int, events: Array, profile: String, tags: Array, summary: String, metrics: Dictionary) -> Dictionary:
	var result := {
		"mode": String(game_state.get("mode", "")),
		"position": position,
		"soul_fragments": fragments,
		"soul_fragment_events": events,
		"profile": profile,
		"interpretation_tags": tags,
		"ended": true,
		"ended_by": String(game_state.get("ended_by", "")),
		"summary": summary,
		"metrics": metrics,
		"state": game_state.duplicate(true)
	}
	
	# Compatibility for UI and GameState
	result["won"] = fragments > 0
	result["fragments"] = fragments
	result["reward"] = "%d Mảnh Hồn" % fragments
	result["detail"] = summary
	result["status"] = "complete"
	result["title"] = game_state.get("title", "")
	result["goal"] = game_state.get("goal", "")
	
	return result

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
