extends CharacterBody3D

signal getSpeed(speed)
var speed
const WALK_SPEED = 14
const SPRINT_SPEED = 28
@export var gravity = 9.8
@export var sensitivity = 0.003

#var target_velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		print("Mouse Moved")
		$CameraPivot.rotate_y(-event.relative.x * sensitivity)
		$CameraPivot/Camera3D.rotate_x(-event.relative.y * sensitivity)
		$CameraPivot/Camera3D.rotation.x = clamp($CameraPivot/Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = ($CameraPivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += 5
		
	#if Input.is_action_just_pressed("sprint"):
		#speed = SPRINT_SPEED
	#if Input.is_action_just_released("sprint"):
		#speed = WALK_SPEED
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	# Ground Velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (gravity * delta)

	# Moving the Character
	#velocity = target_velocity
	getSpeed.emit(speed)
	move_and_slide()
