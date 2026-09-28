
#@tool
extends Node

var guard_lower_bound = 1
var guard_upper_bound = 20
var inmate_lower_bound = 1
var inmate_upper_bound = 3

func getStrength(lowerBound, upperBound, numRolls) -> int:
	var strength = 0
	for i in range(numRolls):
		strength += randi_range(int(lowerBound), int(upperBound))
	return strength

func get_interaction_result(numGuards, numInmates) -> String:
	var guardStrength = getStrength(guard_lower_bound, guard_upper_bound, numGuards)
	var inmateStrength = getStrength(inmate_lower_bound, inmate_upper_bound, numInmates) 
	
	if guardStrength > inmateStrength:
		return "GUARDS";
	else:
		return "INMATES";
		
		

func fight(guard: Group, inmate: Group, did_inmates_initiate: bool):
	print("Fighting")
	var result = get_interaction_result(
		guard.quantity,
		inmate.quantity
	)
	
	
	if result == "GUARDS":
		inmate.retreat(did_inmates_initiate, guard)
	else:
		guard.retreat(did_inmates_initiate, inmate)

#@export var interaction_test: bool = false:
	#set(value):
		#interaction_test = value
		#if value:
			#print("Testing")
			#var guardWinCount = 0
			#var inmateWinCount = 0
			#
			#for i in range(100000):
				#var interaction_result = get_interaction_result(2, 8)
				#if interaction_result == "GUARDS":
					#guardWinCount+=1
				#else:
					#inmateWinCount+=1
			#
			#print("Guard win count:", guardWinCount)
			#print("Inmate win count:", inmateWinCount)
			#print("Guard win percentage: ", float(guardWinCount) / (guardWinCount + inmateWinCount) * 100)
				#
			#interaction_test = false
	
