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
enum estados {idle, caminando, muriendo, agachado}
var estado_actual = estados
var transformacion = 0 #0 enano, 1 alto, 2 escupe fuego
var puede_disparar = true
var inmunidad = false


func _ready():
	estado_actual = estados.idle #Al principio estara en reposo

func _physics_process(delta):
	Velocidad.y += gamehandler.GRAVEDAD * delta #Formula para aplicar gravedad
	if(Input.is_action_just_pressed("tecla_space") && puede_disparar && transformacion == 2): #Si puede disparar y presiono espacio
		get_tree().get_nodes_in_group("sfx")[0].get_node("6").play()
		var newfuego = get_tree().get_nodes_in_group("lista_obj")[0].fuego.instance() #Se crea el obj fuego
		newfuego.global_position.x = global_position.x
		if(get_node("Sprite").flip_h): #Si esta volteado (mirando a la izq)
			newfuego.global_position.x -= get_node("spawn_f").position.x
			newfuego.apply_impulse(newfuego.global_position, Vector2(-newfuego.VEL_IMPULSO,newfuego.VEL_IMPULSO/3)) #Aplico impulso para mover en horizontal
		else:
			newfuego.global_position.x += get_node("spawn_f").position.x
			newfuego.apply_impulse(newfuego.global_position, Vector2(newfuego.VEL_IMPULSO,newfuego.VEL_IMPULSO/3))
		newfuego.global_position.y = get_node("spawn_f").global_position.y
		get_tree().get_nodes_in_group("nivel")[0].add_child(newfuego) #Agrego a la escena
		puede_disparar = false
		yield(get_tree().create_timer(0.5),"timeout") #Espero 1 segundo
		puede_disparar = true #Habilito disparo nuevamente
			
	if(Input.is_action_just_pressed("tecla_s") && transformacion > 0):
		estado_actual = agachado
		get_node("animaciones").play("g_achado") #Reproduzco animacion agacharse
	
	if(Input.is_action_just_released("tecla_s") && transformacion > 0): #Si solto la tecla agacharse
		estado_actual = idle #Vuelve a reposo
		get_node("animaciones").play("idle") #Reproduzco animacion agacharse
	
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
		get_tree().get_nodes_in_group("sfx")[0].get_node("1").play()
		saltando = true
		Velocidad.y = -VEL_SALTO
		get_node("animaciones").play("jump") #Reproduzco animacion salto
		

	
	procesar_movimiento() #Procesamos el movimiento segun su estado actual
	
	Velocidad.y = clamp(Velocidad.y, -300,80) #Maximo y minimo velocidad Y
	
	var movimiento = Velocidad  #Calcula el movimiento en cada instante
	move_and_slide(movimiento) #Mueve
	
	#Raycast de la cabeza
	if(get_node("CollisionShape2D/RayCast2D").is_colliding()): #Nos fijamos que nuestro raycast (en la cabeza) si colisiono
		var obj_colisionado = get_node("CollisionShape2D/RayCast2D").get_collider() #Si golpeo a algo obtenemos el obj golpeado
		if(obj_colisionado.is_in_group("cubo")): #Si es un cubo lo abriremos
			Velocidad.y += VEL_SALTO / 6
			if(obj_colisionado.cantidad > 0 && !obj_colisionado.cooldown):
				obj_colisionado.romper_cubo() #Rompe el cubo y larga el premio
			elif(obj_colisionado.cantidad == 0 && !obj_colisionado.cooldown):
				obj_colisionado.golpear_vacio()
		elif(obj_colisionado.is_in_group("brick")): #Si esta en el grupo ladrillo
			Velocidad.y += VEL_SALTO / 6
			if(transformacion > 0): #Si la transformacion de Mario es grande o el escupe fuego
				get_tree().get_nodes_in_group("sfx")[0].get_node("4").play()
				gamehandler.set_puntos(30)
				var newexp = get_tree().get_nodes_in_group("lista_obj")[0].ladrillo_exp.instance()
				newexp.global_position = obj_colisionado.global_position #Posiciono animacion de explosion donde estaba el ladrillo que rompi. Amen.
				obj_colisionado.free() #Rompe ladrillo
				get_tree().get_nodes_in_group("nivel")[0].add_child(newexp)
				yield(get_tree().create_timer(3.0),"timeout") #Espero 3 segundos
				newexp.queue_free() #Destruyo animacion rompe ladrillo
	
	
	#Raycast de los pies
	if(get_node("CollisionShape2D/RayCast2P").is_colliding()):	
		var obj_colisionado = get_node("CollisionShape2D/RayCast2P").get_collider()
		if(obj_colisionado.is_in_group("enemigo")):
			obj_colisionado.recibir_golpe()
			Velocidad.y = -VEL_SALTO /3
	
	#Colision comun
	if(get_slide_collision(get_slide_count()-1 > 0)): #Colisione con un objeto
		var obj_colisionado = get_slide_collision(get_slide_count()-1).collider #Obtengo el objeto colisionado
		if(obj_colisionado == null):
			return #Si esta vacio termina la funcion
		if(obj_colisionado.is_in_group("suelo") && saltando): #Si colisione contra el suelo y estoy saltando
			get_node("animaciones").play("idle")
			saltando = false
			if(Velocidad.x != 0): #Estaba desplazandome en el aire
				get_node("animaciones").play("caminando")
		elif(obj_colisionado.is_in_group("hongo")): #Si esta en grupo hongo
			if(obj_colisionado.tipo == 0): #Si es rojo
				transformar()
			elif(obj_colisionado.tipo == 2): #Si es verde
				gamehandler.vidas += 1 #Le incremento una vida a la variable
				get_tree().get_nodes_in_group("sfx")[0].get_node("2").play()
			obj_colisionado.free() #Elimino hongo
		elif(obj_colisionado.is_in_group("flor")): #Si es una flor
			transformar() #Transforma
			obj_colisionado.free()
		elif(obj_colisionado.is_in_group("enemigo") && obj_colisionado.vivo): #Si es un enemigo
			if(obj_colisionado.is_in_group("tortuga")):
				if(obj_colisionado.pateada):
					destransformar()
				else:
					dar_inmunidad()
					obj_colisionado.pateada = true
					if(obj_colisionado.global_position.x > global_position.x): #Si la tortuga tiene mayor posicion en X, esta a la derecha
						obj_colisionado.get_node("Sprite").flip_h = true #Volteo mirando a la derecha
					else:
						obj_colisionado.get_node("Sprite").flip_h = false
			else:
				destransformar()

	
