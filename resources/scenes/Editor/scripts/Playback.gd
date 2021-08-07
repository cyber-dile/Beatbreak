extends TextureButton

func button_pressed():
	var menu = get_node("..")
	release_focus()
	if (menu.state == "charting"):
		if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
			menu.update_pb(-1)
		else:
			menu.update_pb(1)

func _ready():
	var this = self
	connect("button_down", self, "button_pressed")
