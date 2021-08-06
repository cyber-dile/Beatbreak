extends TextureButton

func clicked():
	var path = get_node("../Path/TextEnter").get_value()
	var editor = get_node("../../..")
	
	var sm = Util.data.imp_sm(path)
	if (sm):
		editor.song.bpm = sm.bpm
		
		for track in sm.tracks:
			var nt = TrackData.new()
			for note in track:
				var nn = NoteData.new()
				nn.beat = note[0]
				if (note.size() > 1 and note[1] > 0):
					nn.data["hold"] = note[1]
				nt.notes.append(nn)
			nt.sort()
			editor.chart.tracks.append(nt)
		
		get_tree().change_scene("res://resources/scenes/Editor/Editor.tscn")

func _ready():
	connect("pressed", self, "clicked")
