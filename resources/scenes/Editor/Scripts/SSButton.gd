extends TextureButton

func button_pressed():
	var menu = get_node("..")
	var se = get_node("../SongEditor")
	if (menu.state == "charting"):
		menu.state = "song"
		se.visible = true
		se.get_node("BG/SongName/TextEnter").set_value(menu.song.name)
		se.get_node("BG/Artist/TextEnter").set_value(menu.song.artist)
		se.get_node("BG/Credits/TextEnter").set_value(menu.song.credits)
		se.get_node("BG/ID/TextEnter").set_value(menu.song.id)
		se.get_node("BG/MusicPath/TextEnter").set_value(menu.song.song_path)
		se.get_node("BG/ScenePath/TextEnter").set_value(menu.song.scene_path)
		se.get_node("BG/ImagePath/TextEnter").set_value(menu.song.backdrop_path)
		se.get_node("BG/Diff/NumberEnter").set_value(menu.chart.difficulty)
		se.get_node("BG/ChartColor/ColorEnter").set_value(menu.chart.color)
		se.get_node("BG/Players/NumberEnter").set_value(menu.song.players)

func _ready():
	connect("pressed", self, "button_pressed")
