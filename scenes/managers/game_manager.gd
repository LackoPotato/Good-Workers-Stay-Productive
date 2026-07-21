extends Node
var day:int = 0
var time:int = 0:
	set(t):
		time = t
		update_time()
var you:Worker = Worker.new("You",0,0,0,0,0,[0,0,0,0,0,0,0])
var initial_worker_count:int = 100
var productivity_place_quota:int = 80
var written_words:int = 0
var workers:Array[Worker]
var worker_potential_names:PackedStringArray
signal update_background(background:Texture)

const NAME_PATH:String = "res://resources/workernames.txt"

func add_productivity(amount:float) -> void:
	you.productivity += amount

func _ready() -> void:
	read_names()
	initialise_workers()
	update_time()

func read_names() -> void:
	var file := FileAccess.open(NAME_PATH,FileAccess.READ)
	worker_potential_names = file.get_as_text().split("\n")
	worker_potential_names.erase("")

func initialise_workers() -> void:
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

func update_time() -> void:
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
