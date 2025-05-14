extends CharacterBody3D


@export var speed = 14
@export var gravity = 9.8
@export var sensitivity = 0.003

var target_velocity = Vector3.ZERO

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
	
	if direction:
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	else:
		target_velocity.x = 0.0
		target_velocity.z = 0.0
	
	if Input.is_action_pressed("jump") and is_on_floor():
		target_velocity.y += 5
		
	if Input.is_action_just_pressed("sprint"):
		speed *= 2
	if Input.is_action_just_released("sprint"):
		speed /= 2
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (gravity * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
