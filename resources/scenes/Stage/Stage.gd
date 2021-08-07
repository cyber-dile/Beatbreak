extends Spatial

onready var pause_menu = $Pause

var song
var chart
var beatmapper
var scene
var scores = []
var preview = false
var paused = false

func exit():
	var scene_path = "res://resources/scenes/Select/Select.tscn"
	if (Data.data.back_to_editor):
		scene_path = "res://resources/scenes/Editor/Editor.tscn"
	get_tree().change_scene(scene_path)
	get_tree().paused = false

func end():
	var finals = []
	for bank in scores:
		finals.append(bank.compile())
	Data.scores.update_scores(song, Data.data.get("selected_difficulty"), finals)
	Data.scores.save_scores()
	exit()

func _ready():
	song = Data.data.get("selected_song")
	chart = song.charts[Data.data.get("selected_difficulty")]
	
	if (song.song_path.length() == 0 or song.scene_path.length() == 0):
		exit()
		return
	
	for i in range(song.players):
		var new_score = Scorebank.new()
		scores.append(new_score)
	
	beatmapper = Beatmapper.new()
	beatmapper.stream = Util.data.read_ogg(song.song_path)
	beatmapper.set_bpm(song.bpm)
	beatmapper.set_loop(false)
	beatmapper.name = "Beatmapper"
	add_child(beatmapper)
	scene = load(song.scene_path).instance()
	add_child(scene)

func pause():
	if (scene != null):
		paused = not paused
		pause_menu.visible = paused
		beatmapper.stream_paused = paused
		if (paused):
			get_tree().paused = true
			scene.pause_mode = PAUSE_MODE_STOP
			pause_menu.entered()
		else:
			get_tree().paused = false
			scene.pause_mode = PAUSE_MODE_INHERIT
			pause_menu.left()

func _input(ev):
	if (ev is InputEvent):
		if (ev.is_action_pressed("menu-back")):
			pause()
