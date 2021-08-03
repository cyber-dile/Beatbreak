extends Node

var math
var settings
var data

func _ready():
	math = add_node(load("res://source/singletons/Util/math.gd"))
	settings = add_node(load("res://source/singletons/Util/settings.gd"))
	data = add_node(load("res://source/singletons/Util/data.gd"))

func add_node(x):
	x = x.new()
	add_child(x)
	return x
