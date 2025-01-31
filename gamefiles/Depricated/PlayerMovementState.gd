class_name PlayerMovementState
extends State

var _player: Player
var _animation: AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	await owner.ready
	_player = owner as Player
	_animation = _player._animationPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
