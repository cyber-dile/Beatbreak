extends Node

var scores = [] # ["song-id", [[score1, acc1], [score2, acc2]]]

func _ready():
	load_scores()

func save_scores():
	var f = File.new()
	f.open("user://scores.json", File.WRITE)
	f.store_string(JSON.print(scores))
	f.close()

func load_scores():
	var f = File.new()
	f.open("user://scores.json", File.READ)
	var data = f.get_as_text()
	f.close()
	var res = JSON.parse(data)
	if (res.error == OK):
		scores = res.result

func get_array(id):
	for score in scores:
		if (score[0] == id): return score

func get_song(song, chart):
	if (song):
		var players = song.players
		var index = song.id + "-" + str(chart)
		var arr = get_array(index)
		if (arr and arr[1].size() != song.players):
			for i in range(scores.size()):
				var v = scores[i]
				if v[0] == index:
					scores.remove(i)
					break
			arr = null
		if (not arr is Array):
			var new_arr = [index, []]
			for i in range(players):
				new_arr[1].append([0,0])
			scores.append(new_arr)
			return new_arr[1]
		return arr[1]

func update_scores(song, chart, scores):
	var arr = get_song(song, chart)
	for i in range(scores.size()):
		var j = scores[i]
		var k = arr[i]
		k[0] = max(j[0], k[0])
		k[1] = max(j[1], k[1])
