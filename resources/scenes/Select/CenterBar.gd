tool
extends Control

var c = Vector2(640, 360)
func _draw():
	for i in range(-13, 13):
		draw_rect(Rect2(c + i * Vector2(32, 32) - Vector2(320, 16), Vector2(640, 32)), Color(1,1,1,1))
