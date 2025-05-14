extends CharacterBody3D


@export var speed = 14
@export var fall_acceleration = 75
@export var sensitivity = 0.003

var target_velocity = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		print("Mouse Moved")
		$CameraPivot.rotate_y(-event.relative.x * sensitivity)
		$CameraPivot/Camera3D.rotate_x(-event.relative.y * sensitivity)
		$CameraPivot/Camera3D.rotation.x = clamp($CameraPivot/Camera3D.rotation.x, deg_to_rad(-40), deg_to_rad(60))
			

func _physics_process(delta):
	var direction = ($CameraPivot.transform.basis * Vector3()).normalized()
	
	if Input.is_action_pressed("move_right"):
			direction.x += 1
	if Input.is_action_pressed("move_left"):
			direction.x -= 1
	if Input.is_action_pressed("move_back"):
			direction.z += 1
	if Input.is_action_pressed("move_forward"):
			direction.z -= 1
	if Input.is_action_pressed("jump"):
			if is_on_floor():
				target_velocity.y += 15
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		
		$CameraPivot.basis = Basis.looking_at(direction)
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
