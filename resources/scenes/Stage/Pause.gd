extends Node2D

onready var button0 = $Button0
onready var button1 = $Button1

var stage
var selection = 0

func _ready():
	stage = get_node("..")

func entered():
	set_selection(0)

func left():
	pass

func set_selection(n):
	selection = n
	button0.color						= (Color(1,1,1) if n == 0 else Color())
	button1.color						= (Color(1,1,1) if n == 1 else Color())
	button0.get_node("Label").modulate	= (Color(1,1,1) if n == 1 else Color())
	button1.get_node("Label").modulate	= (Color(1,1,1) if n == 0 else Color())

func _input(ev):
	if (visible and ev is InputEvent):
		if (ev.is_action_pressed("menu-left") or ev.is_action_pressed("menu-right")):
			set_selection(fmod(selection + 1, 2))
		elif (ev.is_action_pressed("menu-select")):
			match (int(selection)):
				0: stage.pause()
				1: stage.exit()
