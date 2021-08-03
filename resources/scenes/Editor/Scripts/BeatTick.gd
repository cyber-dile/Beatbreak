tool
extends Control

export var width = 128
export var divisions = 2
export var color = Color(1,1,1,.1)

func pmod(a,b):
	var v = fmod(a,b)
	if (v < 0): v += b
	return v

func _draw():
	var center = rect_size.y / 2
	var iterations = ceil(rect_size.y / width / 2 * divisions)
	for i in range(-iterations, iterations):
		var c = center + width / divisions * i
		var co = color
		var off = pmod(i, divisions)
		if (off == 0):
			co = co.linear_interpolate(Color(1,1,1,1),.5)
		draw_rect(Rect2(Vector2(0,c - 1),Vector2(rect_size.x, 2)), co)

func _process(dt):
	update()
