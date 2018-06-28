extends KinematicBody2D

var suelo_reached = false
var Velocidad = Vector2()
var bandera

func _ready():
	bandera = get_tree().get_nodes_in_group("flag")[0] #Busco a la bandera en el game
	
func _physics_process(delta):
	if(!suelo_reached):
		Velocidad.y += gamehandler.GRAVEDAD/2 * delta
		move_and_slide(Velocidad)
		if(get_slide_count() > 0):
			var obj_col = get_slide_collision(get_slide_count()-1).collider
			if(obj_col.is_in_group("gf")): #Alcance el suelo
				get_tree().get_nodes_in_group("sfx")[0].get_node("7").stop()
				suelo_reached = true
				get_node("AnimationPlayer").play("win") #Ejecuto animacion entra al castillo
		bandera.move_and_slide(Velocidad)

