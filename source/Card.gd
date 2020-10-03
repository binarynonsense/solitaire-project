tool
extends Area2D

const Utils = preload("Utils.gd")

export(bool) var m_is_face_down = true setget set_face_down
var m_index = 54
#export(bool) var m_is_clickable = false setget editor_set_clickable
var m_is_clickable = false
export(int, 1, 13) var m_rank = 1 setget set_rank
export(int, 0, 3) var m_suit = 0 setget set_suit

var m_game
var m_solitaire

var m_mouse_is_over = false

func initialize(game, index):
	m_game = game
	m_solitaire = m_game.m_solitaire
	
	m_index = index
	m_rank = Utils.get_rank_from_index(m_index)
	check_clickable()
	update_sprite()

#func hide():
#	self.visible = false
#	$CollisionShape2D.disabled = true
#
#func restore():
#	self.visible = true
#	$CollisionShape2D.disabled = false

func set_face_down(value):
	m_is_face_down = value
	if Engine.is_editor_hint():
		print("editor_set_face_down called")
		
		update_sprite()

func set_rank(value):
	m_rank = value
	if Engine.is_editor_hint():
		m_index = Utils.get_index_from_rank_and_suit(m_rank, m_suit)
		update_sprite()
		
func set_suit(value):
	m_suit = value
	if Engine.is_editor_hint():
		m_index = Utils.get_index_from_rank_and_suit(m_rank, m_suit)
		update_sprite()

func check_clickable():
	if self.visible == false:
		update_clickable(false)
	if Utils.get_overlapping_areas_above(self).size() > 0:
		update_clickable(false)
#		m_is_face_down = true
	else:
		update_clickable(true)
		m_is_face_down = false

func update_clickable(is_clickable):
	if is_clickable:
		m_is_clickable = true
#		$CollisionShape2D.disabled = false
	else:
		m_is_clickable = false
#		$CollisionShape2D.disabled = true

func update_sprite():
	if m_is_face_down:
		$Sprite.frame = 53
	else:
		$Sprite.frame = m_index

func show_and_make_clickable():
	yield(VisualServer, 'frame_post_draw') # to avoid clicking card just activated #yield(get_tree(), "physics_frame")
	update_clickable(true)
	if m_is_face_down:
		m_is_face_down = false
		highlight(false)
		update_sprite()
	if m_mouse_is_over:
		_mouse_enter()

func highlight(play_sound):
	Utils.tween_scale_bump($Tween, self, 1.2, 0.2, 0)
	if play_sound:
		Utils.play_sound($AudioSource, 'res://sounds/sfx_sound_neutral8.wav', -5)

func _input_event(viewport, event, shape_idx):
	if m_game != null and m_game.m_input_owner != Utils.InputOwner.Gameplay:
		return
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func _mouse_enter():
	m_mouse_is_over = true
	if m_solitaire == null:
		 return
	var hand_rank = Utils.get_rank_from_index(m_solitaire.m_stock.m_current_card_index)
	if m_is_clickable && Utils.is_valid_rank_match(m_rank, hand_rank):
		$Halo.visible = true

func _mouse_exit():
	m_mouse_is_over = false
	$Halo.visible = false

func on_click():
	if !m_is_clickable:
		return
	m_solitaire.on_card_clicked(self)
	
