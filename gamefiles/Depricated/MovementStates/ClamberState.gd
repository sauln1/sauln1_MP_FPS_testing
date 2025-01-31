class_name ClamberState
extends PlayerMovementState

@export var _vertMoveTime: float = 0.35
@export var _horiMoveTime: float = 0.15
	
func enter(_previous_state) -> void:
	_clamber()


func _update(delta):
	_player._update_gravity(delta)
	_player._update_input(_player._speed,_player._acceleration,_player._deceleration)
	_player._update_velocity()


func _clamber():
	_player.velocity = Vector3.ZERO
	
	# Vertical Transforms
	var _verticalMovement = _player.global_transform.origin + Vector3(0,1.2,0)
	var _verticalTween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	# Smoothing, and move player up
	_verticalTween.tween_property(_player,"global_transform:origin", _verticalMovement, _vertMoveTime)
	
	# Wait for vertical movement to finish before starting horizontal
	await _verticalTween.finished
	
	# Horizontal Transforms
	var _forwardMovement = _player.global_transform.origin + (-_player.basis.z * 1.2)
	var _forwardTween = get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	
	_forwardTween.tween_property(_player, "global_transform:origin", _forwardMovement, _horiMoveTime)

	await _forwardTween.finished
	
	transition.emit("IdleState")
