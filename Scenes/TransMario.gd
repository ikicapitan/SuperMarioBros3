extends CollisionShape2D

func _ready():
	get_node("RayCast2P").add_exception(get_tree().get_nodes_in_group("player")[0])
	get_node("RayCast2D").add_exception(get_tree().get_nodes_in_group("player")[0])

