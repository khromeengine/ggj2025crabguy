extends CharacterBody2D
class_name Player

const BUBBLE_TIME: float = 6.0

@export var acceleration: float = 2000.0
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

var _jump_count: int = 0
var _coyote_jump_timer: Timer


var _noctrl: bool = false
var _dead: bool = false

@onready var crab_sprite: Sprite2D = $CrabSprite
@onready var bubble_sprite: Sprite2D = $BubbleSprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var collisionbox: CollisionShape2D = $CollisionShape2D
@onready var bubble_timer: Timer = $BubbleTimer
@onready var bubble_particles: PackedScene = preload("res://scenes/bubbleparticles.tscn")



func _ready():
	GameStateManager.player = self
	_coyote_jump_timer = Timer.new()
	_coyote_jump_timer.autostart = false
	_coyote_jump_timer.one_shot = true
	_coyote_jump_timer.timeout.connect(_on_coyote_timeout)
	add_child(_coyote_jump_timer)
	
	bubble_timer.timeout.connect(_on_bubble_timeout)

	hurtbox.kill_owner.connect(kill)
	GameStateManager.reload_level.connect(_on_reload_level)
	GameStateManager.end_game.connect(_on_end_game)


func _physics_process(delta): 
	_clear_animation_state()
	
	var x_dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var working_accel: float = clampf(lerpf(0, acceleration, (max_speed - abs(velocity.x))/max_speed),
		 0.2 * acceleration, acceleration)
	
	if _bubbling or _dead:
		if velocity.x * x_dir <= 0:
			velocity.x -= (velocity.x * 0.02 * delta * 60)
		else:
			velocity.x -= (velocity.x * 0.01 * delta * 60)
		set_speed_mod(0.2)
		_max_speed_mod = 0.6
		set_gravity(0.1)
	elif is_on_floor() and not _bubbling:
		if velocity.x * x_dir <= 0:
			velocity.x -= (velocity.x * friction * delta * 60)
		_recover_jump()
		_coyote_jump_timer.start(coyote_time)
		reset_move_mod()
	elif not is_on_floor():
		set_speed_mod(0.3)
		
	_jump_gravity_mod = lerpf(_jump_gravity_mod, 0, 1 - 0.3 ** delta)
	
	_apply_gravity()
	
	if not _noctrl:
		if x_dir > 0:
			velocity.x += clampf(working_accel * _speed_mod * delta, 0, (max_speed * _max_speed_mod - velocity.x) )
			crab_sprite.flip_h = false
			if not $RunningSFX.playing and is_on_floor():
				$RunningSFX.play(0.1*(abs(velocity.x)/max_speed))
		elif x_dir < 0:
			velocity.x += clampf(-working_accel * _speed_mod * delta, (-max_speed * _max_speed_mod - velocity.x) , 0) 
			crab_sprite.flip_h = true
			if not $RunningSFX.playing and is_on_floor():
				$RunningSFX.play(0.1*(abs(velocity.x)/max_speed))
			
		if Input.is_action_just_pressed("bubble"):
			_try_bubble()
		elif _bubbling and Input.is_action_just_pressed("jump"):
			_try_bubble_jump()
		elif Input.is_action_just_pressed("jump"):
			_try_jump()
			
		if Input.is_action_just_released("bubble"):
			_try_unbubble()
		
		if Input.is_action_just_released("jump"):
			_jump_gravity_mod = 0.0
	
	if Input.is_action_just_pressed("debug"):
		kill()
	
	if Input.is_action_just_pressed("reset"):
		GameStateManager.reload_level.emit()
	
	
	if is_on_floor() and abs(velocity.x) > max_speed/5:
		$AnimationTree.set("parameters/conditions/running", true)
	elif not is_on_floor():
		$AnimationTree.set("parameters/conditions/falling", true)
	else:
		$AnimationTree.set("parameters/conditions/idle", true)
	
	
	move_and_slide()


func kill():
	if not _dead:
		_try_unbubble()
		_noctrl = true
		_dead = true
		velocity.y = 0.0
		$AnimationTree.active = false
		anim_player.play("die")
		collisionbox.set_deferred("disabled", true)
		hurtbox.set_deferred("monitorable", false)
		$DeathSFX.play()
		GameStateManager.deded.emit()
	

func unkill():
	if _dead:
		_noctrl = false
		_dead = false
		velocity = Vector2.ZERO
		reset_move_mod()
		collisionbox.set_deferred("disabled", false)
		hurtbox.set_deferred("monitorable", true)
		$AnimationTree.active = true
		anim_player.play("RESET")
		$RespawnSFX.play()


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
	if _dead:
		return
	if _bubbling:
		velocity.y = clampf(velocity.y + get_gravity().y * _gravity_mod, -terminal_bubble_floating, INF)
	else:
		velocity.y = clampf(velocity.y + get_gravity().y * (_gravity_mod + _jump_gravity_mod), -INF, terminal_velocity)


func _try_jump():
	if _jump_count > 0:
		_jump_gravity_mod = -0.6
		velocity.y = -jump_speed
		_jump_count -= 1
		$JumpSFX.play()


func _try_bubble_jump():
	_bubbling = false
	bubble_sprite.visible = false
	set_gravity(1.0)
	_jump_gravity_mod = -0.6
	velocity.y = -jump_speed * 0.8
	_max_speed_mod = 1.0
	$PopSFX.play()
	$JumpSFX.play()
	

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
		bubble_timer.start(BUBBLE_TIME)
		$BubbleSFX.play()
		var particles = bubble_particles.instantiate()
		particles.emitting = true
		add_child(particles)
		
func _try_unbubble():
	if _bubbling:
		_bubbling = false
		bubble_sprite.visible = false
		set_gravity(1.0)
		set_speed_mod(1.0)
		_max_speed_mod = 1.0
		$PopSFX.play()


func _clear_animation_state():
	$AnimationTree.set("parameters/conditions/idle", false)
	$AnimationTree.set("parameters/conditions/running", false)
	$AnimationTree.set("parameters/conditions/falling", false)


func _on_coyote_timeout():
	if _jump_count > 0:
		_jump_count -= 1
	set_speed_mod(0.3)


func _on_bubble_timeout():
	_try_unbubble()


func _on_reload_level():
	unkill()


func _on_end_game():
	_noctrl = true
	visible = false
	$PopSFX.play()
	$RespawnSFX.play()
