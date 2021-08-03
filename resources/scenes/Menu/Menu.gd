extends Node2D

onready var viewport = $Viewport/SubViewport
onready var buttons = $Buttons
onready var slabel = $SongLabel

var reset_scene = false
var song
var diff
var selection = 0

func load_scene():
	for child in viewport.get_children():
		child.free()
	if (song != null):
		var nbm = Beatmapper.new()
		nbm.stream = Util.data.read_ogg(song.song_path)
		nbm.volume_db = -10
		nbm.name = "Beatmapper"
		nbm.set_bpm(song.bpm)
		nbm.set_loop(false)
		viewport.beatmapper = nbm
		viewport.add_child(nbm)
		viewport.set_song(song, diff)
		viewport.add_child(load(song.scene_path).instance())

func get_random_song():
	var list = []
	for song in Data.songs.list:
		if (song.is_valid() and song.scene_preview):
			list.append(song)
	if (list.size() > 0):
		var rng = RandomNumberGenerator.new()
		rng.seed = OS.get_ticks_msec()
		var i = rng.randi_range(0, list.size() - 1)
		song = list[i]
		diff = rng.randi_range(0, song.charts.size() - 1)
		load_scene()
		slabel.get_node("Label").text = "Now Playing: " + song.artist + " - " + song.name + " (" + str(song.charts[diff].difficulty) + ")"
		slabel.rect_size = Vector2(16 + slabel.get_node("Label").get_font("font").get_string_size(slabel.get_node("Label").text)[0], 32)
	else:
		slabel.visible = false

func _ready():
	get_random_song()
	update_buttons()

func _process(dt):
	if (reset_scene):
		load_scene()
		reset_scene = false

func update_buttons():
	selection = Util.math.pmod(selection, buttons.get_children().size())
	for button in buttons.get_children():
		var is_sel = str(button.name).to_int() == int(selection)
		button.color						= (Color(1,1,1) if is_sel else Color())
		button.get_node("Label").modulate	= (Color() if is_sel else Color(1,1,1))

func _input(ev):
	if (ev is InputEvent):
		if (ev.is_action_pressed("menu-down")):
			selection += 1
			update_buttons()
		elif (ev.is_action_pressed("menu-up")):
			selection -= 1
			update_buttons()
		elif (ev.is_action_pressed("menu-select")):
			match (int(selection)):
				0: get_tree().change_scene("res://resources/scenes/Select/Select.tscn")
				1: get_tree().change_scene("res://resources/scenes/EditorSelect/EditorSelect.tscn")
				2: get_tree().quit()
