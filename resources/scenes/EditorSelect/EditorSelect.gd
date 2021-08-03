extends Control

onready var center = $CenterBar/CenterBar
onready var back = $CenterBar/BackBar
onready var scroller = $Scroller
onready var info = $SongInfo
onready var backdrop = $Backdrop
onready var nsb = $SongInfo/NewSong
onready var tween = $Tween

var song_example = preload("res://resources/scenes/EditorSelect/EditorSong.tscn")

var state = "selecting"
var shift = 0
var selection = 0
var button_select = 0
var sett_sel = 0
var songs = []
var labels = []
var modify_backdrop = false
var reset_scene = false

func nudge_selection(d):
	if (songs.size() > selection):
		labels[selection].outline.visible = false
		var old_sel = selection
		selection += d
		if (selection < 0):
			selection += songs.size()
		elif (selection >= songs.size()):
			selection -= songs.size()
		shift += (selection - old_sel)
		labels[selection].outline.visible = true
		info.get_node("SongName").text = songs[selection].name
		info.get_node("ArtistName").text = songs[selection].artist
		info.get_node("Credits").text = songs[selection].credits
		info.visible = true
		
		for child in get_node("Viewport/SubViewport").get_children():
			child.free()
		
		get_node("Viewport/SubViewport").set_song(songs[selection], labels[selection].difficulty)
		if (songs[selection].backdrop_path.length() > 0):
			var val = load(songs[selection].backdrop_path)
			if (val):
				set_backdrop(val)
				backdrop.modulate = Color(1, 1, 1)
				modify_backdrop = false
		else:
			set_backdrop(load("res://assets/game/white.png"))
			modify_backdrop = true
		
		if (songs[selection].song_path.length() > 0):
			var beatmapper = Beatmapper.new()
			beatmapper.stream = Util.data.read_ogg(songs[selection].song_path)
			beatmapper.set_bpm(songs[selection].bpm)
			beatmapper.volume_db = -20
			beatmapper.name = "Beatmapper"
			get_node("Viewport/SubViewport").add_child(beatmapper)
			tween.interpolate_property(beatmapper, "volume_db", -20, 0, .5)
			tween.start()
			get_node("Viewport/SubViewport").beatmapper = beatmapper
			beatmapper.set_loop(false)
			var obj = self
		if (get_node_or_null("Viewport/SubViewport/Beatmapper") and get_node("Viewport/SubViewport/Beatmapper").stream and songs[selection].scene_path.length() > 0 and songs[selection].scene_preview):
			var scene = load(songs[selection].scene_path)
			if (scene):
				scene = scene.instance()
				get_node("Viewport/SubViewport").add_child(scene)

func set_backdrop(texture):
	backdrop.texture = texture
	var size = texture.get_size()
	backdrop.scale = Vector2(720 / size.x, 720 / size.y)

func nudge_difficulty(d):
	if (songs.size() > selection):
		labels[selection].set_difficulty(labels[selection].difficulty + d)
		nudge_selection(0)

func collect_songs():
	songs = []
	for song in Data.songs.list:
		songs.append(song)

func button_clicked(i):
	if (state == "selecting"):
		nudge_selection(i - selection)

func load_songs():
	for child in scroller.get_children():
		child.free()
	labels = []
	
	var select_song = null
	var select_diff = null
	
	for i in range(songs.size()):
		var v = songs[i]
		if (v):
			var new_song = song_example.instance()
			scroller.add_child(new_song)
			new_song.rect_position = Vector2(-32, 32) * i - Vector2(256, 16)
			new_song.set_song(v)
			var obj = self
			new_song.get_node("Button").connect("button_down", self, "button_clicked", [i])
			if (i%2 == 1):
				new_song.background.color = Color("#cccccc")
			labels.append(new_song)
			
			if (Data.data.selected_song and v.id == Data.data.selected_song.id):
				select_song = i
				select_diff = Data.data.selected_difficulty
	
	if (select_song is int):
		nudge_selection(select_song)
		nudge_difficulty(select_diff)

