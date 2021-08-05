class_name NoteData
extends Object

var beat = 0
var track = -1 # used for editor only!
var track_obj = null # used for editor only!
var object = null
var data = {} # store any note variables in here! like hold, or whatever

func get_time(mapper):
	return mapper.get_time(self.beat)

func serialize():
	var tab = {"beat": beat}
	if (data.size() > 0):
		tab = {
			"beat": beat,
			"data": data
		}
	return tab

func deserialize(tab):
	beat = tab.beat
	if (tab.get("data")):
		data = tab.data
