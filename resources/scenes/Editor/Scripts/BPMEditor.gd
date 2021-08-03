extends ColorRect

onready var close = $BG/TextureButton
onready var delete = $Delete

func close_menu():
	var menu = get_node("..")
	menu.state = "charting"
	visible = false
	menu.editing.time = get_node("BG/Time/NumberEnter").get_value()
	menu.editing.bpm = get_node("BG/BPM/NumberEnter").get_value()
	menu.update_bpm()

func delete_marker():
	var menu = get_node("..")
	for i in range(menu.bpm_array.size()):
		var v = menu.bpm_array[i]
		if (v == menu.editing):
			menu.bpm_array.remove(i)
			break
	menu.editing.free()
	menu.state = "charting"
	menu.update_bpm()
	visible = false

func _ready():
	close.connect("pressed", self, "close_menu")
	delete.connect("pressed", self, "delete_marker")
