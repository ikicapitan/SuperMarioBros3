extends KinematicBody2D
export (float) var VEL_DESPL #Velocidad a la que se movera
export (float) var VEL_SALTO #Velocidad a la que saltara
export (Texture) var mario_c #Imagen de Mario chico
export (Texture) var mario_g
export (Texture) var mario_f
export (PackedScene) var trans_c #Collision shape y raycast de cuando es chico
export (PackedScene) var trans_g #Idem para grande
var Velocidad = Vector2() #Velocidad a la que se mueve en el momento actual
var saltando = false
enum estados {idle, caminando, muriendo}
var estado_actual = estados
var transformacion = 0 #0 enano, 1 alto, 2 escupe fuego


func _ready():
	estado_actual = estados.idle #Al principio estara en reposo

func _physics_process(delta):
	Velocidad.y += gamehandler.GRAVEDAD * delta #Formula para aplicar gravedad
	
	if(Input.is_action_just_pressed("tecla_d")):
		estado_actual = caminando
		get_node("Sprite").flip_h = false #Desvolteo el sprite si esta volteado
		if(!saltando):
			get_node("animaciones").play("caminando") #Reproduzco animacion caminar
	
	if(Input.is_action_just_pressed("tecla_a")):
		estado_actual = caminando
		get_node("Sprite").flip_h = true #volteo el sprite
		if(!saltando):
			get_node("animaciones").play("caminando")
		
	if(Input.is_action_just_released("tecla_d")):
		estado_actual = idle
		if(!saltando):
			get_node("animaciones").play("idle") #Reproduzco animacion reposo
		
	if(Input.is_action_just_released("tecla_a")):
		estado_actual = idle	
		if(!saltando):
			get_node("animaciones").play("idle") #Reproduzco animacion reposo
		
	if(Input.is_action_just_pressed("tecla_w") && !saltando): #Saltar
		saltando = true
		Velocidad.y = -VEL_SALTO
		get_node("animaciones").play("jump") #Reproduzco animacion salto
	
	procesar_movimiento() #Procesamos el movimiento segun su estado actual
	
	var movimiento = Velocidad  #Calcula el movimiento en cada instante
	move_and_slide(movimiento) #Mueve
	
	if(get_node("CollisionShape2D/RayCast2D").is_colliding()): #Nos fijamos que nuestro raycast (en la cabeza) si colisiono
		var obj_colisionado = get_node("CollisionShape2D/RayCast2D").get_collider() #Si golpeo a algo obtenemos el obj golpeado
		if(obj_colisionado.is_in_group("cubo")): #Si es un cubo lo abriremos
			Velocidad.y += VEL_SALTO / 6
			if(obj_colisionado.cantidad > 0 && !obj_colisionado.cooldown):
				obj_colisionado.romper_cubo() #Rompe el cubo y larga el premio
	
	if(get_slide_collision(get_slide_count()-1 > 0)): #Colisione con un objeto
		var obj_colisionado = get_slide_collision(get_slide_count()-1).collider #Obtengo el objeto colisionado
		if(obj_colisionado.is_in_group("suelo") && saltando): #Si colisione contra el suelo y estoy saltando
			get_node("animaciones").play("idle")
			saltando = false
			if(Velocidad.x != 0): #Estaba desplazandome en el aire
				get_node("animaciones").play("caminando")
		elif(obj_colisionado.is_in_group("hongo")): #Si esta en grupo hongo
			if(obj_colisionado.tipo == 0): #Si es rojo
				transformar()
				obj_colisionado.queue_free() #Elimino hongo
				

	
func procesar_movimiento():
	if(estado_actual == caminando): #Si esta caminando
		if(get_node("Sprite").flip_h): #Si el sprite esta voleado, significa que va a la izq
			Velocidad.x = -VEL_DESPL #Velocidad negativa en X (izq)
		else: #Sino
			Velocidad.x = VEL_DESPL #Va a la derecha
	elif(estado_actual == idle): #Sino esta en reposo
		Velocidad.x = 0 #Velocidad 0
		
func transformar():
	if(transformacion < 2):
		transformacion += 1 #Incrementa valor transformacion y transforma
	if(transformacion == 1):
		get_node("Sprite").texture = mario_g
	else:
		get_node("Sprite").texture = mario_f
	set_colcast()
		
func destransformar():
	if(transformacion > 0):
		transformacion -= 1
		if(transformacion == 1):
			get_node("Sprite").texture = mario_g
		else:
			get_node("Sprite").texture = mario_c
		set_colcast()
	else:
		pass #Muerte
		
func set_colcast(): #Setea colision shape y raycast segun transformacion
	get_node("CollisionShape2D").free() #Elimino el anterior de inmediato
	var newColCast
	if(transformacion > 0): #Si su transformacion es mayor a 0 es grande
		newColCast = trans_g.instance()
	else: #Sino es chico
		newColCast = trans_c.instance()
	add_child(newColCast)
	newColCast.global_position = global_position