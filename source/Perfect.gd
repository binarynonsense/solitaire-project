extends Node
const Utils = preload("Utils.gd")

onready var m_tween = $Tween
onready var m_msg = "PERFECT"

const m_total_time = 0.7

func _ready():
	self.visible = false
	$RichTextLabel.text = ""

func show(points):
	self.visible = true
	$RichTextLabel.text = ""
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_powerup16.wav', -10)
	
	yield(reveal_letter_by_letter(m_msg), "completed")
		
	Utils.tween_scale_bump(m_tween, self, 1.15, 0.2, 0)
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_powerup4.wav', -5)
	
	var animated_points_scene = load("res://scenes/AnimatedPoints.tscn")
	var m_animated_points = animated_points_scene.instance()
	m_animated_points.initialize(self, points)
	
	var game = get_tree().get_root().get_node("Game")
	game.m_camera.small_shake()
	if game.m_particles_type == Utils.ParticlesType.CPU:
		$Particles2DCPU.visible = true
		$Particles2DCPU.emitting = true
		$Particles2D2CPU.visible = true
		$Particles2D2CPU.emitting = true
	elif game.m_particles_type == Utils.ParticlesType.GPU:
		$Particles2D.visible = true
		$Particles2D.emitting = true
		$Particles2D2.visible = true
		$Particles2D2.emitting = true

func reveal_letter_by_letter(string):
	for letter in string:
		yield(get_tree().create_timer(m_total_time/m_msg.length()), "timeout")
		$RichTextLabel.add_text(letter)