func pmod(a,b):
	var v = fmod(a,b)
	if v < 0: v += b
	return v

func set_button_select(n):
	n = pmod(n, 3)
	button_select = n
	var label = labels[selection]
	for button in label.get_node("Buttons").get_children():
		button.color = Color(0,0,0) if button.name == str(button_select) else Color(1,1,1)
		button.get_node("Label").modulate = Color(1,1,1) if button.name == str(button_select) else Color(0,0,0)

func set_setting(n):
	n = pmod(n, songs[selection].settings.size())
	sett_sel = n
	var sett = songs[selection].settings[n]
	var s_name = sett[0]
	var s_val = Util.settings.get_display(sett)
	var label = labels[selection]
	label.get_node("Settings/BG/Label").text = s_name
	label.get_node("Settings/Value/Label").text = s_val

func select():
	if (songs.size() <= selection):
		return
	if (state == "selecting"):
		state = "options"
		var label = labels[selection]
		label.get_node("Buttons").visible = true
		set_button_select(1)
	elif (state == "options"):
		match (int(button_select)):
			0:
				visible = false
				state = ""
				Data.data.set("selected_song", songs[selection])
				Data.data.set("selected_difficulty", labels[selection].difficulty)
				for child in get_node("Viewport/SubViewport").get_children():
					child.free()
				
				yield(get_tree().create_timer(0.5), "timeout")
				get_tree().change_scene("res://resources/scenes/Editor/Editor.tscn")
			1:
				go_back()
			2:
				var song = songs[selection]
				var new_chart = ChartData.new()
				var rng = RandomNumberGenerator.new()
				rng.seed = OS.get_ticks_msec()
				new_chart.color = Color(rng.randf(), rng.randf(), rng.randf())
				var list = []
				for chart in song.charts:
					list.append(chart.difficulty)
				list.sort()
				for diff in list:
					if (new_chart.difficulty == diff):
						new_chart.difficulty += 1
				new_chart.difficulty = max(0, min(999, new_chart.difficulty))
				song.charts.append(new_chart)
				nudge_difficulty(song.charts.size() - 1 - labels[selection].difficulty)
				button_select = 0
				select()
	elif (state == "settings"):
		var sett = songs[selection].settings[sett_sel]
		match (sett[1]):
			"keybind":
				state = "keybind"
				var label = labels[selection]
				label.get_node("Settings/BG").color = Color()
				label.get_node("Settings/Value").color = Color(1,1,1)
				label.get_node("Settings/Value/Label").modulate = Color()
				label.get_node("Settings/BG/Label").modulate = Color(1,1,1)
				label.get_node("Settings/BG/Label").text += " (...)"
				return true
			_:
				state = "nudge"
				var label = labels[selection]
				label.get_node("Settings/BG").color = Color()
				label.get_node("Settings/Value").color = Color(1,1,1)
				label.get_node("Settings/Value/Label").modulate = Color()
				label.get_node("Settings/BG/Label").modulate = Color(1,1,1)
	elif (state == "nudge"):
		go_back()

func go_back():
	if (state == "selecting"):
		Data.data.set("selected_song", songs[selection])
		Data.data.set("selected_difficulty", labels[selection].difficulty)
		get_tree().change_scene("res://resources/scenes/Menu/Menu.tscn")
	elif (state == "options"):
		state = "selecting"
		var label = labels[selection]
		label.get_node("Buttons").visible = false
	elif (state == "settings"):
		state = "options"
		var label = labels[selection]
		label.get_node("Settings").visible = false
		label.get_node("Buttons").visible = true
	elif (state == "nudge" or state == "keybind"):
		state = "settings"
		var label = labels[selection]
		label.get_node("Settings/Value").color = Color()
		label.get_node("Settings/BG").color = Color(1,1,1)
		label.get_node("Settings/BG/Label").modulate = Color()
		label.get_node("Settings/Value/Label").modulate = Color(1,1,1)
		set_setting(sett_sel)

