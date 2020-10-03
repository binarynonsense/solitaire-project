tool
extends Area2D
const Utils = preload("Utils.gd")

export(int) var m_sprite_index = 0 setget set_sprite_index
export(String) var m_id setget set_id

var m_game
var m_solitaire

var m_mouse_is_over = false
var m_is_clickable = true

var m_tooltip

func initialize(game, is_clickable, tooltip = ""):
	m_game = game
	m_solitaire = m_game.m_solitaire
	if tooltip != "":
		m_tooltip = tooltip
	
	update_clickable(is_clickable)

func update_clickable(is_clickable):
	m_is_clickable = is_clickable
	if m_is_clickable:
		modulate = Color(1, 1, 1, 1)
		if m_mouse_is_over:
			_mouse_enter()
	else:
		modulate = Color(1, 1, 1, 0.2)
		if m_mouse_is_over:
			_mouse_exit()

func set_id(value):
	m_id = value

func set_sprite_index(value):
	m_sprite_index = value
	update_sprite()

func update_sprite():
	$Sprite.frame = m_sprite_index

func _input_event(viewport, event, shape_idx):
	if m_game != null and m_game.m_input_owner != Utils.InputOwner.Gameplay:
		return
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func _mouse_enter():
	m_mouse_is_over = true
	if m_is_clickable:
		$Halo.visible = true
		m_solitaire.show_tooltip(m_tooltip, self)

func _mouse_exit():
	m_mouse_is_over = false
	$Halo.visible = false
	m_solitaire.hide_tooltip(self)

func on_click():
	if !m_is_clickable:
		return
	if m_game == null:
		m_game = get_tree().get_root().get_node("Game")
	m_solitaire.on_button_clicked(self)
	if !$Tween.is_active():
		Utils.tween_scale_bump($Tween, self, 1.15, 0.25, 0)
