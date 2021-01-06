extends Node

# How I ran as a server on GCP:  nohup ./Godot_v3.2.1-stable_linux_server.64 --main-pack SquaresClub.pck --network_connection_type=server &

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const DEFAULT_MAX_PLAYERS = 5
const SERVER_ID = 1

var players = {}
var data = {name = '', position = Vector2(0,0)}
var network_connection_type = ''
var ip = null

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
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	
	# Get arguments to check if this is the server before the server runs.
	var args = parse_os_args()
	network_connection_type = args.get('network_connection_type')
	
	if network_connection_type == 'server':
		create_server('David McServerhost')
		
# You're the server host and you create a server.
func create_server(name):
	data.name = name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, DEFAULT_MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	players[SERVER_ID] = data

# Called when local player clicks "join".
func connect_to_server(player_nickname):
	data.name = player_nickname
	var peer = NetworkedMultiplayerENet.new()
	
	if ip:
		peer.create_client(ip, DEFAULT_PORT)
	else:
		peer.create_client(DEFAULT_IP, DEFAULT_PORT)
		
	get_tree().set_network_peer(peer)

# Called when a client successfully connects to the server.
func _connected_to_server():
	var player_id = get_tree().get_network_unique_id()
	players[player_id] = data
	rpc('create_player', player_id, data) # Send all other clients (including server) to create this player on their screens.

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
	new_player.set_network_master(player_id) # Tell this puppet player that it's being controlled by some other peer.
	get_node('/root/World/').add_child(new_player)
#	new_player.init(data['name'], data['position'])

# func update_position(id, position):
#	players[id].position = position
