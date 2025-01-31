class_name SlideState
extends PlayerMovementState

@export_range(1,6,0.1) var _slideAnimSpeed: float = 4.0

func enter(_previous_state) -> void:
	_set_tilt(_player._current_rotation)
	_animation.get_animation("PlayerMovement/Slide").track_set_key_value(4,0,_player.velocity.length())
	_animation.speed_scale = 1.0
	_animation.play("PlayerMovement/Slide", -1.0, _slideAnimSpeed)
	

func update(delta):
	_player._update_gravity(delta)
	# Disabled to prevent movement while sliding
	# _player._update_input(_player.velocity.length(),_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	if _player.is_on_floor():
		if Input.is_action_just_pressed("Jump"):
			transition.emit("JumpState")
	
	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")
	
func _set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(0.39 * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	_animation.get_animation("PlayerMovement/Slide").track_set_key_value(0,1,tilt)
	_animation.get_animation("PlayerMovement/Slide").track_set_key_value(0,2,tilt)
	
	print(_animation.get_animation("PlayerMovement/Slide").track_get_path(7))
	
func finish():
	transition.emit("CrouchState")
