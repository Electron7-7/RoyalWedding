extends Node

@onready var _tick_rate : int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") / _tick_rate

var current_tick : int = 0

func _physics_process(_delta: float) -> void:
	current_tick += 1
	if(current_tick > _tick_rate):
		current_tick = 0
