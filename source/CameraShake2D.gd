extends Camera2D
# ref: http://kidscancode.org/godot_recipes/2d/screen_shake/

export var m_decay = 0.8  # How quickly the shaking stops [0, 1].
export var m_max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var m_max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.

var m_trauma = 0.0  # Current shake strength.
var m_trauma_power = 2  # m_trauma exponent. Use [2, 3].

onready var m_noise = OpenSimplexNoise.new()
var m_noise_y = 0

func _ready():
	randomize()
	m_noise.seed = randi()
	m_noise.period = 4
	m_noise.octaves = 2

func add_trauma(amount):
    m_trauma = min(m_trauma + amount, 1.5)

func _process(delta):
    if target:
        global_position = get_node(target).global_position
    if m_trauma:
        m_trauma = max(m_trauma - m_decay * delta, 0)
        shake()

func shake():
	var amount = pow(m_trauma, m_trauma_power)    
	m_noise_y += 1
	rotation = m_max_roll * amount * m_noise.get_noise_2d(m_noise.seed, m_noise_y)
	offset.x = m_max_offset.x * amount * m_noise.get_noise_2d(m_noise.seed*2, m_noise_y)
	offset.y = m_max_offset.y * amount * m_noise.get_noise_2d(m_noise.seed*3, m_noise_y)

func small_shake():
	add_trauma(1)
	shake()

#func _unhandled_input(event):
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_A:
#			add_m_trauma(1.5)
#			shake()