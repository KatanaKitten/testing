extends CharacterBody3D

signal getSpeed(speed)

const starting_position = Vector3(0,0,0)

@onready var timer = $HUD/Timer
var time = 0



var speed
const WALK_SPEED = 14
const SPRINT_SPEED = 28
const JUMP_VELOCITY = 5
const sensitivity = 0.002

@export var wallrun_angle = float(10)
var wallrun_current_angle = 0
var side = ""


var gravity = 9.8

@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var camera = $Neck/Head/Camera3D
@onready var casts = $Casts

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_side():
	
	if $Casts/Right.is_colliding():
		return "RIGHT"
	elif $Casts/Left.is_colliding():
		return "LEFT"
	elif $Casts/Front.is_colliding():
		return "Front"
	elif $Casts/Back.is_colliding():
		return "Back"
	else:
		return "CENTER"

func _handle_wallrun(delta):
	side = get_side() #may need to use raycasting
	if is_on_wall_only():
		if side == "RIGHT":
			wallrun_current_angle += delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
		elif side == "LEFT":
			wallrun_current_angle -= delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
		elif side == "Front":
			wallrun_current_angle -= delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
		elif side == "Back":
			wallrun_current_angle += delta * 60
			wallrun_current_angle = clamp(wallrun_current_angle, -wallrun_angle, wallrun_angle)
		else:
			if wallrun_current_angle > 0:
				wallrun_current_angle -= delta * 40
				wallrun_current_angle = max(0, wallrun_current_angle)
			elif wallrun_current_angle < 0:
				wallrun_current_angle += delta * 40
				wallrun_current_angle = min(wallrun_current_angle,0)
			
		if side == "RIGHT" || "LEFT":
			neck.rotation_degrees = Vector3(1,0,0) * -wallrun_current_angle
		elif side == "Front" || "Back":
			neck.rotation_degrees = Vector3(0,0,1) * -wallrun_current_angle
		if head:
			pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		#print("Mouse Moved")
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		#casts.rotate_y(-event.relative.x * sensitivity)
			

func _physics_process(delta):
	
	var cam_tween = camera.create_tween()
	
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (gravity * delta)
		
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("jump") and is_on_wall_only():
		velocity = get_wall_normal() * JUMP_VELOCITY * 2
		velocity.y += JUMP_VELOCITY * 1.4
		
	if is_on_wall_only():
		velocity.y -= - ((gravity / 4) * delta)
		# ^fall speed during wall run^
		
		#velocity += (get_wall_normal() * -50) * delta
		# ^makes you stick to wall^
		
		if get_side() == "RIGHT":
			cam_tween.set_trans(Tween.TRANS_SINE)
			cam_tween.tween_property(neck, "rotation_degrees:z",7.5,0.2)
			cam_tween.play()
		elif get_side() == "LEFT":
			cam_tween.set_trans(Tween.TRANS_SINE)
			cam_tween.tween_property(neck, "rotation_degrees:z",-7.5,0.2)
			cam_tween.play()
		elif get_side() == "Front":
			cam_tween.set_trans(Tween.TRANS_SINE)
			cam_tween.tween_property(neck, "rotation_degrees:x",7.5,0.2)
			cam_tween.play()
		elif get_side() == "Back":
			cam_tween.set_trans(Tween.TRANS_SINE)
			cam_tween.tween_property(neck, "rotation_degrees:x",-7.5,0.2)
			cam_tween.play()
	else:
		cam_tween.tween_property(neck, "rotation_degrees:z",0,0.1)
		cam_tween.tween_property(neck, "rotation_degrees:x",0,0.1)
		cam_tween.play()
		
	
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
	getSpeed.emit(time)
	move_and_slide()


func _on_area_3d_reset() -> void:
	position = starting_position
	time = 0


func _on_timer_timeout() -> void:
	time += 1
	
	
