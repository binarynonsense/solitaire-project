extends Node2D
const Utils = preload("Utils.gd")

onready var m_pivot_menu = $Main
onready var m_pivot_credits = $Credits
onready var m_pivot_options = $Options

var m_is_enabled = false
var m_game

func menu_show(game):
	m_game = game
	m_game.m_input_owner = Utils.InputOwner.Menu
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_in.wav', -10)
	
	m_pivot_menu.visible = true
	m_is_enabled = true
	var from = Vector2(0, -720)
	var to = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_menu, from, to, 0.15, 0)
	
	var env = OS.get_name() # "Android", "BlackBerry 10", "Flash", "Haiku", "iOS", "HTML5", "OSX", "Server", "Windows", "WinRT", "X11"
	$Main/Buttons.visible = true
	$Main/Buttons/Button_1/Area2D.initialize("> RESUME", self, true)
	$Main/Buttons/Button_2/Area2D.initialize("> NEW MATCH", self, true)
	$Main/Buttons/Button_3/Area2D.initialize("> OPTIONS", self, true)
	$Main/Buttons/Button_4/Area2D.initialize("> CREDITS", self, true)
	if env == "HTML5":
		$Main/Buttons/Button_5/Area2D.initialize("> QUIT", self, false)
	else:
		$Main/Buttons/Button_5/Area2D.initialize("> QUIT", self, true)

func menu_hide():
	m_is_enabled = false
	m_game.m_input_owner = Utils.InputOwner.Gameplay
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_out.wav', -10)
	
	$Main/Buttons.visible = false
	m_pivot_credits.visible = false
	m_pivot_options.visible = false
	
	$Tween.stop_all()
	var to = Vector2(0, -720)
	var from = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_menu, from, to, 0.15, 0)
	yield(get_tree().create_timer(0.15), "timeout")
	m_pivot_menu.visible = false

func credits_show():
	m_game.m_input_owner = Utils.InputOwner.Credits
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_in.wav', -10)
	$Main/Buttons.visible = false
	
	m_pivot_credits.visible = true
	var from = Vector2(0, -720)
	var to = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_credits, from, to, 0.15, 0)
	
	$Credits/Buttons/Button_11/Area2D.initialize("> BACK", self, true)

func credits_hide():
	m_game.m_input_owner = Utils.InputOwner.Menu
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_out.wav', -10)
	$Main/Buttons.visible = true
	
	$Tween.stop_all()
	var to = Vector2(0, -720)
	var from = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_credits, from, to, 0.15, 0)

func options_show():
	m_game.m_input_owner = Utils.InputOwner.Options
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_in.wav', -10)
	$Main/Buttons.visible = false
	
	m_pivot_options.visible = true
	var from = Vector2(0, -720)
	var to = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_options, from, to, 0.15, 0)
	
	var env = OS.get_name() # "Android", "BlackBerry 10", "Flash", "Haiku", "iOS", "HTML5", "OSX", "Server", "Windows", "WinRT", "X11"
#	print(env)
	$Options/Buttons.visible = true
	
	$Options/Buttons/Button_21/Area2D.initialize("> BACK", self, true)
	$Options/Buttons/Button_22/Area2D.initialize("> MUSIC: ON", self, true)
	
	if env == "HTML5":
		$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: ON", self, false)
	elif env == "Android":
		$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: ON", self, false)
	else:
		if OS.window_fullscreen == true:
			$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: ON", self, true)
		else:
			$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: OFF", self, true)
	
	if m_game.m_difficulty == Utils.Difficulty.Easy:
		$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: EASY", self, true)
	elif m_game.m_difficulty == Utils.Difficulty.Medium:
		$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: MEDIUM", self, true)
	elif m_game.m_difficulty == Utils.Difficulty.Hard:
		$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: HARD", self, true)
	else: # Utils.Difficulty.Random:
		$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: RANDOM", self, true)
		
	if m_game.m_particles_type == Utils.ParticlesType.GPU:
		$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: GPU", self, true)
	elif m_game.m_particles_type == Utils.ParticlesType.CPU:
		$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: CPU", self, true)
	else:
		$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: OFF", self, true)

