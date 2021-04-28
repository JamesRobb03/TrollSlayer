extends Node2D

#Very (VERY) simple component which handles keeping track of enemy states
#Originally one of my design patterns was Finite State Machines, however 
#all the implementations of these i found used classes and this would not 
#have worked with the Entity Component System pattern so I went about doing it 
#this way. I feel like it differs too much from the original pattern so i changed
#my two game design patterns to Singleton and Game Loop instead of FSM and Gameloop.
#however i still felt as though this worked well so decided to keep it.
var currentState = "idle"

func setStateIdle():
	currentState = "idle"

func setStateAttack():
	currentState = "attack"
	
func setStateChase():
	currentState = "chase"
	
func setStateDead():
	currentState = "dead"
