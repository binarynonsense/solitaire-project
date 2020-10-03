extends Sprite
const Utils = preload("Utils.gd")

# ref: https://docs.godotengine.org/en/3.1/classes/class_tween.html#enum-tween-transitiontype

func delayed_destruction(delay):
	var tween = $Tween
	tween.interpolate_callback(self, 3, "queue_free")
	tween.start()

func update_sprite(index):
	frame = index

func animate_rotate_full(times, time, delay):
	Utils.tween_rotate_full($Tween, self, times, time, delay)

func animate_move(to, time, delay):
	Utils.tween_move($Tween, self, get_position(), to, time, delay)

func animate_scale_bump(delay):
	Utils.tween_scale_bump($Tween, self, 1.2, 0.2, delay)

func animate_flip_up(time, index):
	var tween = $Tween
	var init_scale = get_scale()
	update_sprite(53) # card's back
	tween.interpolate_callback(self, 3 * time/4, "update_sprite", index)
	tween.interpolate_property(self, 'scale', \
	 init_scale, Vector2(0, init_scale.y), 3 * time/4, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	tween.interpolate_property(self, 'scale', \
	 Vector2(0, init_scale.y), init_scale, time/4, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	Utils.tween_scale_bump($Tween, self, 1.2, 0.2, time)
	
	tween.start()
