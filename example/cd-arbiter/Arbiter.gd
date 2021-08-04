extends Spatial

onready var cube = $MeshInstance
onready var track0 = $Track0
onready var track1 = $Track1
onready var track2 = $Track2
onready var track3 = $Track3

var stage
var beatmapper
var orot

func _ready():
	stage = get_node("..")
	beatmapper = stage.beatmapper
	beatmapper.song_offset = Data.settings.get_setting(stage.song, "Game Offset (ms)")[2]
	
	track0.set_stage(stage)
	track0.load_track(stage.chart.tracks[0])
	track0.set_input(Data.settings.get_setting(stage.song, "Track 1 Button")[2])
	track1.set_stage(stage)
	track1.load_track(stage.chart.tracks[1])
	track1.set_input(Data.settings.get_setting(stage.song, "Track 2 Button")[2])
	track2.set_stage(stage)
	track2.load_track(stage.chart.tracks[2])
	track2.set_input(Data.settings.get_setting(stage.song, "Track 3 Button")[2])
	track3.set_stage(stage)
	track3.load_track(stage.chart.tracks[3])
	track3.set_input(Data.settings.get_setting(stage.song, "Track 4 Button")[2])
	
	beatmapper.play()
	beatmapper.connect("finished", stage, "end")
	
	orot = cube.transform.basis

func _process(dt):
	var beat = beatmapper.get_beat()
	cube.transform.basis = orot.rotated(Vector3(0,1,0), PI/4 * floor(beat))
