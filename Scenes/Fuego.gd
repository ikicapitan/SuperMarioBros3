extends RigidBody2D

export (float) var VEL_IMPULSO

func _ready():
	pass

func _integrate_forces(state):
	for i in range(state.get_contact_count()): #Reviso todos los obj colisionados
		var obj_colisionado = state.get_contact_collider_object(i)
		if(obj_colisionado.is_in_group("obs")): #Si esta en el grupo obs es un obstaculo
			queue_free() #Elimino el fuego
		elif(obj_colisionado.is_in_group("enemigo")): #Si es enemigo lo golpeo
			if(obj_colisionado.is_in_group("tortuga")): #Si adicionalmente es una tortuga
				obj_colisionado.recibir_fuegazo()
			else: #Sino
				obj_colisionado.recibir_golpe()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free() #Cuando sale de pantalla es eliminado
