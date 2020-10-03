enum InputOwner {None, Gameplay, Menu, Credits, Options}
enum Difficulty {Easy, Medium, Hard, Random}
enum ParticlesType {GPU, CPU, None}

static func play_sound(audio_source, sound, volume_db, pitch = 1):
	audio_source.stop()
	audio_source.volume_db = volume_db
	audio_source.pitch_scale = pitch
	audio_source.stream = load(sound)
	audio_source.play()

static func play_sound_3d(audio_source, sound, volume_db, pitch = 1):
	audio_source.stop()
	audio_source.unit_db = volume_db
	audio_source.pitch_scale = pitch
	audio_source.stream = load(sound)
	audio_source.play()

static func get_rank_from_index(index):
#	var rank = index % 13 + 1
	if index == 52: # JOKER
		return 14
	var rank = ceil((index + 1.0) / 4.0)
	return rank

static func get_index_from_rank_and_suit(rank, suit):
	if rank == 14: # JOKER
		return 52
	var index = ((rank - 1) * 4) + suit
	return index

static func clamp_rank(rank):
	if rank > 13:
		rank = 1
	elif rank < 1:
		rank = 13
	return rank

static func is_valid_rank_match(rank_1, rank_2):
	if rank_1 == 14 || rank_2 == 14: # JOKER
		return true
	if  clamp_rank(rank_1 - 1) == rank_2 || clamp_rank(rank_1 + 1) == rank_2:
		return true
	return false

static func get_all_children_in_group(node, group, array):
	for child in node.get_children():
		if child.is_in_group(group):
			array.append(child)
		if child.get_child_count() > 0:       
			get_all_children_in_group(child, group, array)

static func get_valid_obstructed_areas(area):
	var areas = []
	var overlapping_areas = area.get_overlapping_areas()
	for other in overlapping_areas:
		# TODO: check which is the closest z_index, may not be -1 if map design error
		if other.z_index == area.z_index - 1:
			areas.append(other)
	return areas

static func get_overlapping_areas_above(area):
	var areas = []
	var overlapping_areas = area.get_overlapping_areas()
	for other in overlapping_areas:
		if other.z_index > area.z_index:
			areas.append(other)
	return areas

static func tween_scale_bump(tween, target, scale_factor, time, delay):
	var init_scale = target.get_scale()
#	tween.connect("tween_complete", self, "on_tween_card_completed")
	tween.interpolate_property(target, 'scale', \
	 init_scale, init_scale * scale_factor, time/2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, delay)
	tween.interpolate_property(target, 'scale', \
	 init_scale * scale_factor, init_scale, time/2, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.1)
	tween.start()

static func tween_rect_scale_bump(tween, target, scale_factor, time, delay):
	var init_scale = target.get_scale()
#	tween.connect("tween_complete", self, "on_tween_card_completed")
	tween.interpolate_property(target, 'rect_scale', \
	 init_scale, init_scale * scale_factor, time/2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, delay)
	tween.interpolate_property(target, 'rect_scale', \
	 init_scale * scale_factor, init_scale, time/2, Tween.TRANS_QUAD, Tween.EASE_OUT, delay + 0.1)
	tween.start()

static func tween_rotate_full(tween, target, times, time, delay):
	tween.interpolate_property(target, 'rotation', \
	 0, 2*PI*times, time, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, delay)
	tween.start()
	
static func tween_move(tween, target, from, to, time, delay):
	tween.interpolate_property(target, 'position', \
	 from, to, time, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, delay)
	tween.start()
