extends CharacterBody2D

@export var acceleration: float = 3000.0
@export var max_speed: float = 1000.0
@export var friction: float = 0.16

@export var num_jump: int = 1
@export var num_bubbles: int = 1

@export var jump_speed: float = 700.0
@export var terminal_velocity: float = 1200.0
@export var terminal_bubble_floating: float = 250.0

@export var coyote_time: float = 0.06

var _gravity_mod: float = 1.0
var _jump_gravity_mod: float = -0.4
var _speed_mod: float = 1.0
var _max_speed_mod: float = 1.0

var _bubbling: bool = false
var _bubbles: int = 1

var _jump_count: int = 1
var _coyote_jump_timer: Timer

@onready var crab_sprite: Sprite2D = $CrabSprite
@onready var bubble_sprite: Sprite2D = $BubbleSprite


func _ready():
	_coyote_jump_timer = Timer.new()
	_coyote_jump_timer.autostart = false
	_coyote_jump_timer.one_shot = true
	_coyote_jump_timer.timeout.connect(_on_coyote_timeout)
	add_child(_coyote_jump_timer)



func _physics_process(delta): 
	var x_dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var working_accel: float = clampf(lerpf(0, acceleration, (max_speed - abs(velocity.x))/max_speed),
		 0.2 * acceleration, acceleration)
	
	if x_dir > 0:
		velocity.x += clampf(working_accel * _speed_mod * delta, 0, (max_speed * _max_speed_mod - velocity.x) )
		crab_sprite.flip_h = false
	elif x_dir < 0:
		velocity.x += clampf(-working_accel * _speed_mod * delta, (-max_speed * _max_speed_mod - velocity.x) , 0) 
		crab_sprite.flip_h = true
	
	
	if is_on_floor() and not _bubbling:
		if velocity.x * x_dir <= 0:
			velocity.x -= (velocity.x * friction * delta * 60)
		_recover_jump()
		_coyote_jump_timer.start(coyote_time)
		reset_move_mod()
	elif _bubbling:
		if velocity.x * x_dir <= 0:
			velocity.x -= (velocity.x * 0.02 * delta * 60)
		else:
			velocity.x -= (velocity.x * 0.01 * delta * 60)
		set_speed_mod(0.2)
		_max_speed_mod = 0.6
		set_gravity(0.1)
	elif not is_on_floor():
		set_speed_mod(0.3)
		
	_jump_gravity_mod = lerpf(_jump_gravity_mod, 0, 1 - 0.3 ** delta)
	
	_apply_gravity()
	
	if Input.is_action_just_pressed("bubble"):
		_try_bubble()
		_bubbles -= 1
	elif _bubbling and Input.is_action_just_pressed("jump"):
		_try_bubble_jump()
	elif Input.is_action_just_pressed("jump"):
		_try_jump()
		
	if Input.is_action_just_released("bubble"):
		_try_unbubble()
	
	if Input.is_action_just_released("jump"):
		_jump_gravity_mod = 0.0
	
	
	move_and_slide()


func set_gravity(lmao: float):
	if _bubbling:
		_gravity_mod = -lmao
	else:
		_gravity_mod = lmao


func set_speed_mod(lol: float):
	_speed_mod = lol


func reset_move_mod():
	set_gravity(1.0)
	set_speed_mod(1.0)
	_jump_gravity_mod = 0.0


func _apply_gravity(): 
	if _bubbling:
		velocity.y = clampf(velocity.y + get_gravity().y * _gravity_mod, -terminal_bubble_floating, INF)
	else:
		velocity.y = clampf(velocity.y + get_gravity().y * (_gravity_mod + _jump_gravity_mod), -INF, terminal_velocity)


func _try_jump():
	if _jump_count > 0:
		_jump_gravity_mod = -0.6
		velocity.y = -jump_speed
		_jump_count -= 1


func _try_bubble_jump():
	_bubbling = false
	bubble_sprite.visible = false
	set_gravity(1.0)
	_jump_gravity_mod = -0.6
	velocity.y = -jump_speed * 0.8
	_max_speed_mod = 1.0
	

func _recover_jump():
	_jump_count = num_jump
	_bubbles = num_bubbles


func _try_bubble():
	if not _bubbling and _bubbles > 0:
		if velocity.y > 0:
			velocity.y /= 5
		_bubbling = true
		bubble_sprite.visible = true
		_bubbles -= 1
		
		
func _try_unbubble():
	if _bubbling:
		_bubbling = false
		bubble_sprite.visible = false
		set_gravity(1.0)
		set_speed_mod(1.0)
		_max_speed_mod = 1.0


func _on_coyote_timeout():
	if _jump_count > 0:
		_jump_count -= 1
	set_speed_mod(0.3)
