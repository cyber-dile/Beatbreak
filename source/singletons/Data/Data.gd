extends Node

var settings
var data
var scores
var songs

func _ready():
	settings = add_node(load("res://source/singletons/Data/settings.gd"))
	data = add_node(load("res://source/singletons/Data/data_storage.gd"))
	scores = add_node(load("res://source/singletons/Data/scores.gd"))
	songs = add_node(load("res://source/singletons/Data/songs.gd"))
	
	var dir = Directory.new()
	dir.open("user://")
	dir.make_dir("packages")
	dir.open("user://packages")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		ProjectSettings.load_resource_pack("user://packages/" + file_name, true)
		file_name = dir.get_next()

func add_node(x):
	x = x.new()
	add_child(x)
	return x
