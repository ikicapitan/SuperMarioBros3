extends KinematicBody2D

var Velocidad = Vector2()
var vivo = true
export (float) var VEL_DESP
export (int) var puntos



func _ready():
	pass

func _physics_process(delta):
	if(vivo):
		Velocidad.y += gamehandler.GRAVEDAD * delta
		
		if(get_node("Sprite").flip_h): #Si el sprite esta volteado estoy mirando a la izq
			Velocidad.x = -VEL_DESP
		else:
			Velocidad.x = VEL_DESP
		
		move_and_slide(Velocidad, Vector2(0,-1))
		
		if(is_on_wall()):
			get_node("Sprite").flip_h = !get_node("Sprite").flip_h
		
		if(get_slide_count() > 0):
			var obj_colisionado = get_slide_collision(get_slide_count()-1).collider
			if(obj_colisionado.is_in_group("player") && vivo):
				obj_colisionado.destransformar()
			elif(obj_colisionado.is_in_group("fuego") && vivo):
				recibir_golpe()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func recibir_golpe():
	
	get_node("Sprite").frame = 2 #Cambio a imagen de enemigo muerto
	get_node("CollisionShape2D").free()
	if(vivo):
		gamehandler.set_puntos(puntos)
		get_tree().get_nodes_in_group("sfx")[0].get_node("11").play()
	vivo = false

	yield(get_tree().create_timer(0.7),"timeout")
	free()