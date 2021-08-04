class_name Track
extends Node

var notes = []
var unloaded_notes = []
var loaded_notes = []
var note_time = 2500
var hit_window = 75
var stage
var beatmapper
var note_template # set to an object to be cloned, with the same properties as classes/Note.gd
var track_data
var input
var input_threshold
var automatic = false

func process_note(note, dt): pass
func hit_note(note): pass
func miss_note(note): pass
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
		if (loaded_notes.size() > 0 and beatmapper.get_beat() > loaded_notes[0].beat):
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

func create_note(note):
	var new_note
	if (note_template != null):
		new_note = note_template.duplicate()
	else:
		new_note = Note.new()
	new_note.track = self
	new_note.note = notes
	new_note.beat = note.beat
	new_note.init()
	return new_note

func load_track(track):
	track_data = track
	track.sort()
	for note in track.notes:
		var new_note = create_note(note)
		unloaded_notes.append(new_note)
		notes.append(new_note)

func _process(dt):
	get_threshold()
	input_threshold.refresh()
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
	removed = 0
	for c in range(loaded_notes.size()):
		var i = c - removed
		var note = loaded_notes[i]
		if is_note_missed(note):
			if (automatic):
				hit_note(note) #lag or something idk
			else:
				miss_note(note)
			loaded_notes.remove(i)
			note.remove(automatic)
			removed += 1
		else:
			process_note(note, dt)
	if (loaded_notes.size() > 0):
		var first = loaded_notes[0]
		if (input_threshold.changed and input_threshold.held):
			if is_note_hit(first) or automatic:
				loaded_notes.remove(0)
				first.remove(true)
				hit_note(first)
			else:
				hit_nothing()
	elif (input_threshold.changed and input_threshold.held):
		hit_nothing()