func procesar_movimiento():
	if(estado_actual == caminando): #Si esta caminando
		if(get_node("Sprite").flip_h): #Si el sprite esta voleado, significa que va a la izq
			Velocidad.x = -VEL_DESPL #Velocidad negativa en X (izq)
		else: #Sino
			Velocidad.x = VEL_DESPL #Va a la derecha
	elif(estado_actual == idle): #Sino esta en reposo
		Velocidad.x = 0 #Velocidad 0
		
func transformar():
	get_tree().get_nodes_in_group("sfx")[0].get_node("10").play()
	if(transformacion < 2):
		transformacion += 1 #Incrementa valor transformacion y transforma
	if(transformacion == 1):
		get_node("Sprite").texture = mario_g
	else:
		get_node("Sprite").texture = mario_f
	set_colcast()
		
func destransformar():
	if(inmunidad):
		return #Si el personaje tiene inmunidad finalizo la funcion sin ejecutar el resto
	if(transformacion > 0):
		transformacion -= 1
		if(transformacion == 1):
			get_node("Sprite").texture = mario_g
		else:
			get_node("Sprite").texture = mario_c
		set_colcast()
	else:
		get_tree().get_nodes_in_group("main")[0].morir()
	dar_inmunidad()
	
func dar_inmunidad():
	inmunidad = true
	yield(get_tree().create_timer(1.0),"timeout")
	inmunidad = false
		
func set_colcast(): #Setea colision shape y raycast segun transformacion
	get_node("CollisionShape2D").free() #Elimino el anterior de inmediato
	var newColCast
	if(transformacion > 0): #Si su transformacion es mayor a 0 es grande
		newColCast = trans_g.instance()
	else: #Sino es chico
		newColCast = trans_c.instance()
	add_child(newColCast)
	newColCast.global_position = global_position
	global_position.y -= 10

func _on_VisibilityNotifier2D_screen_exited():
	if(!gamehandler.win):
		get_tree().get_nodes_in_group("main")[0].morir() #Ejecuto la muerte
	