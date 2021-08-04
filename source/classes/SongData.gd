class_name SongData
extends Object

var id = ""
var name = "Song Name"
var artist = "Artist Name"
var credits = "Song Credits"
var bpm = [[0, 120]]
var song_path = ""
var scene_path = ""
var backdrop_path = ""
var scene_preview = true
var players = 1
var settings = []
var charts = []

func is_valid():
	if (not (song_path.length() > 0 and scene_path.length() > 0)):
		return
	var scene = load(scene_path)
	if (scene == null):
		return
	var music = Util.data.read_ogg(song_path)
	if (music == null):
		return
	return true

func save():
	for chart in charts:
		for track in chart.tracks:
			track.sort()
	var data = serialize()
	var f = File.new()
	f.open("user://charts/" + id + ".json", File.WRITE)
	f.store_string(JSON.print(data))
	f.close()

func remove():
	var f = Directory.new()
	f.remove("user://charts/" + id + ".json")
	Data.songs.list.remove(Data.songs.list.find(self))

func serialize():
	var tab = {
		"id": id,
		"name": name,
		"artist": artist,
		"credits": credits,
		"bpm": bpm.duplicate(true),
		"song_path": song_path,
		"scene_path": scene_path,
		"backdrop_path": backdrop_path,
		"scene_preview": scene_preview,
		"players": players,
		"settings": settings.duplicate(true),
		"charts": []
	}
	for chart in charts:
		tab.charts.append(chart.serialize())
	return tab

func deserialize(tab):
	id = tab.id
	name = tab.name
	artist = tab.artist
	credits = tab.credits
	bpm = tab.bpm
	song_path = tab.song_path
	scene_path = tab.scene_path
	backdrop_path = tab.backdrop_path
	scene_preview = tab.scene_preview
	players = tab.players
	settings = tab.settings
	charts = []
	for chart in tab.charts:
		var new_chart = ChartData.new()
		new_chart.deserialize(chart)
		charts.append(new_chart)
