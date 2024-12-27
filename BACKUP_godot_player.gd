# BACKUP
# BACKUP
# BACKUP
# BACKUP
# BACKUP
# BACKUP
# BACKUP
extends CharacterBody3D

@export var mouseSensitivity: float = 0.1
@export var movementSpeed: float = 13.0
@export var movementAcceleration: float = 0.4
@export var jumpForce: float = 5.0

@onready var head := $Head
@onready var camera := $Head/PlayerCamera

var _input_vector: Vector2
var _max_pitch: float = 89.0
var _UP := Vector3.UP
var _RIGHT := Vector3.RIGHT
var _FRONT := Vector3.FORWARD

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	_horizontal_movement()
	_vertical_movement()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_callback(event.screen_relative)

func _mouse_callback(mouse_movement: Vector2):
	head.rotation_degrees.y -= mouse_movement[0] * mouseSensitivity
	head.rotation_degrees.x -= mouse_movement[1] * mouseSensitivity
	if(abs(head.rotation_degrees.x) > _max_pitch):
		head.rotation_degrees.x = _max_pitch * sign(head.rotation_degrees.x)

func _horizontal_movement():
	_input_vector = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backwards").rotated(-head.rotation.y)
	move_and_slide()
	velocity[0] = lerp(velocity[0], _input_vector[0] * movementSpeed, movementAcceleration)
	velocity[2] = lerp(velocity[2], _input_vector[1] * movementSpeed, movementAcceleration)

func _vertical_movement():
	if(!is_on_floor()):
		velocity[1] -= Global.gravity
		return

	velocity[1] = lerp(velocity[1], 0.0, Global.gravity)

	if(Input.is_action_just_pressed("+jump")):
		velocity[1] += jumpForce
		

func isMovingHorizontally(check_direct_inputs: bool = false) -> bool:
	if(check_direct_inputs):
		return (absf(_input_vector[0]) > 0 || absf(_input_vector[1]) > 0)
	return (absf(velocity[0]) > 0.01 || absf(velocity[2]) > 0.01)

func isMovingVertically() -> bool:
	return absf(velocity[1] > 0.01)
