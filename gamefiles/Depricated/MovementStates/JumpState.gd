class_name JumpState
extends PlayerMovementState

# Boost Jump (If gear is equipped)
var _canBoostJump: bool = false # Is BoostPack in Player gear?
var _hasBoostJumped: bool = false

func enter(_previous_state) -> void:
	_player.velocity.y += _player._jumpVelocity
	_animation.play("PlayerMovement/JumpStart")

func update(delta):
	_player._update_gravity(delta)
	_player._update_input(_player.velocity.length()*_player._inputMultiplier,_player._acceleration,_player._deceleration)
	_player._update_velocity()

	if _player.canClamber() == false:
		if Input.is_action_just_pressed("Jump") and _canBoostJump == true and _hasBoostJumped == false:
			_hasBoostJumped = true
			_player.velocity.y = _player._jumpVelocity
	
		if Input.is_action_just_released("Jump"):
			if _player.velocity.y > 0:
				_player.velocity.y = _player.velocity.y / 2.0

		if _player.is_on_floor():
			_animation.play("PlayerMovement/JumpLand")
			transition.emit("IdleState")
		
		elif !_player.is_on_floor() and _player.velocity.y < -3.0:
			transition.emit("FallState")
			
	elif _player.canClamber() == true:
		transition.emit("ClamberState")
