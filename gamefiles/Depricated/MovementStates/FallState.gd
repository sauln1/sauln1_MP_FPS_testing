class_name FallState
extends PlayerMovementState

# Boost Jump (If gear is equipped)
var _canBoostJump: bool = false # Is BoostPack in Player gear?
var _hasBoostJumped: bool = false

var _fallDamage: float = 0.0
var _fallDuration: float = 0.0
@onready var _fallTimer: Timer = %fallTimer

#func _ready():
	#_fallTimer.wait_time = 1.7


func enter(_previous_state) -> void:
	_animation.pause()
	_fallTimer.wait_time = 1.7
	_fallDuration = 0


func exit() -> void:
	_hasBoostJumped = false


func update(delta: float) -> void:
	_player._update_gravity(delta)
	_player._update_input(_player._speed,_player._acceleration,_player._deceleration)
	_player._update_velocity()
	
	_fallDuration += delta
	
	if Input.is_action_just_pressed("Jump") and _hasBoostJumped == false:
		_hasBoostJumped = true
		_player.velocity.y = _player._jumpVelocity
		_fallDuration = 0
		
	if _player.is_on_floor():
		_fallDuration = 0
		_fallDamage = snapped(_fallDuration,.1) * 15
		
		_player._currentHealth - _fallDamage
		
		if _player._currentHealth <= 0 or _fallDuration > 7.0:
			#transition.emit("DeathState")
			pass
		else:
			_animation.play("PlayerMovement/JumpLand")
			transition.emit("IdleState")
