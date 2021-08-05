extends TextureButton

func button_pressed():
	var menu = get_node("..")
	release_focus()
	if (menu.state == "charting"):
		if (Input.is_key_pressed(KEY_SHIFT)):
			menu.update_hold(-1)
		else:
			menu.update_hold(1)

func _ready():
	var this = self
	connect("button_down", self, "button_pressed")
