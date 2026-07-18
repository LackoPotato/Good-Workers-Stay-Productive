extends Window
class_name PCWindow
@export var id:int = 0
signal active()
signal inactive()
signal closed(id:int)
signal opened(id:int)
signal updated_text(text:String)
var is_open:bool = false

var tween:Tween
var size_before_animation:Vector2i
func _init() -> void:
	add_theme_constant_override("resize_margin",8)
	close_requested.connect(close)
	connect("focus_entered",active.emit)
	connect("focus_exited",inactive.emit)
	size_before_animation = size


func close() -> void:
	if is_open:
		is_open = false
		if tween and tween.is_running():
			tween.kill()
			size = size_before_animation
		size_before_animation = size
		closed.emit(id)
		inactive.emit()
		tween = get_tree().create_tween()
		tween.tween_callback(show)
		tween.tween_property(self,"size:y",0,0.1)
		tween.tween_callback(hide)

func open() -> void:
	if not is_open:
		is_open = true
		if tween and tween.is_running():
			tween.kill()
			size.y = 0
		opened.emit()
		tween = get_tree().create_tween()
		tween.tween_callback(show)
		tween.tween_property(self,"size:y",size_before_animation.y,0.1)
	grab_focus()

func update_text(new_text:String) -> void:
	title = new_text
	updated_text.emit(title)
