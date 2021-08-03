extends TextureButton

func button_pressed():
	var pe = get_node("../PropEditor")
	var menu = get_node("..")
	if (menu.state == "charting"):
		menu.state = "properties"
		pe.visible = true
		pe.refresh()

func _ready():
	connect("pressed", self, "button_pressed")
