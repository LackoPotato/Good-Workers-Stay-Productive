@abstract
extends RefCounted
class_name Task
enum ValidTasks{
	TEXT,
	MSG
}
static func make_task(chosen:ValidTasks) -> Task:
	match chosen:
		ValidTasks.TEXT:
			return TextEditor.new(TextEditor.base_count*GameManager.day)
		ValidTasks.MSG:
			return Messenger.new(Messenger.base_count*GameManager.day)
		_:
			push_error("Task %s is not a valid task" % chosen)
	return null

@abstract func get_task_string() -> String
	#return "Send %s messages" % messages_to_send
@abstract func get_progress_string() -> String
	#return "%s/%s" % [sent,messages_to_send]


class TextEditor:
	extends Task
	static var base_count:int = 30
	var base_value:int = 1
	var words_to_write:int
	var words_written:int
	func get_rewarded_productivity() -> int:
		return base_value*words_to_write*GameManager.productivity_scale
	func _init(to_write:int) -> void:
		words_to_write = to_write
	func get_task_string() -> String:
		return "Write %s words in the Document" % words_to_write
	func get_progress_string() -> String:
		return "%s/%s" % [words_written,words_to_write]

class Messenger:
	extends Task
	static var base_count:int = 10
	var base_value:int = 2
	var messages_to_send:int
	var sent:int
	func get_rewarded_productivity() -> int:
		return base_value*messages_to_send*GameManager.productivity_scale
	func _init(to_send:int) -> void:
		messages_to_send = to_send
	func get_task_string() -> String:
		return "Send %s messages" % messages_to_send
	func get_progress_string() -> String:
		return "%s/%s" % [sent,messages_to_send]
