extends KinematicBody

var last_bullet = null

const BULLET = preload("res://Bullet.tscn")

const FALL_MULTIPLIER = 1.0
const LOW_JUMP_MULTIPLIER = 1.5

const gravity = Vector3(0, -10, 0)
const MAX_SPEED = 20
const JUMP_SPEED = 10
const ACCEL = 3
const DEACCEL = 10
const MAX_SLOPE_ANGLE = 40

var MOUSE_SENSITIVITY = 0
var JOYPAD_SENSITIVITY = 0

var vel = Vector3(0, 0, 0)
var dir = Vector3(0, 0, 0)

var is_dead = false
var waiting_for_respawn = false

var camera
var rotation_helper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	camera = $RotationHelper/Camera
	rotation_helper = $RotationHelper

func action_primary(_delta):
	var bullet = BULLET.instance()
	bullet.global_transform = $RotationHelper/Camera/BulletSpawn.global_transform
	var impulse = get_global_transform().basis * Vector3(0, 0, -50).rotated(Vector3(1, 0, 0), rotation_helper.rotation.x)
	get_parent().add_child(bullet)
	bullet.fire(impulse)
	last_bullet = bullet

func action_secondary(_delta):
	if last_bullet == null:
		return
	
	var bullet = last_bullet
	last_bullet = null
	
	translation = bullet.translation
	rotation = bullet.rotation
	bullet.queue_free()

func get_mouse_sensitivity():
	return 45

func get_joypad_sensitivity():
	return 50

var playing = false
func _process(_delta):
	if not playing:
		playing = true
		return
	
	MOUSE_SENSITIVITY = float(get_mouse_sensitivity()) / 100
	JOYPAD_SENSITIVITY = get_joypad_sensitivity()
	
	var horiz = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vert = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	horiz *= JOYPAD_SENSITIVITY
	vert *= JOYPAD_SENSITIVITY
	safe_rotate(Vector2(horiz, vert))

func _physics_process(delta):
	if not is_dead:
		process_input(delta)
		process_movement(delta)
	process_respawn(delta)

func get_last_velocity():
	return vel

func safe_rotate(vec):
	rotation_helper.rotate_x(deg2rad(vec.y * MOUSE_SENSITIVITY * -1))
	self.rotate_y(deg2rad(vec.x * MOUSE_SENSITIVITY * -1))
	# Set x/z to zero to avoid very strange camera stuff.
	self.rotation_degrees.x = 0
	self.rotation_degrees.z = 0
	
	var camera_rot = rotation_helper.rotation_degrees
	# FIXME: This clamp() is pretty arbitrary. It's worth playing with.
	#        -89,89 is one degree before straight down to one degree before straight up.
	#        Anything beyond this would allow the player to see behind them, which is a bit silly.
	camera_rot.x = clamp(camera_rot.x, -80, 89)
	# Set y/z to zero to avoid very strange camera stuff.
	camera_rot.y = 0
	camera_rot.z = 0
	rotation_helper.rotation_degrees = camera_rot

func jostle(amplitude):
	var y = rand_range(0, -amplitude)
	safe_rotate(Vector3(0, y, 0))

func jump(assist=1):
	vel.y = JUMP_SPEED * assist

# Various _process_* functions:

func process_input(delta):
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	var input_movement_vector = Vector2()
	
	if Input.is_action_just_pressed("action_primary"):
		action_primary(delta)
	
	if Input.is_action_just_pressed("action_secondary"):
		action_secondary(delta)
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += Input.get_action_strength("movement_forward")
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= Input.get_action_strength("movement_backward")
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= Input.get_action_strength("movement_left")
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += Input.get_action_strength("movement_right")
	input_movement_vector = input_movement_vector.normalized()
	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	
	# Jumping
	if (is_on_floor() or is_on_wall()) and Input.is_action_just_pressed("movement_jump"):
		vel.y = JUMP_SPEED

func process_movement(delta):
	dir = dir.normalized()
	
	vel += Vector3(delta * gravity.x, delta * gravity.y, delta * gravity.z)
	
	if vel.y < 0:
		vel += Vector3.UP * gravity.y * (FALL_MULTIPLIER - 1) * delta
	elif (vel.y > 0) and not Input.is_action_pressed("movement_jump"):
		vel += Vector3.UP * gravity.y * (LOW_JUMP_MULTIPLIER - 1) * delta
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), false, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_respawn(_delta):
	pass

func _input(event):
	if is_dead:
		if Input.is_key_pressed(KEY_SPACE):
			waiting_for_respawn = true
		return
	
	# Mouse movement.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		safe_rotate(event.relative)

func raycast_adjacent(ray):
	ray.force_raycast_update()
	if not ray.is_colliding():
		return null
	return ray.get_collider()
