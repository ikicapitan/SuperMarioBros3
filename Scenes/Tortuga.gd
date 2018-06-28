extends KinematicBody2D

var Velocidad = Vector2()
var vivo = true
export (float) var VEL_DESP
export (int) var puntos
var vidas = 2
var pateada = false
var puede_golpearse = true


func _ready():
	get_node("AnimationPlayer").play("move")
	#dimension = transform
	#dimension[2].x += get_node("Sprite").texture.get_size().x #Obtengo dimension de mi sprite para testear luego precipicios

func _physics_process(delta):
	if(vivo):

		
		if(vidas == 2):
			Velocidad.y += gamehandler.GRAVEDAD * delta
			
			if(get_node("Sprite").flip_h): #Si el sprite esta volteado estoy mirando a la izq
				Velocidad.x = VEL_DESP
			else:
				Velocidad.x = -VEL_DESP
			
			move_and_slide(Velocidad, Vector2(0,-1))
			
			if(is_on_wall()):
				get_node("Sprite").flip_h = !get_node("Sprite").flip_h
				
			var dimension = transform
			dimension[2].x += get_node("Sprite").texture.get_size().x/3 #Obtengo dimension de mi sprite para testear luego precipicios
			if(!test_move(dimension, Vector2(0,1))): #Testeamos precipicio
				get_node("Sprite").flip_h = !get_node("Sprite").flip_h
		else:
			if(pateada):
				if(get_node("Sprite").flip_h): #Si el sprite esta volteado estoy mirando a la izq
					Velocidad.x = VEL_DESP*3
				else:
					Velocidad.x = -VEL_DESP*3
				move_and_slide(Velocidad, Vector2(0,-1))
				if(is_on_wall()):
					get_node("Sprite").flip_h = !get_node("Sprite").flip_h
		
		if(get_slide_count() > 0):
			var obj_colisionado = get_slide_collision(get_slide_count()-1).collider
			if(obj_colisionado.is_in_group("player") && vivo && vidas > 1):
				obj_colisionado.destransformar()
			elif(obj_colisionado.is_in_group("fuego") && vivo):
				recibir_fuegazo()
			elif(obj_colisionado.is_in_group("player") && vidas == 1):
				
				if(pateada):
					obj_colisionado.destransformar()
				else:
					obj_colisionado.dar_inmunidad()
					pateada = true
					if(obj_colisionado.global_position.x < global_position.x): #Si Mario es menor en X esta a la izq
						get_node("Sprite").flip_h = true
					else:
						get_node("Sprite").flip_h = false

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func recibir_golpe():
	if(!puede_golpearse):
		return
	vidas -= 1
	if(vidas == 1): #Si lo acabo de voltear
		get_node("Sprite").frame = 2 #Cambio a imagen de enemigo volteado
		get_node("AnimationPlayer").play("volteada")
		desvoltear()
	elif(!pateada): #Si la acabo de patear
		pateada = true
		get_tree().get_nodes_in_group("sfx")[0].get_node("9").play()
	elif(pateada):
		pateada = false
		desvoltear()
	puede_golpearse = false
	yield(get_tree().create_timer(0.3), "timeout")
	puede_golpearse = true
	gamehandler.set_puntos(puntos)
		
		
func desvoltear():
	yield(get_tree().create_timer(4.0),"timeout") #Espero 4 segundos
	if(!pateada): #Si no le pegue una patada en ese tiempo
		vidas = 2 #Restauro vidas
		get_node("Sprite").frame = 1 #Vuelvo el frame a caminar
		get_node("AnimationPlayer").play("move")
	
func recibir_fuegazo():
	get_tree().get_nodes_in_group("sfx")[0].get_node("11").play()
	get_node("CollisionShape2D").free()
	vivo = false
	gamehandler.set_puntos(puntos*5)
	free()