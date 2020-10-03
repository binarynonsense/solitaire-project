extends Node2D
const Utils = preload("Utils.gd")

func initialize(parent, points):
	$Label.text = "+" + str(points)
	z_index = 1000
	var tween = $Tween
#	tween.interpolate_callback(self, 6, "queue_free")
	parent.get_parent().add_child(self)
	position = parent.position
#	parent.get_parent().remove_child(self)
#	get_tree().get_root().add_child(self)
	var from = position
	from.y -= 20
	var to = from
	to.y -= 350
	Utils.tween_move(tween, self, from, to, 1, 0)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, 
    Tween.TRANS_LINEAR, Tween.EASE_OUT)
	Utils.tween_scale_bump(tween, self, 1.5, 0.5, 0.1)

