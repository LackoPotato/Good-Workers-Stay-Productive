extends PathFollow2D
@export var wobble_radians:float = 0.261799387799
@export var wobble_time:float = 0.2
@export var speed:float = 5
@export var bug:TextureButton
@export var crush_noises:Array[AudioStream]
@export var audio:AudioStreamPlayer
@export var squished:Texture
var tween:Tween
var dead:bool = false
func wobble() -> void:
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	bug.offset_transform_rotation = 0
	tween.tween_property(bug,"offset_transform_rotation",wobble_radians,wobble_time)
	tween.tween_property(bug,"offset_transform_rotation",0,wobble_time)
	tween.tween_property(bug,"offset_transform_rotation",-wobble_radians,wobble_time)
	tween.tween_property(bug,"offset_transform_rotation",0,wobble_time)
	tween.tween_callback(wobble)

func _ready() -> void:
	wobble()

func _physics_process(delta: float) -> void:
	progress += speed*(delta/0.2)
	if progress_ratio == 1:
		queue_free()


func _on_bug_pressed() -> void:
	if not dead:
		audio.stream = crush_noises[randi_range(0,len(crush_noises)-1)]
		dead = true
		GameManager.update_tasks(Task.ValidTasks.BUG,1)
		bug.texture_hover = squished
		bug.texture_focused = squished
		bug.texture_normal = squished
		bug.texture_pressed = squished
		if tween and tween.is_running():
			tween.kill()
		set_physics_process(false)
		audio.play()
		await audio.finished
		tween = get_tree().create_tween()
		tween.tween_property(self,"modulate:a",0,3)
		tween.tween_callback(queue_free)
