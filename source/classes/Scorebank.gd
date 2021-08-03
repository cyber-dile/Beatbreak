class_name Scorebank
extends Node

var score = 0.0
var accuracy_total = 0.0
var accuracy_count = 0.0

func get_accuracy():
	if (accuracy_count == 0): return 0
	return floor(accuracy_total / accuracy_count * 10000) / 100

func add_accuracy(am): #0-1
	accuracy_total += am
	accuracy_count += 1

func add_score(new): score += new

func compile(): return [score, get_accuracy()]
