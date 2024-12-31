class_name Enemy extends CharacterBody3D

@onready var _sprite = $%Sprite
@onready var _collider = $%Collider

func _process(delta: float) -> void:
	_do_sprite_rotation()

func _do_sprite_rotation():
	if(!Global.player): return
	_sprite.look_at(Global.player.global_position)
	_sprite.flip_h = false
	var angle_to_player = rad_to_deg(_sprite.rotation[1])
	if(sign(angle_to_player) == -1): _sprite.flip_h = true
	angle_to_player = abs(angle_to_player)
	if(angle_to_player <= 30):
		_sprite.frame = 0
		return
	if(angle_to_player <= 60):
		_sprite.frame = 1
		return
	if(angle_to_player <= 120):
		_sprite.frame = 2
		return
	if(angle_to_player <= 150):
		_sprite.frame = 3
		return
	if(angle_to_player <= 180):
		_sprite.frame = 4
