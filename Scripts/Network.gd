extends Node

# How I ran as a server on GCP:  nohup ./Godot_v3.2.1-stable_linux_server.64 --main-pack SquaresClub.pck --network_connection_type=server &

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const DEFAULT_MAX_PLAYERS = 5
const SERVER_ID = 1

var players = {}
var my_data = {'name': '', 'transform':Transform(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, Vector3.ZERO)}
var network_connection_type = ''
var host_ip = ''
var ip = null
var ball_network_id = null

func parse_os_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	return arguments
	
func _ready():
	# Network signals.
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	
	# Get arguments to check if this is the server before the server runs.
	var args = parse_os_args()
	network_connection_type = args.get('network_connection_type')
	host_ip = args.get('host_ip')
	
	if network_connection_type == 'server':
		create_server('David McServerhost', host_ip)
		get_tree().change_scene('res://Scenes/World.tscn')
		
# You're the server host and you create a server.
func create_server(name, ip):
	my_data['name'] = name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, DEFAULT_MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	players[SERVER_ID] = my_data

# Called when local player clicks "join".
func connect_to_server(player_nickname):
	my_data['name'] = player_nickname
	var peer = NetworkedMultiplayerENet.new()
	
	if ip:
		peer.create_client(ip, DEFAULT_PORT)
	else:
		peer.create_client(DEFAULT_IP, DEFAULT_PORT)
		
	get_tree().set_network_peer(peer)

# Called when this client/player successfully connects to the server.
# This is NOT called when server connects... obviously.
func _on_connected_to_server():
	var my_player_id = get_tree().get_network_unique_id()
	players[my_player_id] = my_data
	rpc('create_player', my_player_id, my_data) # Send all other clients (including server) to create this player on their screens.
	rpc_id(SERVER_ID, 'create_ball_for_id', my_player_id)

func _on_player_disconnected(id):
	players.erase(id)

# Notifies this client when another player connects to the same server. 
# This also gets called for the server, but we don't do much with that. 
# 	In that case, other_player_id is 1 for the server.
func _on_player_connected(other_player_id):
	var player_id = get_tree().get_network_unique_id()
	
	# Clients ask the server for the new player's data.
	if not(get_tree().is_network_server()):
		rpc_id(1, 'get_player_data', player_id, other_player_id)

# Function for the server.
# Tells the calling_player_id to create the new player (aka requsted_about_player_id).
remote func get_player_data(calling_player_id, requested_about_player_id):
	if get_tree().is_network_server():
		rpc_id(calling_player_id, 'create_player', requested_about_player_id, players[requested_about_player_id])

# Create puppet player on this player's game.
remote func create_player(player_id, data):
	players[player_id] = data
	var new_player = load('res://Scenes/Warthog.tscn').instance()
	new_player.name = str(player_id)
	print('create_player: ', str(player_id))
	new_player.set_network_master(player_id) # Tell this puppet player that it's being controlled by some other peer.
	get_node('/root/World/Spawn').add_child(new_player)

# Called on the server.
# Tells all other clients (NOT SERVER) to create a ball with
# the ball's network id.
remote func create_ball_for_id(calling_player_id):
	rpc_id(calling_player_id, 'create_ball', ball_network_id)

# Tell all other clients to create puppet ball (just the mesh!).
remote func create_ball(ball_id):
	# Create a ball for the CLIENT.
	var ball_spawn = get_node('/root/World/BallSpawn')
	var ball = preload('res://Scenes/Ball.tscn').instance()
	ball.set_network_master(SERVER_ID)
	ball.name = 'McBall'
	print('created ball clientside with ballid ', str(ball_id))
#	ball.mode = RigidBody.MODE_STATIC
	ball_spawn.add_child(ball)
