extends TextureButton

func button_pressed():
	var menu = get_node("..")
	var im = get_node("../ImportSM")
	if (menu.state == "charting"):
		menu.state = "import"
		im.visible = true

func _ready():
	connect("pressed", self, "button_pressed")
