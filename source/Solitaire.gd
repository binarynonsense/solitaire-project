extends Node2D
const Utils = preload("Utils.gd")

var m_game

var m_level
var m_stock
var m_tooltip
var m_tooltip_owner

var m_level_points = 0
const POINTS_PER_CARD = 3
var m_perfect_reward = 0
const POINTS_PER_PERFECT = 350
var m_combo = 0
var m_max_combo = 1
var m_combo_threshold = 3
var m_undos = 0
var m_max_undos = 0
var m_history
var m_jokers
var m_max_jokers = 3
var m_num_moves = 0

var m_difficulty

func initialize(game, level_path, difficulty):
	m_game = game
	
	m_combo = 0
	m_max_combo = 1
	m_level_points = 0
	m_perfect_reward = 0
	m_undos = 2
	m_max_undos = 2
	m_history = []
	m_jokers = 2
	m_max_jokers = 3
	m_num_moves = -1
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if difficulty == Utils.Difficulty.Random:
		m_difficulty = rng.randi_range(Utils.Difficulty.Easy, Utils.Difficulty.Hard)
	else:
		m_difficulty = difficulty
	
	if m_difficulty == Utils.Difficulty.Easy:
		$UI/LevelInfoLabel.text = "LAYOUT: RANDOM\nDIFFICULTY: EASY"
		m_undos = 2
		m_max_undos = 2
		m_jokers = 2
		m_max_jokers = 2
		m_combo_threshold = 2
	elif m_difficulty == Utils.Difficulty.Medium:
		$UI/LevelInfoLabel.text = "LAYOUT: RANDOM\nDIFFICULTY: MEDIUM"
		m_undos = 1
		m_max_undos = 1
		m_jokers = 1
		m_max_jokers = 2
		m_combo_threshold = 3
	elif m_difficulty == Utils.Difficulty.Hard:
		$UI/LevelInfoLabel.text = "LAYOUT: RANDOM\nDIFFICULTY: HARD"
		m_undos = 1
		m_max_undos = 1
		m_jokers = 1
		m_max_jokers = 1
		m_combo_threshold = 4
	
	show_table()
	
	if m_level != null:
		m_level.queue_free()
	
	randomize()
	var deck = []
	for i in range(52):
		deck.append(i)
	deck.shuffle()

	m_stock = $Stock
	m_tooltip = $Buttons/TooltipLabel
	hide_tooltip(self, true)
	
	var level_scene = load(level_path)
	m_level = level_scene.instance()
	$LevelAnchor.add_child(m_level)
	yield(m_level.randomize_layout(m_difficulty), "completed")
	
	yield(VisualServer, 'frame_post_draw') #initialize calls get_overlapping_areas, so it need one frame
	yield(VisualServer, 'frame_post_draw')
	m_level.initialize(m_game, deck)
	m_stock.initialize(m_game, deck, 0)
	draw_card_from_stock()
	
	update_ui()
	update_buttons()
	
	m_game.m_camera.get_node("Tween").interpolate_property(m_game.m_camera, 'zoom', \
	 Vector2(1,1), Vector2(0.95,0.95), 0.15, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0)
	m_game.m_camera.get_node("Tween").interpolate_property(m_game.m_camera, 'zoom', \
	 Vector2(0.95,0.95), Vector2(1,1), 0.15, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.15)
	m_game.m_camera.get_node("Tween").start()

func on_button_clicked(button):
#	print("button clicked: " + str(button.m_id))
	if button.m_id == "undo":
		undo()
		Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
	elif button.m_id == "joker":
		use_joker()
		Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
	elif button.m_id == "menu":
		m_game.m_menu.menu_show(m_game)
		Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
	elif button.m_id == "end_turn":
		Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
		yield(m_game.solitaire_next_match(), "completed")

func on_card_clicked(card):
	var hand_rank = Utils.get_rank_from_index(m_stock.m_current_card_index)
	var clicked_rank = card.m_rank
	# TODO: joker
	if  Utils.is_valid_rank_match(clicked_rank, hand_rank):
		var save_source = load("res://source/MoveRecord.gd")
		var save_data = save_source.new()
		save_data.m_level_points = m_level_points
		save_data.m_combo = m_combo
		save_data.m_max_combo = m_max_combo
		save_data.m_current_card_index = m_stock.m_current_card_index
		save_data.m_table_card_index = card.m_index
		save_data.m_table_card_z_index = card.z_index
		save_data.m_table_card_position = card.global_position
		m_history.push_back(save_data)
		
		move_made()
		
		var animated_points_scene = load("res://scenes/AnimatedPoints.tscn")
		var m_animated_points = animated_points_scene.instance()
		m_animated_points.initialize(card, POINTS_PER_CARD)
		m_stock.move_card_to_current(card)
		increase_combo()
		increase_points(POINTS_PER_CARD)
		m_level.remove_card(card)
		
		if m_level.m_cards.size() <= 0:
			m_perfect_reward = POINTS_PER_PERFECT
			update_ui()
			hide_after_perfect()
			$PerfectMsg.show(POINTS_PER_PERFECT)

