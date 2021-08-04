extends Control

onready var sidescroll = $Sidescroll
onready var container = $Sidescroll/Container
onready var scroller = $Sidescroll/Container/Scroller
onready var beat_tick = $Sidescroll/BeatTick
onready var trackbgs = $Sidescroll/TrackBGs
onready var track_ex = $Sidescroll/Track
onready var bpm_ex = $Sidescroll/Container/Scroller/Markers/BPMMarker
onready var hitbar = $Sidescroll/Hitbar
onready var bpme = $BPMEditor
onready var endmarker = $Sidescroll/Container/Scroller/Markers/EndMarker
onready var se = $SongEditor
onready var trackcont = $Sidescroll/Container/Scroller/Tracks
onready var note_ex = $NoteEx
onready var im = $ImportSM
onready var pe = $PropEditor
onready var selectbox = $SelectionBox

var beatmapper
var song
var chart
var editing
var start_select_pos
var bpm_array = []
var hscroll = 0
var pos = 0.0
var beat_scale = 720 / 32
var state = "charting"
var selection = []

var snaps = [1,2,3,4,6,8,12,16,24,32]
var this_snap = 2

func beatmapper_finished():
	state = "charting"

func bpm_button_pressed():
	get_node("BPMButton").release_focus()
	if (state == "charting"):
		var time = floor(beatmapper.get_time(snap_pos(pos)))
		var bpm = 120
		for marker in bpm_array:
			if (time > marker.time):
				bpm = marker.bpm
		add_marker(time, bpm)
		update_bpm()

func btm_button_pressed():
	for track in chart.tracks:
		track.sort()
	get_tree().change_scene("res://resources/scenes/EditorSelect/EditorSelect.tscn")

func duplicate_button_pressed():
	get_node("Duplicate").release_focus()
	if (state == "charting"):
		duplicate_selection()

func close_se():
	state = "charting"
	se.visible = false
	song.name = se.get_node("BG/SongName/TextEnter").get_value()
	song.artist = se.get_node("BG/Artist/TextEnter").get_value()
	song.credits = se.get_node("BG/Credits/TextEnter").get_value()
	song.id = se.get_node("BG/ID/TextEnter").get_value()
	song.song_path = se.get_node("BG/MusicPath/TextEnter").get_value()
	song.scene_path = se.get_node("BG/ScenePath/TextEnter").get_value()
	song.backdrop_path = se.get_node("BG/ImagePath/TextEnter").get_value()
	chart.difficulty = se.get_node("BG/Diff/NumberEnter").get_value()
	chart.color = se.get_node("BG/ChartColor/ColorEnter").get_value()
	song.players = max(1, se.get_node("BG/Players/NumberEnter").get_value())
	update_song()

func save_file():
	get_node("SaveToFile").release_focus()
	if (state == "charting"):
		song.save()

func _ready():
	song = Data.data.get("selected_song")
	chart = song.charts[Data.data.get("selected_difficulty")]
	for track in chart.tracks:
		add_track(track)
	beatmapper = Beatmapper.new()
	for marker in song.bpm:
		add_marker(marker[0], marker[1])
	add_child(beatmapper)
	set_beat_scale(128)
	beatmapper.connect("finished", self, "beatmapper_finished")
	get_node("BPMButton").connect("pressed", self, "bpm_button_pressed")
	get_node("BackToMenu").connect("pressed", self, "btm_button_pressed")
	get_node("Duplicate").connect("pressed", self, "duplicate_button_pressed")
	se.get_node("BG/TextureButton").connect("pressed", self, "close_se")
	get_node("SaveToFile").connect("pressed", self, "save_file")
	update_song()
	update_bpm()

func snap_pos(p = pos): return floor(p * this_snap + .5) / this_snap

func update_snap(nudge):
	if (Input.is_key_pressed(KEY_CONTROL)):
		this_snap += nudge
	else:
		var this_ind = 0
		for i in range(snaps.size()):
			var v = snaps[i]
			if (this_snap >= v):
				this_ind = i
		this_ind = Util.math.pmod(this_ind + nudge, snaps.size())
		this_snap = snaps[this_ind]
	this_snap = max(1, min(32, this_snap))
	get_node("Snap/Label").text = "1/" + str(this_snap)

func update_song():
	var ogg = Util.data.read_ogg(song.song_path)
	if (ogg is AudioStreamOGGVorbis):
		beatmapper.stream = ogg
		beatmapper.set_loop(false)

func sort_bpm(a,b):
	return a.time < b.time

