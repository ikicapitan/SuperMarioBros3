extends KinematicBody2D

var Velocidad = Vector2()
var vivo = true
export (float) var VEL_DESP
var vidas = 2
var pateada = false


func _ready():
	get_node("AnimationPlayer").play("move")

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
		else:
			if(pateada):
				if(get_node("Sprite").flip_h): #Si el sprite esta volteado estoy mirando a la izq
					Velocidad.x = VEL_DESP*3
				else:
					Velocidad.x = -VEL_DESP*3
		
		if(get_slide_count() > 0):
			var obj_colisionado = get_slide_collision(get_slide_count()-1).collider
			if(obj_colisionado.is_in_group("player") && vivo):
				obj_colisionado.destransformar()
			elif(obj_colisionado.is_in_group("fuego") && vivo):
				recibir_fuegazo()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func recibir_golpe():
	vidas -= 1
	if(vidas > 1): #Si lo acabo de voltear
		get_node("Sprite").frame = 2 #Cambio a imagen de enemigo volteado
		get_node("AnimationPlayer").play("volteada")
		desvoltear()
	elif(!pateada): #Si la acabo de patear
		pateada = true
	elif(pateada):
		pateada = false
		desvoltear()
		
func desvoltear():
	yield(get_tree().create_timer(4.0),"timeout") #Espero 4 segundos
	if(!pateada): #Si no le pegue una patada en ese tiempo
		vidas = 2 #Restauro vidas
		get_node("Sprite").frame = 1 #Vuelvo el frame a caminar
		get_node("AnimationPlayer").play("move")
	
func recibir_fuegazo():
	get_node("CollisionShape2D").free()
	vivo = false
	free()