func on_stock_clicked():
	draw_card_from_stock()

func update_ui():
	var total = m_level_points * m_max_combo + m_perfect_reward
	$UI/TopLabels/LabelTotal.text = "SCORE: " + str(total).pad_zeros(3)
	$UI/TopLabels/LabelMultiplier.text = "MULTIPLIER: " + str(m_max_combo).pad_zeros(3)
	$UI/TopLabels/LabelPoints.text = "POINTS: " + str(m_level_points).pad_zeros(3)
	$ComboWindow/Label.text = str(m_combo)

func update_buttons():
	if m_undos > 0 and m_history.size() > 0 and m_num_moves > 0:
		$Buttons/Undo.initialize(m_game, true, "undo")
	else:
		$Buttons/Undo.initialize(m_game, false, "undo")
	if m_jokers > 0:
		$Buttons/Joker.initialize(m_game, true, "use joker")
	else:
		$Buttons/Joker.initialize(m_game, false, "use joker")
	$Buttons/Menu.initialize(m_game, true, "open menu")
	if m_stock.m_deck.size() == 0 || m_level.m_cards.size() == 0:
		$Buttons/EndTurn.initialize(m_game, true, "next match")
	else:
		$Buttons/EndTurn.initialize(m_game, false, "next match")
		
	$Buttons/UndoLabel.text = str(m_undos) + "/ " + str(m_max_undos)
	$Buttons/JokerLabel.text = str(m_jokers) + "/ " + str(m_max_jokers)

func hide_after_perfect():
	$Buttons/Undo.initialize(m_game, false)
	$Buttons/Joker.initialize(m_game, false)
	$Buttons/Menu.initialize(m_game, false)
	$Buttons/EndTurn.initialize(m_game, true)
#	$Buttons.visible = false
	$Stock.visible = false
	$ComboWindow.visible = false
	$ComboWindow.position.y = 790 - 360
	
func show_table():
	$ComboWindow.visible = true
	$PerfectMsg.visible = false
	$Buttons.visible = true
	$Stock.visible = true

func show_tooltip(tooltip, owner):
	m_tooltip.text = tooltip.to_upper()
	m_tooltip.visible = true
	m_tooltip_owner = owner

func hide_tooltip(owner, force = false):
	if force or m_tooltip_owner == owner:
		m_tooltip.text = ""
		m_tooltip.visible = false

func move_made():
	m_num_moves += 1
	update_buttons()

func move_unmade():
	m_num_moves -= 1
	update_buttons()
#	m_game.m_camera.small_shake()

func increase_points(amount):
	m_level_points += amount
	update_ui()

func increase_combo():
	m_combo += 1
	if m_combo > m_max_combo:
		m_max_combo = m_combo
	$ComboWindow/Label.text = str(m_combo)
	if m_combo >= m_combo_threshold:
		var comboContainer = $ComboWindow
		Utils.tween_scale_bump($ComboWindow/Tween, comboContainer, 1.2, 0.2, 0.1)
		if m_combo == m_combo_threshold: #was hidden -> show
			var end_position = comboContainer.position
			end_position.y = 600 - 360
			Utils.tween_move($ComboWindow/Tween, comboContainer, comboContainer.position, end_position, 0.1, 0)
			Utils.play_sound($ComboWindow/AudioSource, "res://sounds/sfx_sounds_fanfare2.wav", -5)
		else:
			var pitch = 1 + (m_combo - m_combo_threshold - 1) * 0.1
			pitch = clamp(pitch, 1, 1.5)
			Utils.play_sound($ComboWindow/AudioSource, "res://sounds/sfx_sounds_fanfare3.wav", -5, pitch)

func restore_combo():
	var comboContainer = $ComboWindow
	var end_position = comboContainer.position
	$ComboWindow/Tween.stop_all()
	if m_combo >= m_combo_threshold:
		end_position.y = 600 - 360
	else:
		end_position.y = 790 - 360
	comboContainer.position = end_position

