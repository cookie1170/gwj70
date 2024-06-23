extends Camera2D


var random_str: float = 30.0
var shake_fade: float = 5.0
var rng = RandomNumberGenerator.new()
var shake_str: float = 0.0
var shaking: bool = false
var pr_offs: Vector2 = Vector2.ZERO
var off_to_change: Vector2 = Vector2.ZERO


func _process(delta):
	if shaking:
		shake_str = random_str
	
	if shake_str > 0:
		shake_str = lerpf(shake_str, 0, shake_fade * delta)
		
		pr_offs = off_to_change
		off_to_change = random_offs()
		offset += off_to_change
		offset -= pr_offs


func shake(time, random_strf, shake_fadef):
	random_str = random_strf
	shake_fade= shake_fadef
	shaking = true
	await get_tree().create_timer(time).timeout
	shaking = false


func random_offs() -> Vector2:
	return Vector2(rng.randf_range(-shake_str, shake_str), rng.randf_range(-shake_str, shake_str))
