extends CanvasLayer

@onready var animation: AnimationPlayer = $Animation

var scene_path: String = ""
var can_quit: bool = false

func fade_in(opt: bool = false) -> void:
	if opt:
		animation.play("special_fade_in")
		return

	animation.play("fade_in")


func _on_animation_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_in":
		if can_quit:
			get_tree().quit()
			return
			
		get_tree().change_scene_to_file(scene_path)
		animation.play("fade_out")
	
	if anim_name == "special_fade_in":
		get_tree().change_scene_to_file(scene_path)
		animation.play("fade_out")