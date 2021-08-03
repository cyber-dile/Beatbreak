extends TextureButton

onready var label = $Label
export var limit = 6

func set_value(new_val):
	label.text = Util.data.get_hex(new_val).substr(0,6)

func get_value():
	return Color("#" + label.text)

func _input(ev):
	if (get_focus_owner() == self or get_focus_owner() == label):
		if (ev is InputEventKey and ev.pressed):
			match (ev.scancode):
				KEY_0: if (label.text.length() < limit): label.text = label.text + "0"
				KEY_1: if (label.text.length() < limit): label.text = label.text + "1"
				KEY_2: if (label.text.length() < limit): label.text = label.text + "2"
				KEY_3: if (label.text.length() < limit): label.text = label.text + "3"
				KEY_4: if (label.text.length() < limit): label.text = label.text + "4"
				KEY_5: if (label.text.length() < limit): label.text = label.text + "5"
				KEY_6: if (label.text.length() < limit): label.text = label.text + "6"
				KEY_7: if (label.text.length() < limit): label.text = label.text + "7"
				KEY_8: if (label.text.length() < limit): label.text = label.text + "8"
				KEY_9: if (label.text.length() < limit): label.text = label.text + "9"
				KEY_A: if (label.text.length() < limit): label.text = label.text + "A"
				KEY_B: if (label.text.length() < limit): label.text = label.text + "B"
				KEY_C: if (label.text.length() < limit): label.text = label.text + "C"
				KEY_D: if (label.text.length() < limit): label.text = label.text + "D"
				KEY_E: if (label.text.length() < limit): label.text = label.text + "E"
				KEY_F: if (label.text.length() < limit): label.text = label.text + "F"
				KEY_BACKSPACE: label.text = label.text.substr(0, label.text.length() - 1)
