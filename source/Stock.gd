extends Area2D

const Utils = preload("Utils.gd")

var m_game
var m_solitaire
var m_down_cards
var m_deck
var m_animated_card
var m_current_card_index

func initialize(game, deck, jokers):
	m_game = game
	m_solitaire = m_game.m_solitaire
	m_deck = deck # print(m_deck)
	
	for i in range(jokers): # add jokers
		m_deck.append(52)
	m_deck.shuffle()
	
	if m_down_cards == null:
		m_down_cards = $Deck.get_children()
	if m_animated_card != null:
		m_animated_card.queue_free()
	m_current_card_index = -1

func _mouse_enter():
	if m_deck.size() <= 0:
		$Halo.visible = false
		return
	$Halo.visible = true

func _mouse_exit():
	$Halo.visible = false

func move_card_to_current(card):
	m_current_card_index = card.m_index
	var animated_card_scene = load("res://scenes/AnimatedCard.tscn")
	var falling_card = animated_card_scene.instance()
	falling_card.update_sprite(card.m_index)
	m_animated_card.add_child(falling_card)
	falling_card.add_to_group("animated_cards")
	falling_card.scale = Vector2(1,1)
	falling_card.set_global_position(card.get_global_position())
	var end_pos = Vector2(0, 0)
	falling_card.animate_move(end_pos, 0.3, 0)
	falling_card.animate_rotate_full(1, 0.3, 0)
	falling_card.animate_scale_bump(0.3)
	falling_card.z_index += 10
	Utils.play_sound(falling_card.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction5.wav', -15)

func draw_card():	
	if m_deck.size() > 0:
		if m_solitaire.m_combo >= m_solitaire.m_combo_threshold:
			m_game.m_camera.small_shake()
		
		var save_source = load("res://source/MoveRecord.gd")
		var save_data = save_source.new()
		save_data.m_level_points = m_solitaire.m_level_points
		save_data.m_combo = m_solitaire.m_combo
		save_data.m_max_combo = m_solitaire.m_max_combo
		save_data.m_current_card_index = m_current_card_index

		m_solitaire.hide_combo()
		m_solitaire.move_made()
		m_current_card_index = m_deck.pop_back()
		
		save_data.m_drawed_card_index = m_current_card_index
		m_solitaire.m_history.push_back(save_data)
		
		# current fall
		if m_animated_card != null:
			var end_pos = m_animated_card.position + Vector2(50, 0)
			end_pos.y = get_viewport_rect().size.y + 50
			m_animated_card.animate_move(end_pos, 0.5, 0)
			m_animated_card.animate_rotate_full(1, 0.5, 0)
			m_animated_card.delayed_destruction(1)
		# show new
		var animated_card_scene = load("res://scenes/AnimatedCard.tscn")
		m_animated_card = animated_card_scene.instance()
		$Deck.add_child(m_animated_card)
		m_animated_card.position = $Deck.position
		m_animated_card.animate_move($CardUpPos.position, 0.3, 0)
		m_animated_card.animate_flip_up(0.3, m_current_card_index)
		Utils.play_sound(m_animated_card.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction22.wav', 0)
		
		update_down_cards()
		
		if m_deck.size() == 0:
			$Halo.visible = false
			get_node("../Buttons/EndTurn").initialize(m_game, true)

func update_down_cards():
	for i in range(0, m_down_cards.size()):
			if i < m_deck.size():
				m_down_cards[m_down_cards.size()-i-1].visible = true
			else:
				m_down_cards[m_down_cards.size()-i-1].visible = false

func _input_event(viewport, event, shape_idx):
	if m_game != null and m_game.m_input_owner != Utils.InputOwner.Gameplay:
		return
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		m_solitaire.on_stock_clicked()
