extends CharacterBody2D

@onready var animation: AnimationPlayer = $Animation
@onready var texture: Sprite2D = get_node("Texture")
@onready var attack_area_collision: CollisionShape2D = $AttackArea/CollisionAttack
@onready var aux_animation_player: AnimationPlayer = get_node("AuxAnimationPlayer")

@export var move_speed: float = 256.0
@export var damage: int = 1
@export var health: int = 10

var can_attack: bool = true
var can_die: bool = false


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
		animation.play("run")
		return
		
	animation.play("idle")
		
func attack_handler() -> void:
	if Input.is_action_pressed("attack") and can_attack:		
		can_attack = false
		animation.play("attack")
	


func _on_animation_animation_finished(anim_name: String) -> void:
	match anim_name:
		"attack":
			can_attack = true	
		"death":
			transition_screen.fade_in()
		_:
			pass	
		


func _on_attack_area_body_entered(body):
	body.update_health(damage)
	

func update_health(value: int) -> void:
	health -= value
	
	if health < 1:
		can_die = true
		animation.play("death")
		attack_area_collision.set_deferred("disabled", true)
		return
	
	aux_animation_player.play("hit")
