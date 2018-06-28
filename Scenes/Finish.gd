extends Area2D

func _ready():
	pass

func _on_Finish_body_entered( body ):
	if(body.is_in_group("player") && !gamehandler.win): #Si el area de la bandera fue ingresada por nodo del tipo player
		get_tree().get_nodes_in_group("sfx")[0].get_node("7").play()
		gamehandler.win = true
		var newMariow = get_tree().get_nodes_in_group("lista_obj")[0].mario_w.instance() #Creo al Mario usado para escena de ganar
		var player = get_tree().get_nodes_in_group("player")[0] #Obtengo el Player original
		newMariow.global_position = player.global_position #Pongo al Mario usado para ganar en posicion del player
		var cols = player.get_node("CollisionShape2D")
		player.remove_child(player.get_node("CollisionShape2D"))
		newMariow.add_child(cols) #Me llevo el CollisionShape original
		newMariow.get_node("Sprite").texture = player.get_node("Sprite").texture #Me llevo la textura original
		var cam = player.get_node("Camera2D") #Reasigno camara
		player.remove_child(player.get_node("Camera2D"))
		cam.global_position.y = get_tree().get_nodes_in_group("spawn")[0].global_position.y
		add_child(cam)
		player.free() #Elimino el player
		get_tree().get_nodes_in_group("main")[0].add_child(newMariow)
		
		
		
