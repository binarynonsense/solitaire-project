
#func _ready():
#    var arr = ["",11,1,"",4]
#    arr.sort_custom(self, "customComparison")
#    print (arr)
#
#
#func customComparison(a, b):
#    if typeof(a) != typeof(b):
#        return typeof(a) < typeof(b)
#    else:
#        return a < b


#$myStreamPlayer2D.play()
#
#var temp = $myStreamPlayer2D.get_playback_position( )
#$myStreamPlayer2D.stop()
#
#$myStreamPlayer2D.play()
#$myStreamPlayer2D.seek(temp)

#If is to use tweens only and no extra nodes, can be done tweening rect/scale and rect/pos in the same tween.
#
#Dirty example:
#
#tween.interpolate_property(text, "rect/scale", text.get_scale(), text.get_scale()*4, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
#tween.interpolate_property(text, "rect/pos", text.get_pos(), text.get_pos()-text.get_size()*1.5, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
#tween.start()



#func getallnodes(node):
#    for N in node.get_children():
#        if N.get_child_count() > 0:
#            print("["+N.get_name()+"]")
#            getallnodes(N)
#        else:
#            # Do something
#            print("- "+N.get_name())
#

# $sprite.modulate = Color(0, 0, 1) # blue shade

#enum State { NotSet, Down, Up }
#export(State) var m_state = State.Down
#export (Array, NodePath)var m_parents

#func on_tween_complete(a,b):
#    print(test_value)  # prints 123456792
#
#func _ready():
#    var tw = Tween.new()
#    add_child(tw)
#    tw.interpolate_property(self, "test_value", 0, 123456789, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
#    tw.connect("tween_complete", self, "on_tween_complete")
#    tw.start()

#for enemy in get_tree().get_nodes_in_group("enemy):
#    enemy.queue_free()
#You may want to remove enemies with remove_child()
#is_in_group("group name")
#func _ready():
#    add_to_group("enemies")
#func _on_discovered(): # This is a purely illustrative function.
#    get_tree().call_group("enemies", "player_was_discovered")

#tween.interpolate_property(sprite, 'visibility/opacity',
#    1, 0, 0.3,
#    Tween.TRANS_QUAD, Tween.EASE_OUT)

#var viewportWidth = get_viewport().size.x
#var viewportHeight = get_viewport().size.y
#
#var scale = viewportWidth / $Sprite.texture.get_size().x
## Optional: Center the sprite, required only if the sprite's Offset>Centered checkbox is set
#$Sprite.set_position(Vector2(viewportWidth/2, viewportHeight/2))
## Set same scale value horizontally/vertically to maintain aspect ratio
## If however you don't want to maintain aspect ratio, simply set different
## scale along x and y
#$Sprite.set_scale(Vector2(scale, scale))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#command to create the cards spritesheet from separated images:
#montage -mode concatenate -resize 128x -tile 13x -background none *.png cards.png

#func test_cards_row():
#	var card_scene = load("res://scenes/Card.tscn")
#	for i in range(52):
#		var card = card_scene.instance()
#		card.position.x = i * 30
#		card.position.y = 200
#		card.initialize(self, 2, i) # state: up
#		cards.append(card)
#		add_child(card)
		
		
#func test_cards_row():
#	var card_scene = load("res://scenes/Card.tscn")
#	for i in range(52):
#		var card = card_scene.instance()
#		card.position.x = i * 30
#		card.position.y = 200
#		card.initialize(self, 2, i) # state: up
#		cards.append(card)
#		add_child(card)
		
		
#export(Array, AudioStream) var a_streams

#export(bool) var regenerate setget regenerate
#
#func regenerate(v):
#	if m_state == State.Down:
#		$Sprite.frame = 52
#	else:
#		$Sprite.frame = 1

			
#var script_class = load("res://path/to/script.gd")
#if my_node extends script_class:
#    print("This node extends script.gd")

# 3D WINDOW deleted

#const ray_length = 1000

# https://docs.godotengine.org/en/3.1/tutorials/physics/ray-casting.html
#{
#   position: Vector2 # point in world space for collision
#   normal: Vector2 # normal in world space for collision
#   collider: Object # Object collided or null (if unassociated)
#   collider_id: ObjectID # Object it collided against
#   rid: RID # RID it collided against
#   shape: int # shape index of collider
#   metadata: Variant() # metadata of collider
#}
#func _input(event):
##	var camera = $Pivot3D/CameraFP
#	var camera = $Pivot3D/Viewport/CameraFP
#	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
##		var camera = $Pivot3D/Viewport/CameraFP
#		#camera = $Pivot3D/Camera2
#		var from = camera.project_ray_origin(event.position / 5)
#		var to = from + camera.project_ray_normal(event.position / 5) * ray_length
#		var space_state = camera.get_world().direct_space_state
#		# https://github.com/godotengine/godot/issues/9029 -> enable collision_with_areas
#		var result = space_state.intersect_ray(from, to, [], 0x1, true, true)
#		if result:
#			print("Hit at point: ", result.position)
#			print("Collider: ", result.collider)
#		else:
#			print("No Hit")
	
#	if event is InputEventKey and event.pressed and not event.echo:
##		var camera = $Pivot3D/Viewport/CameraFP
#		if event.scancode == KEY_W:
#			camera.move("up")
#		if event.scancode == KEY_S:
#			camera.move("down")
#		if event.scancode == KEY_D:
#			camera.move("right")
#		if event.scancode == KEY_A:
#			camera.move("left")
		

#func _physics_process(delta):
#	var camera = $Pivot3D/Viewport/Camera
#	#camera = $Pivot3D/Camera2
#	var from = camera.project_ray_origin(Vector2(640,360) / 5)
#	var to = from + camera.project_ray_normal(Vector2(640,360) / 5) * ray_length
#	var space_state = camera.get_world().direct_space_state
#	var result = space_state.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
#	if result:
#		print("Hit at point: ", result.position)
#	else:
#		print("No Hit")
