extends Spatial

const PLAYER_SCENE_PATH = 'res://Scenes/Warthog.tscn'

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	
	add_player()

func _input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()


func add_player():
	var player = preload(PLAYER_SCENE_PATH).instance()
	var player_id = get_tree().get_network_unique_id()
	player.name = str(player_id)
	player.set_network_master(player_id)
	$Spawn.add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
