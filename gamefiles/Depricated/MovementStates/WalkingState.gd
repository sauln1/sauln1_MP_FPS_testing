class_name WalkingState
extends PlayerMovementState


func enter(_previous_state) -> void:
	# Play animations
	_player._speed = _player._walking_speed


func exit() -> void:
	_animation.speed_scale = 1.0


func update(delta):
	_player._update_gravity(delta)
	_player._update_input(_player._walking_speed,_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	set_animation_speed(_player.velocity.length())
	
	if _player.is_on_floor():
		if _player.velocity.length() == 0.0:
			transition.emit("IdleState")

		if Input.is_action_just_pressed("Sprint") or Input.is_action_pressed("Sprint"):
			transition.emit("SprintState")

		if Input.is_action_just_pressed("Crouch"):
			transition.emit("CrouchState")
			
		if Input.is_action_just_pressed("Jump"):
			transition.emit("JumpState")

	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")
		
		
func set_animation_speed(speed):
	var alpha = remap(speed, 0.0, _player._speed, 0.0, 1.0)
	_animation.speed_scale = lerp(0.0, _player._topAnimationSpeed, alpha)
