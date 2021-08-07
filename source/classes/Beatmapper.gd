class_name Beatmapper
extends AudioStreamPlayer

var loop: bool = false
var track_length = 0
var global_offset = 0
var last_check = 0
var song_offset = 0
var bpm = [[0,120]]

func _ready():
	if (stream is AudioStream):
		stream.loop = false
	if (bpm.size() > 0):
		set_bpm(bpm)
	reset()

var least_time = 0
func get_accurate_time():
	if (stream_paused):
		return 1000 * (get_playback_position() / pitch_scale - AudioServer.get_output_latency())
	var t = 1000 * (get_playback_position() / pitch_scale + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency())
	if (t + 100 < least_time or t > least_time):
		least_time = t
	return max(least_time, t)

func reset():
	last_check = -INF
	global_offset = 0

func sort_bpm(a,b):
	return a[0] < b[0]

func set_bpm(new_bpm: Array):
	bpm = []
	new_bpm.sort_custom(self, "sort_bpm")
	
	var this_beat = new_bpm[0]
	this_beat.append(0)
	
	for beat_change in new_bpm:
		assert(beat_change[1] > 0, "BPM has to be a positive float")
		beat_change[0] = float(beat_change[0])
		beat_change[1] = float(beat_change[1])
		this_beat = [
			beat_change[0],
			beat_change[1],
			this_beat[2] + (beat_change[0] - this_beat[0]) * this_beat[1] / 60000
		]
		bpm.append(this_beat)

func get_beat(time = get_accurate_time()):
	time -= song_offset
	time *= pitch_scale
	var this_beat = bpm[0]
	for beat_change in bpm:
		if (time > beat_change[0]):
			this_beat = beat_change
	return this_beat[2] + (time - this_beat[0]) * this_beat[1] / 60000

func check_loop():
	var new_check = get_time()
	if (last_check > new_check):
		track_looped()
	last_check = new_check

func get_global_beat(time: float = get_accurate_time()):
	check_loop()
	return get_beat(time) + global_offset

func get_time(beat = null):
	if (!(beat is float) and !(beat is int)):
		return get_accurate_time()
	var this_beat = bpm[0]
	for beat_change in bpm:
		if beat > beat_change[2]:
			this_beat = beat_change
	return (this_beat[0] + (beat - this_beat[2]) / this_beat[1] * 60000) / pitch_scale + song_offset

func seek_beat(beat):
	seek(clamp(get_time(beat) / 1000 * pitch_scale, 0, stream.get_length()))

func set_loop(new, round_beat: float = 1.0):
	reset()
	if (stream):
		stream.loop = new
	loop = new
	if (loop and stream):
		track_length = round(get_beat(stream.get_length() * 1000) / round_beat) * round_beat

func track_looped():
	if (loop):
		global_offset += track_length

func _process(dt):
	get_global_beat()
