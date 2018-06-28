extends Node

var nivel = 1
var vidas = 3
var puntos = 0
var monedas = 0
var tiempo = 400
var GRAVEDAD = 150 #GRAVEDAD GLOBAL
var CheckPoint = Vector2() #Posicion del checkpoint
var win = false

func _ready():
	pass
	
func set_puntos(var points):
	puntos += points
	get_tree().get_nodes_in_group("txt_point")[0].text = String(puntos)
	
func set_monedas(var coins):
	monedas += coins
	get_tree().get_nodes_in_group("txt_monedas")[0].text = "x" + String(monedas)
	
func set_time():
	if(tiempo != 0):
		tiempo -= 1
		get_tree().get_nodes_in_group("txt_time")[0].text = String(tiempo)
		if(tiempo == 100):
			get_tree().get_nodes_in_group("bgm")[0].get_node("1").stop()
			get_tree().get_nodes_in_group("bgm")[0].get_node("2").play()
	else:
		get_tree().get_nodes_in_group("main")[0].morir() #Mata al jugador