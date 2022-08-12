extends KinematicBody

#    VARS
#EXPORTS
export var RUN_SPEED = 16
export var ACCEL_SECONDS = .1
export var JUMP_POWER = 20
export var GROUND_FRICTION = 8
export var GRAVITY = 20
#LOCALS
var ACCEL = RUN_SPEED/ACCEL_SECONDS
var vel = Vector3.ZERO
var wishDir = Vector3.ZERO
var is_walking = false
#NODES
onready var head = $Camera
onready var mpsL = $Camera/Control/MPSGAGUE
onready var hpTemp = $Camera/Control/HP_TEMP
onready var currentWeapon = $Camera/Weapons/w40CalPistol
onready var footsteps_temo = $walk_temp
onready var jump_temp = $jump_temp
onready var ouch = $ouch

#   FUNCS
#DEFS
func friction(v,grounded,dt):
	if v.distance_to(Vector3.ZERO) < 0.1:
		return v*0
	if grounded:
		return v * clamp(v.distance_to(Vector3.ZERO)/v.distance_to(Vector3.ZERO)-(GROUND_FRICTION*dt), 0, 1)
	return v

func getWish():
	var v = Vector3.ZERO
	v += transform.basis.z * (Input.get_action_strength("game_down")-Input.get_action_strength("game_up"))
	v += transform.basis.x * (Input.get_action_strength("game_right")-Input.get_action_strength("game_left"))
	if v.distance_to(Vector3.ZERO) > .5:
		is_walking = true
	return v.normalized()
	

func groundMove(dt):
	vel = friction(vel,true,dt)
	wishDir = getWish()
	vel.y = -.05
	if is_on_wall():
		vel.x *= 0
		vel.y *= 0
	
	var hSpd = Vector3(vel.x,0,vel.z)
	var currentSpd = hSpd.dot(wishDir)
	var addSpeed = RUN_SPEED-currentSpd
	addSpeed = min(addSpeed,ACCEL*dt)
	if addSpeed <= 0:
		return
	vel += wishDir * addSpeed
	

func airMove(dt):
	vel = friction(vel,false,dt)
	wishDir = getWish()
	vel.y -= GRAVITY*dt
	if is_on_ceiling():
		vel.y *= -.2
	
	var hSpd = Vector3(vel.x,0,vel.z)
	var currentSpd = hSpd.dot(wishDir)
	var addSpeed = RUN_SPEED-currentSpd
	addSpeed = min(addSpeed,ACCEL/2*dt)
	if addSpeed <= 0:
		return
	vel += wishDir * addSpeed
	

#GODOT EVENTS

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_pressed("game_fire_a"):
		currentWeapon.fire()
	if Input.is_action_pressed("game_fire_b"):
		currentWeapon.altFire()
	if Input.is_action_just_pressed("game_reload"):
		currentWeapon.fire()
	

func _physics_process(dt):
	if is_on_floor():
		groundMove(dt)
		if Input.is_action_just_pressed("game_jump"):
			vel.y = JUMP_POWER
			jump_temp.play()
			
		
		if vel.distance_to(Vector3.ZERO) > RUN_SPEED/4 and is_walking:
			if not footsteps_temo.playing:
				footsteps_temo.play()
				
			
		else:
			footsteps_temo.stop()
			
		
	else:
		footsteps_temo.stop()
		airMove(dt)
		
	move_and_slide(vel,Vector3.UP)
	mpsL.text = "Speed: " + str(Vector3(vel.x,0,vel.z).distance_to(Vector3.ZERO)) + "M/S"
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(event.relative.x*-.5))
		head.rotate_x(deg2rad(event.relative.y*-.5))
		
	
