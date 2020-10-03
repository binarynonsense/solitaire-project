extends Node2D
const Utils = preload("Utils.gd")

var m_pivot
var m_is_enabled = false
var m_game

func menu_show(game):
	m_game = game
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_in.wav', -10)
	
	m_pivot.visible = true
	m_is_enabled = true
	var from = Vector2(0, -720)
	var to = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot, from, to, 0.15, 0)

func menu_hide():
	m_is_enabled = false
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_out.wav', -10)
	
	$Tween.stop_all()
	var to = Vector2(0, -720)
	var from = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot, from, to, 0.15, 0)
	yield(get_tree().create_timer(0.15), "timeout")
	m_pivot.visible = false
