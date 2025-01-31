class_name StateMachine
extends Node


@export var _currentState : State
# Holds all states that are a child of the StateMachine node
var states: Dictionary = {}


func _ready():
	# Validate all children nodes
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition.connect(on_child_transition)
			print("Log: State - " + str(child))
		else:
			push_warning("--!!StateMachine node contains incompatible child node!!--")
	# Enter state in export variable as starting state
	await owner.ready
	_currentState.enter(IdleState)


# Run current state's process
func _process(delta):
	_currentState.update(delta)
	Global.debug.addDebugProperty("State", _currentState.name, 1)
	
	
# Run current state's physics process
func _physics_process(delta):
	_currentState.physics_update(delta)
	
	
# Process state changes
func on_child_transition(new_state_name: StringName) -> void:
	var _newState = states.get(new_state_name)
	if _newState != null:
		if _newState != _currentState:
			_currentState.exit()
			_newState.enter(_currentState)
			_currentState = _newState
			print("Transitioned to State - " + str(_newState))
	else:
		push_warning("--!!State does not exist!!--")
