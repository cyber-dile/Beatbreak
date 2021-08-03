extends TextureButton

onready var label = $Label

func set_value(new_val):
	label.text = str(new_val)

func get_value():
	return str(label.text)

func _input(ev):
	if (get_focus_owner() == self or get_focus_owner() == label):
		if (ev is InputEventKey and ev.pressed):
			match (ev.scancode):
				KEY_BACKSPACE: label.text = label.text.substr(0, label.text.length() - 1)
				_: label.text += char(ev.unicode)