func update_bpm():
	bpm_array.sort_custom(self, "sort_bpm")
	var new_bpm = []
	for marker in bpm_array:
		new_bpm.append([marker.time, marker.bpm])
	song.bpm = new_bpm
	beatmapper.set_bpm(new_bpm)
	bpme.get_node("Delete").visible = bpm_array.size() > 1

func set_beat_scale(s):
	var scale = s / 128.0
	var invscale = 128.0 / s
	beat_tick.width = s
	container.scale = Vector2(1, scale)
	beat_scale = 720.0 / s
	for bpm in bpm_array:
		bpm.scale = Vector2(1, invscale)
	var increase = log(s) / log(2) - log(128) / log(2)
	var mid = max(1, pow(2,floor(increase + .5) + 2))
	beat_tick.divisions = mid
	for track in trackcont.get_children():
		for note in track.get_children():
			note.scale = Vector2(1, invscale)

func add_track(input = null):
	var exists = input
	if (not exists is TrackData):
		exists = TrackData.new()
		chart.tracks.append(exists)
	var nt = track_ex.duplicate()
	nt.name = str(trackbgs.get_children().size())
	nt.get_node("Label").text = str(trackbgs.get_children().size() + 1)
	nt.visible = true
	trackbgs.add_child(nt)
	nt.rect_position = sidescroll.get_node("NewTrack").rect_position
	sidescroll.get_node("NewTrack").rect_position += Vector2(80, 0)
	sidescroll.get_node("RemTrack").rect_position += Vector2(80, 0)
	sidescroll.get_node("RemTrack").visible = trackbgs.get_children().size() != 0
	beat_tick.rect_size += Vector2(80, 0)
	hitbar.rect_size += Vector2(80, 0)
	var new_cont = Node2D.new()
	new_cont.name = nt.name
	new_cont.position = Vector2(80,0) * (trackbgs.get_children().size() - 1)
	trackcont.add_child(new_cont)
	for note in exists.notes:
		var new_note = note_ex.duplicate()
		new_note.note = note
		new_note.note.track = trackbgs.get_children().size() - 1
		new_note.note.track_obj = exists
		new_note.note.object = new_note
		new_note.beat = note.beat
		new_note.track = trackcont.get_children().size() - 1
		new_note.position = Vector2(0, -note.beat * 128)
		new_note.visible = true
		new_cont.add_child(new_note)

func remove_track():
	trackcont.get_node(str(trackcont.get_children().size() - 1)).free()
	trackbgs.get_node(str(trackbgs.get_children().size() - 1)).free()
	chart.tracks.remove(chart.tracks.size() - 1)
	sidescroll.get_node("NewTrack").rect_position -= Vector2(80, 0)
	sidescroll.get_node("RemTrack").rect_position -= Vector2(80, 0)
	beat_tick.rect_size -= Vector2(80, 0)
	hitbar.rect_size -= Vector2(80, 0)
	sidescroll.get_node("RemTrack").visible = trackbgs.get_children().size() != 0

func remove_note(note):
	rem_selection(note.note)
	var track = chart.tracks[note.track]
	track.remove_note(note.note)
	note.queue_free()

func remove_all_notes():
	if (selection.size() > 0):
		while (selection.size() > 0):
			for note in selection:
				remove_note(selection[0].object)
	selection = []

func place_note(track, beat, remove = true, rnd = true):
	if (rnd):
		beat = snap_pos(beat)
	var note = chart.tracks[track].has(beat)
	if (not note is NoteData):
		var new_note = note_ex.duplicate()
		new_note.visible = true
		new_note.note = NoteData.new()
		new_note.note.track = track
		new_note.note.track_obj = chart.tracks[track]
		new_note.note.object = new_note
		new_note.note.beat = beat
		new_note.beat = beat
		new_note.track = track
		new_note.position = Vector2(0, -beat * 128)
		new_note.scale = Vector2(1, 128.0 / beat_tick.width)
		trackcont.get_node(str(track)).add_child(new_note)
		chart.tracks[track].notes.append(new_note.note)
		return new_note
	elif (remove == true):
		remove_note(note.object)
	else:
		return note.object

func marker_pressed(new_marker):
	if (state == "charting"):
		editing = new_marker
		state = "bpm"
		bpme.visible = true
		bpme.get_node("BG/Time/NumberEnter").set_value(new_marker.time)
		bpme.get_node("BG/BPM/NumberEnter").set_value(new_marker.bpm)

