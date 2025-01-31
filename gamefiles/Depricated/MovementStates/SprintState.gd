class_name SprintState
extends PlayerMovementState

func enter(_previous_state) -> void:
	# Play animations
	_player._speed = _player._sprint_speed


func exit() -> void:
	_animation.speed_scale = 1.0


func update(delta):
	_player._update_gravity(delta)
	_player._update_input(_player._sprint_speed,_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	if _player.is_on_floor():
		if _player.velocity.length() == 0.0:
			transition.emit("IdleState")
	
		if Input.is_action_just_released("Sprint"):
			transition.emit("WalkingState")

		if Input.is_action_just_pressed("Crouch") and _player.velocity.length() > 6:
			transition.emit("SlideState")
			
		if Input.is_action_just_pressed("Jump") and !_player.is_on_wall():
			transition.emit("JumpState")

		if Input.is_action_pressed("Jump") and _player.is_on_wall():
			transition.emit("OnWallState")

	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")
