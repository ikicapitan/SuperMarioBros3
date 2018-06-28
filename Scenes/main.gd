extends Node

export (PackedScene) var mario

func _ready():
	respawnear_j()

func morir():
	get_tree().get_nodes_in_group("player")[0].queue_free() #Elimino al jugador
	gamehandler.vidas -= 1 #Resto una vida
	if(gamehandler.vidas >= 0): #Si tiene vidas, respawneo
		#respawnear_j()
		get_tree().reload_current_scene() #Recarga la escena actual
		
func respawnear_j():
	var newmario = mario.instance() #Creamos un Mario desde la escena
	add_child(newmario) #Lo agrego a la escena del juego
	if(gamehandler.CheckPoint == Vector2(0,0)): #Compruebo si ya toque un checkpoint, si el dato esta vacio es porque no
		newmario.global_position = get_tree().get_nodes_in_group("spawn")[0].global_position #Posiciono a Mario en el punto de Spawn
	else: #Se basa en el punto guardado
		newmario.global_position.x = gamehandler.CheckPoint.x 
		newmario.global_position.y = get_tree().get_nodes_in_group("spawn")[0].global_position #Posiciono a Mario en el punto de Spawn

func _on_Timer_timeout():
	gamehandler.set_time() #Resto 1 segundo
