extends CharacterBody2D

const AUDIO_TEMPLATE: PackedScene = preload("res://scenes/management/audio_template.tscn") 

@onready var animation: AnimationPlayer = $Animation
@onready var texture: Sprite2D = get_node("Texture")
@onready var attack_area_collision: CollisionShape2D = $AttackArea/CollisionAttack
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimationPlayer")
@onready var dust: GPUParticles2D = get_node("Dust")


@export var move_speed: float = 256.0
@export var damage: int = 1
@export var health: int = 10


var can_attack: bool = true
var can_die: bool = false


func _ready():
	if transition_screen.player_health != 0:
		health = transition_screen.player_health
		return
	
	transition_screen.player_health = health

func _physics_process(_delta: float) -> void:
	if (
		!can_attack or 
		can_die
	):
		return
		
	move()
	animate()
	attack_handler()

func move() -> void:	
#	var direction: Vector2 = Input.get_vector("ui_left","ui_right", "ui_up", "ui_down")
	var direction: Vector2 = get_direction()
	velocity = direction * move_speed
	move_and_slide()
	
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left","move_right"),
		Input.get_axis("move_up","move_down")
	).normalized()
	
func animate() -> void:
	if velocity.x > 0:
		texture.flip_h = false
		attack_area_collision.position.x = 58
		
	if velocity.x < 0: 
		texture.flip_h = true
		attack_area_collision.position.x = -58
		
	if velocity != Vector2.ZERO:
		dust.emitting = true
		animation.play("run")
		return
	
	dust.emitting = false	
	animation.play("idle")
		
func attack_handler() -> void:
	if Input.is_action_pressed("attack") and can_attack:		
		can_attack = false
		dust.emitting = false
		animation.play("attack")
	


func _on_animation_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_attack = true	
		"death":
			transition_screen.player_health = 0
			transition_screen.player_score = 0
			transition_screen.fade_in()
		_:
			pass	
		


func _on_attack_area_body_entered(body):
	body.update_health(damage)
	

func update_health(value: int) -> void:
	health -= value
	
	transition_screen.player_health = health
	get_tree().call_group("level", "update_health", health)
	
	if health < 1:
		can_die = true
		animation.play("death")
		attack_area_collision.set_deferred("disabled", true)
		return
	
	aux_animation_player.play("hit")

func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate() as AudioStreamPlayer2D
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
