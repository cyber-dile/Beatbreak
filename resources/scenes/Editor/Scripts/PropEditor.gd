extends ColorRect

onready var ex = $BG/Container/Example
onready var container = $BG/Container
onready var scroller = $BG/Container/Scroller
onready var np = $BG/NewProp
onready var dp = $BG/DelProp

var song
var settings
var vscroll = 0.0

func _ready():
	ex.visible = false
	dp.connect("pressed", self, "del_prop")
	np.connect("pressed", self, "new_prop")
	get_node("BG/TextureButton").connect("pressed", self, "close")

func del_prop():
	if (scroller.get_children().size() > 0):
		scroller.get_node(str(scroller.get_children().size() - 1)).free()

func new_prop():
	var new = ex.duplicate()
	new.name = str(scroller.get_children().size())
	new.rect_position = Vector2(0,80 * scroller.get_children().size())
	new.visible = true
	scroller.add_child(new)

func refresh():
	song = get_node("..").song
	settings = song.settings
	for child in scroller.get_children():
		child.free()
	for i in range(settings.size()):
		var setting = settings[i]
		var sname = setting[0]
		var type = setting[1]
		var value = setting[2]
		if (type == "keybind" or type == "menu"):
			value = value[1]
		if (value is Array):
			value = JSON.print(value)
		else:
			value = str(value)
		var new_ex = ex.duplicate()
		new_ex.name = str(i)
		new_ex.visible = true
		scroller.add_child(new_ex)
		new_ex.get_node("PName").set_value(sname)
		new_ex.get_node("PType").set_value(type)
		new_ex.get_node("PValue").set_value(value)
		new_ex.rect_position = Vector2(0,80 * i)

func close():
	var menu = get_node("..")
	menu.state = "charting"
	visible = false
	var new_settings = []
	for i in range(scroller.get_children().size()):
		var v = scroller.get_node(str(i))
		var pname = v.get_node("PName").get_value()
		var type = v.get_node("PType").get_value()
		var value = v.get_node("PValue").get_value()
		match (type):
			"keybind":
				var sc = OS.find_scancode_from_string(value)
				if (sc):
					new_settings.append([pname, type, ["keyboard", value]])
			"menu":
				var res = JSON.parse(value)
				if (res.error == OK):
					var dat = res.result
					if (dat is Array):
						var valid = true
						for element in dat:
							if (element is Array or element is Dictionary):
								valid = false
								break
						if (valid):
							new_settings.append([pname, type, [dat[0], dat]])
			"integer":
				new_settings.append([pname, type, value.to_int()])
			"boolean":
				new_settings.append([pname, type, (value.to_lower() == "true")])
	song.settings = new_settings

func scroll(dir):
	vscroll -= dir * 16

func _process(dt):
	var mins = 0
	var maxs = max(0, scroller.get_children().size() * 80 - 336)
	vscroll = max(mins, min(vscroll, maxs))
	scroller.position = Vector2(0,-vscroll)

func _input(ev):
	if (ev.is_pressed() and ev is InputEventMouseButton):
		if (ev.button_index == BUTTON_WHEEL_UP):
			scroll(1)
		if (ev.button_index == BUTTON_WHEEL_DOWN):
			scroll(-1)
