extends MeshInstance

var beat
var note
var track
var loaded = false

func init():
	visible = false

func on_load():
	visible = true
	track.add_child(self)

func remove(note_hit):
	visible = false
	track.remove_child(self)
