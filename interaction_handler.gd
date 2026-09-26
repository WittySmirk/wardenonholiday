
@tool
extends Node

@export var guard_lower_bound = 0
@export var guard_upper_bound = 0
@export var inmate_lower_bound = 0
@export var inmate_upper_bound = 0

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
	
