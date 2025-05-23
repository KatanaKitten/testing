extends CharacterBody3D

signal getSpeed(speed)

var speed
const WALK_SPEED = 14
const SPRINT_SPEED = 28
const JUMP_VELOCITY = 5
const sensitivity = 0.003

@export var wallrun_angle = float(15)
var wallrun_current_angle = 0
var side = ""


var gravity = 9.8

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var camera = $Neck/Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_side(point):
	point = to_local(point)
	
	if point.x > 0:
		return "RIGHT"
	elif point.x < 0:
		return "LEFT"
	else:
		return "CENTER"




func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#print("Mouse Moved")
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			

func _physics_process(delta):
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (gravity * delta)
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		velocity = get_wall_normal() * JUMP_VELOCITY * 2
		velocity.y += JUMP_VELOCITY * 1.4
	if is_on_wall_only():
		velocity.y -= - ((gravity / 2) * delta)
		side = get_side(get_wall_normal()) #may need to use raycasting
		if side == "RIGHT":
			wallrun_current_angle += delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
		elif side == "LEFT":
			wallrun_current_angle -= delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
	else:
		if wallrun_current_angle > 0:
			wallrun_current_angle -= delta * 40
			wallrun_current_angle = max(0, wallrun_current_angle)
		elif wallrun_current_angle < 0:
			wallrun_current_angle += delta * 40
			wallrun_current_angle = min(wallrun_current_angle,0)
	neck.rotation_degrees = Vector3(0,0,1) * wallrun_current_angle
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	
	getSpeed.emit(speed)
	move_and_slide()
