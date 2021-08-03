class_name TrackData
extends Object

var notes = []

func sort_notes(a,b):
	return a.beat < b.beat

func sort():
	notes.sort_custom(self, "sort_notes")

func remove_note(note):
	var ind = notes.find(note)
	if (ind >= 0):
		notes.remove(ind)
		return

func has(beat):
	for note in notes:
		if (abs(beat - note.beat) < 1e-4):
			return note

func serialize():
	var tab = {
		"notes": []
	}
	for note in notes:
		tab.notes.append(note.serialize())
	return tab

func deserialize(tab):
	notes = []
	for note in tab.notes:
		var new_note = NoteData.new()
		new_note.deserialize(note)
		notes.append(new_note)