func options_hide():
	m_game.m_input_owner = Utils.InputOwner.Menu
	Utils.play_sound($AudioSource, 'res://sounds/sfx_sounds_pause1_out.wav', -10)
	$Main/Buttons.visible = true
	
	$Tween.stop_all()
	var to = Vector2(0, -720)
	var from = Vector2(0, 0)
	Utils.tween_move($Tween, m_pivot_options, from, to, 0.15, 0)

func on_button_click(button):
	if m_game != null and m_game.m_input_owner == Utils.InputOwner.Gameplay:
		return
	elif m_game.m_input_owner == Utils.InputOwner.Menu:
		if button.get_parent().name == "Button_1": # RESUME
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			menu_hide()
			
		elif button.get_parent().name == "Button_2": # RESTART / NEW MATCH
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			$Main/Buttons.visible = false
#			yield(get_tree().create_timer(1), "timeout")
			yield(m_game.solitaire_next_match(), "completed")
			menu_hide()
			
		elif button.get_parent().name == "Button_3": # OPTIONS
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			options_show()
				
		elif button.get_parent().name == "Button_4": # CREDITS
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			credits_show()
			
		elif button.get_parent().name == "Button_5": # QUIT
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			get_tree().quit()
	
	elif m_game.m_input_owner == Utils.InputOwner.Credits:
		if button.get_parent().name == "Button_11": # BACK
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			credits_hide()
	
	elif m_game.m_input_owner == Utils.InputOwner.Options:
		if button.get_parent().name == "Button_21": # BACK
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			options_hide()
			
		elif button.get_parent().name == "Button_22": # MUSIC ON
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			var music = m_game.get_node("AudioSourceMusic")
			var wind = m_game.get_node("AudioSourceWind")
			if music.playing:
				music.stop()
				wind.stop()
				$Options/Buttons/Button_22/Area2D.initialize("> MUSIC: OFF", self, true)
			else:
				music.play()
				wind.stop()
				$Options/Buttons/Button_22/Area2D.initialize("> MUSIC: ON", self, true)
				
		elif button.get_parent().name == "Button_23": # FULLSCREEN
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			if OS.window_fullscreen == true:
				$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: OFF", self, true)
				OS.window_fullscreen = false
			else:
				$Options/Buttons/Button_23/Area2D.initialize("> FULLSCREEN: ON", self, true)
				OS.window_fullscreen = true
				
		elif button.get_parent().name == "Button_24": # DIFFICULTY
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			if m_game.m_difficulty == Utils.Difficulty.Easy:
				m_game.m_difficulty = Utils.Difficulty.Medium
				$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: MEDIUM", self, true)
			elif m_game.m_difficulty == Utils.Difficulty.Medium:
				m_game.m_difficulty = Utils.Difficulty.Hard
				$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: HARD", self, true)
			elif m_game.m_difficulty == Utils.Difficulty.Hard:
				m_game.m_difficulty = Utils.Difficulty.Random
				$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: RANDOM", self, true)
			else: # m_game.m_difficulty == Utils.Difficulty.Random:
				m_game.m_difficulty = Utils.Difficulty.Easy
				$Options/Buttons/Button_24/Area2D.initialize("> DIFFICULTY: EASY", self, true)
				
		elif button.get_parent().name == "Button_25": # PARTICLES
			Utils.play_sound(button.get_node("AudioSource"), 'res://sounds/sfx_sounds_interaction18.wav', -20)
			if m_game.m_particles_type == Utils.ParticlesType.GPU:
				m_game.m_particles_type = Utils.ParticlesType.CPU
				m_game.update_particles()
				$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: CPU", self, true)
			elif m_game.m_particles_type == Utils.ParticlesType.CPU:
				m_game.m_particles_type = Utils.ParticlesType.None
				m_game.update_particles()
				$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: OFF", self, true)
			else:
				m_game.m_particles_type = Utils.ParticlesType.GPU
				m_game.update_particles()
				$Options/Buttons/Button_25/Area2D.initialize("> PARTICLES: GPU", self, true)
