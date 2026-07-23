extends PCWindow
@export var tasks_root:VBoxContainer
@export var task_scene:PackedScene
@export var task_max_offset:float = 1000
@export var task_transition_time:float = 1
@export var task_progress_text:String = "[scroll time=0.2]%s[/scroll]/%s"
func _ready() -> void:
	create_tasks()
	GameManager.tasks_updated.connect(update)
	GameManager.task_finished.connect(remove_task)

func create_tasks() -> void:
	for child in tasks_root.get_children():
		if child is Control:
			child.queue_free()
	
	for task in GameManager.tasks:
		task_tweens.append(null)
		var scene := task_scene.instantiate()
		scene.get_node("%task").text = task.get_task_string()
		scene.get_node("%progress").text = task.get_progress_string()
		tasks_root.add_child(scene)

func remove_task(index:int) -> void:
	var tween:Tween = task_tweens[index]
	var tbar:Control = tasks_root.get_children()[index]
	if (tween and tween.is_running()):
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(tbar,"offset_transform_position:x",-task_max_offset,task_transition_time)
	tween.tween_callback(tbar.set.bind("offset_transform_position",Vector2(task_max_offset,0)))
	tween.tween_property(tbar,"offset_transform_position:x",0,task_transition_time)
	task_tweens[index] = tween

func _on_opened() -> void:
	update()

var task_tweens:Array[Tween]

func update() -> void:
	for i in len(tasks_root.get_children()):
		var task:Task = GameManager.tasks[i]
		var tbar:Control = tasks_root.get_children()[i]
		tbar.get_node("%task").set("text",task.get_task_string())
		tbar.get_node("%progress").set("text",task.get_progress_string())
