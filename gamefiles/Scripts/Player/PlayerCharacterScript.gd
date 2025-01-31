class_name PlayerCharacter
extends CharacterBody3D

var states = Global.player_states
var currentState 

#player stats
@export_group("Player Stats")
@export var playerMaxHealth: float = 100
@export var playerMaxArmor: float = 100
@export var currentHealth: float = 100
@export var currentArmor: float

#speed variables
@export_group("Speed Variables")
var moveSpeed : float
var desiredMoveSpeed : float 
@export var maxSpeed : float 
@export var walkSpeed : float
@export var runSpeed : float
@export var crouchSpeed : float
var slideSpeed : float
@export var slideSpeedAddon : float 
@export var dashSpeed : float 
var moveAcceleration : float
@export var walkAcceleration : float
@export var runAcceleration : float 
@export var crouchAcceleration : float 
var moveDecceleration : float
@export var walkDecceleration : float
@export var runDecceleration : float 
@export var crouchDecceleration : float 
@export var inAirMoveSpeed : float 

#movement variables
@export_group("Movement Variables")
@export var inputDirection : Vector2 
@export var moveDirection : Vector3 
@export var hitGroundCooldown : float #amount of time the character keep his accumulated speed before losing it (while being on ground)
var hitGroundCooldownRef : float 
var lastFramePosition : Vector3 
var floorAngle #angle of the floor the character is on 
var slopeAngle #angle of the slope the character is on
var canInput : bool 
var collisionInfo

#jump variables
@export_group("Jump Variables")
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToFall : float
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float
@export var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int 
@export var nbJumpsInAirAllowedRef : int
@export var fallDamageMultiplier: float
@export var fallDurationTrigger: float
@export var fallDuration: float

#slide variables
@export_group("Slide Variables")
@export var slideTime : float
@export var slideTimeRef : float 
var slideVector : Vector2 = Vector2.ZERO #slide direction
var startSlideInAir : bool
@export var timeBeforeCanSlideAgain : float
var timeBeforeCanSlideAgainRef : float 

#wall run variables
@export_group("Wall Run Variables")
@export var wallJumpVelocity : float 
var canWallRun : bool

#clamber variables
@onready var chestRay: ShapeCast3D = $CameraHolder/Camera3D/ChestClamberCheck
@onready var headRay: ShapeCast3D = $CameraHolder/Camera3D/HeadClamberCheck
@export_group("Clamber Varaibles")
@export var _vertMoveTime: float = 0.35

