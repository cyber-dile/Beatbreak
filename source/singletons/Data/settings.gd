extends Node

var settings = []

func _ready():
	load_settings()

func save_settings():
	var f = File.new()
	f.open("user://settings.json", File.WRITE)
	f.store_string(JSON.print(settings))
	f.close()

func load_settings():
	var f = File.new()
	f.open("user://settings.json", File.READ)
	var data = f.get_as_text()
	f.close()
	var res = JSON.parse(data)
	if (res.error == OK):
		settings = res.result

func get_list(song):
	for list in settings:
		if (list[0] == song.id):
			return list

func check_validity(song):
	var index = 0
	for i in range(settings.size()):
		var list = settings[i]
		if (list[0] == song.id):
			index = i
	if (song.settings.size() != settings[index][1].size()):
		settings.remove(index)
		settings.append([song.id, song.settings.duplicate()])
		return
	for sett in song.settings:
		var found = false
		for new_setting in settings[index][1]:
			if (new_setting[0] == sett[0] and new_setting[1] == sett[1] and new_setting.size() == sett.size()):
				found = true
				break
		if (not found):
			settings.remove(index)
			settings.append([song.id, song.settings.duplicate()])
			return

func register_settings(song):
	var val = get_list(song)
	if (not (val is Array)):
		val = [song.id, song.settings.duplicate()]
		settings.append(val)
	check_validity(song)
	return get_list(song)[1]

func get_setting(song, setting):
	var list = register_settings(song)
	for new_setting in list:
		if new_setting[0] == setting:
			return new_setting
	return [setting, null, 0]
