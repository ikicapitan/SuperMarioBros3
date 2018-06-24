extends Area2D

func _ready():
	pass



func _on_CheckPoint_body_entered( body ):
	if(body.is_in_group("player")): #Si el cuerpo que entro al area es un player
		gamehandler.CheckPoint.x = global_position.x