#gravity variables
@export_group("Gravity Variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)
@export var wallGravityMultiplier : float

#references variables
@onready var cameraHolder = $CameraHolder
@onready var standHitbox = $standingHitbox
@onready var crouchHitbox = $crouchingHitbox
@onready var ceilingCheck = $CeilingCheck
@onready var mesh = $MeshInstance3D
@onready var hud = $HUD
@onready var healthBar: TextureProgressBar = %HealthProgressBar
@onready var armorBar: TextureProgressBar = %ArmorProgressBar
@onready var detailedHealthBar: TextureProgressBar = %DetailedHealthBar
@onready var detailedArmorBar: TextureProgressBar = %DetailedArmorBar
@onready var detailedHealthCounter: Label = detailedHealthBar.get_child(0)
@onready var detailedArmorCounter: Label = detailedArmorBar.get_child(0)
@onready var respawnMenu: Panel = $RespawnMenu

#game settings
@onready var FOV = $CameraHolder/Camera3D.fov

#multiplayer
@export_group("Multiplayer")
@export var teamNumber := 1
@export var squadNumber := 1
@export var followingNPCNumbers := []
var _is_on_floor = true
var _is_colliding = false
var do_jump = false
var do_crouch = false
var do_sprint = false
@export var player_id := 1:
	set(id):
		player_id = id
		print("id"+str(id))
		# Gives authority to the inputs for this player to this player's ID
		setAuth.call_deferred(id)
		
func setAuth(id):
	print("Setting auth: "+str(id))
	%InputSynchronizer.set_multiplayer_authority(id)
	set_multiplayer_authority(id)

func _ready():
	#camera should only run on client, not server
	print("mp authority: "+str(get_multiplayer_authority()))
	print("is mp auth: "+str(is_multiplayer_authority()))
	print("playerid: "+str(player_id))
	
	if get_multiplayer_authority() == player_id:
		$CameraHolder/Camera3D.make_current()

	Global.player = self

	#set the start move speed
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration
	currentHealth = playerMaxHealth

	#set the values refenrencials for the needed variables
	desiredMoveSpeed = moveSpeed 
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	hitGroundCooldownRef = hitGroundCooldown
	slideTimeRef = slideTime
	timeBeforeCanSlideAgainRef = timeBeforeCanSlideAgain
	canWallRun = false 
	canInput = true

	#disable the crouch hitbox, enable is standing one
	if !crouchHitbox.disabled: crouchHitbox.disabled = true 
	if standHitbox.disabled: standHitbox.disabled = false

	#set the mesh scale of the character
	mesh.scale = Vector3(1.0, 1.0, 1.0)

	#set stats
	healthBar.max_value = playerMaxHealth
	armorBar.max_value = playerMaxArmor
	detailedHealthBar.max_value = playerMaxHealth
	detailedArmorBar.max_value = playerMaxArmor


func _process(_delta):
	#the behaviours that is preferable to check every "visual" frame
	inputManagement()
	displayStats()
	if currentHealth <= 0:
		death()


func _physics_process(delta):
	#the behaviours that is preferable to check every "physics" frame
	if multiplayer.is_server():
		applies(delta)
		move(delta)
		collisionHandling()
		move_and_slide()
		if currentHealth <= 0:
			death()


func inputManagement():
	#for each state, check the possibles actions available
	#This allow to have a good control of the controller behaviour, because you can easely check the actions possibls, 
	#add or remove some, and it prevent certain actions from being played when they shouldn't be

	if canInput:
		match currentState:
			states.IDLE:
				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					crouchStateChanges()
					do_crouch = false

			states.WALK:
				#if Input.is_action_just_pressed("Sprint"):
				if do_sprint:
					runStateChanges()
					do_sprint = false

				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					crouchStateChanges()
					do_crouch = false

				##if Input.is_action_just_pressed("dash"):
				#if do_dash:
					#dashStateChanges()
					#do_dash = false

			states.RUN:
				#if Input.is_action_just_pressed("Sprint"):
				if do_sprint:
					walkStateChanges()
					do_sprint = false

				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					slideStateChanges()
					do_crouch = false

				##if Input.is_action_just_pressed("dash"):
				#if do_dash:
					#dashStateChanges()
					#do_dash = false

			states.CROUCH: 
				#if Input.is_action_just_pressed("Sprint") and !ceilingCheck.is_colliding():
				if do_sprint and !ceilingCheck.is_colliding():
					walkStateChanges()
					do_sprint = false

				#if Input.is_action_just_pressed("Crouch") and !ceilingCheck.is_colliding(): 
				if do_crouch and !ceilingCheck.is_colliding():
					walkStateChanges()
					do_crouch = false

			states.SLIDE: 
				#if Input.is_action_just_pressed("Sprint"):
				if do_sprint:
					runStateChanges()
					do_sprint = false

				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					runStateChanges()
					do_crouch = false

			states.JUMP:
				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					slideStateChanges()
					do_crouch = false
					

				##if Input.is_action_just_pressed("dash"):
				#if do_dash:
					#dashStateChanges()
					#do_dash = false

				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

			states.INAIR: 
				#if Input.is_action_just_pressed("Crouch"):
				if do_crouch:
					slideStateChanges()
					do_crouch = false

				##if Input.is_action_just_pressed("dash"):
				#if do_dash:
					#dashStateChanges()
					#do_crouch = false

				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

			states.ONWALL:
				#if Input.is_action_just_pressed("Jump"):
				if do_jump:
					jump(0.0, false)
					do_jump = false

			states.CLAMBER:
				#if canClamber() and Input.is_action_just_pressed("Jump"):
				if canClamber() and do_jump:
					clamber()
					do_jump = false

			#states.DASH:
				#pass


func displayStats():
	#call the functions in charge of displaying the controller properties
	hud.displayCurrentState(currentState)
	hud.displayMoveSpeed(moveSpeed)
	hud.displayDesiredMoveSpeed(desiredMoveSpeed)
	hud.displayVelocity(velocity.length())
	hud.displayNbJumpsAllowedInAir(nbJumpsInAirAllowed)

	#not a property, but a visual
	#if currentState == states.DASH: hud.displaySpeedLines(dashTime)

func applies(delta):
	#general appliements

	floorAngle = get_floor_normal() #get the angle of the floor
	if !is_on_floor():
		#modify the type of gravity to apply to the character, depending of his velocity (when jumping jump gravity, otherwise fall gravity)
		if velocity.y >= 0.0:
				velocity.y += jumpGravity * delta
				if currentState != states.SLIDE:
					currentState = states.JUMP
		else: 
			velocity.y += fallGravity * delta
			if currentState != states.SLIDE:
				currentState = states.INAIR
				
		if currentState == states.INAIR:
			fallDuration += delta
			if fallDuration > fallDurationTrigger:
				print("falling")
				currentState = states.FALLING

		if currentState == states.SLIDE:
			if !startSlideInAir: 
				slideTime = -1 #if the character start slide on the grund, and the jump, the slide is canceled

		if hitGroundCooldown != hitGroundCooldownRef: hitGroundCooldown = hitGroundCooldownRef #reset the before bunny hopping value
	if is_on_floor() and currentState == states.FALLING:

		# If player is falling for too long, kill outright to prevent infinite falling
		if fallDuration >= 8:
			death()
		else:
			# Fall Damage does not impact armor
			var damage = (fallDuration * fallDamageMultiplier) * 8
			print("fall damage taken: " + str(damage))
			updateHealth(snapped(damage,.1))
			damage = 0
		fallDuration = 0


	if is_on_floor():
		slopeAngle = rad_to_deg(acos(floorAngle.dot(Vector3.UP))) #get the angle of the slope 

		if hitGroundCooldown >= 0: hitGroundCooldown -= delta #disincremente the value each frame, when it's <= 0, the player lose the speed he accumulated while being in the air 

		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef #set the number of jumps possible

		#set the move state depending on the move speed, only when the character is moving
		if inputDirection != Vector2.ZERO and moveDirection != Vector3.ZERO:
			match moveSpeed:
				crouchSpeed: currentState = states.CROUCH 
				walkSpeed: currentState = states.WALK
				runSpeed: currentState = states.RUN 
				slideSpeed: currentState = states.SLIDE 

		else:
			#set the state to idle
			if currentState == states.JUMP or currentState == states.INAIR or currentState == states.WALK or currentState == states.RUN: 
				if velocity.length() < 1.0: currentState = states.IDLE

	if is_on_wall(): #if the character is on a wall
		#set the state on onwall
		wallrunStateChanges()

	#manage the clamber behavior
	if is_on_floor() and canClamber() == true and Input.is_action_just_pressed("Jump"):
		clamber()

	if is_on_floor() or !is_on_floor():
		#manage the slide behaviour
		if currentState == states.SLIDE:
			if !startSlideInAir and lastFramePosition.y < position.y: slideTime = -1 #if character slide on an uphill, cancel slide
			if slopeAngle < 16:
				if slideTime > 0: 
					slideTime -= delta
			if slideTime <= 0: 
				timeBeforeCanSlideAgain = timeBeforeCanSlideAgainRef
				#go to crouch state if the ceiling is too low, otherwise go to run state 
				if ceilingCheck.is_colliding(): crouchStateChanges()
				else: runStateChanges()


		if timeBeforeCanSlideAgain > 0: timeBeforeCanSlideAgain -= delta 

		#if timeBeforeCanDashAgain > 0: timeBeforeCanDashAgain -= delta

		if currentState == states.JUMP: floor_snap_length = 0.0 #the character cannot stick to structures while jumping

		if currentState == states.INAIR: floor_snap_length = 2.5 #but he can if he stopped jumping, but he's still in the air

		if jumpCooldown > 0: jumpCooldown -= delta


func move(delta):
	#direction input
	inputDirection = %InputSynchronizer.input_direction

	#get direction input when sliding
	if currentState == states.SLIDE:
		if moveDirection == Vector3.ZERO: #if the character is moving
			moveDirection = (cameraHolder.basis * Vector3(slideVector.x, 0.0, slideVector.y)).normalized() #get move direction at the start of the slide, and stick to it

	#get direction input when wall running
	elif currentState == states.ONWALL:
		moveDirection = velocity.normalized() #get character current velocity and apply it as the current move direction, and stick to it

	#all others 
	else:
		#get the move direction depending on the input
		moveDirection = (cameraHolder.basis * Vector3(inputDirection.x, 0.0, inputDirection.y)).normalized()

	#move applies when the character is on the floor
	if is_on_floor():
		#if the character is moving
		if moveDirection:
			#apply slide move
			if currentState == states.SLIDE:
				if slopeAngle > 40: desiredMoveSpeed += 3.0 * delta #increase more significantly desired move speed if the slope is steep enough
				else: desiredMoveSpeed += 2.0 * delta

				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed

			#apply smooth move when walking, crouching, running
			else:
				velocity.x = lerp(velocity.x, moveDirection.x * moveSpeed, moveAcceleration * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * moveSpeed, moveAcceleration * delta)

				#cancel desired move speed accumulation if the timer is out
				if hitGroundCooldown <= 0:
					#here, there's some nasty code : to keep it simple, i struggle to get a way to have a good speed accumulation behaviour
					#and so i decided to add some resistance related to the current state the character is, to get a smoother momuntem
					#but it's clearly not ideal, i and advice you to modify the values depending on the speed your character will move
					if currentState == states.WALK : desiredMoveSpeed = velocity.length()-walkSpeed
					else: desiredMoveSpeed = velocity.length()-(runSpeed / 2.5)

		#if the character is not moving
		else:
			#apply smooth stop 
			velocity.x = lerp(velocity.x, 0.0, moveDecceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, moveDecceleration * delta)

			#cancel desired move speed accumulation

			if currentState == states.WALK : desiredMoveSpeed = velocity.length()-walkSpeed
			else: desiredMoveSpeed = velocity.length()-(runSpeed / 2.5)

	#move applies when the character is not on the floor (so if in the air)
	if !is_on_floor():
		if moveDirection:
			#apply slide move
			if currentState == states.SLIDE:
				desiredMoveSpeed += 2.5 * delta

				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed

			#apply smooth move when in the air (air control)
			else:
				if desiredMoveSpeed < maxSpeed: desiredMoveSpeed += 1.5 * delta

				velocity.x = lerp(velocity.x, moveDirection.x * desiredMoveSpeed, inAirMoveSpeed * delta)
				velocity.z = lerp(velocity.z, moveDirection.z * desiredMoveSpeed, inAirMoveSpeed * delta)

		else:
			#accumulate desired speed for bunny hopping
			if currentState == states.WALK : desiredMoveSpeed = velocity.length()-walkSpeed
			else: desiredMoveSpeed = velocity.length()-(runSpeed / 2.5)

	#move applies when the character is on the wall
	if is_on_wall():
		#apply on wall move
		if currentState == states.ONWALL:
			if moveDirection:
				desiredMoveSpeed += 1.0 * delta 

				velocity.x = moveDirection.x * desiredMoveSpeed
				velocity.z = moveDirection.z * desiredMoveSpeed

	if desiredMoveSpeed >= maxSpeed: desiredMoveSpeed = maxSpeed #set to ensure the character don't exceed the max speed authorized

	lastFramePosition = position


func jump(jumpBoostValue : float, isJumpBoost : bool): 
	#this function manage the jump behaviour, depending of the different variables and states the character is

	var canJump : bool = false #jump condition

	#on wall jump 
	if is_on_wall() and canWallRun: 
		currentState = states.JUMP
		velocity = get_wall_normal() * wallJumpVelocity #add some knockback in the opposite direction of the wall
		velocity.y = jumpVelocity
		jumpCooldown = jumpCooldownRef
	else:
		#in air jump
		if !is_on_floor():
			if jumpCooldown <= 0:
				#if the character jump from a jumppad, the jump isn't taken into account in the max numbers of jumps allowed, allowing the character to continusly jump as long as it lands on a jumppad
				if (nbJumpsInAirAllowed > 0) or (nbJumpsInAirAllowed <= 0 and isJumpBoost):
					if !isJumpBoost: nbJumpsInAirAllowed -= 1
					jumpCooldown = jumpCooldownRef
					canJump = true 
		#on floor jump
		else:
			jumpCooldown = jumpCooldownRef
			canJump = true 

	#apply jump
	if canJump:
		if isJumpBoost: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef
		currentState = states.JUMP
		velocity.y = jumpVelocity + jumpBoostValue #apply directly jump velocity to y axis velocity, to give the character instant vertical forcez
		canJump = false 


#theses functions manages the differents changes and appliments the character will go trought when changing his current state
func crouchStateChanges():
	currentState = states.CROUCH
	moveSpeed = crouchSpeed
	moveAcceleration = crouchAcceleration 
	moveDecceleration = crouchDecceleration

	standHitbox.disabled = true
	crouchHitbox.disabled = false 

	if mesh.scale.y != 0.7:
		mesh.scale.y = 0.7
		mesh.position.y = -0.5


func walkStateChanges():
	currentState = states.WALK
	moveSpeed = walkSpeed
	moveAcceleration = walkAcceleration
	moveDecceleration = walkDecceleration

	standHitbox.disabled = false 
	crouchHitbox.disabled = true

	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0


func runStateChanges():
	currentState = states.RUN
	moveSpeed = runSpeed
	moveAcceleration = runAcceleration
	moveDecceleration = runDecceleration

	standHitbox.disabled = false 
	crouchHitbox.disabled = true 

	if mesh.scale.y != 1.0:
		mesh.scale.y = 1.0
		mesh.position.y = 0.0


func slideStateChanges():
	#condition here, the state is changed only if the character is moving (so has an input direction)
	if inputDirection != Vector2.ZERO and timeBeforeCanSlideAgain <= 0 and lastFramePosition.y >= position.y: #character can slide only on flat or downhill surfaces
		currentState = states.SLIDE 

		#change the start slide in air variable depending zon where the slide begun
		if !is_on_floor() and slideTime <= 0: startSlideInAir = true
		elif is_on_floor(): 
			desiredMoveSpeed += slideSpeedAddon #slide speed boost when on ground (for balance purpose)
			startSlideInAir = false 

		slideTime = slideTimeRef
		moveSpeed = slideSpeed
		slideVector = inputDirection

		standHitbox.disabled = true
		crouchHitbox.disabled = false 

		if mesh.scale.y != 0.7:
			mesh.scale.y = 0.7
			mesh.position.y = -0.5


func wallrunStateChanges():
	#condition here, the state is changed only if the character speed is greater than the walk speed
	if velocity.length() > walkSpeed and currentState != states.CROUCH and canWallRun: 
		currentState = states.ONWALL
		velocity.y *= wallGravityMultiplier #gravity value became onwall one

		if nbJumpsInAirAllowed != nbJumpsInAirAllowedRef: nbJumpsInAirAllowed = nbJumpsInAirAllowedRef

		standHitbox.disabled = false
		crouchHitbox.disabled = true

		if mesh.scale.y != 1.0:
			mesh.scale.y = 1.0
			mesh.position.y = 0.0


func collisionHandling():
	#this function handle the collisions, but in this case, only the collision with a wall, to detect if the character can wallrun
	if is_on_wall():
		var lastCollision = get_slide_collision(0)

		if lastCollision:
			var collidedBody = lastCollision.get_collider()
			var layer = collidedBody.collision_layer

			#here, we check the layer of the collider, then we check if the layer 3 (walkableWall) is enabled, with 1 << 3-1. If theses two points are valid, the character can wallrun
			if layer & (1 << 3-1) != 0: canWallRun = true 
			else: canWallRun = false 


func canClamber():
	if chestRay.is_colliding() and !headRay.is_colliding():
		return true
	else:
		return false


func clamber():
	# Vertical Transforms
	var _verticalMovement = global_transform.origin + Vector3(0,1.2,0)
	var _verticalTween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	# Smoothing, and move player up
	_verticalTween.tween_property(self,"global_transform:origin",_verticalMovement,_vertMoveTime)

	# Wait for vertical movement to finish before starting horizontal
	await _verticalTween.finished
	currentState = states.IDLE


func death():
	currentState = states.DEAD
	currentHealth = 0
	# Play death animation
	self.get_parent().remove_child(self)
	# Respawn
	respawnMenu.show()
	

func updateArmor(damageValue: float):
	var currentArmor: float = detailedArmorBar.value
	var remainingArmor: float

	remainingArmor = currentArmor - damageValue
	# If we have armor, reduce current armor by that amount, otherwise, health damamge = spillover damage not taken by armor
	# Either update currentArmor or updateHealth
	if remainingArmor > 0:
		armorBar.value = remainingArmor
		detailedArmorBar.value = remainingArmor
		currentArmor = detailedArmorBar.value
		detailedArmorCounter.text = str(currentArmor) + "/100"
	else:
		armorBar.value = 0
		detailedArmorBar.value = 0
		detailedArmorCounter.text = "0/100"
		updateHealth(damageValue - currentArmor)


func updateHealth(damageValue: float):
	healthBar.value -= damageValue
	detailedHealthBar.value -= damageValue
	currentHealth = detailedHealthBar.value
	detailedHealthCounter.text = str(currentHealth) + "/100"
