extends Node
var day:int = 0
var time:int = 0
var default_max_time:int = 200
var max_time:int = 200
var work_start_time:int = 32400
var work_end_time:int = 75600
var you:Worker = Worker.new("You",0,0,0,0,0,[0,0,0,0,0,0,0])
var initial_worker_count:int = 99
var productivity_place_quota:int = 120
var workers:Array[Worker]
var worker_potential_names:PackedStringArray
var cheated:bool = false
var productivity_has_been_changed:bool = false
signal work_ended

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

func reset() -> void:
	day = 0
	time = 0
	productivity_place_quota = 120
	cheated = false
	productivity_has_been_changed = false
	workers.clear()
	tasks.clear()

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
		@warning_ignore("integer_division")
		var l:float = max(0.2,log(i/2))
		workers.append(Worker.new(
			worker_potential_names[randi_range(0,len(worker_potential_names)-1)],
			l+get_random_variance(),
			-(1.0/2.0)*l+get_random_variance(),
			+(1.0/2.0)*l+get_random_variance(),
			-(1.0/4.0)*l+get_random_variance(),
			+(1.0/4.0)*l+get_random_variance()
		))

func get_random_variance() -> float:
	return randf_range(-0.1,0.3)

func tick() -> void:
	if not has_work_ended():
		time += 1
		for worker in workers:
				worker.productivity += worker.calculate_work()
	else:
		work_ended.emit()


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

func int_to_time(t:int) -> String:
	var minutes:int = int(t/60) % 60
	var hours:int = int(t/3600)
	return "%d:%02d" % [hours,minutes]

func get_string_time() -> String:
	return int_to_time(get_time_ratio() * time + work_start_time)

var tasks:Array[Task]:
	set(t):
		tasks = t
		tasks_updated.emit()
var max_tasks:int = 3
@warning_ignore("int_as_enum_without_cast")
var unlocked_tasks:Array[Task.ValidTasks] = [0,1]
var task_unlock_line:Array[Task.ValidTasks] = [0,1,2]
var posted_blogs:Array[String]
var tasks_finished:int = 0
signal tasks_updated()
signal task_finished(index:int)

func on_task_finished(index:int):
	add_productivity(tasks[index].get_rewarded_productivity())
	tasks.remove_at(index)
	tasks.append(get_random_task())
	tasks_finished += 1

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

func has_passed() -> bool:
	return (get_place(you) <= productivity_place_quota) or (len(workers) <= productivity_place_quota)

func sort_workers() -> void:
	workers.sort_custom(func (a:Worker,b:Worker) -> bool: return a.productivity > b.productivity)

func get_place(worker:Worker) -> int:
	sort_workers()
	return workers.find(worker)+1

func remove_fired_workers() -> void:
	for i in len(workers)-productivity_place_quota:
		workers.pop_back()

func new_day() -> void:
	time = 0
	remove_fired_workers()
	for worker in workers:
		worker.productivity = 0
	productivity_place_quota = max(1,productivity_place_quota-20)
	tasks_finished = 0
	day += 1
	unlocked_tasks = task_unlock_line.slice(0,min(day,len(task_unlock_line)))

func int_to_place(i:int) -> String:
	if i >= 10 and str(i)[-2] == "1":
		return "%sth" % i
	match i % 10:
		1:
			return "%sst" % i
		2:
			return "%snd" % i
		3:
			return "%srd" % i
		_:
			return "%sth" % i

func has_work_ended() -> bool:
	return time >= max_time
