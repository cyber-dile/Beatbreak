extends Viewport

var menu

var song
var chart
var scores = []
var beatmapper
var preview = true

func exit(): menu.reset_scene = true
func end(): exit()

func _ready():
	menu = get_node("../..")

func set_song(new_song, difficulty):
	if (new_song):
		song = new_song
		var rng = RandomNumberGenerator.new()
		rng.seed = OS.get_ticks_msec()
		chart = song.charts[difficulty]
		scores = []
		for player in range(song.players):
			scores.append(Scorebank.new())