func add_marker(time, bpm):
	var new_marker = bpm_ex.duplicate()
	new_marker.visible = true
	new_marker.scale = Vector2(1, 128.0 / beat_tick.width)
	new_marker.time = time
	new_marker.bpm = bpm
	sidescroll.get_node("Container/Scroller/Markers").add_child(new_marker)
	bpm_array.append(new_marker)
	var this = self
	new_marker.get_node("Button").connect("pressed", self, "marker_pressed", [new_marker])

func duplicate_selection():
	if (selection.size() > 0):
		var earliest = INF
		for note in selection:
			earliest = min(earliest, note.beat)
		var this = snap_pos()
		var off = this - earliest
		var new_notes = []
		for note in selection:
			var new_note = place_note(note.track, note.beat + off, false, false)
			new_notes.append(new_note.note)
		deselect_all()
		for note in new_notes:
			add_selection(note)

func get_track_point(x):
		x -= 1280.0/2.0 - hscroll
		var hovered = -1
		for i in range(trackbgs.get_children().size()):
			if (i * 80 - 32 <= x and x <= i * 80 + 32):
				hovered = i
				break
		return hovered

func get_beat_point(y):
	var y_off = y - (720.0 - 128.0)
	y_off = -y_off / beat_tick.width
	return pos + y_off

func get_track_range(border1, border2):
	var left = min(border1, border2)
	var right = max(border1, border2)
	var first = -1
	var last = -1
	left -= 1280/2.0 - hscroll
	right -= 1280/2.0 - hscroll
	var tracks = trackbgs.get_children().size()
	for i in range(tracks):
		if (left < (tracks - 1 - i) * 80.0 + 32.0):
			first = (tracks - 1 - i)
		if (right > i * 80.0 - 32.0):
			last = i
	if (first >= 0 and last >= 0):
		return range(first, last + 1)

func clicked(ev, b):
	if (not get_node("BPMButton").is_hovered() and
		not get_node("Snap").is_hovered() and
		not get_node("BackToMenu").is_hovered() and
		not get_node("SaveToFile").is_hovered() and
		not get_node("Import").is_hovered() and
		not get_node("Duplicate").is_hovered() and
		not get_node("SongSettings").is_hovered()):
		if (state == "charting"):
			if (b == 1):
				var hovered = get_track_point(ev.position.x)
				if (hovered >= 0):
						var beat = get_beat_point(ev.position.y)
						place_note(hovered, beat)
			if (b == 2):
				start_select_pos = ev.position + Vector2(hscroll, 0)
				start_select_pos = Vector2(start_select_pos.x, get_beat_point(ev.position.y))
				selectbox.visible = true

func deselect_all():
	for note in selection:
		if (note != null):
			note.object.get_node("ColorRect").color = Color(1,1,1)
	selection = []

func add_selection(note):
	if (not selection.has(note)):
		note.object.get_node("ColorRect").color = Color(1,.9,.5)
		selection.append(note)

func rem_selection(note):
	if (selection.has(note)):
		for i in range(selection.size()):
			if (selection[i] == note):
				selection.remove(i)
				return

func nudge(tracks,units):
	if (selection.size() > 0):
		if (tracks != 0):
			var count = chart.tracks.size()
			var lb = count
			var rb = -1
			for note in selection:
				lb = min(lb, note.track)
				rb = max(lb, note.track)
			if (tracks > 0):
				if (rb + tracks >= count):
					return
			else:
				if (lb + tracks < 0):
					return
			for note in selection:
				var new_track = note.track + tracks
				note.track_obj.remove_note(note)
				note.track = new_track
				note.track_obj = chart.tracks[new_track]
				note.object.track = new_track
				note.object.get_node("..").remove_child(note.object)
				trackcont.get_node(str(new_track)).add_child(note.object)
				chart.tracks[new_track].notes.append(note)
		if (units != 0):
			var least = INF
			for note in selection:
				least = min(note.beat, least)
			if (least + units * 1.0/this_snap >= 0):
				for note in selection:
					note.beat += units * 1.0/this_snap
					note.object.position = Vector2(0, note.beat * -128)
			

