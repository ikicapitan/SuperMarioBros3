extends KinematicBody2D

export (float) var VEL_DESPL #Vel a la que se movera
var Velocidad = Vector2() #Vel actual
var tipo = 0 #0 Rojo, 1 Flor, 2 Verde


func _ready():
	pass
	
func _physics_process(delta):
	Velocidad.y += gamehandler.GRAVEDAD * delta #Aplico gravedad V = a*t
	
	if(get_node("Sprite").flip_h):
		Velocidad.x = -VEL_DESPL
	else:
		Velocidad.x = VEL_DESPL
	
	move_and_slide(Velocidad, Vector2(0,-1)) #Muevo y seteo la normal del suelo
	
	if(is_on_wall()): #Si esta en pared
		get_node("Sprite").flip_h = !get_node("Sprite").flip_h #Volteo el sprite a volteado contrario
		
	if(get_slide_collision(get_slide_count()-1 > 0)): #Chequeo colisiones
		var obj_colisionado = get_slide_collision(get_slide_count()-1).collider #Obtengo obj colisionado
		if(obj_colisionado.is_in_group("player")): #Si el obj colisionado es el player
			if(tipo != 2): #Si es diferente al hongo que da una vida
				obj_colisionado.transformar() #Transformo
			else:
				gamehandler.vidas += 1 #Agrego una vida
				get_tree().get_nodes_in_group("sfx")[0].get_node("2").play()
			free()
	

