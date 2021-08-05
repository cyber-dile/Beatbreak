extends ColorRect

onready var close = $BG/TextureButton
onready var delete = $Delete

func delete_chart():
	var menu = get_node("..")
	menu.song.charts.remove(Data.data.get("selected_difficulty"))
	if (menu.song.charts.size() == 0):
		menu.song.remove()
	menu.get_tree().change_scene("res://resources/scenes/EditorSelect/EditorSelect.tscn")

func close_chart():
	var menu = get_node("..")
	menu.state = "charting"
	visible = false
	menu.song.name = get_node("BG/SongName/TextEnter").get_value()
	menu.song.artist = get_node("BG/Artist/TextEnter").get_value()
	menu.song.credits = get_node("BG/Credits/TextEnter").get_value()
	menu.song.id = get_node("BG/ID/TextEnter").get_value()
	menu.song.song_path = get_node("BG/MusicPath/TextEnter").get_value()
	menu.song.scene_path = get_node("BG/ScenePath/TextEnter").get_value()
	menu.song.backdrop_path = get_node("BG/ImagePath/TextEnter").get_value()
	menu.chart.difficulty = get_node("BG/Diff/NumberEnter").get_value()
	menu.chart.color = get_node("BG/ChartColor/ColorEnter").get_value()
	menu.song.players = max(1, get_node("BG/Players/NumberEnter").get_value())
	menu.update_song()

func _ready():
	delete.connect("pressed", self, "delete_chart")
	close.connect("pressed", self, "close_chart")
