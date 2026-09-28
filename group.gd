extends CharacterBody2D
class_name Group

@export var quantity: int = 1
enum GroupType {GUARD, INMATE}
var fighting = false
var initiated_fight = true

@export var groupType: GroupType
