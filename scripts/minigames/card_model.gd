extends RefCounted
class_name CardModel

const SUITS := ["clubs", "diamonds", "hearts", "spades"]
const SUIT_LABELS := {
	"clubs": "Chuồn",
	"diamonds": "Rô",
	"hearts": "Cơ",
	"spades": "Bích",
}
const SYMBOLS := ["Gương", "Nến", "Chìa khóa", "Ngôi sao"]
const VALUES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
const VALUE_LABELS := {
	1: "A",
	11: "J",
	12: "Q",
	13: "K",
}

var cards: Array[Dictionary] = []

func _init() -> void:
	reset()

func reset() -> void:
	cards = create_deck()

func create_deck() -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	for suit_index in SUITS.size():
		var suit: String = SUITS[suit_index]
		for value in VALUES:
			var rank: String = _rank_for_value(value)
			var image_path := "res://assets/art/Playing-cards/%s_%s.png" % [suit, rank]
			deck.append({
				"suit": suit,
				"suit_label": String(SUIT_LABELS.get(suit, suit)),
				"value": value,
				"rank": rank,
				"symbol": SYMBOLS[suit_index],
				"label": "%s %s" % [String(SUIT_LABELS.get(suit, suit)), rank],
				"image_path": image_path,
				"art_path": image_path,
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

static func get_art_path_for_card(card: Dictionary) -> String:
	var art_path := String(card.get("image_path", card.get("art_path", "")))
	if art_path.is_empty() or not ResourceLoader.exists(art_path):
		return ""
	return art_path

static func suit_action_labels() -> Array:
	return SUIT_LABELS.values()

static func suit_for_label(label: String) -> String:
	for suit in SUITS:
		if String(SUIT_LABELS.get(suit, suit)) == label:
			return suit
	return label

static func _rank_for_value(value: int) -> String:
	return String(VALUE_LABELS.get(value, str(value)))
