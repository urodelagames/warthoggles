extends Area

export var goal_color: Color = Color.black


# Called when the node enters the scene tree for the first time.
func _ready():
	set_color(goal_color)


func set_color(new_color: Color) -> void:
	for child in get_children():
		if 'Wall' in child.get_name():
			var mesh_instance: MeshInstance = child.get_node('MeshInstance')
			mesh_instance.get_surface_material(0).albedo_color = new_color
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Goal_body_entered(body):
	if body.is_in_group('Balls'):
		$Particles.emitting = true
