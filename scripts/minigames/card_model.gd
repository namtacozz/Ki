extends RefCounted
class_name CardModel

const SUITS := ["Wands", "Cups", "Swords", "Pentacles"]
const SYMBOLS := ["Gương", "Nến", "Chìa khóa", "Ngôi sao"]
const VALUES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

var cards: Array[Dictionary] = []

func _init() -> void:
	reset()

func reset() -> void:
	cards = create_deck()

func create_deck() -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	for suit_index in SUITS.size():
		for value in VALUES:
			deck.append({
				"suit": SUITS[suit_index],
				"value": value,
				"symbol": SYMBOLS[suit_index],
				"label": "%s %d" % [SUITS[suit_index], value],
			})
	return deck

func shuffle() -> void:
	cards.shuffle()

func draw(count: int = 1) -> Array[Dictionary]:
	var drawn: Array[Dictionary] = []
	for _i in count:
		if cards.is_empty():
			break
		drawn.append(cards.pop_front())
	return drawn

func remaining() -> int:
	return cards.size()

static func card_points(card: Dictionary) -> int:
	return min(int(card.get("value", 0)), 10)

static func labels(hand: Array) -> String:
	var names: Array[String] = []
	for card in hand:
		if card is Dictionary:
			names.append(String(card.get("label", "")))
	return ", ".join(names)
