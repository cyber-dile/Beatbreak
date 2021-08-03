extends ColorRect

onready var close = $BG/TextureButton
onready var delete = $Delete

func _ready():
	var menu = get_node("..")
	var this = self
	delete.connect("pressed", func():
		menu.song.charts.remove(Data.data.get("selected_difficulty"))
		if (menu.song.charts.size() == 0):
			menu.song.remove()
		menu.get_tree().change_scene("res://resources/scenes/EditorSelect/EditorSelect.tscn")
	)
	close.connect("pressed", func():
		menu.state = "charting"
		this.visible = false
		menu.song.name = this.get_node("BG/SongName/TextEnter").get_value()
		menu.song.artist = this.get_node("BG/Artist/TextEnter").get_value()
		menu.song.credits = this.get_node("BG/Credits/TextEnter").get_value()
		menu.song.id = this.get_node("BG/ID/TextEnter").get_value()
		menu.song.song_path = this.get_node("BG/MusicPath/TextEnter").get_value()
		menu.song.scene_path = this.get_node("BG/ScenePath/TextEnter").get_value()
		menu.song.backdrop_path = this.get_node("BG/ImagePath/TextEnter").get_value()
		menu.chart.difficulty = this.get_node("BG/Diff/NumberEnter").get_value()
		menu.chart.color = this.get_node("BG/ChartColor/ColorEnter").get_value()
		menu.song.players = max(1, this.get_node("BG/Players/NumberEnter").get_value())
		menu.update_song()
	)
