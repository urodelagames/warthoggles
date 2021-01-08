extends RigidBody

puppet var puppet_transform = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# If this is the server, which actually controls the ball
	if is_network_master():
		# Change the transform of this node on all peers.
		rset_unreliable('puppet_transform', transform)
	else:
		if puppet_transform != null:
			transform = puppet_transform
