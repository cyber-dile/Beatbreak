extends TextureButton

onready var label = $Label
export var minus = true
export var limit = 16
export var decimal = true

func set_value(new_val):
	label.text = str(new_val)

func get_value():
	if (label.text.length() == 0): return 0
	return label.text.to_float()

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
				KEY_MINUS:
					if (label.text.length() == 0 and minus):
						label.text = "-"
				KEY_BACKSPACE: label.text = label.text.substr(0, label.text.length() - 1)
				KEY_PERIOD, KEY_KP_PERIOD:
					if (label.text.find(".") < 0 and decimal):
						label.text += "."
