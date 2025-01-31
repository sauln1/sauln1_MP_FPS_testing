extends MultiplayerSynchronizer

@onready var player = $".."
var input_direction
var input_jump
var input_crouch
var input_sprint
var input_dash

# This script serves to facilitate synchronized movement between all clients and
#	the server. This does this by taking the inputs of what the player wants
#	to do, then executing that action in sync with the server.

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
		
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backward")
	input_crouch = Input.is_action_just_pressed("Crouch")
	input_sprint = Input.is_action_just_pressed("Sprint")
	#input_dash = Input.is_action_just_pressed("dash")

func _physics_process(delta):
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backward")
	#input_dash = Input.is_action_just_pressed("dash")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Jump"):
		rpc_jump.rpc()

	if Input.is_action_just_pressed("Crouch"):
		rpc_crouch.rpc()

	if Input.is_action_just_pressed("Sprint"):
		rpc_sprint.rpc()


@rpc("call_local")
func rpc_jump():
	if multiplayer.is_server():
		player.do_jump = true


@rpc("call_local")
func rpc_crouch():
	if multiplayer.is_server():
		player.do_crouch = true
		

@rpc("call_local")
func rpc_sprint():
	if multiplayer.is_server():
		player.do_sprint = true
