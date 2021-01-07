extends KinematicBody

export var color: Color = Color.black

var speed = 7
var sprint_speed = 14
var acceleration = 10
var gravity = 0.09
var jump = 5

var mouse_sensitivity = 0.25

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 
onready var animation_player = get_node("WarthogModel/AnimationPlayer")

puppet var puppet_transform = null

func _ready():
	animation_player.get_animation('ArmatureAction').set_loop(true)
	animation_player.play("ArmatureAction")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	set_process_input(is_network_master())
	
func set_color(new_color: Color) -> void:
	$Armature/Skeleton/Plane.get_surface_material(0).albedo_color = new_color
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
	
	if event.is_action_released('sprint'):
		speed = 7
		animation_player.playback_speed = 2
	elif event.is_action_pressed('sprint'):
		speed = sprint_speed
		animation_player.playback_speed = 4

func _physics_process(delta):
	if is_network_master():
		direction = Vector3()
		
		move_and_slide(fall, Vector3.UP)
		
		if not is_on_floor():
			fall.y -= gravity

		if Input.is_action_just_pressed("jump") and is_on_floor():
			fall.y = jump
		if Input.is_action_pressed("move_forward"):
			direction -= transform.basis.x
		elif Input.is_action_pressed("move_backward"):
			direction += transform.basis.x
		if Input.is_action_pressed("move_left"):
			direction += transform.basis.z
		elif Input.is_action_pressed("move_right"):
			direction -= transform.basis.z

		direction = direction.normalized()
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
		velocity = move_and_slide(velocity, Vector3.UP)
		
		# Change the transform of this node on all peers.
		rset_unreliable('puppet_transform', transform)
	else:
		if puppet_transform != null:
			transform = puppet_transform
