extends Node

func get_display(setting):
	var result
	match (setting[1]):
		"integer", "boolean": result = setting[2]
		"menu": result = setting[2][0] # value is [option, [list, of, option, s]]
		"keybind": # value is [keytype, keybind, controllerport?]
			match (setting[2][0]):
				"keyboard": return setting[2][1]
				"controller": return setting[2][1] + " (" + str(setting[2][2]) + ")"
	result = str(result)
	if (setting.size() > 3):
		result = setting[3][0] + result + setting[3][1]
	return result
