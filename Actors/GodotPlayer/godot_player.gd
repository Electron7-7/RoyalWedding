class_name GodotPlayer extends CharacterBody3D

@export_enum("PC:10", "LAPTOP:3") var _MOUSE_SENSITIVITY_PRESET: int

@export var mouseSensitivity: float = 0.15
@export var movementSpeed: float = 7.0
@export var groundedAcceleration: float = 1.0
@export var airAcceleration: float = 0.2
@export var jumpForce: float = 9.0
@export var terminalVelocity: float = 1000.0

@onready var head := $Head
@onready var camera := $Head/PlayerCamera
@onready var gravity_fucker := $%GravityFucker

var facing_direction: String
var _current_direction := "Y_NEG"

var air_velocity: Vector3
var grounded_velocity: Vector3
var _horizontal_acceleration: float
var _vertical_acceleration: float
var _input_vector: Vector2
var _max_pitch: float = 89.0
var _wish_rotation: Quaternion

var _UP := Vector3.UP
var _RIGHT := Vector3.RIGHT
var _FORWARD := Vector3.FORWARD

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouseSensitivity /= _MOUSE_SENSITIVITY_PRESET

func _process(_delta: float) -> void:
	var wX = roundi(gravity_fucker.rotation_degrees.x)
	var wY = (roundi(gravity_fucker.rotation_degrees.y) % 360)
	if(wY < 0): wY += 360

	# I'll have to choose who owns the corners; I could do some fancy math, or even randomize it... but hardcoding a "winner" is the easiest solution LMFAO
	if(wY < 45 || wY >= 315): # Front
		facing_direction = "Z_NEG"
	if(wY < 315 && wY >= 225): # Right
		facing_direction = "X_POS"
	if(wY < 225 && wY >= 135): # Back
		facing_direction = "Z_POS"
	if(wY < 135 && wY >= 45): # Left
		facing_direction = "X_NEG"

	if(wX <= -45): # Down
		facing_direction = "Y_NEG"
	if(wX >= 45): # Up
		facing_direction = "Y_POS"
	$%DebugOut1.text = "Velocity: %5.2v\nGlobal Rotation: %5.2v\nTest Rotation Cap: %s\nFacing Direction: %s" % [velocity, rotation_degrees, wY, facing_direction]

func _physics_process(_delta: float) -> void:
	if(quaternion != _wish_rotation):
		quaternion = quaternion.slerp(_wish_rotation, 0.1)
	_do_movement()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_mouse_callback(event.screen_relative)
	if event.is_action_pressed("fuck_gravity"):
		_on_gravity_fucked()

func _mouse_callback(mouse_movement: Vector2):
	head.rotation_degrees.y -= mouse_movement[0] * mouseSensitivity
	head.rotation_degrees.x -= mouse_movement[1] * mouseSensitivity
	if(abs(head.rotation_degrees.x) > _max_pitch):
		head.rotation_degrees.x = _max_pitch * sign(head.rotation_degrees.x)
	gravity_fucker.rotation = head.global_rotation

func _do_movement():
	_input_vector = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backwards").rotated(-head.rotation.y)
	move_and_slide()
	air_velocity = air_velocity.move_toward(_get_vertical_movement(), _vertical_acceleration)
	grounded_velocity = grounded_velocity.move_toward(_get_horizontal_movement(), _horizontal_acceleration)
	velocity = air_velocity + grounded_velocity

func _get_horizontal_movement() -> Vector3:
	return ((_RIGHT * _input_vector[0]) + (_FORWARD * -_input_vector[1])) * movementSpeed

func _get_vertical_movement() -> Vector3:
	_horizontal_acceleration = groundedAcceleration
	if(!is_on_floor()):
		_vertical_acceleration = Global.gravity
		_horizontal_acceleration = airAcceleration
		return -_UP * terminalVelocity
	if(Input.is_action_just_pressed("+jump")):
		_vertical_acceleration = 100.0
		return _UP * jumpForce
	_vertical_acceleration = 100.0
	return Vector3.ZERO


func isMovingHorizontally(check_direct_inputs: bool = false) -> bool:
	if(check_direct_inputs):
		return (absf(_input_vector[0]) > 0 || absf(_input_vector[1]) > 0)
	return (absf(velocity[0]) > 0.01 || absf(velocity[2]) > 0.01)

func isMovingVertically() -> bool:
	return absf(velocity[1] > 0.01)

func _on_gravity_fucked():
	if(_current_direction == facing_direction):
		return
	match facing_direction:
		"Y_NEG": # Gravity goes down
			_UP = Vector3.UP
			_RIGHT = Vector3.RIGHT
			_FORWARD = Vector3.FORWARD
			_wish_rotation = Quaternion(0.0, 0.0, 0.0, 1.0)
		"Y_POS": # Gravity goes up
			_UP = Vector3.DOWN
			_RIGHT = Vector3.RIGHT
			_FORWARD = Vector3.BACK
			_wish_rotation = Quaternion(1.0, 0.0, 0.0, 0.0)
		"Z_NEG": # Gravity goes forward
			_UP = Vector3.BACK
			_RIGHT = Vector3.RIGHT
			_FORWARD = Vector3.UP
			_wish_rotation = Quaternion(0.707, 0.0, 0.0, 0.707)
		"Z_POS": # Gravity goes back
			_UP = Vector3.FORWARD
			_RIGHT = Vector3.RIGHT
			_FORWARD = Vector3.DOWN
			_wish_rotation = Quaternion(-0.707, 0.0, 0.0, 0.707)
		"X_NEG": # Gravity goes right
			_UP = Vector3.RIGHT
			_RIGHT = Vector3.FORWARD
			_FORWARD = Vector3.UP
			_wish_rotation =  Quaternion(0.5, 0.5, -0.5, 0.5)
		"X_POS": # Gravity goes left
			_UP = Vector3.LEFT
			_RIGHT = Vector3.BACK
			_FORWARD = Vector3.UP
			_wish_rotation = Quaternion(0.5, -0.5, 0.5, 0.5)

	up_direction = _UP
	_current_direction = facing_direction
