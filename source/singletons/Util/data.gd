extends Node

func read_ogg(path):
	var a = load(path)
	if (a != null):
		return a
	var file: File = File.new()
	if (not file.file_exists(path)):
		return
	file.open(path, File.READ)
	var data = file.get_buffer(file.get_len())
	file.close()
	var stream = AudioStreamOGGVorbis.new()
	stream.data = data
	return stream

func time_format(ms):
	var sn = 1
	if (ms < 0):
		sn = -1
	ms = abs(ms)
	var s = floor(ms / 1000)
	var m = floor(s / 60)
	var h = floor(m / 60)
	if (sn < 0):
		s = ceil(ms / 1000)
		m = floor(s / 60)
		h = floor(m / 60)
	s = fmod(s, 60)
	m = fmod(m, 60)
	var final = ""
	if (sn < 0):
		final += "-"
	if (h > 0):
		final += str(h) + ":"
	m = str(m)
	if (m.length() < 2 and h > 0): m = "0" + m
	s = str(s)
	if (s.length() < 2): s = "0" + s
	return final + m + ":" + s

func get_hex(c):
	var r = int(clamp(floor(c.r * 255 + .5), 0, 255))
	var g = int(clamp(floor(c.g * 255 + .5), 0, 255))
	var b = int(clamp(floor(c.b * 255 + .5), 0, 255))
	r = "%02X" % r
	g = "%02X" % g
	b = "%02X" % b
	return r + g + b
	
