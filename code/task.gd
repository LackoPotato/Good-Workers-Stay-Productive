@abstract
extends RefCounted
class_name Task
enum ValidTasks{
	TEXT,
	MSG,
	BUG
}
static func make_task(chosen:ValidTasks) -> Task:
	match chosen:
		ValidTasks.TEXT:
			return TextEditor.new()
		ValidTasks.MSG:
			return Messenger.new()
		ValidTasks.BUG:
			return Bug.new()
		_:
			push_error("Task %s is not a valid task" % chosen)
	return null

@abstract func get_task_string() -> String
	#return "Send %s messages" % messages_to_send
@abstract func get_progress_string() -> String
	#return "%s/%s" % [sent,messages_to_send]
@abstract func add_progress(progress:int) -> bool #Returns if the task is finished
@abstract func get_rewarded_productivity() -> int
@abstract func get_type() -> ValidTasks

class TextEditor:
	extends Task
	static var base_count:int = 20
	static var scale:int = 5
	func get_type() -> ValidTasks:
		return ValidTasks.TEXT
	var base_value:int = 1
	var words_to_write:int
	var words_written:int
	func add_progress(progress:int) -> bool:
		words_written += progress
		return words_written >= words_to_write
	func get_rewarded_productivity() -> int:
		return int(base_value*words_to_write*(GameManager.productivity_scale))
	func _init() -> void:
		words_to_write = base_count+scale*GameManager.day
	func get_task_string() -> String:
		return "Write %s words in the Document" % words_to_write
	func get_progress_string() -> String:
		return "%s/%s" % [words_written,words_to_write]

class Bug:
	extends Task
	static var base_count:int = 15
	static var scale:int = 5
	func get_type() -> ValidTasks:
		return ValidTasks.BUG
	var base_value:int = 3
	var to_do:int
	var done:int
	func add_progress(progress:int) -> bool:
		done += progress
		return done >= to_do
	func get_rewarded_productivity() -> int:
		return int(base_value*to_do*GameManager.productivity_scale)
	func _init() -> void:
		to_do = base_count+scale*GameManager.day
	func get_task_string() -> String:
		return "Fix %s bugs" % to_do
	func get_progress_string() -> String:
		return "%s left" % (to_do-done)

class Messenger:
	extends Task
	static var base_count:int = 10
	static var scale:int = 5
	func get_type() -> ValidTasks:
		return ValidTasks.MSG
	var base_value:int = 2
	var messages_to_send:int
	var sent:int
	func add_progress(progress:int) -> bool:
		sent += progress
		return sent >= messages_to_send
	func get_rewarded_productivity() -> int:
		return int(base_value*messages_to_send*GameManager.productivity_scale)
	func _init() -> void:
		messages_to_send = base_count+scale*GameManager.day
	func get_task_string() -> String:
		return "Send %s messages" % messages_to_send
	func get_progress_string() -> String:
		return "%s/%s" % [sent,messages_to_send]
