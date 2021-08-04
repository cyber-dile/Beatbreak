extends Track

onready var n_ex = $NoteEx

func _ready():
	n_ex.visible = false
	note_template = n_ex

func hit_note(note):
	var score = stage.scores[0]
	score.add_score(500)
	score.add_accuracy(1)

func miss_note(note):
	var score = stage.scores[0]
	score.add_score(-250)
	score.add_accuracy(0)

func hit_nothing():
	var score = stage.scores[0]
	score.add_score(-100)
	score.add_accuracy(0)
	
func process_note(note, dt):
	var pos = beatmapper.get_time() - beatmapper.get_time(note.beat)
	note.transform.origin = Vector3(0, -pos / 125, 0)
