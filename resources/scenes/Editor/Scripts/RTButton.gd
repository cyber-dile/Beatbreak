extends TextureButton

func button_pressed():
	var menu = get_node("../../..")
	release_focus()
	if (menu.state == "charting"):
		menu.remove_track()

func _ready():
	var menu = get_node("../../..")
	var this = self
	connect("pressed", self, "button_pressed")