func create_new_song():
	if (state == "selecting"):
		var ns = SongData.new()
		var rng = RandomNumberGenerator.new()
		rng.seed = OS.get_ticks_msec()
		var id = rng.randi()
		ns.id = "song-" + str(id)
		var nc = ChartData.new()
		nc.color = Color(rng.randf(), rng.randf(), rng.randf())
		ns.charts.append(nc)
		Data.songs.list.append(ns)
		Data.songs.sort()
		collect_songs()
		load_songs()
		for i in range(songs.size()):
			var song = songs[i]
			if (song == ns):
				nudge_selection(i - selection)
				break
		nsb.visible = false
		yield(get_tree().create_timer(5), "timeout")
		nsb.visible = true

func _ready():
	collect_songs()
	load_songs()
	nudge_selection(0)
	nsb.connect("pressed", self, "create_new_song")

func _process(dt):
	shift *= pow(0.5, dt * 30)
	scroller.position = Vector2(640, 360) - Vector2(-32, 32) * (selection - shift)
	center.rect_position = Vector2(1280,0) + Vector2(-32,32) * fmod(shift, 1.0)
	if (songs.size() > selection):
		back.modulate = labels[selection].get_node("Difficulty").color
	
	if (modify_backdrop):
		var color = labels[selection].get_node("Outline").modulate
		var complement = Color(1 - color.r, 1 - color.g, 1 - color.b)
		backdrop.modulate = complement
	
	if (reset_scene):
		reset_scene = false
		nudge_selection(0)
	
	var bm = get_node_or_null("Viewport/SubViewport/Beatmapper")
	if (bm):
		if (get_node("Viewport/SubViewport").get_children().size() == 1 and not bm.playing):
			bm.set_loop(true)
			bm.play()

func nudge(amount):
	Data.settings.register_settings(songs[selection])
	var sett = Data.settings.settings_list[songs[selection].id][sett_sel]
	match (sett[1]):
		"boolean":
			if (pmod(amount, 2) == 1):
				sett[2] = not sett[2]
		"integer":
			sett[2] += amount
		"menu":
			var v = sett[2][0]
			var m = sett[2][1]
			var i = m.find(v)
			sett[2][0] = m[pmod(i + amount,m.size())]
	set_setting(sett_sel)

func _input(ev):
	if (ev is InputEvent):
		if (ev.is_action_pressed("menu-up")):
			if (state == "selecting"): nudge_selection(-1)
			if (state == "settings"): set_setting(sett_sel - 1)
			if (state == "nudge"): nudge(10)
		elif (ev.is_action_pressed("menu-down")):
			if (state == "selecting"): nudge_selection(1)
			if (state == "settings"): set_setting(sett_sel + 1)
			if (state == "nudge"): nudge(-10)
		elif (ev.is_action_pressed("menu-left")):
			if (state == "selecting"): nudge_difficulty(-1)
			if (state == "options"): set_button_select(button_select - 1)
			if (state == "nudge"): nudge(-1)
		elif (ev.is_action_pressed("menu-right")):
			if (state == "selecting"): nudge_difficulty(1)
			if (state == "options"): set_button_select(button_select + 1)
			if (state == "nudge"): nudge(1)
		elif (ev.is_action_pressed("menu-select")):
			var ret = select()
			if (ret): return
		elif (ev.is_action_pressed("menu-back")):
			go_back()
	if (state == "keybind"):
		Data.settings.register_settings(songs[selection])
		var sett = Data.settings.settings_list[songs[selection].id][sett_sel]
		if (ev is InputEventJoypadButton and ev.pressed):
			var button = ev.button_index
			sett[2][1] = Input.get_joy_button_string(button)
			var c = 0
			while (Input.is_joy_known(c)):
				if (Input.is_joy_button_pressed(c, button)):
					sett[2][2] = c
					break
			go_back()
		elif (ev is InputEventKey and ev.pressed):
			var keycode = ev.keycode
			sett[2][1] = OS.get_keycode_string(keycode)
			go_back()
