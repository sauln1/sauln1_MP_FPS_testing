class_name CrouchState
extends PlayerMovementState

@onready var _crouchShapecast: ShapeCast3D = %CrouchCollision
var _slideRelease: bool = false

func enter(_previous_state) -> void:
	_player._animationPlayer.speed_scale = 1.0
	if _previous_state.name != "SlideState":
		_player._animationPlayer.play("PlayerMovement/Crouch",-1.0,_player._crouch_speed)
	elif _previous_state.name == "SlideState":
		_player._animationPlayer.current_animation = "PlayerMovement/Crouch"
		_player._animationPlayer.seek(1.0,true)


func exit() -> void:
	_slideRelease = false


func update(delta):
	_player._update_gravity(delta)
	_player._update_input(_player._crouch_speed,_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	if _player.is_on_floor():
		if Input.is_action_just_released("Crouch"):
			_uncrouch()
		elif Input.is_action_pressed("Crouch") == false and _slideRelease == false:
			_slideRelease = true
			_uncrouch()
		
		if Input.is_action_just_pressed("Jump"):
			transition.emit("JumpState")

	elif !_player.is_on_floor() and _player.velocity.y < -3.0:
		transition.emit("FallState")

func _uncrouch():
	if _crouchShapecast.is_colliding() == false and Input.is_action_pressed("Crouch") == false:
		_animation.play("PlayerMovement/Crouch", -1.0, -_player._crouch_speed, true)
		if _animation.is_playing():
			await _animation.animation_finished
		transition.emit("IdleState")
	elif _crouchShapecast.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		_uncrouch()
