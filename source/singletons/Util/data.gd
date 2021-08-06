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

func sort_sm_bpm(a,b):
	return a[0] < b[0]

func imp_sm(path):
	var f = File.new()
	var err = f.open(path, File.READ)
	if (err != OK):
		return
	var line = f.get_line()
	var data = {}
	data["bpm"] = []
	data["tracks"] = [[],[],[],[]]
	var measures = []
	var measure = []
	while (not f.eof_reached()):
		if (line.substr(0,6) == "#BPMS:"):
			var bpms = []
			var type = 0
			var ind = ""
			var val = ""
			for i in range(6,line.length()):
				var c = line.substr(i, 1)
				match (c):
					"=":
						type = 1
					";":
						bpms.append([float(ind), float(val)])
						ind = ""
						val = ""
						type = 0
					_:
						match (type):
							0:
								ind += c
							1:
								val += c
			bpms.sort_custom(self, "sort_sm_bpm")
			data.bpm = bpms
		elif (line.substr(0,1) == "," or line.substr(0,1) == ";"):
			measures.append(measure)
			measure = []
		elif (line.length() == 4):
			var notes = []
			for i in range(4):
				notes.append(line.substr(i, 1))
			measure.append(notes)
		line = f.get_line()
	f.close()
	
	var holds = [null, null, null, null]
	var beat = 1
	for m in measures:
		var nsz = 4.0 / m.size()
		for notes in m:
			for track in range(notes.size()):
				var type = notes[track]
				match type:
					"1": data.tracks[track].append([beat])
					"2", "4":
						var t = [beat, 0]
						holds[track] = t
						data.tracks[track].append(t)
					"3":
						if (holds[track]):
							holds[track][1] = beat - holds[track][0]
						holds[track] = null
			beat += nsz
	
	return data
