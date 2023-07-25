extends CharacterBody2D

const ATTACK_AREA: PackedScene = preload("res://scenes/enemies/enemy_attack_area.tscn")
const OFFSET: Vector2 = Vector2(0, 30)
const AUDIO_TEMPLATE: PackedScene = preload("res://scenes/management/audio_template.tscn") 

@onready var animation: AnimationPlayer = $AnimationGoblin
@onready var aux_animation_player = $AuxAnimationPlayer
@onready var texture: Sprite2D = $TextureGoblin
@onready var dust: GPUParticles2D = get_node("Dust")

@export var move_speed: float = 192.0
@export var distance_threshold: float = 60.0
@export var health: int = 3
@export var score: int = 100

var player_ref: CharacterBody2D = null
var can_die: bool = false


func _physics_process(_delta: float) -> void:
	if can_die:
		return
			
	if player_ref == null or player_ref.can_die:
		velocity = Vector2.ZERO
		animate()
		return
	
	var direction: Vector2 = global_position.direction_to(player_ref.global_position)
	var distance: float = global_position.distance_to(player_ref.global_position)
	
	if distance < distance_threshold:
		dust.emitting = false
		animation.play("attack")
		return

	velocity = direction * move_speed
	move_and_slide()
	
	animate()


func spawn_attack_area():
	var attack_area = ATTACK_AREA.instantiate() as Area2D
	attack_area.position = OFFSET
	add_child(attack_area)


func animate() -> void:
	if velocity.x > 0:
		texture.flip_h = false
	
	if velocity.x < 0:
		texture.flip_h = true
		
	if velocity != Vector2.ZERO:
		dust.emitting = true
		animation.play("run")
		return
	
	dust.emitting = false
	animation.play("idle")
	
func update_health(value: int) -> void:
	health -= value
	
	if health < 1:
		can_die = true
		animation.play("death")
		return
	
	aux_animation_player.play("hit")

func _on_detection_area_body_entered(body):
	player_ref = body

func _on_detection_area_body_exited(_body):
	player_ref = null


func _on_animation_goblin_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		transition_screen.player_score += score
		get_tree().call_group("level", "increase_kill_count")
		get_tree().call_group("level", "update_score", transition_screen.player_score)
		queue_free()

func spawn_sfx(sfx_path: String) -> void:
	var sfx = AUDIO_TEMPLATE.instantiate() as AudioStreamPlayer2D
	sfx.sfx_to_play = sfx_path
	add_child(sfx)
