extends CanvasLayer

func change_scene(scene):
	$rect_animation.play("fade")
	await $rect_animation.animation_finished
	get_tree().change_scene_to_file(scene)
	$rect_animation.play_backwards("fade")


func fail(player, position: Vector2):
	$rect_animation.play("fade")
	await $rect_animation.animation_finished
	player.position = position
	$rect_animation.play_backwards("fade")
