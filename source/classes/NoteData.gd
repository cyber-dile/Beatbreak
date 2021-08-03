class_name NoteData
extends Object

var beat = 0
var track = -1 # used for editor only!
var track_obj = null # used for editor only!
var object = null

func get_time(mapper):
	return mapper.get_time(self.beat)

func serialize():
	var tab = {
		"beat": beat
	}
	return tab

func deserialize(tab):
	beat = tab.beat
