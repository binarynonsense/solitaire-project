extends Node2D
const Utils = preload("Utils.gd")

var m_cards = []
var m_game

func initialize(game, deck):
	m_game = game
	m_cards = []
	Utils.get_all_children_in_group($Map, "cards", m_cards)
	for card in m_cards:
		card.initialize(game, deck.pop_back())

func remove_card(card):
	# NOTE: I use the z_index of the cards when designing the levels
	# so I can detect the cards that will unlock when the one obstructing
	# them is freed, so it's IMPORTANT that the levels are designed with that in mind
	var obstructed_cards = Utils.get_valid_obstructed_areas(card)
	m_cards.erase(card)
	card.queue_free()
	yield(VisualServer, 'frame_post_draw')
	for area in obstructed_cards:
		if area.is_in_group("cards"):
			if Utils.get_overlapping_areas_above(area).size() <= 0:
				area.show_and_make_clickable()	

func update_clickable():
	m_cards = []
	Utils.get_all_children_in_group($Map, "cards", m_cards)
	for card in m_cards:
		card.check_clickable()

func add_card(index, z_index,  global_position):
	var card_scene = load("res://scenes/Card.tscn")
	var card = card_scene.instance()
	$Map.add_child(card)
	card.global_position = global_position
	card.z_index = z_index
	card.add_to_group("cards")
	card.initialize(m_game, index)
	m_cards.append(card) #not needed? updated in update_clickable?
	card.highlight(true)
	yield(get_tree(), "idle_frame") # so areas are updated in physics
	yield(get_tree(), "idle_frame") # once wasn't always good enough
	update_clickable()

func randomize_layout(difficulty):
	var num_remove = 0
	var face_up_divider = 2
	
	var columns = []
	Utils.get_all_children_in_group($Map, "columns", columns)
	for column in columns:
		var cards = column.get_children()
		var total = cards.size()
		
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		
		if difficulty == Utils.Difficulty.Easy:
			num_remove = rng.randi_range(total/2, total - 1)
			face_up_divider = 2
		elif difficulty == Utils.Difficulty.Medium:
			num_remove = rng.randi_range(total/3, total - 2)
			face_up_divider = 3
		elif difficulty == Utils.Difficulty.Hard:
			num_remove = rng.randi_range(0, total/5)
			face_up_divider = 5
		
		if num_remove > 0:
			for i in range(1, num_remove + 1):
				var card = cards.pop_front()
				card.queue_free()
	
	# yield so cards have time to be freed
	yield(VisualServer, 'frame_post_draw')
	
	var cards = []
	Utils.get_all_children_in_group($Map, "cards", cards)
	cards.shuffle()
	for i in range(0, cards.size()/face_up_divider):
		cards[i].set_face_down(false)
