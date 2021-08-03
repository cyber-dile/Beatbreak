extends Node

var list = []

func sort_valid(a,b): return (0 if a.is_valid() else 1) < (0 if b.is_valid() else 1)
func sort_name(a,b): return a.name < b.name
func sort_artist(a,b): return a.artist < b.artist

func sort():
	if (list.size() > 1):
		list.sort_custom(self, "sort_name")
		list.sort_custom(self, "sort_artist")
		list.sort_custom(self, "sort_valid")

func load_song(dir):
	var f = File.new()
	f.open(dir, File.READ)
	var data = f.get_as_text()
	f.close()
	var res = JSON.parse(data)
	if (res.error == OK):
		var song = SongData.new()
		song.deserialize(res.result)
		return song

func _ready():
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("charts")
	dir.open("user://charts/")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var result = load_song("user://charts/" + file_name)
		if (result):
			list.append(result)
		file_name = dir.get_next()
	
	sort()
