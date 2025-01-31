class_name State
extends Node

# Emits when we transition
signal transition(new_state_name: StringName)

# What happens when we enter a state
func enter(_previous_state) -> void:
	pass
	
# What happens when we exit a state
func exit() -> void:
	pass
	
# Process function, occurs every frame
func update(delta: float) -> void:
	pass
	
# Physics Process
func physics_update(delta: float) -> void:
	pass