func click_released(ev, b):
	if (not get_node("BPMButton").is_hovered() and
		not get_node("Snap").is_hovered() and
		not get_node("BackToMenu").is_hovered() and
		not get_node("SaveToFile").is_hovered() and
		not get_node("Import").is_hovered() and
		not get_node("Duplicate").is_hovered() and
		not get_node("SongSettings").is_hovered()):
		if (b == 2):
			if (start_select_pos):
				var np = start_select_pos - Vector2(hscroll, 0)
				np = Vector2(np.x, (720 - 128 - (np.y - pos) * beat_tick.width))
				var tp = ev.position
				selectbox.visible = false
				var track_range = get_track_range(np.x, tp.x)
				if (not Input.is_key_pressed(KEY_SHIFT)):
					deselect_all()
				if (track_range):
					var beat1 = get_beat_point(np.y)
					var beat2 = get_beat_point(tp.y)
					var beat_range = [min(beat1, beat2), max(beat1, beat2)]
					for trackn in track_range:
						var track = chart.tracks[trackn]
						for note in track.notes:
							if (beat_range[0] <= note.beat and note.beat <= beat_range[1]):
								add_selection(note)

func scroll(dir):
	if (state == "charting"):
		var width = beat_tick.width
		width = width * pow(1.1,dir)
		width = max(4, min(width, 720))
		set_beat_scale(width)

func _process(dt):
	if (state == "charting"):
		if Input.is_action_pressed("menu-left"):
			hscroll -= dt * 1280 / 2
		if Input.is_action_pressed("menu-right"):
			hscroll += dt * 1280 / 2
		if Input.is_action_pressed("menu-down"):
			pos -= dt * beat_scale
		if Input.is_action_pressed("menu-up"):
			pos += dt * beat_scale
	
	if (start_select_pos):
		var np = start_select_pos - Vector2(hscroll, 0)
		np = Vector2(np.x, (720 - 128 - (np.y - pos) * beat_tick.width))
		var tp = get_viewport().get_mouse_position()
		
		var tl = Vector2(min(np.x, tp.x), min(np.y, tp.y))
		var br = Vector2(max(np.x, tp.x), max(np.y, tp.y))
		var s = br - tl
		selectbox.rect_position = tl
		selectbox.rect_size = s
	
	pos = max(0, pos)
	if (state == "playing"):
		pos = beatmapper.get_beat()
	
	sidescroll.get_node("Label").text = "Beat " + str(floor(pos)) + "\n " + Util.data.time_format(beatmapper.get_time(pos))
	beat_tick.rect_position = Vector2(576, -1568 + Util.math.pmod(pos, 1) * beat_tick.width)
	scroller.position = Vector2(0, pos * 128)
	hscroll = max(0, min(80 * (trackbgs.get_children().size() - 1), hscroll))
	sidescroll.position = Vector2(-hscroll, 0)
	
	if (beatmapper.stream is AudioStreamOGGVorbis):
		endmarker.visible = true
		endmarker.scale = Vector2(1, 128.0 / beat_tick.width)
		endmarker.position = Vector2(-160, -128 * beatmapper.get_beat(beatmapper.stream.get_length() * 1000))
		endmarker.get_node("Label").text = "SONG END\n" + Util.data.time_format(beatmapper.stream.get_length() * 1000)
	else:
		endmarker.visible = false
	
	for v in bpm_array:
		v.position = Vector2(-160, -128 * beatmapper.get_beat(v.time))
		v.get_node("Label").text = str(v.bpm) + "\nBPM"

func _input(ev):
	if (ev is InputEvent):
		if (ev.is_action_pressed("menu-select")):
			if (beatmapper.stream is AudioStreamOGGVorbis):
				if (state == "charting"):
					state = "playing"
					beatmapper.play()
					beatmapper.seek_beat(pos)
				elif (state == "playing"):
					state = "charting"
					beatmapper.stop()
		elif (ev.is_action_pressed("nudge-up")):
			nudge(0,1)
		elif (ev.is_action_pressed("nudge-down")):
			nudge(0,-1)
		elif (ev.is_action_pressed("nudge-left")):
			nudge(-1,0)
		elif (ev.is_action_pressed("nudge-right")):
			nudge(1,0)
		elif (ev.is_action_pressed("delete-selection")):
			remove_all_notes()
	if (ev is InputEventMouseButton):
		if (ev.is_pressed()):
			if (ev.button_index == BUTTON_WHEEL_UP):
				scroll(1)
			if (ev.button_index == BUTTON_WHEEL_DOWN):
				scroll(-1)
			if (ev.button_index == BUTTON_LEFT):
				clicked(ev, 1)
			if (ev.button_index == BUTTON_RIGHT):
				clicked(ev, 2)
		else:
			if (ev.button_index == BUTTON_LEFT):
				click_released(ev, 1)
			if (ev.button_index == BUTTON_RIGHT):
				click_released(ev, 2)
