extends Area2D
const Utils = preload("Utils.gd")

var m_menu
var m_mouse_is_over = false
var m_is_clickable = true
var m_color_normal = Color(0.8, 0.8, 0.8, 1)
var m_color_highlight = Color(0.3, 0.3, 0.3, 1) #Color(1, 1, 1, 1)

func initialize(title, menu, is_clickable):
	m_menu = menu
	get_parent().text = title
	get_parent().set("custom_colors/font_color", m_color_normal)
	update_clickable(is_clickable)

func update_clickable(is_clickable):
	m_is_clickable = is_clickable
	if m_is_clickable:
		get_parent().visible = true
		if m_mouse_is_over:
			_mouse_enter()
	else:
		get_parent().visible = false
		if m_mouse_is_over:
			_mouse_exit()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click()

func _mouse_enter():
	m_mouse_is_over = true
	if m_is_clickable:
		get_parent().set("custom_colors/font_color", m_color_highlight)

func _mouse_exit():
	m_mouse_is_over = false
	get_parent().set("custom_colors/font_color", m_color_normal)

func on_click():
	if !m_is_clickable:
		return
	get_parent().get_parent().get_parent().get_parent().on_button_click(self)
	if !$Tween.is_active():
		Utils.tween_rect_scale_bump($Tween, get_parent(), 1.1, 0.25, 0)
