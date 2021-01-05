extends KinematicBody

export var color: Color = Color.black

var speed = 7
var sprint_speed = 14
var sprinting: bool = false
var acceleration = 10
var gravity = 0.09
var jump = 5

var mouse_sensitivity = 0.25

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 

func _ready():
	$AnimationPlayer.play("ArmatureAction")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_color(color)
	
func set_color(new_color: Color) -> void:
	$Armature/Skeleton/Plane.get_surface_material(0).albedo_color = new_color
	
func _input(event):
	if event is InputEventMouseMotion and not sprinting:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
	
	if event.is_action_released('sprint'):
		speed = 7
	elif event.is_action_pressed('sprint'):
		speed = sprint_speed

func _physics_process(delta):
	
	direction = Vector3()
	
	move_and_slide(fall, Vector3.UP)
	
	if not is_on_floor():
		fall.y -= gravity
	
	if not sprinting:
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

func _on_SprintTimer_timeout():
	sprinting = false
	speed = 7
