extends Spatial

export var MAX_HP = 100
export var knbckFunc = false
export var deathFunc = false
export var debug = true
var hp = MAX_HP
onready var character = get_parent()

func hurt_Char(dm,kb):
	hp -= dm
	print(hp)
	if knbckFunc:
		character.ApplyKB(kb)
	if hp <= 0 and deathFunc:
		character.Death()
