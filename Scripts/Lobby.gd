extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JoinButton_pressed():
	Network.ip = $VBoxContainer/ServerSection/LineEdit.get_text()
	Network.connect_to_server($VBoxContainer/NameSection/LineEdit.get_text())
	get_tree().change_scene('res://Scenes/World.tscn')


func _on_HostButton_pressed():
	Network.ip = $VBoxContainer/ServerSection/LineEdit.get_text()
	Network.create_server('David McServerhost', Network.ip)
	get_tree().change_scene('res://Scenes/World.tscn')
