extends PCWindow
@export var tasks_root:VBoxContainer
@export var task_scene:PackedScene

func _ready() -> void:
	GameManager.update_tasks.connect(update)

func update() -> void:
	for child in tasks_root.get_children():
		child.queue_free()
	
	for task in GameManager.tasks:
		var scene := task_scene.instantiate()
		scene.get_node("%task").text = task.get_task_string()
		scene.get_node("%progress").text = task.get_progress_string()
		tasks_root.add_child(scene)

func _on_opened() -> void:
	update()
