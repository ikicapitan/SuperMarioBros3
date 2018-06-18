extends StaticBody2D

var abierto = false #No golpeo el cubo aun
export (int) var item #Numero de item que va a contener 0 / Moneda 1 / xHongo
export (int) var cantidad #Cantidad de n items que tendra el objeto
export (PackedScene) var moneda
export (PackedScene) var hongo
var cooldown = false #Enframiento o tiempo de espera para romperse nuevamente

func _ready():
	pass

func romper_cubo():
	var newitem #Variable para alojar al nuevo powerup creado
	
	if(item == 0): #Si el cubo contenia el item 0
		newitem = moneda.instance() #Creamos la moneda
		add_child(newitem)

	elif(item == 1): #Si el cubo contenia el item 1
		newitem = hongo.instance() #Creamos el hongo rojo
		get_tree().get_nodes_in_group("main")[0].add_child(newitem) #Lo agregamos a la escena
		
	newitem.global_position = get_node("SpawnPoint").global_position #Seteamos la posicion del nuevo item
	cantidad -= 1 #Le sacamos 1 a cantidad (puede haber varias monedas por ejemplo)

	if(cantidad == 0): #Si cantidad es 0, ya no hay mas items en el cubo
		get_node("animacion").play("cubo_roto") #Reproduzco animacion de cubo roto
		
	cooldown = true #Activo tiempo de espera
	yield(get_tree().create_timer(0.5), "timeout") #Esperamos 0.5 segundos
	cooldown = false #Se puede volver a romper
