extends Control

var song
var difficulty = 0
var this_diff = 0
var dest_color = Color(1,1,1,1)
var hovered = false

onready var diff = $Difficulty
onready var dl = $Difficulty/Label
onready var nl = $Label
onready var outline = $Outline
onready var background = $Background

func parse_diff(n):
	var diff = str(n)
	if (diff.length() < 3):
		var zero = "0"
		diff = zero.repeat(3 - diff.length()) + diff
	return diff

func set_song(new_song):
	if (new_song):
		song = new_song
		nl.text = (song.artist) + " - " + (song.name)
		set_difficulty(0)

func pmod(a,b):
	var res = fmod(a,b)
	if (res < 0):
		res += b
	return res

func set_difficulty(n = 0):
	n = pmod(float(n), song.charts.size())
	difficulty = n
	dest_color = song.charts[n].color

var t = 0
var last_tick = 0
func _process(dt):
	t += dt
	var lc = Util.math.lerpc(.5,1.0/30.0,dt)
	diff.color = diff.color.linear_interpolate(dest_color, lc)
	outline.modulate = diff.color
	var arrows = get_node_or_null("Settings/Arrows")
	if (arrows):
		arrows.modulate = diff.color
	if (song and this_diff != song.charts[difficulty].difficulty):
		var time = pow(.5,log(abs(song.charts[difficulty].difficulty - this_diff))) / 16
		if (t - last_tick >= time):
			this_diff = Util.math.logtick(this_diff, song.charts[difficulty].difficulty)
			dl.text = parse_diff(this_diff)
			last_tick = t
