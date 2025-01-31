class_name Player
extends CharacterBody3D

# Player Variables
@export var _walking_speed: float = 7
@export var _sprint_speed: float = 10
@export var _crouch_speed: float = 5
@export var _jumpVelocity: float = 5.5
@export var _maxHealth: float = 100.0
@export var _currentHealth: float = 100.0

# Game Settings
@export var _acceleration: float = 0.4
@export var _deceleration: float = 0.3
@export_range(0.5,1.0,0.01) var _inputMultiplier: float = .95
@export var _horizontal_sens: float = 0.75
@export var _vertical_sens: float = 0.75
@export var _topAnimationSpeed: float = 1
var _speed: float
var _playerInput: Vector3
var _mouse_input: bool = false
var _rotation_input: float
var _tilt_input: float
var _mouse_rotation: Vector3
var _tilt_lower_limit := deg_to_rad(-90.0)
var _tilt_upper_limit := deg_to_rad(90.0)
@onready var _camera_controller: Camera3D = $Head/Camera3D
@onready var _animationPlayer: AnimationPlayer = $AnimationPlayer
var _player_rotation: Vector3
var _camera_rotation: Vector3
var _current_rotation: float
@onready var _head: Node3D = $Head

@onready var chestRay = $ChestClamberCheck
@onready var headRay = $HeadClamberCheck

# Debug variables
var _fps: String

# Gravity Settings
@export var _gravityNormal = 12
@export var _wallRunGravity: float = 3.0
@onready var _gravity = _gravityNormal #ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event):
	if Input.is_action_pressed("debugExit"):
		get_tree().quit()


func _unhandled_input(event):
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * _horizontal_sens
		_tilt_input = -event.relative.y * _vertical_sens


func _update_camera(delta):
	# Slide rotation
	_current_rotation = _rotation_input
	
	# Rotate camera
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, _tilt_lower_limit, _tilt_upper_limit)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	_camera_controller.transform.basis = Basis.from_euler(_camera_rotation)
	_camera_controller.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	_rotation_input = 0.0
	_tilt_input = 0.0


func _ready():
	Global.player = self
	_speed = _walking_speed
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _process(delta):
	# DEBUG
	_fps = "%.2f" % (1.9/delta)
	Global.debug.addDebugProperty("FPS", _fps, 1)
	Global.debug.addDebugProperty("Speed", round(velocity.length()), 3)
	Global.debug.addDebugProperty("Floor", is_on_floor(), 4)
	Global.debug.addDebugProperty("Health", _currentHealth, 5)
	Global.debug.addDebugProperty("Can Clamber", canClamber(), 6)
	Global.debug.addDebugProperty("Is on wall", is_on_wall(), 7)
	
	
func _physics_process(delta):
	# Rotate Camera
	_update_camera(delta)
	canClamber()


func _update_gravity(delta) -> void:
	velocity.y -= _gravity * delta
	
	
func _update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var _input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var _direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()

	if _direction:
		velocity.x = lerp(velocity.x, _direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, _direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)
	
	
func _update_velocity() -> void:
	move_and_slide()


func canClamber():
	if chestRay.is_colliding() and !headRay.is_colliding():
		return true
	else:
		return false
