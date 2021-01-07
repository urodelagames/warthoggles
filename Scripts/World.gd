extends Spatial

const PLAYER_SCENE_PATH = 'res://Scenes/Warthog.tscn'

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	
	add_player()
	
	if get_tree().is_network_server():
		create_ball()

func _input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("quit"):
		get_tree().quit()

func add_player():
	var player = preload(PLAYER_SCENE_PATH).instance()
	var player_id = get_tree().get_network_unique_id()
	player.name = str(player_id)
	player.set_network_master(player_id)
	$Spawn.add_child(player)
	
# create_ball() called by server only.
func create_ball():
	# For the server, create the ball.
	var ball = preload('res://Scenes/Ball.tscn').instance()
	var ball_id = ball.get_instance_id()# @TODO is this truly random?!
	Network.ball_network_id = ball_id
	ball.name = 'McBall'
	ball.set_network_master(get_tree().get_network_unique_id())
	$BallSpawn.add_child(ball)
	print('created ball_id serverside with ball_id ', str(ball_id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
