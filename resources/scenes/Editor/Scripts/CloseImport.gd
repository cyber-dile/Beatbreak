extends TextureButton

func button_pressed():
	var menu = get_node("../../..")
	var im = get_node("../..")
	menu.state = "charting"
	im.visible = false

func _ready():
	connect("pressed", self, "button_pressed")
