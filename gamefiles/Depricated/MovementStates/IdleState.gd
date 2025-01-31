class_name IdleState
extends PlayerMovementState

func enter(_previous_state) -> void:
	# Play animations
	if _animation.is_playing() and _animation.current_animation == "JumpEnd":
		await _animation.animation_finished
		_animation.pause()
	else:
		_animation.pause()


func update(delta):
	_player._update_gravity(delta)
	_player._update_input(0,_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	if _player.is_on_floor():
		if Input.is_action_pressed("Forward") or Input.is_action_pressed("Backward") or Input.is_action_pressed("Left") or Input.is_action_pressed("Right"): 
			transition.emit("WalkingState")
		
		if Input.is_action_just_pressed("Crouch"):
			transition.emit("CrouchState")

		if Input.is_action_just_pressed("Jump"):
			transition.emit("JumpState")
			
	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")
