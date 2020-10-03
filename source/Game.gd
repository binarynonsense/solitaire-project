extends Node2D
const Utils = preload("Utils.gd")

var m_cursor_0
var m_input_owner = Utils.InputOwner.Gameplay

var m_solitaire
var m_menu
var m_camera

var m_particles_type

var m_current_level_path
var m_difficulty

var m_matches_played

func _ready():
	VisualServer.set_default_clear_color(Color( 6.0/255.0, 41.0/255.0, 95.0/255.0, 1 ))#(Color( 71.0/255.0, 45.0/255.0, 60.0/255.0, 1 )) #(Color.black)#(Color( 0.58, 0, 0.83, 1 )) #(Color.darkviolet)
	get_tree().get_root().connect("size_changed", self, "on_resize")
	m_cursor_0 = load("res://images/cursor_white_al.png")
	Input.set_custom_mouse_cursor(m_cursor_0)
	
	var env = OS.get_name() # "Android", "BlackBerry 10", "Flash", "Haiku", "iOS", "HTML5", "OSX", "Server", "Windows", "WinRT", "X11"
	if env != "HTML5" and OS.is_debug_build() != true:
		OS.window_fullscreen = true
	
	var anim =  $Pivot2D/Background/ColorRect/AnimationPlayer.get_animation("color")
	anim.set_loop(true)
	$Pivot2D/Background/ColorRect/AnimationPlayer.play("color")
	
	if env == "Android" || OS.get_current_video_driver() == 1: # VIDEO_DRIVER_GLES2
		m_particles_type = Utils.ParticlesType.CPU
	else: # VIDEO_DRIVER_GLES3
		m_particles_type = Utils.ParticlesType.GPU
	update_particles()
	
	m_solitaire = $Pivot2D/Solitaire
	m_menu = $Pivot2D/Menu
	m_camera = $Camera2D
	
	m_matches_played = 0
	
	m_difficulty = Utils.Difficulty.Random
	m_current_level_path = "res://scenes/layouts/Layout_0.tscn"
#	m_current_level_path = "res://scenes/layouts/Level_1.tscn"
#	m_menu.menu_show(self)
	m_solitaire.initialize(self, m_current_level_path, Utils.Difficulty.Easy)

func update_particles():
	if m_particles_type == Utils.ParticlesType.CPU:
		$Pivot2D/Background/SnowParticles2DCPU.visible = true
		$Pivot2D/Background/SnowParticles2D.visible = false
	elif m_particles_type == Utils.ParticlesType.GPU:
		$Pivot2D/Background/SnowParticles2DCPU.visible = false
		$Pivot2D/Background/SnowParticles2D.visible = true
	else:
		$Pivot2D/Background/SnowParticles2DCPU.visible = false
		$Pivot2D/Background/SnowParticles2D.visible = false

func on_resize():
	print("Resizing: ", get_viewport_rect().size)
	$Pivot2D.position = get_viewport_rect().size / 2

#func solitaire_restart():
#	yield(m_solitaire.initialize(self, m_current_level_path), "completed")

func solitaire_next_match():
	m_matches_played += 1
	
	if m_matches_played < 3:
		m_current_level_path = "res://scenes/layouts/Layout_0.tscn"
	elif m_matches_played == 3:
		m_current_level_path = "res://scenes/layouts/Layout_1.tscn"
	else:
		var num = randi() % 2
		m_current_level_path = "res://scenes/layouts/Layout_" + str(num) + ".tscn"
		
	yield(m_solitaire.initialize(self, m_current_level_path, m_difficulty), "completed")
