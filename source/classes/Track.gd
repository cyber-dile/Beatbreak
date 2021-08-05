class_name Track
extends Node

var notes = []
var unloaded_notes = []
var loaded_notes = []
var held_notes = []
var stage
var beatmapper
var note_template # set to an object to be cloned, with the same properties as classes/Note.gd
var track_data
var input
var input_threshold

var note_range = null # either null, or table [min_limit, max_limit] to cull out any unwanted notes
var automatic = false # autoplay
var note_time = 2500 # time needed for notes to be loaded in
var hit_window = 75 # window, in ms, that notes are allowed to be hit in
var explicit_hold_release = false # whether or not notes need to be EXACTLY released to count as hit

func process_note(note, dt): pass
func process_held_note(note, dt): pass
func hit_note(note): pass
func miss_note(note): pass
func hit_hold(note): pass
func miss_hold(note): pass
func hit_nothing(): pass

func get_threshold():
	if (not input_threshold):
		input_threshold = Threshold.new()
		var this = self
		input_threshold.input = funcref(self, "get_input")

func set_stage(new_stage):
	stage = new_stage
	beatmapper = stage.beatmapper
	automatic = stage.preview

func set_input(value):
	input = value

func get_input():
	if (automatic):
		if (held_notes.size() > 0):
			if (beatmapper.get_beat() < held_notes[0].beat + held_notes[0].note.data.hold):
				return true
			return false
		if ((loaded_notes.size() > 0 and beatmapper.get_beat() > loaded_notes[0].beat)):
			return true
		return false
	if (not (input is Array)):
		return false
	var type = input[0]
	var value = input[1]
	match (type):
		"keyboard":
			value = OS.find_scancode_from_string(value)
			return Input.is_key_pressed(value)
		"controller":
			return Input.is_joy_button_pressed(input[2], value)

func can_load_note(note):
	var off = beatmapper.get_time() - beatmapper.get_time(note.beat)
	return off >= -note_time

func is_note_missed(note):
	var off = beatmapper.get_time() - beatmapper.get_time(note.beat)
	return off > hit_window

func is_note_hit(note):
	var off = beatmapper.get_time() - beatmapper.get_time(note.beat)
	return abs(off) <= hit_window

func is_hold_missed(note):
	var off = beatmapper.get_time() - beatmapper.get_time(note.beat + note.note.data.hold)
	return off > hit_window

func is_hold_hit(note):
	var off = beatmapper.get_time() - beatmapper.get_time(note.beat + note.note.data.hold)
	return abs(off) <= hit_window

func create_note(note):
	var new_note
	if (note_template != null):
		new_note = note_template.duplicate()
	else:
		new_note = Note.new()
	new_note.track = self
	new_note.note = note
	new_note.beat = note.beat
	new_note.init()
	return new_note

func load_track(track):
	track_data = track
	track.sort()
	for note in track.notes:
		if (not note_range or (note.beat >= note_range[0] and note.beat <= note_range[1])):
			var new_note = create_note(note)
			unloaded_notes.append(new_note)
			notes.append(new_note)

func load_notes():
	var removed = 0
	for c in range(unloaded_notes.size()):
		var i = c - removed
		var v = unloaded_notes[i]
		if (can_load_note(v)):
			unloaded_notes.remove(i)
			v.loaded = true
			v.on_load()
			loaded_notes.append(v)
			removed += 1
		else:
			break

func process_notes(dt):
	var removed = 0
	for c in range(loaded_notes.size()):
		var i = c - removed
		var note = loaded_notes[i]
		if is_note_missed(note):
			if (automatic):
				hit_note(note) #lag or something idk
			else:
				miss_note(note)
				if (note.note.data.get("hold")):
					miss_hold(note)
			loaded_notes.remove(i)
			note.remove(automatic)
			removed += 1
		else:
			process_note(note, dt)

func first_note_hit():
	var note = loaded_notes[0]
	loaded_notes.remove(0)
	hit_note(note)
	if (note.note.data.get("hold")):
		held_notes.append(note)
	else:
		note.remove(true)

func process_first_note():
	if (loaded_notes.size() > 0):
		var first = loaded_notes[0]
		if (input_threshold.changed and input_threshold.held):
			if is_note_hit(first) or automatic:
				first_note_hit()
			else:
				hit_nothing()
	elif (input_threshold.changed and input_threshold.held):
		hit_nothing()

func hold_note_missed(note):
	miss_hold(note)
	var ind = held_notes.find(note)
	held_notes.remove(ind)
	note.remove(false)

func hold_note_hit(note):
	hit_hold(note)
	var ind = held_notes.find(note)
	held_notes.remove(ind)
	note.remove(true)

func process_held_notes(dt):
	for note in held_notes:
		if (is_hold_missed(note)):
			if (explicit_hold_release):
				hold_note_missed(note)
			else:
				hold_note_hit(note)
		elif (not input_threshold.held):
			if (explicit_hold_release or is_hold_hit(note)):
				hold_note_hit(note)
			else:
				hold_note_missed(note)
		else:
			process_held_note(note, dt)

func _process(dt):
	get_threshold()
	input_threshold.refresh()
	load_notes()
	process_notes(dt)
	process_first_note()
	process_held_notes(dt)
