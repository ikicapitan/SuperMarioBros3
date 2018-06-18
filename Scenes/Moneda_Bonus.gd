extends Sprite

func _ready():
	pass

func _on_AnimationPlayer_animation_finished( anim_name ):
	queue_free() #Al finalizar animacion elimina la moneda bonus
