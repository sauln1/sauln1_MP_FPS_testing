class_name OnWallState
extends PlayerMovementState

func enter(_previous_state) -> void:
	_player._gravity = 0


func update(delta):
	_player._update_input(_player._speed, _player._acceleration, _player._deceleration)
	_player._update_velocity()
	
	if !_player.is_on_wall():
		_player._gravity = _player._gravityNormal
		_player._update_gravity(delta)
		if _player.is_on_floor():
			_animation.play("PlayerMovement/JumpLand")

			if _player.velocity.length() == 0.0:
				transition.emit("IdleState")

			if Input.is_action_just_pressed("Sprint"):
				transition.emit("SprintState")

			if Input.is_action_just_pressed("Crouch"):
				transition.emit("CrouchState")
			
			if Input.is_action_just_pressed("Jump"):
				transition.emit("JumpState")

	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")
