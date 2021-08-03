class_name Threshold
extends Object

var input
var threshold = .5
var held = false
var changed = false

func refresh():
	if (input):
		var val = input.call_func()
		if (val is float or val is int):
			val = val >= self.threshold
		if not val:
			val = false
		changed = val != held
		held = val