func hide_combo():
	var comboContainer = $ComboWindow
	var end_position = comboContainer.position
	end_position.y = 790 - 360
	Utils.tween_move($ComboWindow/Tween, comboContainer, comboContainer.position, end_position, 0.1, 0)
	if m_combo >= m_combo_threshold:
		Utils.play_sound($ComboWindow/AudioSource, "res://sounds/sfx_exp_odd7.wav", -5)
	m_combo = 0

func draw_card_from_stock():
	m_stock.draw_card()

func use_joker():
	if m_jokers > 0:
		m_jokers -= 1
		update_buttons()
		
		var save_source = load("res://source/MoveRecord.gd")
		var save_data = save_source.new()
		save_data.m_level_points = m_level_points
		save_data.m_combo = m_combo
		save_data.m_max_combo = m_max_combo
		save_data.m_current_card_index = m_stock.m_current_card_index
		save_data.m_joker_used = true
		m_history.push_back(save_data)
		
		move_made()
		
		m_stock.m_current_card_index = 52 # joker
		m_stock.m_animated_card.update_sprite(52)
		m_stock.m_animated_card.animate_scale_bump(0)
		Utils.play_sound(m_stock.m_animated_card.get_node("AudioSource"), 'res://sounds/sfx_coin_cluster3.wav', -5)
		for i in m_stock.m_animated_card.get_children():
				if i.is_in_group("animated_cards"):
					i.queue_free()

func undo():
#	print(m_history.size())
	if m_undos > 0 and m_history.size() > 0 and m_num_moves > 0:
		m_undos -= 1
		update_buttons()
#		if m_undos == 0:
#			$Buttons/Undo.initialize(m_game, false)
#			$Buttons/UndoLabel.text = str(m_undos) + "/ 1"
#		Utils.play_sound($Buttons/Undo.get_node("AudioSource"), 'res://sounds/sfx_sounds_error8.wav', -10)
		var save_data = m_history.pop_back()
		
		# joker used
		if save_data.m_joker_used == true: 
			m_combo = save_data.m_combo
			restore_combo()
			m_max_combo = save_data.m_max_combo
			m_level_points = save_data.m_level_points
			
			m_stock.m_current_card_index = save_data.m_current_card_index
			m_stock.m_animated_card.update_sprite(save_data.m_current_card_index)
			m_stock.m_animated_card.animate_scale_bump(0)
			Utils.play_sound(m_stock.m_animated_card.get_node("AudioSource"), 'res://sounds/sfx_sound_neutral8.wav', -5)
			for i in m_stock.m_animated_card.get_children():
				if i.is_in_group("animated_cards"):
					i.queue_free()
			
			m_jokers += 1
			update_buttons()
			
			update_ui()
			move_unmade()
			
		# stock draw
		if save_data.m_drawed_card_index >= 0: 
			m_combo = save_data.m_combo
			restore_combo()
			m_max_combo = save_data.m_max_combo
			m_level_points = save_data.m_level_points		
			
			m_stock.m_current_card_index = save_data.m_current_card_index
			m_stock.m_deck.push_back(save_data.m_drawed_card_index)
			m_stock.m_animated_card.update_sprite(save_data.m_current_card_index)
			m_stock.m_animated_card.animate_scale_bump(0)
			Utils.play_sound(m_stock.m_animated_card.get_node("AudioSource"), 'res://sounds/sfx_sound_neutral8.wav', -5)
			m_stock.update_down_cards()
			
			update_ui()
			move_unmade()
			
		# matched card
		elif save_data.m_table_card_index >= 0:
			m_combo = save_data.m_combo
			restore_combo()
			m_max_combo = save_data.m_max_combo
			m_level_points = save_data.m_level_points
			
			m_stock.m_current_card_index = save_data.m_current_card_index
			m_stock.m_animated_card.update_sprite(m_stock.m_current_card_index)
			m_stock.m_animated_card.animate_scale_bump(0)
			Utils.play_sound(m_stock.m_animated_card.get_node("AudioSource"), 'res://sounds/sfx_sound_neutral8.wav', -5)
			for i in m_stock.m_animated_card.get_children():
				if i.is_in_group("animated_cards"):
					i.queue_free()
			
			m_level.add_card(save_data.m_table_card_index, save_data.m_table_card_z_index, save_data.m_table_card_position)
			
			update_ui()
			move_unmade()
