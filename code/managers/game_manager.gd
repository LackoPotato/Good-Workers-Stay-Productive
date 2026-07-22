extends Node
var day:int = 1
var time:int = 0
var default_max_time:int = 200
var max_time:int = 200
var work_start_time:int = 32400
var work_end_time:int = 75600
var you:Worker = Worker.new("You",0,0,0,0,0,[0,0,0,0,0,0,0])
var initial_worker_count:int = 100
var productivity_place_quota:int = 80
var written_words:int = 0
var workers:Array[Worker]
var worker_potential_names:PackedStringArray

var productivity_scale:float = 1
var background:Texture = preload("res://resources/textures/backgrounds/orangesky.JPG"):
	set(t):
		background = t
		update_background.emit(t)
signal update_background(background:Texture)

const NAME_PATH:String = "res://resources/workernames.txt"

func add_productivity(amount:float) -> void:
	you.productivity += amount

func _ready() -> void:
	read_names()
	task_finished.connect(on_task_finished)

func start() -> void:
	initialise_workers()
	generate_tasks()

func read_names() -> void:
	var file := FileAccess.open(NAME_PATH,FileAccess.READ)
	worker_potential_names = file.get_as_text().split("\n")
	worker_potential_names.erase("")

func initialise_workers() -> void:
	workers.clear()
	you = Worker.new("You",0,0,0,0,0,[0,0,0,0,0,0,0])
	workers.append(you)
	for i in initial_worker_count:
		workers.append(Worker.new(
			worker_potential_names[randi_range(0,len(worker_potential_names)-1)],
			0,
			-0.2,
			0.3,
			-0.2,
			0.2
		))


func tick() -> void:
	time += 1
	for worker in workers:
			worker.productivity += worker.calculate_work()


class Worker:
	var name:String
	var productivity:float
	var weekly_productivity:Array[float] = [0.4,0.5,0.5,0.65,0.8]
	var daily_variance_min:float
	var daily_variance_max:float
	var hourly_variance_min:float
	var hourly_variance_max:float
	@warning_ignore("shadowed_variable")
	func _init(name:String,productivity:float,daily_variance_min:float,daily_variance_max:float,hourly_variance_min:float,hourly_variance_max:float,weekly_productivity:Array[float] = [0.4,0.5,0.5,0.65,0.8]) -> void:
		self.name = name
		self.productivity = productivity
		self.weekly_productivity = weekly_productivity
		self.daily_variance_min = daily_variance_min
		self.daily_variance_max = daily_variance_max
		self.hourly_variance_min = hourly_variance_min
		self.hourly_variance_max = hourly_variance_max
	
	func calculate_work() -> float:
		var base_work:float = weekly_productivity[GameManager.day % 5]
		var rng := RandomNumberGenerator.new()
		rng.seed = GameManager.day % 5
		var daily_variance:float = rng.randf_range(daily_variance_min,daily_variance_max)
		rng.seed = GameManager.time
		var hourly_variance:float = rng.randf_range(hourly_variance_min,hourly_variance_max)
		return base_work+daily_variance+hourly_variance

func get_time_ratio() -> float:
	return float(work_end_time-work_start_time)/max_time

func get_string_time() -> String:
	var irlseconds:float = get_time_ratio() * time + work_start_time
	var minutes:int = int(irlseconds/60) % 60
	var hours:int = int(irlseconds/3600)
	return "%d:%02d" % [hours,minutes]

var tasks:Array[Task]:
	set(t):
		tasks = t
		tasks_updated.emit()
var max_tasks:int = 3
@warning_ignore("int_as_enum_without_cast")
var unlocked_tasks:Array[Task.ValidTasks] = [0,1]
signal tasks_updated()
signal task_finished(index:int)

func on_task_finished(index:int):
	add_productivity(tasks[index].get_rewarded_productivity())
	tasks.remove_at(index)
	tasks.append(get_random_task())

func generate_tasks() -> void:
	tasks.clear()
	for i in max_tasks:
		tasks.append(get_random_task())

func get_random_task() -> Task:
	return Task.make_task(unlocked_tasks[randi_range(0,len(unlocked_tasks)-1)])

func update_tasks(type:Task.ValidTasks,progress:int) -> void:
	for i in len(tasks):
		var task:Task = tasks[i]
		if task.get_type() == type:
			if task.add_progress(progress):
				task_finished.emit(i)
			tasks_updated.emit()
			break
