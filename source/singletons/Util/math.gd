extends Node

func pmod(a,b):
	var v = fmod(a,b)
	if v < 0: v += b
	return v

func lerp(a,b,c): return a + (b-a) * c
func lerpc(c, rt, dt): return 1 - pow((1 - c), (dt/rt))
func logb(a,b = 10): return log(a)/log(b)

func logtick(cval, dval, b = 10):
	if (cval == dval): return cval
	return cval + pow(b, max(0, floor(logb(abs(dval - cval) - .5, b)))) * sign(dval - cval)

func format(number):
	if (number == 0): return "0"
	var sn = sign(number)
	var before = floor(abs(number))
	var remaining = abs(number) - before
	number = str(number)
	var n = ""
	for i in range(number.length()):
		var c = number.substr(number.length() - i - 1, 1)
		n = c + n
		if ((i % 3) == 2 and i != number.length() - 1):
			n = "," + n
	return ("-" if sn < 0 else "") + n + str(remaining).substr(2, -1)
