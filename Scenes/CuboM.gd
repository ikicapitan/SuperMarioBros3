extends StaticBody2D

var abierto = false #No golpeo el cubo aun
export (int) var item #Numero de item que va a contener 0 / Moneda 1 / xHongo
export (int) var cantidad #Cantidad de n items que tendra el objeto
export (PackedScene) var moneda
export (PackedScene) var hongo
export (PackedScene) var flor
var cooldown = false #Enframiento o tiempo de espera para romperse nuevamente

func _ready():
	pass

func romper_cubo():
	var newitem #Variable para alojar al nuevo powerup creado
	
	if(item == 0): #Si el cubo contenia el item 0
		newitem = moneda.instance() #Creamos la moneda
		add_child(newitem)
		gamehandler.set_monedas(1)
		get_tree().get_nodes_in_group("sfx")[0].get_node("3").play()

	elif(item == 1): #Si el cubo contenia el item 1
		get_tree().get_nodes_in_group("sfx")[0].get_node("8").play()
		if(get_tree().get_nodes_in_group("player")[0].transformacion > 0): #Si ya es grande
			newitem = flor.instance() #Creamos la flor	
			get_tree().get_nodes_in_group("main")[0].add_child(newitem) #Lo agregamos a la escena
		else:
			newitem = hongo.instance() #Creamos el hongo rojo
			get_tree().get_nodes_in_group("main")[0].add_child(newitem) #Lo agregamos a la escena
		
	elif(item == 2): #Si el cubo teniael item 2 (hongo vida)
		get_tree().get_nodes_in_group("sfx")[0].get_node("8").play()
		get_node("Sprite").visible = true #Hago visible el bloque
		newitem = hongo.instance()
		newitem.get_node("Sprite").frame = 1 #cambio a verde
		get_tree().get_nodes_in_group("main")[0].add_child(newitem) #Lo agregamos a la escena
		newitem.tipo = 2 #Le indicamos al propio hongo que va a ser del tipo vida
		
	newitem.global_position = get_node("SpawnPoint").global_position #Seteamos la posicion del nuevo item
	cantidad -= 1 #Le sacamos 1 a cantidad (puede haber varias monedas por ejemplo)

	if(cantidad == 0): #Si cantidad es 0, ya no hay mas items en el cubo
		get_node("animacion").play("cubo_roto") #Reproduzco animacion de cubo roto
		
	cooldown = true #Activo tiempo de espera
	yield(get_tree().create_timer(0.5), "timeout") #Esperamos 0.5 segundos
	cooldown = false #Se puede volver a romper

func golpear_vacio():
	cooldown = true #Activo tiempo de espera
	get_tree().get_nodes_in_group("sfx")[0].get_node("5").play()
	yield(get_tree().create_timer(0.5), "timeout") #Esperamos 0.5 segundos
	cooldown = false #Se puede volver a romper
