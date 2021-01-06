extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("reload"):
		get_tree().reload_current_scene()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
