extends Label

var stage

func _ready():
	stage = get_node("../..")
	visible = not stage.preview

func _process(dt):
	text = "Score: " + str(stage.scores[0].score)
