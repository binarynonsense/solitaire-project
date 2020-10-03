extends RichTextLabel # Godot 3.1 Beta

# ref: https://godotengine.org/qa/40904/animate-individual-letters-in-a-string

export var message = "Example Fade"
export var message_delay = 1.5
export var cascading_delay = 0.1

export var start_delay = 0.8


func _ready():

    set_physics_process(false)

    bbcode_enabled = true
    bbcode_text = message

    yield(get_tree().create_timer(start_delay), "timeout")

    fade_text(message, message_delay, cascading_delay)


func fade_text(string, duration, cascading_delay):

    char_timers = []

    var i = 0

    for c in string: # Characters in string.

        char_timers.append ({

            letter   = c,
            delay    = cascading_delay * i,
            count    = duration,
            duration = duration,
        })

        i += 1

    set_physics_process(true)


var char_timers

func _physics_process(delta):

    var is_active = false

    bbcode_text = ""

    var idx = 0

    for c_timer in char_timers:

        var color   = Color(1,1,1,0)

        if(c_timer.delay > 0.0):

            is_active = true
            c_timer.delay -= delta
            color.a = 1.0

        else:
            if(c_timer.count > 0.0):

                is_active = true
                c_timer.count -= delta
                color.a = max(c_timer.count / c_timer.duration, 0.0)


        bbcode_text += '[color=#' + color.to_html() + ']' + c_timer.letter + '[/color]'

    set_physics_process(is_active)