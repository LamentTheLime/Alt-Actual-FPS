extends MeshInstance

var DAMAGE = 5
var USE_TIME = .5
var CLIP_SIZE = 12
var RELOAD_TIME = 1.2
var RANGE = 100
var AMMO_TYPE = "40CAL"

onready var SFX_FIRE = $fire
onready var SFX_RELOAD = $reload
onready var camera = get_parent().get_parent()
onready var raycast = $RayCast
onready var muzzleFlash = $MuzzleFlash

var clip = CLIP_SIZE
var timer = 0
var enabled = true

func fire():
	if timer>0:
		return
	if clip > 0:
		clip -= 1
		timer = USE_TIME
	else:
		reload()
		return
	SFX_FIRE.play()
	muzzleFlash.visible = true
	muzzleFlash.frame = -1
	raycast.global_transform = camera.get_global_transform()
	raycast.force_raycast_update()
	var col = raycast.get_collider()
	if col == null:
		return
	var otherChildren = col.get_children()
	var otherHPM
	for v in otherChildren:
		if v.name == 'HealthManager':
			otherHPM = v
			
		
	if otherHPM == null:
		return
	otherHPM.hurt_Char(DAMAGE,Vector3.ZERO)

func reload():
	if timer>0:
		return
	SFX_RELOAD.play()
	timer = RELOAD_TIME
	clip = CLIP_SIZE

func altFire():
	print('Alt Fire')
	SFX_FIRE.play(1)

func _process(delta):
	if muzzleFlash.frame >= 1:
		muzzleFlash.visible = false
	else:
		muzzleFlash.frame+=1
	if timer > 0:
		enabled = false
		timer -= delta
	else:
		enabled = true
