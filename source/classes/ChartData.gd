class_name ChartData
extends Object

var difficulty = 1
var color = Color("#bbbbbb")
var tracks = []

func sort():
	for track in tracks:
		track.sort()

func serialize():
	var tab = {
		"difficulty": difficulty,
		"color": Util.data.get_hex(color),
		"tracks": [],
	}
	for track in tracks:
		tab.tracks.append(track.serialize())
	return tab

func deserialize(tab):
	difficulty = tab.difficulty
	color = Color(tab.color)
	tracks = []
	for track in tab.tracks:
		var new_track = TrackData.new()
		new_track.deserialize(track)
		tracks.append(new_track)
